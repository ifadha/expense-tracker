export type TransactionType = 'expense' | 'income';

export interface Category {
  id: string;
  name: string;
  iconName: string;
  color: string;
  bgLight: string;
  isCustom?: boolean;
}

export interface Transaction {
  id: string;
  title: string;
  amount: number;
  type: TransactionType;
  categoryId: string;
  date: string; // ISO date string YYYY-MM-DD
  wallet: string; // e.g., 'Spending Wallet', 'Credit Card', 'Cash'
  note?: string;
  recurring?: boolean;
}

export interface Wallet {
  id: string;
  name: string;
  balance: number;
  type: 'checking' | 'savings' | 'credit' | 'cash';
  color: string;
}

export interface MonthlyBudget {
  month: string; // YYYY-MM
  totalBudget: number;
}

export type ActiveTab = 'home' | 'history' | 'analytics' | 'account';

export interface AnalyticsMonthData {
  month: string;
  monthShort: string;
  income: number;
  expense: number;
}
