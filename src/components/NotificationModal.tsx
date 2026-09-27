import React from 'react';
import {
  X,
  Bell,
  TrendingDown,
  Sparkles,
  CheckCircle2,
  Calendar,
  AlertCircle,
} from 'lucide-react';
import { useExpense } from '../context/ExpenseContext';

export const NotificationModal: React.FC = () => {
  const { isNotificationOpen, setIsNotificationOpen, formatCurrency, selectedMonthSpend } = useExpense();

  if (!isNotificationOpen) return null;

  const notifications = [
    {
      id: 'notif-1',
      title: 'Spending Velocity Insight',
      message: `You are spending 67% below last month's pace! Great financial discipline.`,
      time: '2 hours ago',
      type: 'insight',
      icon: <Sparkles size={16} className="text-[#704fe6]" />,
      bg: 'bg-purple-50',
    },
    {
      id: 'notif-2',
      title: 'Monthly Subscription Renewed',
      message: 'Spotify Subscriptions ($4.99) was auto-debited from Spending Wallet.',
      time: 'Yesterday',
      type: 'bill',
      icon: <Calendar size={16} className="text-blue-600" />,
      bg: 'bg-blue-50',
    },
    {
      id: 'notif-3',
      title: 'Income Direct Deposit',
      message: 'Aura Studio Monthly Salary (+$4,200.00) successfully credited.',
      time: 'Sep 1, 2026',
      type: 'income',
      icon: <CheckCircle2 size={16} className="text-emerald-600" />,
      bg: 'bg-emerald-50',
    },
  ];

  return (
    <div className="fixed inset-0 z-50 bg-black/40 backdrop-blur-xs flex items-end sm:items-center justify-center p-0 sm:p-4">
      <div className="bg-[#f7f5fd] w-full max-w-sm rounded-t-[32px] sm:rounded-3xl p-5 shadow-2xl animate-in slide-in-from-bottom duration-200 border border-white/60">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 rounded-xl bg-purple-100 text-[#704fe6] flex items-center justify-center">
              <Bell size={16} />
            </div>
            <h2 className="text-base font-bold text-slate-900">Notifications</h2>
          </div>
          <button
            onClick={() => setIsNotificationOpen(false)}
            className="w-8 h-8 rounded-full bg-slate-100 hover:bg-slate-200 text-slate-600 flex items-center justify-center cursor-pointer"
          >
            <X size={16} />
          </button>
        </div>

        <div className="space-y-2.5 mb-5 max-h-80 overflow-y-auto no-scrollbar">
          {notifications.map((n) => (
            <div
              key={n.id}
              className="bg-white rounded-2xl p-3.5 shadow-xs border border-slate-100/80 flex items-start gap-3"
            >
              <div className={`w-9 h-9 rounded-xl ${n.bg} flex items-center justify-center shrink-0 mt-0.5`}>
                {n.icon}
              </div>
              <div className="flex-1 min-w-0">
                <div className="text-xs font-bold text-slate-800">{n.title}</div>
                <div className="text-[11px] text-slate-500 mt-0.5 leading-snug">{n.message}</div>
                <div className="text-[10px] text-slate-400 mt-1">{n.time}</div>
              </div>
            </div>
          ))}
        </div>

        <button
          onClick={() => setIsNotificationOpen(false)}
          className="w-full h-11 rounded-xl bg-[#1b1433] hover:bg-[#2c2250] text-white text-xs font-bold transition-colors cursor-pointer"
        >
          Dismiss All
        </button>
      </div>
    </div>
  );
};
