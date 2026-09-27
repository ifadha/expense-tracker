import React from 'react';
import {
  Settings,
  Calendar,
  Bell,
  Wallet as WalletIcon,
  ChevronRight,
  ChevronLeft,
  TrendingDown,
  TrendingUp,
  AlertCircle,
  RefreshCw,
  Plus,
} from 'lucide-react';
import { useExpense } from '../context/ExpenseContext';
import { CategoryIcon } from './CategoryIcon';

export const HomeScreen: React.FC = () => {
  const {
    transactions,
    selectedMonth,
    selectedMonthName,
    prevMonth,
    nextMonth,
    selectedMonthSpend,
    selectedMonthIncome,
    selectedMonthTransactionCount,
    percentageChangeVsLastMonth,
    isSpendLowerThanLastMonth,
    activeWallet,
    formatCurrency,
    setActiveTab,
    setIsAddExpenseOpen,
    setEditingTransaction,
    setIsWalletModalOpen,
    setIsNotificationOpen,
    getCategoryById,
    monthlyBudget,
    isLoading,
    isSyncing,
    firestoreError,
    retrySync,
    clearError,
  } = useExpense();

  // Filter transactions for the selected month (or top 5 if none in selected)
  const monthTransactions = transactions.filter((t) => t.date.startsWith(selectedMonth));
  const recentTransactions = monthTransactions.length > 0 ? monthTransactions.slice(0, 6) : transactions.slice(0, 6);

  // Budget calculations
  const budgetSpentPercent = Math.min(100, Math.round((selectedMonthSpend / monthlyBudget) * 100));

  const formatTxDate = (dateStr: string) => {
    try {
      const [y, m, d] = dateStr.split('-');
      const date = new Date(parseInt(y), parseInt(m) - 1, parseInt(d));
      return new Intl.DateTimeFormat('en-US', {
        day: 'numeric',
        month: 'short',
      }).format(date);
    } catch {
      return dateStr;
    }
  };

  return (
    <div className="flex-1 overflow-y-auto no-scrollbar px-5 pb-6 pt-1">
      {/* Top Header Row */}
      <div className="flex items-center justify-between py-2">
        {/* Settings Button */}
        <button
          onClick={() => setActiveTab('account')}
          className="w-11 h-11 rounded-2xl bg-white/85 hover:bg-white text-slate-700 flex items-center justify-center shadow-xs border border-white/70 active:scale-95 transition-all cursor-pointer"
          aria-label="Account Settings"
        >
          <Settings size={19} className="stroke-[2]" />
        </button>

        {/* Center: Interactive Month Selector Pill */}
        <div className="flex items-center bg-white/90 rounded-full border border-white/80 shadow-xs px-1.5 py-1">
          <button
            onClick={prevMonth}
            className="w-8 h-8 rounded-full flex items-center justify-center text-slate-600 hover:text-slate-950 hover:bg-slate-100 transition-colors cursor-pointer"
            aria-label="Previous month"
          >
            <ChevronLeft size={16} />
          </button>
          <div className="flex items-center gap-1.5 px-2.5 text-xs font-bold text-slate-800 select-none">
            <Calendar size={13} className="text-[#704fe6]" />
            <span className="truncate max-w-[110px]">{selectedMonthName}</span>
          </div>
          <button
            onClick={nextMonth}
            className="w-8 h-8 rounded-full flex items-center justify-center text-slate-600 hover:text-slate-950 hover:bg-slate-100 transition-colors cursor-pointer"
            aria-label="Next month"
          >
            <ChevronRight size={16} />
          </button>
        </div>

        {/* Notifications Button with Live Sync Indicator */}
        <button
          onClick={() => setIsNotificationOpen(true)}
          className="relative w-11 h-11 rounded-2xl bg-white/85 hover:bg-white text-slate-700 flex items-center justify-center shadow-xs border border-white/70 active:scale-95 transition-all cursor-pointer"
          aria-label="Notifications"
        >
          {isSyncing ? (
            <RefreshCw size={17} className="text-[#704fe6] animate-spin" />
          ) : (
            <Bell size={19} className="stroke-[2]" />
          )}
          {!isSyncing && (
            <span className="absolute top-2.5 right-2.5 w-2.5 h-2.5 bg-[#704fe6] rounded-full ring-2 ring-white" />
          )}
        </button>
      </div>

      {/* Error State Banner */}
      {firestoreError && (
        <div className="mt-2 bg-rose-50 border border-rose-200 text-rose-800 rounded-2xl p-3 flex items-center justify-between text-xs animate-in fade-in duration-200">
          <div className="flex items-center gap-2 min-w-0 pr-2">
            <AlertCircle size={16} className="text-rose-600 shrink-0" />
            <span className="truncate font-medium">{firestoreError}</span>
          </div>
          <div className="flex items-center gap-1 shrink-0">
            <button
              onClick={retrySync}
              className="px-2 py-1 bg-rose-600 text-white font-bold rounded-lg hover:bg-rose-700 transition-colors"
            >
              Retry
            </button>
            <button
              onClick={clearError}
              className="px-1.5 py-1 text-rose-500 hover:text-rose-700 font-bold"
            >
              ✕
            </button>
          </div>
        </div>
      )}

      {/* Loading Skeleton / State */}
      {isLoading ? (
        <div className="py-12 flex flex-col items-center justify-center space-y-3">
          <div className="w-10 h-10 border-3 border-[#704fe6]/20 border-t-[#704fe6] rounded-full animate-spin" />
          <p className="text-xs font-semibold text-slate-500">Loading Cloud Firestore records...</p>
        </div>
      ) : (
        <>
          {/* Hero Spending Section for Selected Month */}
          <div className="text-center pt-4 pb-5">
            <span className="text-xs font-semibold text-slate-500 tracking-wide uppercase">
              Total Expenses · {selectedMonthName}
            </span>
            <div className="text-[38px] font-extrabold text-[#17122b] tracking-tight leading-tight mt-1 font-mono tabular-nums">
              {formatCurrency(selectedMonthSpend)}
            </div>
            <div className="inline-flex items-center gap-1 text-[13px] font-medium text-slate-500 mt-1">
              {isSpendLowerThanLastMonth ? (
                <>
                  <TrendingDown size={14} className="text-emerald-500 stroke-[2.5]" />
                  <span className="text-slate-600 font-medium">
                    {percentageChangeVsLastMonth}% below last month
                  </span>
                </>
              ) : (
                <>
                  <TrendingUp size={14} className="text-rose-500 stroke-[2.5]" />
                  <span className="text-slate-600 font-medium">
                    {percentageChangeVsLastMonth}% above last month
                  </span>
                </>
              )}
            </div>
          </div>

          {/* Spending Wallet Card */}
          <button
            onClick={() => setIsWalletModalOpen(true)}
            className="w-full bg-white/90 hover:bg-white rounded-2xl p-4 shadow-[0_4px_20px_rgba(30,20,60,0.04)] border border-white/80 flex items-center justify-between text-left transition-all active:scale-[0.99] cursor-pointer mb-4 group"
          >
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-xl bg-[#f4f0ff] text-[#704fe6] flex items-center justify-center">
                <WalletIcon size={19} className="stroke-[2]" />
              </div>
              <div>
                <div className="text-sm font-bold text-slate-800">
                  {activeWallet.name}
                </div>
                <div className="text-[11px] text-slate-400">
                  Tap to switch or manage
                </div>
              </div>
            </div>

            <div className="flex items-center gap-1.5">
              <span className="text-base font-bold text-slate-900 font-mono tabular-nums">
                {formatCurrency(activeWallet.balance)}
              </span>
              <ChevronRight size={17} className="text-slate-400 group-hover:translate-x-0.5 transition-transform" />
            </div>
          </button>

          {/* Monthly Budget Progress Bar */}
          <div className="bg-white/75 rounded-2xl p-3.5 border border-white/60 mb-5 shadow-xs">
            <div className="flex items-center justify-between text-xs mb-1.5">
              <span className="font-semibold text-slate-600">Monthly Budget</span>
              <span className="font-semibold text-slate-800 font-mono tabular-nums">
                {formatCurrency(selectedMonthSpend)} / {formatCurrency(monthlyBudget)} ({budgetSpentPercent}%)
              </span>
            </div>
            <div className="w-full h-2 bg-slate-100 rounded-full overflow-hidden">
              <div
                className={`h-full rounded-full transition-all duration-500 ${
                  budgetSpentPercent > 90
                    ? 'bg-rose-500'
                    : budgetSpentPercent > 70
                    ? 'bg-amber-400'
                    : 'bg-[#704fe6]'
                }`}
                style={{ width: `${budgetSpentPercent}%` }}
              />
            </div>
          </div>

          {/* Transactions Header Row */}
          <div className="flex items-center justify-between mb-3 px-1">
            <div className="flex items-center gap-2">
              <h2 className="text-base font-bold text-slate-900 tracking-tight">
                Recent Transactions
              </h2>
              <span className="text-[11px] font-bold text-[#704fe6] bg-purple-100/70 px-2 py-0.5 rounded-full">
                {selectedMonthTransactionCount}
              </span>
            </div>
            <button
              onClick={() => setActiveTab('history')}
              className="text-xs font-bold text-slate-600 hover:text-[#704fe6] transition-colors cursor-pointer py-1 px-2.5 rounded-lg hover:bg-white/60"
            >
              See All
            </button>
          </div>

          {/* Transactions List */}
          <div className="space-y-2.5">
            {recentTransactions.map((tx) => {
              const cat = getCategoryById(tx.categoryId);
              const isExpense = tx.type === 'expense';

              return (
                <div
                  key={tx.id}
                  onClick={() => setEditingTransaction(tx)}
                  className="bg-white/95 hover:bg-white rounded-2xl p-3.5 shadow-[0_2px_12px_rgba(30,20,60,0.03)] border border-white/70 flex items-center justify-between transition-all duration-150 active:scale-[0.99] cursor-pointer group"
                >
                  <div className="flex items-center gap-3.5 min-w-0 pr-2">
                    {/* Icon Container */}
                    <div
                      className="w-11 h-11 rounded-2xl flex items-center justify-center shrink-0 shadow-xs"
                      style={{
                        backgroundColor: cat.bgLight || '#f5f3ff',
                        color: cat.color || '#7c3aed',
                      }}
                    >
                      <CategoryIcon iconName={cat.iconName} size={20} color={cat.color} />
                    </div>

                    {/* Details */}
                    <div className="min-w-0">
                      <div className="text-[14px] font-bold text-slate-900 truncate">
                        {tx.title}
                      </div>
                      <div className="text-xs text-slate-500 font-medium flex items-center gap-1.5 mt-0.5">
                        <span>{formatTxDate(tx.date)}</span>
                        <span>·</span>
                        <span className="truncate">{cat.name}</span>
                      </div>
                    </div>
                  </div>

                  {/* Amount & Action */}
                  <div className="flex items-center gap-2 shrink-0">
                    <span
                      className={`text-sm font-bold font-mono tabular-nums ${
                        isExpense ? 'text-rose-500' : 'text-emerald-600'
                      }`}
                    >
                      {isExpense ? `-${formatCurrency(tx.amount)}` : `+${formatCurrency(tx.amount)}`}
                    </span>
                    <ChevronRight
                      size={16}
                      className="text-slate-300 group-hover:text-slate-600 group-hover:translate-x-0.5 transition-all"
                    />
                  </div>
                </div>
              );
            })}

            {/* Empty State for Selected Month */}
            {recentTransactions.length === 0 && (
              <div className="bg-white/80 rounded-2xl p-7 text-center border border-white/70 shadow-xs">
                <div className="w-12 h-12 rounded-2xl bg-purple-50 text-[#704fe6] flex items-center justify-center mx-auto mb-2.5">
                  <Calendar size={22} />
                </div>
                <h3 className="text-sm font-bold text-slate-800">
                  No expenses for {selectedMonthName}
                </h3>
                <p className="text-xs text-slate-400 mt-1 max-w-xs mx-auto">
                  Start tracking your spending for this period by recording a new expense.
                </p>
                <button
                  onClick={() => setIsAddExpenseOpen(true)}
                  className="mt-4 px-4 py-2 bg-[#1b1433] hover:bg-[#2c2250] text-white text-xs font-bold rounded-xl transition-all cursor-pointer shadow-xs inline-flex items-center gap-1.5"
                >
                  <Plus size={14} />
                  <span>Add Expense</span>
                </button>
              </div>
            )}
          </div>
        </>
      )}
    </div>
  );
};
