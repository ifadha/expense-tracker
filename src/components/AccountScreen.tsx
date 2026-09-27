import React, { useState } from 'react';
import {
  User,
  Wallet as WalletIcon,
  CreditCard,
  PiggyBank,
  DollarSign,
  Bell,
  Shield,
  RotateCcw,
  Check,
  ChevronRight,
  Sliders,
  Smartphone,
} from 'lucide-react';
import { useExpense } from '../context/ExpenseContext';

export const AccountScreen: React.FC = () => {
  const {
    wallets,
    currency,
    setCurrency,
    monthlyBudget,
    setMonthlyBudget,
    resetToDemoData,
    formatCurrency,
    setIsWalletModalOpen,
    setIsNotificationOpen,
    setActiveTab,
  } = useExpense();

  const [budgetInput, setBudgetInput] = useState(monthlyBudget.toString());
  const [isSaved, setIsSaved] = useState(false);

  const currencies = [
    { symbol: '$', label: 'USD ($)' },
    { symbol: '€', label: 'EUR (€)' },
    { symbol: '£', label: 'GBP (£)' },
    { symbol: '¥', label: 'JPY (¥)' },
    { symbol: '₹', label: 'INR (₹)' },
    { symbol: 'C$', label: 'CAD (C$)' },
    { symbol: 'Rs.', label: 'LKR (Rs.)' },
  ];

  const handleUpdateBudget = (e: React.FormEvent) => {
    e.preventDefault();
    const val = parseFloat(budgetInput);
    if (!isNaN(val) && val > 0) {
      setMonthlyBudget(val);
      setIsSaved(true);
      setTimeout(() => setIsSaved(false), 2000);
    }
  };

  return (
    <div className="flex-1 overflow-y-auto no-scrollbar px-5 pb-8 pt-2">
      {/* Title */}
      <div className="text-center py-2 mb-3">
        <h1 className="text-base font-bold text-slate-900 tracking-tight">
          Account & Settings
        </h1>
      </div>

      {/* User Profile Card */}
      <div className="bg-white/95 rounded-3xl p-4.5 shadow-[0_4px_20px_rgba(30,20,60,0.03)] border border-white/80 mb-5 flex items-center gap-3.5">
        <div className="w-14 h-14 rounded-2xl bg-gradient-to-tr from-[#704fe6] to-[#a855f7] text-white flex items-center justify-center font-bold text-xl shadow-sm">
          IF
        </div>
        <div className="min-w-0 flex-1">
          <h2 className="text-base font-bold text-slate-900 truncate">
            Ifadha
          </h2>
        </div>
      </div>

      {/* Currency Switcher */}
      <div className="bg-white/95 rounded-3xl p-4.5 shadow-[0_4px_20px_rgba(30,20,60,0.03)] border border-white/80 mb-5">
        <h3 className="text-xs font-bold text-slate-800 mb-2.5">
          Display Currency
        </h3>
        <div className="flex items-center gap-2 flex-wrap">
          {currencies.map((c) => (
            <button
              key={c.symbol}
              onClick={() => setCurrency(c.symbol)}
              className={`px-3.5 py-2 rounded-xl text-xs font-bold transition-all cursor-pointer min-h-[38px] ${
                currency === c.symbol
                  ? 'bg-[#1b1433] text-white shadow-xs'
                  : 'bg-slate-100 hover:bg-slate-200 text-slate-700'
              }`}
            >
              {c.label}
            </button>
          ))}
        </div>
      </div>

      {/* Monthly Budget Goal Editor */}
      <div className="bg-white/95 rounded-3xl p-4.5 shadow-[0_4px_20px_rgba(30,20,60,0.03)] border border-white/80 mb-5">
        <h3 className="text-xs font-bold text-slate-800 mb-1">
          Monthly Target Budget
        </h3>
        <p className="text-xs text-slate-500 mb-3">
          Used to calculate progress bars and spending velocity warnings.
        </p>

        <form onSubmit={handleUpdateBudget} className="flex items-center gap-2">
          <div className="relative flex-1">
            <span className="absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 font-mono text-sm font-semibold">
              {currency}
            </span>
            <input
              type="number"
              min="100"
              step="50"
              value={budgetInput}
              onChange={(e) => setBudgetInput(e.target.value)}
              className="w-full h-11 pl-9 pr-3 bg-slate-50 rounded-xl text-sm font-bold text-slate-800 border border-slate-200 focus:outline-hidden focus:ring-2 focus:ring-[#704fe6]/20 font-mono"
            />
          </div>
          <button
            type="submit"
            className="h-11 px-4.5 bg-[#704fe6] hover:bg-[#5b3dc9] text-white text-xs font-bold rounded-xl transition-all cursor-pointer flex items-center gap-1.5 shadow-xs"
          >
            {isSaved ? <Check size={15} /> : 'Save'}
          </button>
        </form>
      </div>

      {/* Wallets & Accounts overview */}
      <div className="bg-white/95 rounded-3xl p-4.5 shadow-[0_4px_20px_rgba(30,20,60,0.03)] border border-white/80 mb-5">
        <div className="flex items-center justify-between mb-3">
          <h3 className="text-xs font-bold text-slate-700">Connected Wallets</h3>
          <button
            onClick={() => setIsWalletModalOpen(true)}
            className="text-xs font-semibold text-[#704fe6] cursor-pointer"
          >
            Manage
          </button>
        </div>

        <div className="space-y-2">
          {wallets.map((w) => (
            <div
              key={w.id}
              onClick={() => setIsWalletModalOpen(true)}
              className="flex items-center justify-between p-2.5 rounded-xl hover:bg-slate-50 transition-colors cursor-pointer border border-slate-100"
            >
              <div className="flex items-center gap-2.5">
                <div
                  className="w-8 h-8 rounded-lg flex items-center justify-center text-white"
                  style={{ backgroundColor: w.color }}
                >
                  <WalletIcon size={16} />
                </div>
                <div>
                  <div className="text-xs font-bold text-slate-800">{w.name}</div>
                  <div className="text-[10px] text-slate-400 capitalize">{w.type}</div>
                </div>
              </div>
              <span className="text-xs font-bold font-mono text-slate-900">
                {formatCurrency(w.balance)}
              </span>
            </div>
          ))}
        </div>
      </div>

      {/* Quick Action links */}
      <div className="bg-white/95 rounded-3xl p-2 shadow-[0_4px_20px_rgba(30,20,60,0.03)] border border-white/80 mb-5 divide-y divide-slate-100">
        <button
          onClick={() => setIsNotificationOpen(true)}
          className="w-full p-3 flex items-center justify-between hover:bg-slate-50 rounded-xl transition-colors text-left cursor-pointer"
        >
          <div className="flex items-center gap-3">
            <Bell size={18} className="text-slate-500" />
            <span className="text-xs font-semibold text-slate-700">Notifications & Alerts</span>
          </div>
          <ChevronRight size={16} className="text-slate-400" />
        </button>

        <button
          onClick={() => {
            if (confirm('Reset transactions and categories to default demo state?')) {
              resetToDemoData();
            }
          }}
          className="w-full p-3 flex items-center justify-between hover:bg-rose-50 rounded-xl transition-colors text-left cursor-pointer text-rose-600 group"
        >
          <div className="flex items-center gap-3">
            <RotateCcw size={18} className="group-hover:rotate-180 transition-transform duration-300" />
            <span className="text-xs font-semibold">Reset to Demo Transactions</span>
          </div>
          <ChevronRight size={16} className="text-rose-400" />
        </button>
      </div>

      <div className="text-center text-[11px] text-slate-400">
        Lumina Expense Tracker v2.4 · Production Mobile Release
      </div>
    </div>
  );
};
