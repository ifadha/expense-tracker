import React, { createContext, useContext, useState, useEffect, useMemo, useCallback } from 'react';
import {
  collection,
  doc,
  setDoc,
  deleteDoc,
  onSnapshot,
  getDocs,
} from 'firebase/firestore';
import { db, testFirestoreConnection, handleFirestoreError, OperationType } from '../firebase';
import { Transaction, Category, Wallet, ActiveTab } from '../types';
import { INITIAL_CATEGORIES, INITIAL_TRANSACTIONS, INITIAL_WALLETS } from '../data/initialData';

interface CategoryBreakdownItem {
  category: Category;
  total: number;
  percentage: number;
  count: number;
}

interface ExpenseContextType {
  transactions: Transaction[];
  categories: Category[];
  wallets: Wallet[];
  activeWallet: Wallet;
  currency: string;
  monthlyBudget: number;

  // Selected Month State
  selectedMonth: string; // YYYY-MM
  setSelectedMonth: (month: string) => void;
  selectedMonthName: string;
  prevMonth: () => void;
  nextMonth: () => void;

  // Monthly Metrics for Selected Month
  selectedMonthSpend: number;
  selectedMonthIncome: number;
  selectedMonthBalance: number;
  selectedMonthTransactionCount: number;

  // Comparisons
  percentageChangeVsLastMonth: number;
  isSpendLowerThanLastMonth: boolean;
  categorySpendBreakdown: CategoryBreakdownItem[];

  // Firestore & Status States
  isLoading: boolean;
  isSyncing: boolean;
  firestoreError: string | null;
  clearError: () => void;
  retrySync: () => void;

  // Navigation & Modals
  activeTab: ActiveTab;
  setActiveTab: (tab: ActiveTab) => void;
  isAddExpenseOpen: boolean;
  setIsAddExpenseOpen: (open: boolean) => void;
  isSelectCategoryOpen: boolean;
  setIsSelectCategoryOpen: (open: boolean) => void;
  isCategoryPickerForNewExpense: boolean;
  setIsCategoryPickerForNewExpense: (val: boolean) => void;
  pendingCategorySelection: string | null;
  setPendingCategorySelection: (catId: string | null) => void;
  editingTransaction: Transaction | null;
  setEditingTransaction: (tx: Transaction | null) => void;
  isWalletModalOpen: boolean;
  setIsWalletModalOpen: (open: boolean) => void;
  isNotificationOpen: boolean;
  setIsNotificationOpen: (open: boolean) => void;

  // Core Actions
  addTransaction: (tx: Omit<Transaction, 'id'>) => Promise<Transaction>;
  updateTransaction: (id: string, updated: Partial<Transaction>) => Promise<void>;
  deleteTransaction: (id: string) => Promise<void>;
  addCategory: (cat: Omit<Category, 'id'>) => Category;
  setActiveWalletId: (id: string) => void;
  setCurrency: (curr: string) => void;
  setMonthlyBudget: (budget: number) => void;
  resetToDemoData: () => Promise<void>;
  getCategoryById: (id: string) => Category;
  formatCurrency: (amount: number) => string;
}

const ExpenseContext = createContext<ExpenseContextType | undefined>(undefined);

const LOCAL_STORAGE_TX_KEY = 'lumina_transactions_v2';
const LOCAL_STORAGE_CAT_KEY = 'lumina_categories_v2';
const LOCAL_STORAGE_WALLET_KEY = 'lumina_wallets_v2';
const LOCAL_STORAGE_ACTIVE_WALLET_KEY = 'lumina_active_wallet_id_v2';
const LOCAL_STORAGE_CURRENCY_KEY = 'lumina_currency_v2';
const LOCAL_STORAGE_BUDGET_KEY = 'lumina_budget_v2';

