import React, { useState } from 'react';
import { ArrowLeft, Search, Plus, Check, X } from 'lucide-react';
import { useExpense } from '../context/ExpenseContext';
import { CategoryIcon } from './CategoryIcon';
import { Category } from '../types';

interface CategorySelectionScreenProps {
  onSelect?: (category: Category) => void;
  onClose?: () => void;
  selectedCategoryId?: string;
}

export const CategorySelectionScreen: React.FC<CategorySelectionScreenProps> = ({
  onSelect,
  onClose,
  selectedCategoryId,
}) => {
  const {
    categories,
    addCategory,
    setIsSelectCategoryOpen,
    isCategoryPickerForNewExpense,
    setIsCategoryPickerForNewExpense,
    setPendingCategorySelection,
    setIsAddExpenseOpen,
  } = useExpense();

  const [searchQuery, setSearchQuery] = useState('');
  const [isCreatingCustom, setIsCreatingCustom] = useState(false);
  const [newCatName, setNewCatName] = useState('');
  const [newCatIcon, setNewCatIcon] = useState('Tag');
  const [newCatColor, setNewCatColor] = useState('#8b5cf6');

  const filteredCategories = categories.filter((c) =>
    c.name.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const handleCategoryClick = (cat: Category) => {
    if (onSelect) {
      onSelect(cat);
    } else {
      setPendingCategorySelection(cat.id);
      setIsSelectCategoryOpen(false);
      if (isCategoryPickerForNewExpense) {
        setIsAddExpenseOpen(true);
      }
    }
  };

  const handleClose = () => {
    if (onClose) {
      onClose();
    } else {
      setIsSelectCategoryOpen(false);
      if (isCategoryPickerForNewExpense) {
        setIsAddExpenseOpen(true);
      }
    }
    setIsCategoryPickerForNewExpense(false);
  };

  const handleCreateCategory = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newCatName.trim()) return;

    const created = addCategory({
      name: newCatName.trim(),
      iconName: newCatIcon,
      color: newCatColor,
      bgLight: `${newCatColor}18`, // 10% opacity
    });

    setNewCatName('');
    setIsCreatingCustom(false);
    handleCategoryClick(created);
  };

  const availableIcons = [
    'ShoppingBag',
    'Plane',
    'Car',
    'Home',
    'ShieldCheck',
    'BookOpen',
    'Megaphone',
    'Wifi',
    'Droplets',
    'Key',
    'Dumbbell',
    'Bell',
    'Palmtree',
    'Utensils',
    'Coffee',
    'HeartPulse',
    'Tv',
    'Tag',
  ];

  const availableColors = [
    '#7c3aed', // Purple
    '#2563eb', // Blue
    '#059669', // Emerald
    '#d97706', // Amber
    '#e11d48', // Rose
    '#06b6d4', // Cyan
    '#ea580c', // Orange
    '#ca8a04', // Yellow
    '#9333ea', // Violet
  ];

  return (
    <div className="flex-1 flex flex-col overflow-hidden bg-gradient-to-b from-[#ded7fc] via-[#f4f2fb] to-[#f6f5fc] text-slate-800">
      {/* Top Header */}
      <div className="px-5 pt-3 pb-3 flex items-center justify-between">
        <button
          onClick={handleClose}
          className="w-11 h-11 rounded-2xl bg-white/85 hover:bg-white text-slate-700 flex items-center justify-center shadow-xs border border-white/70 active:scale-95 transition-all cursor-pointer"
          aria-label="Back"
        >
          <ArrowLeft size={19} className="stroke-[2.2]" />
        </button>

        <h1 className="text-base font-bold text-slate-900 tracking-tight">
          Select Category
        </h1>

        <div className="w-11" /> {/* Spacer */}
      </div>

      {/* Search Input Bar */}
      <div className="px-5 pb-4">
        <div className="relative">
          <Search
            size={18}
            className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 pointer-events-none"
          />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search for Categories"
            className="w-full h-11 pl-11 pr-4 bg-white/90 focus:bg-white text-sm text-slate-800 placeholder-slate-400 rounded-full border border-white/80 shadow-xs focus:outline-hidden focus:ring-2 focus:ring-[#704fe6]/20 transition-all"
          />
          {searchQuery && (
            <button
              onClick={() => setSearchQuery('')}
              className="absolute right-3.5 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 p-1"
            >
              <X size={15} />
            </button>
          )}
        </div>
      </div>

      {/* Categories Grid (4 Columns) */}
      <div className="flex-1 overflow-y-auto no-scrollbar px-5 pb-8">
        <div className="grid grid-cols-4 gap-y-5 gap-x-3 text-center">
          {/* Add Category Card (First item like in reference) */}
          <div className="flex flex-col items-center">
            <button
              onClick={() => setIsCreatingCustom(true)}
              className="w-14 h-14 rounded-2xl bg-white/80 hover:bg-white text-slate-600 flex items-center justify-center shadow-xs border border-dashed border-slate-300 hover:border-[#704fe6] hover:text-[#704fe6] active:scale-95 transition-all cursor-pointer group"
            >
              <Plus size={22} className="stroke-[2] transition-transform group-hover:rotate-90" />
            </button>
            <span className="text-[11px] font-medium text-slate-600 mt-2 truncate w-full">
              Add
            </span>
          </div>

          {/* Render category list */}
          {filteredCategories.map((cat) => {
            const isSelected = selectedCategoryId === cat.id;

            return (
              <div key={cat.id} className="flex flex-col items-center">
                <button
                  onClick={() => handleCategoryClick(cat)}
                  className={`relative w-14 h-14 rounded-2xl flex items-center justify-center shadow-[0_2px_10px_rgba(30,20,60,0.03)] border transition-all active:scale-95 cursor-pointer ${
                    isSelected
                      ? 'bg-white ring-2 ring-[#704fe6] border-[#704fe6] scale-105'
                      : 'bg-white hover:bg-white/90 border-white/90'
                  }`}
                >
                  <CategoryIcon
                    iconName={cat.iconName}
                    size={22}
                    color={cat.color}
                  />

                  {isSelected && (
                    <span className="absolute -top-1 -right-1 w-4 h-4 bg-[#704fe6] text-white rounded-full flex items-center justify-center text-[10px]">
                      <Check size={10} className="stroke-[3]" />
                    </span>
                  )}
                </button>
                <span className="text-[11px] font-medium text-slate-700 mt-2 truncate w-full px-0.5">
                  {cat.name}
                </span>
              </div>
            );
          })}
        </div>

        {filteredCategories.length === 0 && (
          <div className="text-center py-12">
            <p className="text-sm text-slate-500">No categories found matching "{searchQuery}"</p>
            <button
              onClick={() => {
                setNewCatName(searchQuery);
                setIsCreatingCustom(true);
              }}
              className="mt-3 px-4 py-2 bg-[#704fe6] text-white text-xs font-semibold rounded-xl"
            >
              Create "{searchQuery}"
            </button>
          </div>
        )}
      </div>

      {/* Modal to Create Custom Category */}
      {isCreatingCustom && (
        <div className="fixed inset-0 z-50 bg-black/40 backdrop-blur-xs flex items-end justify-center p-4">
          <div className="bg-white rounded-3xl w-full max-w-sm p-5 shadow-2xl animate-in fade-in slide-in-from-bottom duration-200">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-base font-bold text-slate-900">New Category</h3>
              <button
                onClick={() => setIsCreatingCustom(false)}
                className="w-8 h-8 rounded-full bg-slate-100 text-slate-500 flex items-center justify-center"
              >
                <X size={16} />
              </button>
            </div>

            <form onSubmit={handleCreateCategory} className="space-y-4">
              <div>
                <label className="text-xs font-medium text-slate-600 block mb-1">
                  Category Name
                </label>
                <input
                  type="text"
                  required
                  placeholder="e.g. Pet Care, Books, Coffee"
                  value={newCatName}
                  onChange={(e) => setNewCatName(e.target.value)}
                  className="w-full h-11 px-3.5 bg-slate-50 rounded-xl text-sm border border-slate-200 focus:outline-hidden focus:ring-2 focus:ring-[#704fe6]/20"
                />
              </div>

              <div>
                <label className="text-xs font-medium text-slate-600 block mb-1.5">
                  Choose Color
                </label>
                <div className="flex items-center gap-2 flex-wrap">
                  {availableColors.map((color) => (
                    <button
                      key={color}
                      type="button"
                      onClick={() => setNewCatColor(color)}
                      className={`w-7 h-7 rounded-full transition-transform ${
                        newCatColor === color ? 'scale-120 ring-2 ring-slate-800 ring-offset-2' : ''
                      }`}
                      style={{ backgroundColor: color }}
                    />
                  ))}
                </div>
              </div>

              <div>
                <label className="text-xs font-medium text-slate-600 block mb-1.5">
                  Choose Icon
                </label>
                <div className="grid grid-cols-6 gap-2 max-h-36 overflow-y-auto p-1 bg-slate-50 rounded-xl border border-slate-100">
                  {availableIcons.map((iconName) => (
                    <button
                      key={iconName}
                      type="button"
                      onClick={() => setNewCatIcon(iconName)}
                      className={`w-9 h-9 rounded-lg flex items-center justify-center transition-all ${
                        newCatIcon === iconName
                          ? 'bg-[#704fe6] text-white shadow-xs'
                          : 'bg-white text-slate-600 hover:bg-slate-100'
                      }`}
                    >
                      <CategoryIcon
                        iconName={iconName}
                        size={17}
                        color={newCatIcon === iconName ? '#ffffff' : newCatColor}
                      />
                    </button>
                  ))}
                </div>
              </div>

              <div className="pt-2 flex items-center gap-2">
                <button
                  type="button"
                  onClick={() => setIsCreatingCustom(false)}
                  className="flex-1 h-11 rounded-xl bg-slate-100 text-slate-600 text-xs font-semibold hover:bg-slate-200 transition-colors"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="flex-1 h-11 rounded-xl bg-[#1b1433] hover:bg-[#2c2250] text-white text-xs font-semibold transition-colors shadow-sm"
                >
                  Create Category
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};
