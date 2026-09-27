import { Category, Transaction, Wallet } from '../types';

export const INITIAL_CATEGORIES: Category[] = [
  {
    id: 'groceries',
    name: 'Groceries',
    iconName: 'ShoppingBag',
    color: '#16a34a', // green
    bgLight: '#ecfdf5',
  },
  {
    id: 'travel',
    name: 'Travel',
    iconName: 'Plane',
    color: '#06b6d4', // cyan
    bgLight: '#ecfeff',
  },
  {
    id: 'car',
    name: 'Car',
    iconName: 'Car',
    color: '#2563eb', // blue
    bgLight: '#eff6ff',
  },
  {
    id: 'home',
    name: 'Home',
    iconName: 'Home',
    color: '#db2777', // magenta / pink
    bgLight: '#fdf2f8',
  },
  {
    id: 'insurance',
    name: 'Insurances',
    iconName: 'ShieldCheck',
    color: '#0d9488', // teal
    bgLight: '#f0fdfa',
  },
  {
    id: 'education',
    name: 'Education',
    iconName: 'BookOpen',
    color: '#7c3aed', // purple
    bgLight: '#f5f3ff',
  },
  {
    id: 'marketing',
    name: 'Marketing',
    iconName: 'Megaphone',
    color: '#d97706', // amber
    bgLight: '#fffbeb',
  },
  {
    id: 'shopping',
    name: 'Shopping',
    iconName: 'ShoppingBag',
    color: '#059669', // emerald
    bgLight: '#ecfdf5',
  },
  {
    id: 'internet',
    name: 'Internet',
    iconName: 'Wifi',
    color: '#8b5cf6', // violet
    bgLight: '#f5f3ff',
  },
  {
    id: 'water',
    name: 'Water',
    iconName: 'Droplets',
    color: '#0284c7', // sky
    bgLight: '#f0f9ff',
  },
  {
    id: 'rent',
    name: 'Rent',
    iconName: 'Key',
    color: '#ea580c', // orange
    bgLight: '#fff7ed',
  },
  {
    id: 'gym',
    name: 'Gym',
    iconName: 'Dumbbell',
    color: '#ca8a04', // yellow / amber
    bgLight: '#fefce8',
  },
  {
    id: 'subscription',
    name: 'Subscription',
    iconName: 'Bell',
    color: '#9333ea', // purple
    bgLight: '#faf5ff',
  },
  {
    id: 'vacation',
    name: 'Vacation',
    iconName: 'Palmtree',
    color: '#10b981', // green
    bgLight: '#ecfdf5',
  },
  {
    id: 'dining',
    name: 'Food & Dining',
    iconName: 'Utensils',
    color: '#e11d48', // rose
    bgLight: '#fff1f2',
  },
  {
    id: 'other',
    name: 'Other',
    iconName: 'Grid',
    color: '#6366f1', // indigo
    bgLight: '#eef2ff',
  },
];

export const INITIAL_WALLETS: Wallet[] = [
  {
    id: 'wallet-1',
    name: 'Spending Wallet',
    balance: 5631.22,
    type: 'checking',
    color: '#8b5cf6',
  },
  {
    id: 'wallet-2',
    name: 'MasterCard •••• 9918',
    balance: 1420.5,
    type: 'credit',
    color: '#eb001b',
  },
  {
    id: 'wallet-3',
    name: 'Savings Vault',
    balance: 14850.0,
    type: 'savings',
    color: '#10b981',
  },
];

// Helper to generate dates relative to today or current month
export const INITIAL_TRANSACTIONS: Transaction[] = [
  {
    id: 'tx-1',
    title: 'Spotify Subscriptions',
    amount: 4.99,
    type: 'expense',
    categoryId: 'subscription',
    date: '2026-09-25',
    wallet: 'Spending Wallet',
    note: 'Premium Individual monthly plan',
    recurring: true,
  },
  {
    id: 'tx-2',
    title: 'Guy Hawkins',
    amount: 182.99,
    type: 'income',
    categoryId: 'marketing',
    date: '2026-09-24',
    wallet: 'MasterCard •••• 9918',
    note: 'Consultation retainer',
  },
  {
    id: 'tx-3',
    title: 'Davy Jones',
    amount: 12.49,
    type: 'expense',
    categoryId: 'dining',
    date: '2026-09-22',
    wallet: 'MasterCard •••• 9918',
    note: 'Team lunch split',
  },
  {
    id: 'tx-4',
    title: 'Freepik Subscriptions',
    amount: 109.0,
    type: 'expense',
    categoryId: 'subscription',
    date: '2026-09-20',
    wallet: 'Spending Wallet',
    note: 'Premium vector download license',
  },
  {
    id: 'tx-5',
    title: 'Whole Foods Market',
    amount: 76.45,
    type: 'expense',
    categoryId: 'groceries',
    date: '2026-09-19',
    wallet: 'Spending Wallet',
    note: 'Weekly organic produce & fruits',
  },
  {
    id: 'tx-6',
    title: 'Fiber Internet 1Gbps',
    amount: 65.0,
    type: 'expense',
    categoryId: 'internet',
    date: '2026-09-17',
    wallet: 'Spending Wallet',
    note: 'Monthly ultra-fast fiber connection',
    recurring: true,
  },
  {
    id: 'tx-7',
    title: 'Shell Smart Fuel',
    amount: 48.2,
    type: 'expense',
    categoryId: 'car',
    date: '2026-09-15',
    wallet: 'Spending Wallet',
    note: 'Gasoline refill and wiper fluid',
  },
  {
    id: 'tx-8',
    title: 'Freelance Mobile UI Project',
    amount: 1850.0,
    type: 'income',
    categoryId: 'marketing',
    date: '2026-09-15',
    wallet: 'Spending Wallet',
    note: 'Final milestone release payment',
  },
  {
    id: 'tx-9',
    title: 'Equinox Gym & Spa',
    amount: 95.0,
    type: 'expense',
    categoryId: 'gym',
    date: '2026-09-12',
    wallet: 'Spending Wallet',
    note: 'Monthly fitness studio membership',
    recurring: true,
  },
  {
    id: 'tx-10',
    title: 'City Municipal Water',
    amount: 34.5,
    type: 'expense',
    categoryId: 'water',
    date: '2026-09-10',
    wallet: 'Spending Wallet',
    note: 'Utility bill payment',
  },
  {
    id: 'tx-11',
    title: 'Aura Studio Monthly Salary',
    amount: 4200.0,
    type: 'income',
    categoryId: 'other',
    date: '2026-09-01',
    wallet: 'Spending Wallet',
    note: 'Direct deposit payroll',
    recurring: true,
  },
  {
    id: 'tx-12',
    title: 'Modern Loft Apartment Rent',
    amount: 1200.0,
    type: 'expense',
    categoryId: 'rent',
    date: '2026-09-01',
    wallet: 'Spending Wallet',
    note: 'Monthly lease installment',
    recurring: true,
  },
  {
    id: 'tx-13',
    title: 'Delta Airlines Flight Seat',
    amount: 245.0,
    type: 'expense',
    categoryId: 'travel',
    date: '2026-08-28',
    wallet: 'Spending Wallet',
    note: 'Conference flight ticket',
  },
  {
    id: 'tx-14',
    title: 'Coursera Tech Certificate',
    amount: 49.0,
    type: 'expense',
    categoryId: 'education',
    date: '2026-08-20',
    wallet: 'Spending Wallet',
    note: 'Advanced TypeScript & Flutter cert',
  },
];
