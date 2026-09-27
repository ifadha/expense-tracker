import React from 'react';
import { Home, ReceiptText, BarChart2, User, Plus } from 'lucide-react';
import { useExpense } from '../context/ExpenseContext';
import { ActiveTab } from '../types';

export const BottomNavBar: React.FC = () => {
  const { activeTab, setActiveTab, setIsAddExpenseOpen } = useExpense();

  const navItems: { id: ActiveTab; label: string; icon: React.ReactNode }[] = [
    {
      id: 'home',
      label: 'Home',
      icon: <Home size={20} className={activeTab === 'home' ? 'stroke-[2.5]' : 'stroke-[1.8]'} />,
    },
    {
      id: 'history',
      label: 'Transaction',
      icon: <ReceiptText size={20} className={activeTab === 'history' ? 'stroke-[2.5]' : 'stroke-[1.8]'} />,
    },
    {
      id: 'analytics',
      label: 'Analytics',
      icon: <BarChart2 size={20} className={activeTab === 'analytics' ? 'stroke-[2.5]' : 'stroke-[1.8]'} />,
    },
    {
      id: 'account',
      label: 'Account',
      icon: <User size={20} className={activeTab === 'account' ? 'stroke-[2.5]' : 'stroke-[1.8]'} />,
    },
  ];

  return (
    <div className="relative z-30 px-4 pb-4 pt-1">
      <div className="relative bg-white/95 backdrop-blur-md rounded-[28px] shadow-[0_10px_35px_rgba(40,25,80,0.08)] border border-white/80 px-2 py-2 flex items-center justify-between">
        {/* Left two tabs */}
        <div className="flex items-center justify-around w-[42%]">
          {navItems.slice(0, 2).map((item) => {
            const isActive = activeTab === item.id;
            return (
              <button
                key={item.id}
                onClick={() => setActiveTab(item.id)}
                className={`flex flex-col items-center justify-center min-h-[48px] min-w-[52px] py-1 px-2 rounded-2xl transition-all duration-200 cursor-pointer ${
                  isActive
                    ? 'text-[#704fe6]'
                    : 'text-slate-500 hover:text-slate-750'
                }`}
                aria-label={item.label}
              >
                <div className="relative">
                  {item.icon}
                  {isActive && (
                    <span className="absolute -bottom-1 left-1/2 -translate-x-1/2 w-1.5 h-1.5 bg-[#704fe6] rounded-full" />
                  )}
                </div>
                <span className={`text-[10px] mt-1 tracking-tight ${isActive ? 'font-bold text-[#704fe6]' : 'font-medium text-slate-500'}`}>
                  {item.label}
                </span>
              </button>
            );
          })}
        </div>

        {/* Center Floating Action Button (FAB) */}
        <div className="absolute left-1/2 -top-5 -translate-x-1/2 flex items-center justify-center">
          <button
            onClick={() => setIsAddExpenseOpen(true)}
            aria-label="Add new expense"
            className="w-13 h-13 rounded-full bg-[#1b1433] hover:bg-[#2c2250] text-white flex items-center justify-center shadow-[0_8px_20px_rgba(27,20,51,0.35)] active:scale-95 transition-all duration-200 cursor-pointer group border-3 border-[#f0edf9]"
          >
            <Plus size={24} className="stroke-[2.8] transition-transform duration-200 group-hover:rotate-90" />
          </button>
        </div>

        {/* Spacer for FAB */}
        <div className="w-12 shrink-0 pointer-events-none" />

        {/* Right two tabs */}
        <div className="flex items-center justify-around w-[42%]">
          {navItems.slice(2, 4).map((item) => {
            const isActive = activeTab === item.id;
            return (
              <button
                key={item.id}
                onClick={() => setActiveTab(item.id)}
                className={`flex flex-col items-center justify-center min-h-[48px] min-w-[52px] py-1 px-2 rounded-2xl transition-all duration-200 cursor-pointer ${
                  isActive
                    ? 'text-[#704fe6]'
                    : 'text-slate-500 hover:text-slate-750'
                }`}
                aria-label={item.label}
              >
                <div className="relative">
                  {item.icon}
                  {isActive && (
                    <span className="absolute -bottom-1 left-1/2 -translate-x-1/2 w-1.5 h-1.5 bg-[#704fe6] rounded-full" />
                  )}
                </div>
                <span className={`text-[10px] mt-1 tracking-tight ${isActive ? 'font-bold text-[#704fe6]' : 'font-medium text-slate-500'}`}>
                  {item.label}
                </span>
              </button>
            );
          })}
        </div>
      </div>
    </div>
  );
};
