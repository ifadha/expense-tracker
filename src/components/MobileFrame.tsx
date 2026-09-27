import React, { useState } from 'react';
import { Smartphone, Monitor, RotateCcw, Image, Sparkles, Code2 } from 'lucide-react';
import { TopStatusBar } from './TopStatusBar';
import { BottomNavBar } from './BottomNavBar';
import { FlutterCodeViewer } from './FlutterCodeViewer';
import { useExpense } from '../context/ExpenseContext';

interface MobileFrameProps {
  children: React.ReactNode;
}

export const MobileFrame: React.FC<MobileFrameProps> = ({ children }) => {
  const [deviceStyle, setDeviceStyle] = useState<'pixel' | 'iphone' | 'fullscreen'>('pixel');
  const [showRefComparison, setShowRefComparison] = useState(false);
  const [showFlutterCode, setShowFlutterCode] = useState(false);
  const { isAddExpenseOpen, isSelectCategoryOpen } = useExpense();

  return (
    <div className="min-h-screen bg-[#130f24] text-slate-800 flex flex-col items-center justify-start p-0 sm:py-6 sm:px-4 select-none relative overflow-x-hidden">
      {/* Top Device Switcher Toolbar (Visible on screens >= sm) */}
      <aside aria-label="Simulator Controls" className="hidden sm:flex items-center justify-between w-full max-w-[390px] mb-3 px-3 py-1.5 bg-slate-900/90 backdrop-blur-md rounded-2xl border border-white/10 text-white text-xs shadow-lg">
        <div className="flex items-center gap-2">
          <Smartphone size={14} className="text-[#a855f7]" />
          <span className="font-semibold text-slate-200">Mobile Simulator</span>
        </div>

        <div className="flex items-center gap-1 bg-black/40 p-1 rounded-xl">
          <button
            onClick={() => setDeviceStyle('pixel')}
            className={`px-2.5 py-1 rounded-lg text-[11px] font-semibold transition-all cursor-pointer ${
              deviceStyle === 'pixel' ? 'bg-[#704fe6] text-white shadow-xs' : 'text-slate-400 hover:text-white'
            }`}
          >
            Android
          </button>
          <button
            onClick={() => setDeviceStyle('iphone')}
            className={`px-2.5 py-1 rounded-lg text-[11px] font-semibold transition-all cursor-pointer ${
              deviceStyle === 'iphone' ? 'bg-[#704fe6] text-white shadow-xs' : 'text-slate-400 hover:text-white'
            }`}
          >
            iOS
          </button>
          <button
            onClick={() => setDeviceStyle('fullscreen')}
            className={`px-2.5 py-1 rounded-lg text-[11px] font-semibold transition-all cursor-pointer ${
              deviceStyle === 'fullscreen' ? 'bg-[#704fe6] text-white shadow-xs' : 'text-slate-400 hover:text-white'
            }`}
          >
            Full
          </button>
        </div>

        <button
          onClick={() => setShowFlutterCode(!showFlutterCode)}
          className={`flex items-center gap-1 px-2.5 py-1 rounded-lg text-[11px] font-semibold transition-colors cursor-pointer ${
            showFlutterCode ? 'bg-emerald-500/30 text-emerald-200 border border-emerald-500/30' : 'text-slate-300 hover:text-white bg-white/5'
          }`}
          title="Inspect Flutter Codebase"
        >
          <Code2 size={12} />
          <span>Flutter Code</span>
        </button>
      </aside>

      {/* Flutter Architecture Modal */}
      {showFlutterCode && (
        <FlutterCodeViewer onClose={() => setShowFlutterCode(false)} />
      )}

      {/* The Mobile Chassis Phone Container */}
      <div
        className={`w-full transition-all duration-300 flex flex-col ${
          deviceStyle === 'fullscreen'
            ? 'max-w-md sm:max-w-lg min-h-screen sm:min-h-[844px] sm:rounded-[40px] overflow-hidden'
            : 'max-w-full sm:max-w-[390px] min-h-screen sm:h-[844px] sm:rounded-[52px] sm:ring-[12px] sm:ring-[#2b2447] sm:shadow-[0_25px_70px_rgba(0,0,0,0.6)]'
        } relative overflow-hidden bg-gradient-to-b from-[#c8bbf8] via-[#e8e2fa] to-[#f6f5fc]`}
      >
        {/* Hardware Elements for Realistic Mobile View */}
        {deviceStyle === 'pixel' && (
          <div className="absolute top-3.5 left-1/2 -translate-x-1/2 w-3.5 h-3.5 bg-black rounded-full z-40 ring-1 ring-white/10" />
        )}

        {deviceStyle === 'iphone' && (
          <div className="absolute top-2.5 left-1/2 -translate-x-1/2 w-24 h-6 bg-black rounded-full z-40 flex items-center justify-end pr-2 ring-1 ring-white/10">
            <div className="w-2.5 h-2.5 bg-[#101018] rounded-full ring-1 ring-slate-800" />
          </div>
        )}

        {/* Mobile Status Bar (9:41, Cellular, Wifi, Battery) */}
        <TopStatusBar />

        {/* Dynamic Content Viewport */}
        <main className="flex-1 flex flex-col overflow-hidden relative">
          {children}
        </main>

        {/* Fixed Floating Bottom Nav (hidden during Add Expense or Category Selection modal for full screen focus) */}
        {!isAddExpenseOpen && !isSelectCategoryOpen && (
          <BottomNavBar />
        )}

        {/* Mobile Home Gesture Indicator Bar */}
        <div className="h-4 flex items-center justify-center pb-1">
          <div className="w-32 h-1 bg-slate-900/30 rounded-full" />
        </div>
      </div>
    </div>
  );
};
