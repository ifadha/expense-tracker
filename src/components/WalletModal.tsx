import React, { useState } from 'react';
import {
  X,
  Wallet as WalletIcon,
  Check,
  Plus,
  ArrowUpRight,
  CreditCard,
  PiggyBank,
  DollarSign,
} from 'lucide-react';
import { useExpense } from '../context/ExpenseContext';

export const WalletModal: React.FC = () => {
  const {
    wallets,
    activeWallet,
    setActiveWalletId,
    formatCurrency,
    isWalletModalOpen,
    setIsWalletModalOpen,
  } = useExpense();

  const [topUpAmount, setTopUpAmount] = useState('');
  const [showTopUp, setShowTopUp] = useState(false);

  if (!isWalletModalOpen) return null;

  return (
    <div className="fixed inset-0 z-50 bg-black/40 backdrop-blur-xs flex items-end sm:items-center justify-center p-0 sm:p-4">
      <div className="bg-[#f7f5fd] w-full max-w-sm rounded-t-[32px] sm:rounded-3xl p-5 shadow-2xl animate-in slide-in-from-bottom duration-200 border border-white/60">
        {/* Header */}
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 rounded-xl bg-purple-100 text-[#704fe6] flex items-center justify-center">
              <WalletIcon size={16} />
            </div>
            <h2 className="text-base font-bold text-slate-900">
              Wallets & Accounts
            </h2>
          </div>
          <button
            onClick={() => setIsWalletModalOpen(false)}
            className="w-8 h-8 rounded-full bg-slate-100 hover:bg-slate-200 text-slate-600 flex items-center justify-center cursor-pointer"
          >
            <X size={16} />
          </button>
        </div>

        {/* Wallets List */}
        <div className="space-y-2.5 mb-5">
          {wallets.map((w) => {
            const isActive = activeWallet.id === w.id;

            return (
              <button
                key={w.id}
                onClick={() => {
                  setActiveWalletId(w.id);
                  setIsWalletModalOpen(false);
                }}
                className={`w-full p-3.5 rounded-2xl flex items-center justify-between border transition-all cursor-pointer text-left ${
                  isActive
                    ? 'bg-white border-[#704fe6] shadow-sm ring-1 ring-[#704fe6]/20'
                    : 'bg-white/80 hover:bg-white border-slate-100'
                }`}
              >
                <div className="flex items-center gap-3">
                  <div
                    className="w-10 h-10 rounded-xl flex items-center justify-center text-white shrink-0"
                    style={{ backgroundColor: w.color }}
                  >
                    <WalletIcon size={18} />
                  </div>
                  <div>
                    <div className="text-sm font-bold text-slate-800 flex items-center gap-1.5">
                      <span>{w.name}</span>
                      {isActive && (
                        <span className="text-[10px] bg-[#f4f0ff] text-[#704fe6] px-1.5 py-0.5 rounded-full font-semibold">
                          Active
                        </span>
                      )}
                    </div>
                    <div className="text-[11px] text-slate-400 capitalize">
                      {w.type} account
                    </div>
                  </div>
                </div>

                <div className="flex items-center gap-2">
                  <span className="text-sm font-extrabold font-mono tabular-nums text-slate-900">
                    {formatCurrency(w.balance)}
                  </span>
                  {isActive && <Check size={16} className="text-[#704fe6]" />}
                </div>
              </button>
            );
          })}
        </div>

        <button
          onClick={() => setIsWalletModalOpen(false)}
          className="w-full h-11 rounded-xl bg-[#1b1433] hover:bg-[#2c2250] text-white text-xs font-bold transition-colors cursor-pointer"
        >
          Done
        </button>
      </div>
    </div>
  );
};
