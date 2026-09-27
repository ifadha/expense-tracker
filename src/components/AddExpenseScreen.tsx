import React, { useState } from 'react';
import {
  X,
  ChevronDown,
  Calendar,
  Wallet as WalletIcon,
  Tag,
  Check,
  ChevronRight,
  Plus,
  Repeat,
  RefreshCw,
  AlertCircle,
} from 'lucide-react';
import { useExpense } from '../context/ExpenseContext';
import { CategoryIcon } from './CategoryIcon';
import { Category, TransactionType } from '../types';

export const AddExpenseScreen: React.FC = () => {
  const {
    categories,
    wallets,
    currency,
    addTransaction,
    setIsAddExpenseOpen,
    setIsSelectCategoryOpen,
    setIsCategoryPickerForNewExpense,
    pendingCategorySelection,
    setPendingCategorySelection,
    getCategoryById,
  } = useExpense();

  const [type, setType] = useState<TransactionType>('expense');
  const [amountStr, setAmountStr] = useState<string>('');
  const [title, setTitle] = useState<string>('');
  const [selectedCategoryId, setSelectedCategoryId] = useState<string>(() => {
    return pendingCategorySelection || 'subscription';
  });
  const [selectedWallet, setSelectedWallet] = useState<string>(wallets[0]?.name || 'Spending Wallet');
  
  // Date state with friendly formatted display (e.g. "14/02/2026 - Today")
  const [date, setDate] = useState<string>(() => {
    return new Date().toISOString().split('T')[0];
  });
  const [datePreset, setDatePreset] = useState<'today' | 'yesterday' | 'custom'>('today');
  const [showDatePicker, setShowDatePicker] = useState<boolean>(false);

  const [note, setNote] = useState<string>('');
  const [recurring, setRecurring] = useState<boolean>(false);
  const [error, setError] = useState<string>('');
  const [isSubmitting, setIsSubmitting] = useState<boolean>(false);

  // Synchronize if category was picked from full CategorySelection screen
  React.useEffect(() => {
    if (pendingCategorySelection) {
      setSelectedCategoryId(pendingCategorySelection);
      setPendingCategorySelection(null);
    }
  }, [pendingCategorySelection, setPendingCategorySelection]);

  const selectedCategory = getCategoryById(selectedCategoryId);

  // Popular category quick-pills
  const popularCategoryIds = [
    'subscription',
    'groceries',
    'dining',
    'home',
    'gym',
    'travel',
    'internet',
    'shopping',
  ];

  // Quick amount suggestions
  const quickAmounts = [10, 25, 50, 100];

  const handleOpenFullCategoryPicker = () => {
    setIsCategoryPickerForNewExpense(true);
    setIsAddExpenseOpen(false);
    setIsSelectCategoryOpen(true);
  };

  // Date formatting for pill display
  const getFormattedDateDisplay = () => {
    try {
      const [y, m, d] = date.split('-');
      const formatted = `${d}/${m}/${y}`;
      const todayStr = new Date().toISOString().split('T')[0];
      const yesterday = new Date();
      yesterday.setDate(yesterday.getDate() - 1);
      const yesterdayStr = yesterday.toISOString().split('T')[0];

      if (date === todayStr) {
        return `${formatted} - Today`;
      } else if (date === yesterdayStr) {
        return `${formatted} - Yesterday`;
      } else {
        return formatted;
      }
    } catch {
      return date;
    }
  };

  const handleDatePresetSelect = (preset: 'today' | 'yesterday') => {
    if (preset === 'today') {
      setDate(new Date().toISOString().split('T')[0]);
      setDatePreset('today');
    } else {
      const yest = new Date();
      yest.setDate(yest.getDate() - 1);
      setDate(yest.toISOString().split('T')[0]);
      setDatePreset('yesterday');
    }
    setShowDatePicker(false);
  };

  const isFormValid = title.trim().length > 0 && parseFloat(amountStr) > 0 && !!selectedCategoryId && !!date;

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');

    // Strict Validations
    const parsedAmount = parseFloat(amountStr);
    if (isNaN(parsedAmount) || parsedAmount <= 0) {
      setError('Please enter a valid amount greater than 0');
      return;
    }

    if (!title.trim()) {
      setError('Expense title is required');
      return;
    }

    if (!selectedCategoryId) {
      setError('Please select an expense category');
      return;
    }

    if (!date) {
      setError('Please select a valid date');
      return;
    }

    try {
      setIsSubmitting(true);
      await addTransaction({
        title: title.trim(),
        amount: parsedAmount,
        type,
        categoryId: selectedCategoryId,
        date,
        wallet: selectedWallet,
        note: note.trim() || undefined,
        recurring,
      });
      setIsSubmitting(false);
      setIsAddExpenseOpen(false);
    } catch (err) {
      setIsSubmitting(false);
      setError('Failed to record expense. Please try again.');
    }
  };

  return (
    <div className="flex-1 flex flex-col overflow-hidden bg-gradient-to-b from-[#ded7fc] via-[#f4f2fb] to-[#f6f5fc] text-slate-800">
      {/* Top Drag Handle Indicator */}
      <div className="pt-2 pb-1 flex justify-center">
        <div className="w-10 h-1 bg-slate-300/80 rounded-full" />
      </div>

      {/* Header Bar */}
      <div className="px-5 py-2.5 flex items-center justify-between">
        <h1 className="text-lg font-bold text-slate-900 tracking-tight">
          {type === 'expense' ? 'Add Expense' : 'Add Income'}
        </h1>

        {/* Type toggle: Expense vs Income */}
        <div className="flex items-center p-1 bg-white/90 rounded-full border border-white/80 shadow-xs">
          <button
            type="button"
            onClick={() => setType('expense')}
            className={`px-3.5 py-1.5 text-xs font-bold rounded-full transition-all cursor-pointer ${
              type === 'expense'
                ? 'bg-[#1b1433] text-white shadow-xs'
                : 'text-slate-600 hover:text-slate-950'
            }`}
          >
            Expense
          </button>
          <button
            type="button"
            onClick={() => setType('income')}
            className={`px-3.5 py-1.5 text-xs font-bold rounded-full transition-all cursor-pointer ${
              type === 'income'
                ? 'bg-[#10b981] text-white shadow-xs'
                : 'text-slate-600 hover:text-slate-950'
            }`}
          >
            Income
          </button>
        </div>

        {/* Close Button */}
        <button
          onClick={() => setIsAddExpenseOpen(false)}
          disabled={isSubmitting}
          className="w-10 h-10 rounded-2xl bg-white/85 hover:bg-white text-slate-700 flex items-center justify-center shadow-xs border border-white/70 active:scale-95 transition-all cursor-pointer disabled:opacity-50"
          aria-label="Close"
        >
          <X size={18} className="stroke-[2.2]" />
        </button>
      </div>

      {/* Error Banner */}
      {error && (
        <div className="mx-5 mb-2 p-2.5 bg-rose-50 border border-rose-200 text-rose-700 rounded-xl text-xs flex items-center gap-2">
          <AlertCircle size={15} className="shrink-0" />
          <span>{error}</span>
        </div>
      )}

      {/* Form Content */}
      <form onSubmit={handleSubmit} className="flex-1 overflow-y-auto no-scrollbar px-5 pb-6 pt-1 space-y-4">
        {/* 1. Expense Name Field */}
        <div>
          <label className="text-xs font-semibold text-slate-500 block mb-1.5 pl-0.5">
            {type === 'expense' ? 'Expense Title *' : 'Income Source *'}
          </label>
          <div className="relative">
            <input
              type="text"
              autoFocus
              required
              maxLength={120}
              placeholder={type === 'expense' ? 'e.g. Gym Membership' : 'e.g. Salary, Client Payout'}
              value={title}
              onChange={(e) => {
                setTitle(e.target.value);
                setError('');
              }}
              className="w-full h-12 px-4 bg-white/95 text-slate-800 font-semibold text-sm placeholder-slate-400 rounded-2xl border border-white shadow-[0_2px_10px_rgba(30,20,60,0.02)] focus:outline-hidden focus:ring-2 focus:ring-[#704fe6]/20 transition-all"
            />
          </div>

          {/* Quick preset name suggestions */}
          <div className="flex items-center gap-1.5 mt-2 overflow-x-auto no-scrollbar pb-0.5">
            {['Gym Membership', 'Spotify', 'Whole Foods', 'Uber Ride', 'Rent', 'Freelance'].map((tag) => (
              <button
                key={tag}
                type="button"
                onClick={() => setTitle(tag)}
                className="px-2.5 py-1 text-[11px] font-medium rounded-lg bg-white/70 hover:bg-white text-slate-600 hover:text-slate-900 border border-white/60 shadow-xs shrink-0 transition-colors cursor-pointer"
              >
                {tag}
              </button>
            ))}
          </div>
        </div>

        {/* 2. Amount Field with Prefix */}
        <div>
          <label className="text-xs font-semibold text-slate-500 block mb-1.5 pl-0.5">
            Amount *
          </label>
          <div className="relative flex items-center bg-white/95 rounded-2xl border border-white shadow-[0_2px_10px_rgba(30,20,60,0.02)] focus-within:ring-2 focus-within:ring-[#704fe6]/20 transition-all overflow-hidden h-12 px-4">
            <span className="text-slate-400 font-bold text-sm select-none pr-2 font-mono">
              {currency}
            </span>
            <span className="text-slate-300 font-light select-none pr-2">|</span>
            <input
              type="number"
              step="0.01"
              min="0.01"
              required
              placeholder="0.00"
              value={amountStr}
              onChange={(e) => {
                setAmountStr(e.target.value);
                setError('');
              }}
              className="flex-1 bg-transparent text-sm font-bold text-slate-800 placeholder-slate-400 focus:outline-hidden font-mono"
            />

            {/* Quick increment pills */}
            <div className="flex items-center gap-1 shrink-0">
              {quickAmounts.map((q) => (
                <button
                  key={q}
                  type="button"
                  onClick={() => {
                    const cur = parseFloat(amountStr) || 0;
                    setAmountStr((cur + q).toFixed(2));
                    setError('');
                  }}
                  className="px-1.5 py-0.5 text-[10px] font-semibold bg-slate-100 hover:bg-purple-100 hover:text-[#704fe6] text-slate-600 rounded-md transition-colors cursor-pointer"
                >
                  +{q}
                </button>
              ))}
            </div>
          </div>
        </div>

        {/* 3. Select a Category */}
        <div>
          <div className="flex items-center justify-between mb-1.5 pl-0.5">
            <label className="text-xs font-semibold text-slate-500">
              Category *
            </label>
            <button
              type="button"
              onClick={handleOpenFullCategoryPicker}
              className="text-xs font-semibold text-[#704fe6] hover:text-[#5839c4] transition-colors cursor-pointer flex items-center gap-0.5"
            >
              <span>View All</span>
              <ChevronRight size={13} />
            </button>
          </div>

          {/* Horizontal scrolling pill chips */}
          <div className="flex items-center gap-2 overflow-x-auto no-scrollbar py-1">
            {popularCategoryIds.map((catId) => {
              const cat = getCategoryById(catId);
              const isSelected = selectedCategoryId === cat.id;

              return (
                <button
                  key={cat.id}
                  type="button"
                  onClick={() => {
                    setSelectedCategoryId(cat.id);
                    setError('');
                  }}
                  className={`flex items-center gap-1.5 px-3 py-1.5 rounded-xl text-xs font-medium shrink-0 transition-all cursor-pointer ${
                    isSelected
                      ? 'bg-white ring-2 ring-[#704fe6] text-[#704fe6] font-bold shadow-xs'
                      : 'bg-white/80 hover:bg-white text-slate-600 border border-white/60 shadow-xs'
                  }`}
                >
                  <CategoryIcon
                    iconName={cat.iconName}
                    size={14}
                    color={isSelected ? '#704fe6' : cat.color}
                  />
                  <span>{cat.name}</span>
                  {isSelected && (
                    <span className="w-3.5 h-3.5 rounded-full bg-[#704fe6]/15 text-[#704fe6] flex items-center justify-center text-[9px] ml-0.5">
                      ✓
                    </span>
                  )}
                </button>
              );
            })}

            <button
              type="button"
              onClick={handleOpenFullCategoryPicker}
              className="flex items-center gap-1 px-3 py-1.5 rounded-xl text-xs font-semibold bg-white/60 hover:bg-white text-slate-500 border border-dashed border-slate-300 shrink-0 cursor-pointer"
            >
              <Plus size={13} />
              <span>More</span>
            </button>
          </div>
        </div>

        {/* 4. Date Field */}
        <div>
          <label className="text-xs font-semibold text-slate-500 block mb-1.5 pl-0.5">
            Date *
          </label>
          <div className="relative">
            <button
              type="button"
              onClick={() => setShowDatePicker(!showDatePicker)}
              className="w-full h-12 px-4 bg-white/95 rounded-2xl border border-white shadow-[0_2px_10px_rgba(30,20,60,0.02)] flex items-center justify-between text-left text-sm font-semibold text-slate-800 cursor-pointer hover:bg-white transition-all"
            >
              <div className="flex items-center gap-2.5">
                <Calendar size={16} className="text-[#704fe6]" />
                <span className="font-mono">{getFormattedDateDisplay()}</span>
              </div>
              <ChevronDown
                size={16}
                className={`text-slate-400 transition-transform ${showDatePicker ? 'rotate-180' : ''}`}
              />
            </button>

            {/* Date options drop card */}
            {showDatePicker && (
              <div className="absolute top-14 inset-x-0 bg-white rounded-2xl p-3 shadow-xl border border-slate-100 z-30 space-y-2 animate-in fade-in zoom-in-95 duration-150">
                <div className="grid grid-cols-2 gap-2">
                  <button
                    type="button"
                    onClick={() => handleDatePresetSelect('today')}
                    className="py-2 px-3 rounded-xl bg-purple-50 text-[#704fe6] text-xs font-bold hover:bg-purple-100 transition-colors"
                  >
                    Today
                  </button>
                  <button
                    type="button"
                    onClick={() => handleDatePresetSelect('yesterday')}
                    className="py-2 px-3 rounded-xl bg-slate-50 text-slate-700 text-xs font-bold hover:bg-slate-100 transition-colors"
                  >
                    Yesterday
                  </button>
                </div>
                <div className="pt-1 border-t border-slate-100">
                  <label className="text-[11px] font-semibold text-slate-400 block mb-1">
                    Select Custom Date
                  </label>
                  <input
                    type="date"
                    required
                    value={date}
                    onChange={(e) => {
                      setDate(e.target.value);
                      setDatePreset('custom');
                      setShowDatePicker(false);
                    }}
                    className="w-full p-2 bg-slate-50 rounded-xl text-xs font-semibold text-slate-800 border border-slate-200"
                  />
                </div>
              </div>
            )}
          </div>
        </div>

        {/* 5. Wallet & Recurring */}
        <div className="grid grid-cols-2 gap-3 pt-1">
          <div className="bg-white/90 rounded-2xl p-3 border border-white shadow-xs">
            <label className="text-[11px] font-semibold text-slate-400 block mb-1">
              Account / Card
            </label>
            <select
              value={selectedWallet}
              onChange={(e) => setSelectedWallet(e.target.value)}
              className="w-full bg-slate-50 text-xs font-bold text-slate-800 rounded-xl p-2 border border-slate-200 focus:outline-hidden"
            >
              {wallets.map((w) => (
                <option key={w.id} value={w.name}>
                  {w.name}
                </option>
              ))}
            </select>
          </div>

          <div className="bg-white/90 rounded-2xl p-3 border border-white shadow-xs flex flex-col justify-between">
            <div className="flex items-center justify-between">
              <span className="text-[11px] font-semibold text-slate-400">Recurring</span>
              <label className="relative inline-flex items-center cursor-pointer">
                <input
                  type="checkbox"
                  checked={recurring}
                  onChange={(e) => setRecurring(e.target.checked)}
                  className="sr-only peer"
                />
                <div className="w-9 h-5 bg-slate-200 peer-focus:outline-hidden rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-slate-300 after:border after:rounded-full after:h-4 after:w-4 after:transition-all peer-checked:bg-[#704fe6]" />
              </label>
            </div>
            <span className="text-[10px] text-slate-400 mt-1">Repeat monthly</span>
          </div>
        </div>

        {/* 6. Optional Note */}
        <div>
          <label className="text-xs font-semibold text-slate-500 block mb-1.5 pl-0.5">
            Note (Optional)
          </label>
          <input
            type="text"
            maxLength={300}
            placeholder="Add details, receipt memo, etc."
            value={note}
            onChange={(e) => setNote(e.target.value)}
            className="w-full h-11 px-4 bg-white/95 text-slate-800 text-xs font-medium placeholder-slate-400 rounded-2xl border border-white shadow-[0_2px_10px_rgba(30,20,60,0.02)] focus:outline-hidden focus:ring-2 focus:ring-[#704fe6]/20 transition-all"
          />
        </div>

        {/* 7. Primary Action Button */}
        <div className="pt-2">
          <button
            type="submit"
            disabled={!isFormValid || isSubmitting}
            className={`w-full h-12.5 rounded-2xl font-bold text-sm flex items-center justify-center transition-all duration-200 shadow-md cursor-pointer gap-2 ${
              isFormValid && !isSubmitting
                ? 'bg-[#704fe6] hover:bg-[#5e3cdb] text-white shadow-[0_8px_25px_rgba(112,79,230,0.35)] active:scale-[0.99]'
                : 'bg-slate-300/80 text-white/80 cursor-not-allowed shadow-none'
            }`}
          >
            {isSubmitting ? (
              <>
                <RefreshCw size={16} className="animate-spin" />
                <span>Saving to Firestore...</span>
              </>
            ) : (
              <span>Add Expense</span>
            )}
          </button>
        </div>
      </form>
    </div>
  );
};
