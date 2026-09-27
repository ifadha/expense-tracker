import React, { useState, useEffect } from 'react';
import { Wifi, Battery } from 'lucide-react';

export const TopStatusBar: React.FC = () => {
  const [time, setTime] = useState<string>('9:41');

  useEffect(() => {
    const updateTime = () => {
      const now = new Date();
      let hours = now.getHours();
      const minutes = String(now.getMinutes()).padStart(2, '0');
      // Format 9:41 style or 12hr
      const formatted = `${hours % 12 || 12}:${minutes}`;
      setTime(formatted);
    };

    updateTime();
    const interval = setInterval(updateTime, 30000);
    return () => clearInterval(interval);
  }, []);

  return (
    <div className="flex items-center justify-between px-6 pt-3 pb-2 text-slate-800 text-xs font-semibold select-none">
      {/* Time */}
      <span className="tracking-tight font-medium text-[13px]">{time}</span>

      {/* Dynamic Island / Notch Placeholder is handled in MobileFrame, but here we keep icons right-aligned */}
      <div className="flex items-center gap-1.5 opacity-90">
        {/* Cellular Signal Icon */}
        <div className="flex items-end gap-[1.5px] h-3">
          <div className="w-[3px] h-1.5 bg-slate-800 rounded-xs" />
          <div className="w-[3px] h-2 bg-slate-800 rounded-xs" />
          <div className="w-[3px] h-2.5 bg-slate-800 rounded-xs" />
          <div className="w-[3px] h-3 bg-slate-800 rounded-xs" />
        </div>

        {/* Wifi */}
        <Wifi size={13} className="text-slate-800 stroke-[2.2]" />

        {/* Battery */}
        <div className="flex items-center">
          <div className="w-5 h-2.5 border-[1.2px] border-slate-800 rounded-xs p-[1px] flex items-center">
            <div className="w-3/4 h-full bg-slate-800 rounded-[0.5px]" />
          </div>
          <div className="w-[1px] h-1 bg-slate-800 rounded-r-xs ml-[0.5px]" />
        </div>
      </div>
    </div>
  );
};
