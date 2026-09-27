import React, { useState } from 'react';
import {
  X,
  Trash2,
  Check,
  ChevronRight,
  AlertTriangle,
  RefreshCw,
} from 'lucide-react';
import { useExpense } from '../context/ExpenseContext';
import { CategoryIcon } from './CategoryIcon';
import { Transaction, TransactionType } from '../types';

export const EditExpenseModal: React.FC = () => {
  const {
    editingTransaction,
    setEditingTransaction,
    updateTransaction,
    deleteTransaction,
    categories,
    wallets,
    currency,
    getCategoryById,
  } = useExpense();

  if (!editingTransaction) return null;

  const [type, setType] = useState<TransactionType>(editingTransaction.type);
  const [amountStr, setAmountStr] = useState<string>(editingTransaction.amount.toString());
  const [title, setTitle] = useState<string>(editingTransaction.title);
  const [categoryId, setCategoryId] = useState<string>(editingTransaction.categoryId);
  const [wallet, setWallet] = useState<string>(editingTransaction.wallet);
  const [date, setDate] = useState<string>(editingTransaction.date);
  const [note, setNote] = useState<string>(editingTransaction.note || '');
  const [recurring, setRecurring] = useState<boolean>(!!editingTransaction.recurring);
  const [showDeleteConfirm, setShowDeleteConfirm] = useState(false);
  const [isChangingCategory, setIsChangingCategory] = useState(false);

  // Loading and Error states
  const [isSaving, setIsSaving] = useState(false);
  const [isDeleting, setIsDeleting] = useState(false);
  const [errorMessage, setErrorMessage] = useState('');

  const selectedCategory = getCategoryById(categoryId);

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    setErrorMessage('');

    // Validation
    const parsedAmount = parseFloat(amountStr);
    if (isNaN(parsedAmount) || parsedAmount <= 0) {
      setErrorMessage('Please enter a valid amount greater than 0');
      return;
    }

    if (!title.trim()) {
      setErrorMessage('Please enter a title or description');
      return;
    }

    if (!date) {
      setErrorMessage('Please select a valid date');
      return;
    }

    try {
      setIsSaving(true);
      await updateTransaction(editingTransaction.id, {
        title: title.trim(),
        amount: parsedAmount,
        type,
        categoryId,
        wallet,
        date,
        note: note.trim() || undefined,
        recurring,
      });
      setIsSaving(false);
      setEditingTransaction(null);
    } catch (err) {
      setIsSaving(false);
      setErrorMessage('Failed to update expense in Firestore.');
    }
  };

  const handleDelete = async () => {
    try {
      setIsDeleting(true);
      await deleteTransaction(editingTransaction.id);
      setIsDeleting(false);
      setEditingTransaction(null);
    } catch (err) {
      setIsDeleting(false);
      setErrorMessage('Failed to delete expense from Firestore.');
    }
  };

  return (
    <div className="fixed inset-0 z-50 bg-black/40 backdrop-blur-xs flex items-end sm:items-center justify-center p-0 sm:p-4">
      <div className="bg-[#f7f5fd] w-full max-w-md max-h-[92vh] rounded-t-[32px] sm:rounded-3xl flex flex-col overflow-hidden shadow-2xl animate-in slide-in-from-bottom duration-200 border border-white/60">
        {/* Header */}
        <div className="px-5 pt-4 pb-3 flex items-center justify-between border-b border-slate-200/50">
          <button
            onClick={() => setEditingTransaction(null)}
            disabled={isSaving || isDeleting}
            className="w-9 h-9 rounded-full bg-white/80 hover:bg-white text-slate-700 flex items-center justify-center shadow-xs cursor-pointer disabled:opacity-50"
          >
            <X size={17} />
          </button>

          <h2 className="text-base font-bold text-slate-900">
            Edit Expense
          </h2>

          <button
            onClick={() => setShowDeleteConfirm(true)}
            disabled={isSaving || isDeleting}
            className="w-9 h-9 rounded-full bg-rose-50 hover:bg-rose-100 text-rose-600 flex items-center justify-center shadow-xs cursor-pointer disabled:opacity-50"
            aria-label="Delete"
          >
            <Trash2 size={16} />
          </button>
        </div>

        {/* Delete Confirmation Banner */}
        {showDeleteConfirm && (
          <div className="bg-rose-50 border-b border-rose-200 p-4 flex flex-col gap-2 animate-in fade-in duration-150">
            <div className="flex items-center gap-2 text-rose-800 text-xs font-semibold">
              <AlertTriangle size={16} />
              <span>Permanently delete this expense from Cloud Firestore?</span>
            </div>
            <div className="flex items-center gap-2 mt-1">
              <button
                type="button"
                disabled={isDeleting}
                onClick={() => setShowDeleteConfirm(false)}
                className="flex-1 py-1.5 bg-white text-slate-700 text-xs font-semibold rounded-lg border border-slate-200 hover:bg-slate-50 cursor-pointer"
              >
                Cancel
              </button>
              <button
                type="button"
                disabled={isDeleting}
                onClick={handleDelete}
                className="flex-1 py-1.5 bg-rose-600 text-white text-xs font-semibold rounded-lg hover:bg-rose-700 cursor-pointer shadow-xs flex items-center justify-center gap-1"
              >
                {isDeleting ? (
                  <RefreshCw size={13} className="animate-spin" />
                ) : (
                  <span>Yes, Delete</span>
                )}
              </button>
            </div>
          </div>
        )}

        {/* Error message */}
        {errorMessage && (
          <div className="px-5 pt-3">
            <div className="bg-rose-100 border border-rose-200 text-rose-700 text-xs font-medium p-2.5 rounded-xl">
              {errorMessage}
            </div>
          </div>
        )}

        {/* Scrollable Form */}
        <form onSubmit={handleSave} className="flex-1 overflow-y-auto no-scrollbar p-5 space-y-4">
          {/* Expense/Income Toggle */}
          <div className="flex items-center justify-center">
            <div className="flex items-center p-1 bg-white rounded-full border border-slate-200/60 shadow-xs">
              <button
                type="button"
                onClick={() => setType('expense')}
                className={`px-4 py-1 text-xs font-bold rounded-full transition-all cursor-pointer ${
                  type === 'expense'
                    ? 'bg-[#ff4866] text-white shadow-xs'
                    : 'text-slate-600'
                }`}
              >
                Expense
              </button>
              <button
                type="button"
                onClick={() => setType('income')}
                className={`px-4 py-1 text-xs font-bold rounded-full transition-all cursor-pointer ${
                  type === 'income'
                    ? 'bg-[#10b981] text-white shadow-xs'
                    : 'text-slate-600'
                }`}
              >
                Income
              </button>
            </div>
          </div>

          {/* Amount Input */}
          <div className="text-center py-1">
            <span className="text-xs font-medium text-slate-400">Amount *</span>
            <div className="flex items-center justify-center gap-1">
              <span className="text-2xl font-bold text-slate-400 font-mono">
                {currency}
              </span>
              <input
                type="number"
                step="0.01"
                min="0.01"
                required
                value={amountStr}
                onChange={(e) => {
                  setAmountStr(e.target.value);
                  setErrorMessage('');
                }}
                className="text-3xl font-extrabold text-slate-900 font-mono text-center bg-transparent border-none focus:outline-hidden w-44"
              />
            </div>
          </div>

          {/* Title Input */}
          <div className="bg-white rounded-2xl p-3.5 shadow-xs border border-white">
            <label className="text-xs font-semibold text-slate-400 block mb-1">
              Expense Title *
            </label>
            <input
              type="text"
              required
              maxLength={120}
              value={title}
              onChange={(e) => {
                setTitle(e.target.value);
                setErrorMessage('');
              }}
              className="w-full h-10 px-3 bg-slate-50 rounded-xl text-sm font-semibold text-slate-800 border border-slate-200 focus:outline-hidden focus:ring-2 focus:ring-[#704fe6]/20"
            />
          </div>

          {/* Category Picker Selector */}
          <div className="bg-white rounded-2xl p-3.5 shadow-xs border border-white">
            <div className="flex items-center justify-between mb-2">
              <span className="text-xs font-semibold text-slate-400">Category *</span>
              <button
                type="button"
                onClick={() => setIsChangingCategory(!isChangingCategory)}
                className="text-xs font-semibold text-[#704fe6] cursor-pointer"
              >
                {isChangingCategory ? 'Done' : 'Change'}
              </button>
            </div>

            <div className="flex items-center gap-3">
              <div
                className="w-10 h-10 rounded-xl flex items-center justify-center shadow-xs"
                style={{
                  backgroundColor: selectedCategory.bgLight,
                  color: selectedCategory.color,
                }}
              >
                <CategoryIcon
                  iconName={selectedCategory.iconName}
                  size={18}
                  color={selectedCategory.color}
                />
              </div>
              <span className="text-sm font-bold text-slate-800">
                {selectedCategory.name}
              </span>
            </div>

            {/* In-line category selector grid when changing */}
            {isChangingCategory && (
              <div className="grid grid-cols-4 gap-2 pt-3 mt-3 border-t border-slate-100 max-h-44 overflow-y-auto no-scrollbar">
                {categories.map((c) => (
                  <button
                    key={c.id}
                    type="button"
                    onClick={() => {
                      setCategoryId(c.id);
                      setIsChangingCategory(false);
                    }}
                    className={`p-2 rounded-xl flex flex-col items-center gap-1 border transition-all cursor-pointer ${
                      categoryId === c.id
                        ? 'border-[#704fe6] bg-purple-50/50'
                        : 'border-slate-100 hover:bg-slate-50'
                    }`}
                  >
                    <div
                      className="w-8 h-8 rounded-lg flex items-center justify-center"
                      style={{ backgroundColor: c.bgLight, color: c.color }}
                    >
                      <CategoryIcon iconName={c.iconName} size={15} color={c.color} />
                    </div>
                    <span className="text-[10px] font-medium text-slate-700 truncate w-full text-center">
                      {c.name}
                    </span>
                  </button>
                ))}
              </div>
            )}
          </div>

          {/* Wallet & Date */}
          <div className="grid grid-cols-2 gap-3">
            <div className="bg-white rounded-2xl p-3 shadow-xs border border-white">
              <label className="text-[11px] font-semibold text-slate-400 block mb-1">
                Wallet / Account
              </label>
              <select
                value={wallet}
                onChange={(e) => setWallet(e.target.value)}
                className="w-full bg-slate-50 text-xs font-semibold text-slate-800 rounded-lg p-2 border border-slate-200 focus:outline-hidden"
              >
                {wallets.map((w) => (
                  <option key={w.id} value={w.name}>
                    {w.name}
                  </option>
                ))}
              </select>
            </div>

            <div className="bg-white rounded-2xl p-3 shadow-xs border border-white">
              <label className="text-[11px] font-semibold text-slate-400 block mb-1">
                Date *
              </label>
              <input
                type="date"
                required
                value={date}
                onChange={(e) => setDate(e.target.value)}
                className="w-full bg-slate-50 text-xs font-semibold text-slate-800 rounded-lg p-2 border border-slate-200 focus:outline-hidden"
              />
            </div>
          </div>

          {/* Notes */}
          <div className="bg-white rounded-2xl p-3.5 shadow-xs border border-white">
            <label className="text-xs font-semibold text-slate-400 block mb-1">
              Note (Optional)
            </label>
            <input
              type="text"
              maxLength={300}
              placeholder="Add note or memo"
              value={note}
              onChange={(e) => setNote(e.target.value)}
              className="w-full h-10 px-3 bg-slate-50 rounded-xl text-sm font-medium text-slate-800 border border-slate-200 focus:outline-hidden"
            />
          </div>

          {/* Save Button */}
          <div className="pt-2">
            <button
              type="submit"
              disabled={isSaving || isDeleting}
              className="w-full h-12 rounded-xl bg-[#1b1433] hover:bg-[#2c2250] text-white font-bold text-sm flex items-center justify-center shadow-md active:scale-[0.99] transition-all cursor-pointer disabled:opacity-50 gap-2"
            >
              {isSaving ? (
                <>
                  <RefreshCw size={15} className="animate-spin" />
                  <span>Saving to Firestore...</span>
                </>
              ) : (
                <span>Update Expense</span>
              )}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};