export const ExpenseProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  // Local state initialized with fallback
  const [transactions, setTransactions] = useState<Transaction[]>(() => {
    try {
      const saved = localStorage.getItem(LOCAL_STORAGE_TX_KEY);
      return saved ? JSON.parse(saved) : INITIAL_TRANSACTIONS;
    } catch {
      return INITIAL_TRANSACTIONS;
    }
  });

  const [categories, setCategories] = useState<Category[]>(() => {
    try {
      const saved = localStorage.getItem(LOCAL_STORAGE_CAT_KEY);
      return saved ? JSON.parse(saved) : INITIAL_CATEGORIES;
    } catch {
      return INITIAL_CATEGORIES;
    }
  });

  const [wallets, setWallets] = useState<Wallet[]>(() => {
    try {
      const saved = localStorage.getItem(LOCAL_STORAGE_WALLET_KEY);
      return saved ? JSON.parse(saved) : INITIAL_WALLETS;
    } catch {
      return INITIAL_WALLETS;
    }
  });

  const [activeWalletId, setActiveWalletIdState] = useState<string>(() => {
    try {
      return localStorage.getItem(LOCAL_STORAGE_ACTIVE_WALLET_KEY) || 'wallet-1';
    } catch {
      return 'wallet-1';
    }
  });

  const [currency, setCurrencyState] = useState<string>(() => {
    try {
      return localStorage.getItem(LOCAL_STORAGE_CURRENCY_KEY) || '$';
    } catch {
      return '$';
    }
  });

  const [monthlyBudget, setMonthlyBudgetState] = useState<number>(() => {
    try {
      const saved = localStorage.getItem(LOCAL_STORAGE_BUDGET_KEY);
      return saved ? Number(saved) : 3200;
    } catch {
      return 3200;
    }
  });

  // Loading and Error states for Firestore
  const [isLoading, setIsLoading] = useState<boolean>(true);
  const [isSyncing, setIsSyncing] = useState<boolean>(false);
  const [firestoreError, setFirestoreError] = useState<string | null>(null);

  // Selected Month State (Default to current month or September 2026 for demo consistency)
  const now = new Date();
  const currentMonthStr = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`;
  const [selectedMonth, setSelectedMonth] = useState<string>(currentMonthStr);

  // UI state
  const [activeTab, setActiveTab] = useState<ActiveTab>('home');
  const [isAddExpenseOpen, setIsAddExpenseOpen] = useState(false);
  const [isSelectCategoryOpen, setIsSelectCategoryOpen] = useState(false);
  const [isCategoryPickerForNewExpense, setIsCategoryPickerForNewExpense] = useState(false);
  const [pendingCategorySelection, setPendingCategorySelection] = useState<string | null>(null);
  const [editingTransaction, setEditingTransaction] = useState<Transaction | null>(null);
  const [isWalletModalOpen, setIsWalletModalOpen] = useState(false);
  const [isNotificationOpen, setIsNotificationOpen] = useState(false);

  // Sync to localStorage
  useEffect(() => {
    try {
      localStorage.setItem(LOCAL_STORAGE_TX_KEY, JSON.stringify(transactions));
    } catch (e) {
      console.warn('Storage sync failed', e);
    }
  }, [transactions]);

  useEffect(() => {
    try {
      localStorage.setItem(LOCAL_STORAGE_CAT_KEY, JSON.stringify(categories));
    } catch (e) {
      console.warn('Storage sync failed', e);
    }
  }, [categories]);

  useEffect(() => {
    try {
      localStorage.setItem(LOCAL_STORAGE_WALLET_KEY, JSON.stringify(wallets));
    } catch (e) {
      console.warn('Storage sync failed', e);
    }
  }, [wallets]);

  useEffect(() => {
    try {
      localStorage.setItem(LOCAL_STORAGE_ACTIVE_WALLET_KEY, activeWalletId);
    } catch (e) {
      console.warn('Storage sync failed', e);
    }
  }, [activeWalletId]);

  useEffect(() => {
    try {
      localStorage.setItem(LOCAL_STORAGE_CURRENCY_KEY, currency);
    } catch (e) {
      console.warn('Storage sync failed', e);
    }
  }, [currency]);

  useEffect(() => {
    try {
      localStorage.setItem(LOCAL_STORAGE_BUDGET_KEY, monthlyBudget.toString());
    } catch (e) {
      console.warn('Storage sync failed', e);
    }
  }, [monthlyBudget]);

  // Firestore real-time synchronization
  const setupFirestoreSubscription = useCallback(() => {
    setIsLoading(true);
    setFirestoreError(null);

    // Test connection first
    testFirestoreConnection();

    const expensesCol = collection(db, 'expenses');

    const unsubscribe = onSnapshot(
      expensesCol,
      (snapshot) => {
        setIsLoading(false);
        setIsSyncing(false);

        if (snapshot.empty) {
          // If Firestore collection is empty, seed with initial transactions so user has an active starting state
          seedInitialDataToFirestore();
        } else {
          const loaded: Transaction[] = [];
          snapshot.forEach((docSnap) => {
            const data = docSnap.data();
            loaded.push({
              id: docSnap.id,
              title: data.title || 'Untitled',
              amount: Number(data.amount) || 0,
              type: data.type === 'income' ? 'income' : 'expense',
              categoryId: data.categoryId || 'other',
              date: data.date || new Date().toISOString().split('T')[0],
              wallet: data.wallet || 'Spending Wallet',
              note: data.note || undefined,
              recurring: Boolean(data.recurring),
            });
          });

          // Sort descending by date
          loaded.sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime());
          setTransactions(loaded);
        }
      },
      (error) => {
        setIsLoading(false);
        setIsSyncing(false);
        const errInfo = handleFirestoreError(error, OperationType.LIST, 'expenses');
        setFirestoreError(errInfo.error || 'Failed to connect to Firebase Firestore');
      }
    );

    return unsubscribe;
  }, []);

  const seedInitialDataToFirestore = async () => {
    try {
      setIsSyncing(true);
      for (const tx of INITIAL_TRANSACTIONS) {
        await setDoc(doc(db, 'expenses', tx.id), {
          title: tx.title,
          amount: tx.amount,
          type: tx.type,
          categoryId: tx.categoryId,
          date: tx.date,
          wallet: tx.wallet,
          note: tx.note || '',
          recurring: !!tx.recurring,
          createdAt: new Date().toISOString(),
          updatedAt: new Date().toISOString(),
        });
      }
      setIsSyncing(false);
    } catch (err) {
      console.warn('Initial seeding note:', err);
      setIsSyncing(false);
    }
  };

  useEffect(() => {
    const unsub = setupFirestoreSubscription();
    return () => {
      if (unsub) unsub();
    };
  }, [setupFirestoreSubscription]);

  const activeWallet = useMemo(() => {
    return wallets.find((w) => w.id === activeWalletId) || wallets[0];
  }, [wallets, activeWalletId]);

  // Selected Month formatted name
  const selectedMonthName = useMemo(() => {
    try {
      const [yearStr, monthStr] = selectedMonth.split('-');
      const d = new Date(parseInt(yearStr), parseInt(monthStr) - 1, 1);
      return new Intl.DateTimeFormat('en-US', { month: 'long', year: 'numeric' }).format(d);
    } catch {
      return selectedMonth;
    }
  }, [selectedMonth]);

  const prevMonth = () => {
    const [y, m] = selectedMonth.split('-').map(Number);
    const prevDate = new Date(y, m - 2, 1);
    setSelectedMonth(`${prevDate.getFullYear()}-${String(prevDate.getMonth() + 1).padStart(2, '0')}`);
  };

  const nextMonth = () => {
    const [y, m] = selectedMonth.split('-').map(Number);
    const nextDate = new Date(y, m, 1);
    setSelectedMonth(`${nextDate.getFullYear()}-${String(nextDate.getMonth() + 1).padStart(2, '0')}`);
  };

  // Calculate Metrics for selected month
  const {
    selectedMonthSpend,
    selectedMonthIncome,
    selectedMonthBalance,
    selectedMonthTransactionCount,
    percentageChangeVsLastMonth,
    isSpendLowerThanLastMonth,
  } = useMemo(() => {
    const [curYear, curMonthNum] = selectedMonth.split('-').map(Number);
    const lastMonthDate = new Date(curYear, curMonthNum - 2, 1);
    const lastMonthPrefix = `${lastMonthDate.getFullYear()}-${String(lastMonthDate.getMonth() + 1).padStart(2, '0')}`;

    let thisSpend = 0;
    let thisIncome = 0;
    let lastSpend = 0;
    let count = 0;

    transactions.forEach((tx) => {
      const isSelected = tx.date.startsWith(selectedMonth);
      const isLast = tx.date.startsWith(lastMonthPrefix);

      if (isSelected) {
        count++;
        if (tx.type === 'expense') {
          thisSpend += tx.amount;
        } else {
          thisIncome += tx.amount;
        }
      } else if (isLast) {
        if (tx.type === 'expense') {
          lastSpend += tx.amount;
        }
      }
    });

    const baselineLast = lastSpend > 0 ? lastSpend : 1250;
    const diff = baselineLast - thisSpend;
    const pct = Math.abs(Math.round((diff / baselineLast) * 100));
    const isLower = thisSpend <= baselineLast;

    return {
      selectedMonthSpend: thisSpend,
      selectedMonthIncome: thisIncome,
      selectedMonthBalance: thisIncome - thisSpend,
      selectedMonthTransactionCount: count,
      percentageChangeVsLastMonth: pct > 0 ? pct : 35,
      isSpendLowerThanLastMonth: isLower,
    };
  }, [transactions, selectedMonth]);

  // Category Spend Breakdown for selected month (or all if selected has none)
  const categorySpendBreakdown = useMemo(() => {
    const map = new Map<string, { total: number; count: number }>();
    let totalExpense = 0;

    // Filter to selected month
    const targetTxs = transactions.filter((t) => t.date.startsWith(selectedMonth));
    const txsToUse = targetTxs.length > 0 ? targetTxs : transactions;

    txsToUse.forEach((tx) => {
      if (tx.type === 'expense') {
        totalExpense += tx.amount;
        const existing = map.get(tx.categoryId) || { total: 0, count: 0 };
        map.set(tx.categoryId, {
          total: existing.total + tx.amount,
          count: existing.count + 1,
        });
      }
    });

    const items: CategoryBreakdownItem[] = [];
    map.forEach((val, catId) => {
      const category = categories.find((c) => c.id === catId) || {
        id: catId,
        name: 'Other',
        iconName: 'Grid',
        color: '#6366f1',
        bgLight: '#eef2ff',
      };
      items.push({
        category,
        total: val.total,
        percentage: totalExpense > 0 ? Math.round((val.total / totalExpense) * 100) : 0,
        count: val.count,
      });
    });

    return items.sort((a, b) => b.total - a.total);
  }, [transactions, categories, selectedMonth]);

  const getCategoryById = (id: string): Category => {
    return (
      categories.find((c) => c.id === id) || {
        id,
        name: 'Other',
        iconName: 'Grid',
        color: '#6366f1',
        bgLight: '#eef2ff',
      }
    );
  };

  const formatCurrency = (amount: number): string => {
    return `${currency}${amount.toLocaleString('en-US', {
      minimumFractionDigits: 2,
      maximumFractionDigits: 2,
    })}`;
  };

  // Add Expense to Firestore and local state
  const addTransaction = async (txData: Omit<Transaction, 'id'>): Promise<Transaction> => {
    const newId = `tx-${Date.now()}-${Math.random().toString(36).substring(2, 6)}`;
    const newTx: Transaction = {
      ...txData,
      id: newId,
    };

    // Optimistically update local state
    setTransactions((prev) => [newTx, ...prev]);

    // Update wallet balance locally
    setWallets((prev) =>
      prev.map((w) => {
        if (w.name === txData.wallet) {
          const delta = txData.type === 'expense' ? -txData.amount : txData.amount;
          return { ...w, balance: Math.max(0, w.balance + delta) };
        }
        return w;
      })
    );

    // Save to Firestore
    try {
      setIsSyncing(true);
      await setDoc(doc(db, 'expenses', newId), {
        title: txData.title,
        amount: txData.amount,
        type: txData.type,
        categoryId: txData.categoryId,
        date: txData.date,
        wallet: txData.wallet,
        note: txData.note || '',
        recurring: !!txData.recurring,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      });
      setIsSyncing(false);
    } catch (error) {
      setIsSyncing(false);
      const err = handleFirestoreError(error, OperationType.CREATE, `expenses/${newId}`);
      setFirestoreError(err.error);
    }

    return newTx;
  };

  // Update Expense in Firestore and local state
  const updateTransaction = async (id: string, updated: Partial<Transaction>): Promise<void> => {
    setTransactions((prev) =>
      prev.map((tx) => {
        if (tx.id === id) {
          return { ...tx, ...updated };
        }
        return tx;
      })
    );

    try {
      setIsSyncing(true);
      const docRef = doc(db, 'expenses', id);
      await setDoc(
        docRef,
        {
          ...updated,
          updatedAt: new Date().toISOString(),
        },
        { merge: true }
      );
      setIsSyncing(false);
    } catch (error) {
      setIsSyncing(false);
      const err = handleFirestoreError(error, OperationType.UPDATE, `expenses/${id}`);
      setFirestoreError(err.error);
    }
  };

  // Delete Expense from Firestore and local state
  const deleteTransaction = async (id: string): Promise<void> => {
    setTransactions((prev) => prev.filter((tx) => tx.id !== id));

    try {
      setIsSyncing(true);
      await deleteDoc(doc(db, 'expenses', id));
      setIsSyncing(false);
    } catch (error) {
      setIsSyncing(false);
      const err = handleFirestoreError(error, OperationType.DELETE, `expenses/${id}`);
      setFirestoreError(err.error);
    }
  };

  const addCategory = (catData: Omit<Category, 'id'>): Category => {
    const newCat: Category = {
      ...catData,
      id: `cat-${Date.now()}`,
      isCustom: true,
    };
    setCategories((prev) => [...prev, newCat]);
    return newCat;
  };

  const setActiveWalletId = (id: string) => {
    setActiveWalletIdState(id);
  };

  const setCurrency = (curr: string) => {
    setCurrencyState(curr);
  };

  const setMonthlyBudget = (budget: number) => {
    setMonthlyBudgetState(budget);
  };

  const resetToDemoData = async () => {
    setIsSyncing(true);
    setTransactions(INITIAL_TRANSACTIONS);
    setCategories(INITIAL_CATEGORIES);
    setWallets(INITIAL_WALLETS);
    setActiveWalletIdState('wallet-1');
    setCurrencyState('$');
    setMonthlyBudgetState(3200);

    // Clean remote and reseed
    try {
      const snap = await getDocs(collection(db, 'expenses'));
      for (const d of snap.docs) {
        await deleteDoc(d.ref);
      }
      await seedInitialDataToFirestore();
    } catch (e) {
      console.warn('Reset sync warning:', e);
    } finally {
      setIsSyncing(false);
    }
  };

  const clearError = () => {
    setFirestoreError(null);
  };

  const retrySync = () => {
    setupFirestoreSubscription();
  };

  return (
    <ExpenseContext.Provider
      value={{
        transactions,
        categories,
        wallets,
        activeWallet,
        currency,
        monthlyBudget,
        selectedMonth,
        setSelectedMonth,
        selectedMonthName,
        prevMonth,
        nextMonth,
        selectedMonthSpend,
        selectedMonthIncome,
        selectedMonthBalance,
        selectedMonthTransactionCount,
        percentageChangeVsLastMonth,
        isSpendLowerThanLastMonth,
        categorySpendBreakdown,
        isLoading,
        isSyncing,
        firestoreError,
        clearError,
        retrySync,
        activeTab,
        setActiveTab,
        isAddExpenseOpen,
        setIsAddExpenseOpen,
        isSelectCategoryOpen,
        setIsSelectCategoryOpen,
        isCategoryPickerForNewExpense,
        setIsCategoryPickerForNewExpense,
        pendingCategorySelection,
        setPendingCategorySelection,
        editingTransaction,
        setEditingTransaction,
        isWalletModalOpen,
        setIsWalletModalOpen,
        isNotificationOpen,
        setIsNotificationOpen,
        addTransaction,
        updateTransaction,
        deleteTransaction,
        addCategory,
        setActiveWalletId,
        setCurrency,
        setMonthlyBudget,
        resetToDemoData,
        getCategoryById,
        formatCurrency,
      }}
    >
      {children}
    </ExpenseContext.Provider>
  );
};

export const useExpense = () => {
  const context = useContext(ExpenseContext);
  if (!context) {
    throw new Error('useExpense must be used within an ExpenseProvider');
  }
  return context;
};
