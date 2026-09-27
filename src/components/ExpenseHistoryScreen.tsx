import React, { useState, useMemo } from 'react';
import {
  ArrowLeft,
  Search,
  Download,
  ArrowUpRight,
  ArrowDownLeft,
  X,
  Calendar,
  Filter,
  RefreshCw,
  AlertCircle,
  Plus,
} from 'lucide-react';
import { useExpense } from '../context/ExpenseContext';
import { CategoryIcon } from './CategoryIcon';
import { Transaction } from '../types';

export const ExpenseHistoryScreen: React.FC = () => {
  const {
    transactions,
    categories,
    formatCurrency,
    setEditingTransaction,
    getCategoryById,
    setActiveTab,
    setIsAddExpenseOpen,
    isLoading,
    isSyncing,
    firestoreError,
    retrySync,
  } = useExpense();

  const [searchQuery, setSearchQuery] = useState('');
  // Filter pills: "All", "Deposit of funds" (income), "Withdrawal of funds" (expense)
  const [filterType, setFilterType] = useState<'all' | 'income' | 'expense'>('all');
  const [selectedCategoryFilter, setSelectedCategoryFilter] = useState<string>('all');
  const [selectedDateFilter, setSelectedDateFilter] = useState<string>(''); // YYYY-MM-DD or YYYY-MM
  const [showSearch, setShowSearch] = useState<boolean>(false);
  const [showDateFilter, setShowDateFilter] = useState<boolean>(false);

  // Filter transactions
  const filteredTransactions = useMemo(() => {
    return transactions.filter((tx) => {
      // Search match
      const cat = getCategoryById(tx.categoryId);
      const query = searchQuery.toLowerCase();
      const matchesSearch =
        !searchQuery ||
        tx.title.toLowerCase().includes(query) ||
        cat.name.toLowerCase().includes(query) ||
        (tx.note && tx.note.toLowerCase().includes(query)) ||
        tx.amount.toString().includes(query) ||
        tx.wallet.toLowerCase().includes(query);

      // Type match (deposit vs withdrawal)
      const matchesType = filterType === 'all' || tx.type === filterType;

      // Category match
      const matchesCategory =
        selectedCategoryFilter === 'all' || tx.categoryId === selectedCategoryFilter;

      // Date match (exact date or month prefix)
      const matchesDate = !selectedDateFilter || tx.date.startsWith(selectedDateFilter);

      return matchesSearch && matchesType && matchesCategory && matchesDate;
    });
  }, [transactions, searchQuery, filterType, selectedCategoryFilter, selectedDateFilter, getCategoryById]);

  // Format date as DD.MM.YYYY
  const formatDateDDMMYYYY = (dateStr: string) => {
    try {
      const [y, m, d] = dateStr.split('-');
      return `${d}.${m}.${y}`;
    } catch {
      return dateStr;
    }
  };

  const [showExportToast, setShowExportToast] = useState(false);

  const handleExportCSV = () => {
    const headers = ['ID', 'Date', 'Title', 'Type', 'Amount', 'Category', 'Wallet', 'Note'];
    const rows = filteredTransactions.map((t) => [
      t.id,
      t.date,
      `"${t.title.replace(/"/g, '""')}"`,
      t.type,
      t.amount,
      getCategoryById(t.categoryId).name,
      t.wallet,
      `"${(t.note || '').replace(/"/g, '""')}"`,
    ]);

    const csvContent =
      'data:text/csv;charset=utf-8,' +
      [headers.join(','), ...rows.map((e) => e.join(','))].join('\n');
    const encodedUri = encodeURI(csvContent);
    const link = document.createElement('a');
    link.setAttribute('href', encodedUri);
    link.setAttribute('download', `lumina_transactions_${new Date().toISOString().split('T')[0]}.csv`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);

    setShowExportToast(true);
    setTimeout(() => setShowExportToast(false), 2500);
  };

  // Payment brand logo badge helper
  const renderPaymentBadge = (walletName: string) => {
    const isCredit = walletName.toLowerCase().includes('credit') || walletName.toLowerCase().includes('card');

    return (
      <div className="flex items-center gap-1.5 text-[11px] text-slate-400 font-medium">
        {isCredit ? (
          <div className="flex items-center -space-x-1 shrink-0">
            <span className="w-2.5 h-2.5 rounded-full bg-[#eb001b] inline-block" />
            <span className="w-2.5 h-2.5 rounded-full bg-[#f79e1b] inline-block opacity-90" />
          </div>
        ) : (
          <span className="w-2 h-2 rounded-full bg-[#704fe6]/60 inline-block shrink-0" />
        )}
        <span className="truncate">
          {isCredit ? 'MasterCard •••• 9918' : walletName}
        </span>
      </div>
    );
  };

  const hasActiveFilters =
    filterType !== 'all' || selectedCategoryFilter !== 'all' || !!selectedDateFilter || !!searchQuery;

  const resetAllFilters = () => {
    setFilterType('all');
    setSelectedCategoryFilter('all');
    setSelectedDateFilter('');
    setSearchQuery('');
  };

  return (
    <div className="flex-1 overflow-y-auto no-scrollbar px-5 pb-8 pt-2">
      {/* Top Header Row */}
      <div className="flex items-center justify-between py-2 mb-2">
        <button
          onClick={() => setActiveTab('home')}
          className="w-11 h-11 rounded-2xl bg-white/85 hover:bg-white text-slate-700 flex items-center justify-center shadow-xs border border-white/70 active:scale-95 transition-all cursor-pointer"
          aria-label="Back to Home"
        >
          <ArrowLeft size={19} className="stroke-[2.2]" />
        </button>

        <h1 className="text-base font-bold text-slate-900 tracking-tight">
          Transactions
        </h1>

        <div className="flex items-center gap-2">
          <button
            onClick={() => setShowDateFilter(!showDateFilter)}
            className={`w-11 h-11 rounded-2xl flex items-center justify-center shadow-xs border transition-all cursor-pointer ${
              selectedDateFilter || showDateFilter
                ? 'bg-[#704fe6] text-white border-[#704fe6] shadow-purple-500/20 shadow-md'
                : 'bg-white/85 hover:bg-white text-slate-700 border-white/70'
            }`}
            title="Filter by Date"
            aria-label="Filter by Date"
          >
            <Calendar size={18} />
          </button>

          <button
            onClick={() => setShowSearch(!showSearch)}
            className={`w-11 h-11 rounded-2xl flex items-center justify-center shadow-xs border transition-all cursor-pointer ${
              showSearch || searchQuery
                ? 'bg-[#704fe6] text-white border-[#704fe6] shadow-purple-500/20 shadow-md'
                : 'bg-white/85 hover:bg-white text-slate-700 border-white/70'
            }`}
            aria-label="Search"
          >
            <Search size={18} />
          </button>

          <button
            onClick={handleExportCSV}
            className="w-11 h-11 rounded-2xl bg-white/85 hover:bg-white text-slate-700 flex items-center justify-center shadow-xs border border-white/70 active:scale-95 transition-all cursor-pointer"
            title="Export CSV"
            aria-label="Export CSV"
          >
            <Download size={18} className="text-slate-700" />
          </button>
        </div>
      </div>

      {/* CSV Export Success Toast */}
      {showExportToast && (
        <div className="mb-3 bg-emerald-50 border border-emerald-200 text-emerald-800 rounded-2xl p-3 flex items-center justify-between text-xs animate-in fade-in duration-200 shadow-xs">
          <span className="font-semibold">CSV transaction file successfully exported!</span>
          <button onClick={() => setShowExportToast(false)} className="text-emerald-700 font-bold px-1">✕</button>
        </div>
      )}

      {/* Error state */}
      {firestoreError && (
        <div className="mb-3 bg-rose-50 border border-rose-200 text-rose-800 rounded-2xl p-3 flex items-center justify-between text-xs">
          <div className="flex items-center gap-2">
            <AlertCircle size={15} className="text-rose-600 shrink-0" />
            <span className="font-medium">{firestoreError}</span>
          </div>
          <button
            onClick={retrySync}
            className="px-2 py-0.5 bg-rose-600 text-white font-bold rounded-lg hover:bg-rose-700 text-[11px]"
          >
            Retry
          </button>
        </div>
      )}

      {/* Date Filter Bar */}
      {showDateFilter && (
        <div className="mb-3 p-3 bg-white/95 rounded-2xl border border-white shadow-xs animate-in fade-in slide-in-from-top-2 duration-150">
          <div className="flex items-center justify-between text-xs mb-2">
            <span className="font-bold text-slate-700 flex items-center gap-1.5">
              <Calendar size={13} className="text-[#704fe6]" />
              <span>Filter by Date</span>
            </span>
            {selectedDateFilter && (
              <button
                onClick={() => setSelectedDateFilter('')}
                className="text-[11px] font-semibold text-[#704fe6] hover:underline"
              >
                Clear Date
              </button>
            )}
          </div>
          <div className="flex items-center gap-2">
            <input
              type="date"
              value={selectedDateFilter}
              onChange={(e) => setSelectedDateFilter(e.target.value)}
              className="flex-1 h-9 px-3 bg-slate-50 border border-slate-200 rounded-xl text-xs font-semibold text-slate-800"
            />
          </div>
        </div>
      )}

      {/* Search Input Bar */}
      {(showSearch || searchQuery) && (
        <div className="relative mb-3 animate-in fade-in slide-in-from-top-2 duration-150">
          <Search
            size={16}
            className="absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 pointer-events-none"
          />
          <input
            type="text"
            autoFocus
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search by merchant, note, or wallet..."
            className="w-full h-11 pl-10 pr-9 bg-white/95 text-xs font-medium text-slate-800 placeholder-slate-400 rounded-2xl border border-white shadow-xs focus:outline-hidden focus:ring-2 focus:ring-[#704fe6]/20 transition-all"
          />
          {searchQuery && (
            <button
              onClick={() => setSearchQuery('')}
              className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 p-1"
            >
              <X size={14} />
            </button>
          )}
        </div>
      )}

      {/* Filter Pills Row */}
      <div className="flex items-center gap-2 overflow-x-auto no-scrollbar pb-2 mb-2 pt-1">
        <button
          onClick={() => setFilterType('all')}
          className={`px-4 py-2 rounded-full text-xs font-bold shrink-0 transition-all cursor-pointer ${
            filterType === 'all'
              ? 'bg-[#1b1433] text-white shadow-sm'
              : 'bg-white/80 hover:bg-white text-slate-600 border border-white/70'
          }`}
        >
          All
        </button>

        <button
          onClick={() => setFilterType('income')}
          className={`flex items-center gap-1.5 px-4 py-2 rounded-full text-xs font-bold shrink-0 transition-all cursor-pointer ${
            filterType === 'income'
              ? 'bg-[#1b1433] text-white shadow-sm'
              : 'bg-white/80 hover:bg-white text-slate-600 border border-white/70'
          }`}
        >
          <span className={`w-1.5 h-1.5 rounded-full ${filterType === 'income' ? 'bg-[#10b981]' : 'bg-slate-400'}`} />
          <span>Deposit of funds</span>
        </button>

        <button
          onClick={() => setFilterType('expense')}
          className={`flex items-center gap-1.5 px-4 py-2 rounded-full text-xs font-bold shrink-0 transition-all cursor-pointer ${
            filterType === 'expense'
              ? 'bg-[#1b1433] text-white shadow-sm'
              : 'bg-white/80 hover:bg-white text-slate-600 border border-white/70'
          }`}
        >
          <span className={`w-1.5 h-1.5 rounded-full ${filterType === 'expense' ? 'bg-[#ff4866]' : 'bg-slate-400'}`} />
          <span>Withdrawal of funds</span>
        </button>
      </div>

      {/* Category Filter Chips */}
      <div className="flex items-center gap-1.5 overflow-x-auto no-scrollbar pb-3 mb-2">
        <button
          onClick={() => setSelectedCategoryFilter('all')}
          className={`px-3 py-1 rounded-full text-[11px] font-semibold shrink-0 transition-all cursor-pointer ${
            selectedCategoryFilter === 'all'
              ? 'bg-[#704fe6] text-white shadow-xs'
              : 'bg-white/60 text-slate-500 hover:bg-white/90 border border-white/60'
          }`}
        >
          All Categories
        </button>
        {categories.map((c) => {
          const isSelected = selectedCategoryFilter === c.id;
          return (
            <button
              key={c.id}
              onClick={() => setSelectedCategoryFilter(c.id)}
              className={`flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[11px] font-medium shrink-0 transition-all cursor-pointer ${
                isSelected
                  ? 'bg-[#704fe6] text-white shadow-xs'
                  : 'bg-white/60 text-slate-600 hover:bg-white/90 border border-white/60'
              }`}
            >
              <CategoryIcon iconName={c.iconName} size={11} color={isSelected ? '#ffffff' : c.color} />
              <span>{c.name}</span>
            </button>
          );
        })}
      </div>

      {/* Filter status strip with active filter notice */}
      {hasActiveFilters && (
        <div className="flex items-center justify-between px-3 py-1.5 bg-purple-50/70 rounded-xl mb-3 text-xs text-[#704fe6] border border-purple-100">
          <span className="font-semibold">
            {filteredTransactions.length} results matching filter
          </span>
          <button
            onClick={resetAllFilters}
            className="text-[11px] font-bold underline hover:text-[#5233be]"
          >
            Clear All
          </button>
        </div>
      )}

      {/* Loading state */}
      {isLoading ? (
        <div className="py-12 flex flex-col items-center justify-center space-y-3">
          <div className="w-8 h-8 border-3 border-[#704fe6]/20 border-t-[#704fe6] rounded-full animate-spin" />
          <p className="text-xs text-slate-400 font-semibold">Loading transactions from Firestore...</p>
        </div>
      ) : (
        /* Transactions List */
        <div className="space-y-2.5">
          {filteredTransactions.map((tx) => {
            const cat = getCategoryById(tx.categoryId);
            const isExpense = tx.type === 'expense';

            return (
              <div
                key={tx.id}
                onClick={() => setEditingTransaction(tx)}
                className="bg-white/95 hover:bg-white rounded-[22px] px-4 py-3.5 shadow-[0_2px_12px_rgba(30,20,60,0.03)] border border-white/80 flex items-center justify-between transition-all duration-150 active:scale-[0.99] cursor-pointer group"
              >
                {/* Left Side: Circular Indicator & Details */}
                <div className="flex items-center gap-3.5 min-w-0 pr-2">
                  <div
                    className={`w-11 h-11 rounded-full flex items-center justify-center shrink-0 border ${
                      isExpense
                        ? 'bg-slate-50 text-slate-600 border-slate-100 group-hover:border-slate-200'
                        : 'bg-emerald-50 text-emerald-600 border-emerald-100/70 group-hover:border-emerald-200'
                    }`}
                  >
                    {isExpense ? (
                      <ArrowUpRight size={19} className="stroke-[2.2] text-slate-600" />
                    ) : (
                      <ArrowDownLeft size={19} className="stroke-[2.2] text-emerald-600" />
                    )}
                  </div>

                  <div className="min-w-0">
                    <div className="text-[14px] font-bold text-slate-900 truncate">
                      {tx.title}
                    </div>
                    <div className="mt-0.5 flex items-center gap-2">
                      <span className="text-xs text-slate-500 font-medium truncate">{cat.name}</span>
                      <span className="text-slate-300">·</span>
                      {renderPaymentBadge(tx.wallet)}
                    </div>
                  </div>
                </div>

                {/* Right Side: Amount and Date */}
                <div className="text-right shrink-0 pl-2">
                  <div
                    className={`text-[15px] font-extrabold font-mono tabular-nums leading-tight ${
                      isExpense ? 'text-rose-500' : 'text-emerald-600'
                    }`}
                  >
                    {isExpense ? `-${formatCurrency(tx.amount)}` : `+${formatCurrency(tx.amount)}`}
                  </div>
                  <div className="text-xs font-medium text-slate-500 mt-0.5 font-mono">
                    {formatDateDDMMYYYY(tx.date)}
                  </div>
                </div>
              </div>
            );
          })}

          {/* Empty State */}
          {filteredTransactions.length === 0 && (
            <div className="bg-white/80 rounded-3xl p-8 text-center border border-white/60 mt-4">
              <div className="w-12 h-12 rounded-2xl bg-purple-50 text-[#704fe6] flex items-center justify-center mx-auto mb-3">
                <Filter size={20} />
              </div>
              <p className="text-sm font-bold text-slate-800">No transactions found</p>
              <p className="text-xs text-slate-400 mt-1 max-w-xs mx-auto">
                No records match your selected filter criteria or search query.
              </p>
              <div className="flex items-center justify-center gap-2 mt-4">
                {hasActiveFilters && (
                  <button
                    onClick={resetAllFilters}
                    className="px-3.5 py-2 bg-slate-100 hover:bg-slate-200 text-slate-700 text-xs font-semibold rounded-xl transition-colors cursor-pointer"
                  >
                    Reset Filters
                  </button>
                )}
                <button
                  onClick={() => setIsAddExpenseOpen(true)}
                  className="px-3.5 py-2 bg-[#704fe6] hover:bg-[#5e3cdb] text-white text-xs font-bold rounded-xl transition-all cursor-pointer shadow-xs inline-flex items-center gap-1"
                >
                  <Plus size={14} />
                  <span>Add Expense</span>
                </button>
              </div>
            </div>
          )}
        </div>
      )}
    </div>
  );
};
