import React, { useState, useMemo } from 'react';
import {
  ChevronDown,
  PiggyBank,
  Receipt,
  TrendingUp,
  TrendingDown,
  ArrowUpRight,
  ArrowDownRight,
  Sparkles,
  PieChart as PieIcon,
  BarChart2,
} from 'lucide-react';
import { useExpense } from '../context/ExpenseContext';
import { CategoryIcon } from './CategoryIcon';

export const AnalyticsScreen: React.FC = () => {
  const {
    transactions,
    selectedMonthSpend,
    selectedMonthIncome,
    formatCurrency,
    categorySpendBreakdown,
    getCategoryById,
    setEditingTransaction,
  } = useExpense();

  const [timeframe, setTimeframe] = useState<'Monthly' | 'Weekly' | 'Yearly'>('Monthly');
  const [selectedBarMonth, setSelectedBarMonth] = useState<string | null>(null);

  // Generate 6 months of historical comparisons for the dual bar chart
  const chartData = useMemo(() => {
    const months = ['Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'];
    // Default baseline values matching the aesthetic proportion of reference image
    const baseline = [
      { month: 'Feb', income: 4200, expense: 3100 },
      { month: 'Mar', income: 4500, expense: 2800 },
      { month: 'Apr', income: 4100, expense: 3450 },
      { month: 'May', income: 5200, expense: 3200 },
      { month: 'Jun', income: 4800, expense: 2900 },
      { month: 'Jul', income: 5600, expense: selectedMonthSpend > 0 ? selectedMonthSpend : 3800 },
    ];
    return baseline;
  }, [selectedMonthSpend]);

  const maxVal = Math.max(
    ...chartData.map((d) => Math.max(d.income, d.expense)),
    6000
  );

  // Group transactions for the history section below the chart
  const groupedTransactions = useMemo(() => {
    const map = new Map<string, typeof transactions>();
    transactions.slice(0, 10).forEach((tx) => {
      const existing = map.get(tx.date) || [];
      existing.push(tx);
      map.set(tx.date, existing);
    });
    return Array.from(map.entries()).sort(
      (a, b) => new Date(b[0]).getTime() - new Date(a[0]).getTime()
    );
  }, [transactions]);

  const totalAllIncome = chartData.reduce((acc, curr) => acc + curr.income, 0);
  const totalAllExpense = chartData.reduce((acc, curr) => acc + curr.expense, 0);
  const netSaved = totalAllIncome - totalAllExpense;

  return (
    <div className="flex-1 overflow-y-auto no-scrollbar px-5 pb-8 pt-2">
      {/* Title */}
      <div className="text-center py-2 mb-2">
        <h1 className="text-base font-bold text-slate-900 tracking-tight">
          Analytics
        </h1>
      </div>

      {/* Main Chart Card */}
      <div className="bg-white/95 rounded-3xl p-5 shadow-[0_8px_30px_rgba(30,20,60,0.04)] border border-white/80 mb-5">
        {/* Controls row: Dropdown + Legend */}
        <div className="flex items-center justify-between mb-6">
          {/* Timeframe selector pill */}
          <div className="relative inline-block">
            <select
              value={timeframe}
              onChange={(e) => setTimeframe(e.target.value as any)}
              className="appearance-none bg-slate-50 hover:bg-slate-100 text-slate-700 text-xs font-semibold px-3 py-1.5 pr-7 rounded-xl border border-slate-200/70 focus:outline-hidden cursor-pointer transition-colors"
            >
              <option value="Weekly">Weekly</option>
              <option value="Monthly">Monthly</option>
              <option value="Yearly">Yearly</option>
            </select>
            <ChevronDown
              size={14}
              className="absolute right-2 top-1/2 -translate-y-1/2 text-slate-400 pointer-events-none"
            />
          </div>

          {/* Legend */}
          <div className="flex items-center gap-3 text-xs font-medium text-slate-600">
            <div className="flex items-center gap-1.5">
              <span className="w-2.5 h-2.5 rounded-full bg-[#8b5cf6]" />
              <span className="text-[11px]">Income</span>
            </div>
            <div className="flex items-center gap-1.5">
              <span className="w-2.5 h-2.5 rounded-full bg-[#84cc16]" />
              <span className="text-[11px]">Expense</span>
            </div>
          </div>
        </div>

        {/* Dual Bar Chart */}
        <div className="relative h-44 flex items-end justify-between pt-6 pb-2 px-1">
          {/* Subtle horizontal grid lines */}
          <div className="absolute inset-x-0 top-6 border-b border-slate-100 border-dashed" />
          <div className="absolute inset-x-0 top-20 border-b border-slate-100 border-dashed" />
          <div className="absolute inset-x-0 top-32 border-b border-slate-100 border-dashed" />

          {/* Left Y-axis labels */}
          <div className="absolute left-0 top-0 bottom-4 flex flex-col justify-between text-[10px] text-slate-400 font-mono pointer-events-none select-none">
            <span>{formatCurrency(Math.round(maxVal))}</span>
            <span>{formatCurrency(Math.round(maxVal * 0.6))}</span>
            <span>{formatCurrency(Math.round(maxVal * 0.3))}</span>
            <span>{formatCurrency(0)}</span>
          </div>

          {/* Bar Groups */}
          <div className="flex-1 flex items-end justify-around pl-8 h-full">
            {chartData.map((d) => {
              const incomeHeight = Math.max(15, (d.income / maxVal) * 100);
              const expenseHeight = Math.max(15, (d.expense / maxVal) * 100);
              const isSelected = selectedBarMonth === d.month;

              return (
                <div
                  key={d.month}
                  onClick={() =>
                    setSelectedBarMonth(selectedBarMonth === d.month ? null : d.month)
                  }
                  className="flex flex-col items-center cursor-pointer group"
                >
                  {/* Tooltip if active */}
                  {isSelected && (
                    <div className="absolute -top-6 bg-slate-900/95 backdrop-blur-xs text-white text-[10px] font-mono px-2.5 py-1 rounded-lg shadow-xl pointer-events-none whitespace-nowrap z-20 border border-white/10 animate-in fade-in zoom-in-95 duration-100">
                      Inc: {formatCurrency(d.income)} · Exp: {formatCurrency(d.expense)}
                    </div>
                  )}

                  {/* Dual Bars Container */}
                  <div className="flex items-end gap-1.5 h-34 pb-1">
                    {/* Expense Bar (Lime Green) */}
                    <div
                      style={{ height: `${expenseHeight}%` }}
                      className="w-2.5 sm:w-3 rounded-full bg-[#84cc16] hover:bg-[#65a30d] transition-all duration-300"
                    />

                    {/* Income Bar (Purple) */}
                    <div
                      style={{ height: `${incomeHeight}%` }}
                      className="w-2.5 sm:w-3 rounded-full bg-[#8b5cf6] hover:bg-[#7c3aed] transition-all duration-300"
                    />
                  </div>

                  {/* Month Label */}
                  <span
                    className={`text-[11px] font-medium mt-1 transition-colors ${
                      isSelected ? 'text-[#8b5cf6] font-bold' : 'text-slate-500'
                    }`}
                  >
                    {d.month}
                  </span>
                </div>
              );
            })}
          </div>
        </div>

        {/* 2 Bottom Metric Cards (Matching reference screenshot exactly!) */}
        <div className="grid grid-cols-2 gap-3 mt-4 pt-3 border-t border-slate-100">
          {/* Income Card */}
          <div className="bg-[#faf8ff] rounded-2xl p-3 flex items-center gap-2.5 border border-purple-100/50">
            <div className="w-10 h-10 rounded-xl bg-purple-100/80 text-[#8b5cf6] flex items-center justify-center shrink-0">
              <PiggyBank size={20} className="stroke-[2]" />
            </div>
            <div>
              <div className="text-[13px] font-extrabold text-slate-800 font-mono tabular-nums leading-tight">
                {formatCurrency(totalAllIncome)}
              </div>
              <div className="text-[11px] text-slate-500 font-medium">Income</div>
            </div>
          </div>

          {/* Expenses Card */}
          <div className="bg-[#f7fdf7] rounded-2xl p-3 flex items-center gap-2.5 border border-emerald-100/50">
            <div className="w-10 h-10 rounded-xl bg-emerald-100/80 text-[#16a34a] flex items-center justify-center shrink-0">
              <Receipt size={20} className="stroke-[2]" />
            </div>
            <div>
              <div className="text-[13px] font-extrabold text-slate-800 font-mono tabular-nums leading-tight">
                {formatCurrency(totalAllExpense)}
              </div>
              <div className="text-[11px] text-slate-500 font-medium">Expenses</div>
            </div>
          </div>
        </div>
      </div>

      {/* Category Spend Share breakdown */}
      <div className="bg-white/95 rounded-3xl p-4.5 shadow-[0_4px_20px_rgba(30,20,60,0.03)] border border-white/80 mb-5">
        <h3 className="text-sm font-bold text-slate-800 mb-3 flex items-center justify-between">
          <span>Top Categories</span>
          <span className="text-xs font-normal text-slate-400">By Spending</span>
        </h3>

        <div className="space-y-3">
          {categorySpendBreakdown.slice(0, 4).map((item) => (
            <div key={item.category.id} className="space-y-1">
              <div className="flex items-center justify-between text-xs">
                <div className="flex items-center gap-2">
                  <div
                    className="w-6 h-6 rounded-lg flex items-center justify-center"
                    style={{ backgroundColor: item.category.bgLight, color: item.category.color }}
                  >
                    <CategoryIcon iconName={item.category.iconName} size={14} color={item.category.color} />
                  </div>
                  <span className="font-semibold text-slate-700">{item.category.name}</span>
                </div>
                <div className="flex items-center gap-2">
                  <span className="font-mono text-slate-500 text-[11px]">
                    {formatCurrency(item.total)}
                  </span>
                  <span className="font-bold text-slate-900 text-xs w-8 text-right">
                    {item.percentage}%
                  </span>
                </div>
              </div>
              <div className="w-full h-1.5 bg-slate-100 rounded-full overflow-hidden">
                <div
                  className="h-full rounded-full transition-all duration-300"
                  style={{
                    width: `${Math.max(5, item.percentage)}%`,
                    backgroundColor: item.category.color,
                  }}
                />
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* History section (like bottom of Screen 3) */}
      <div className="space-y-3">
        <h2 className="text-sm font-bold text-slate-900 px-1">
          History
        </h2>

        {groupedTransactions.slice(0, 4).map(([date, txs]) => {
          const totalSpent = txs
            .filter((t) => t.type === 'expense')
            .reduce((sum, t) => sum + t.amount, 0);
          const totalEarned = txs
            .filter((t) => t.type === 'income')
            .reduce((sum, t) => sum + t.amount, 0);

          let displayDate = date;
          try {
            const [y, m, d] = date.split('-');
            displayDate = new Intl.DateTimeFormat('en-US', {
              day: 'numeric',
              month: 'long',
              year: 'numeric',
            }).format(new Date(parseInt(y), parseInt(m) - 1, parseInt(d)));
          } catch {}

          return (
            <div
              key={date}
              className="bg-white/90 rounded-2xl p-3.5 shadow-xs border border-white/80"
            >
              <div className="flex items-center justify-between text-xs pb-2 border-b border-slate-100">
                <div>
                  <div className="text-[10px] text-slate-400 font-medium">Date</div>
                  <div className="font-bold text-slate-800">{displayDate}</div>
                </div>

                <div className="text-right font-mono tabular-nums">
                  {totalSpent > 0 && (
                    <div className="text-rose-500 font-bold">
                      -{formatCurrency(totalSpent)}
                    </div>
                  )}
                  {totalEarned > 0 && (
                    <div className="text-emerald-600 font-bold">
                      +{formatCurrency(totalEarned)}
                    </div>
                  )}
                </div>
              </div>

              {/* Transactions in this day */}
              <div className="pt-2 space-y-2">
                {txs.map((tx) => {
                  const cat = getCategoryById(tx.categoryId);
                  return (
                    <div
                      key={tx.id}
                      onClick={() => setEditingTransaction(tx)}
                      className="flex items-center justify-between text-xs py-0.5 hover:bg-slate-50/50 rounded-lg px-1 cursor-pointer"
                    >
                      <div className="flex items-center gap-2">
                        <span
                          className="w-2 h-2 rounded-full"
                          style={{ backgroundColor: cat.color }}
                        />
                        <span className="text-slate-700 font-medium">{tx.title}</span>
                      </div>
                      <span className={`font-mono font-semibold ${tx.type === 'expense' ? 'text-slate-600' : 'text-emerald-600'}`}>
                        {tx.type === 'expense' ? '-' : '+'}{formatCurrency(tx.amount)}
                      </span>
                    </div>
                  );
                })}
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
};
