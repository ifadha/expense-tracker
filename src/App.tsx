/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import React from 'react';
import { ExpenseProvider, useExpense } from './context/ExpenseContext';
import { MobileFrame } from './components/MobileFrame';
import { HomeScreen } from './components/HomeScreen';
import { ExpenseHistoryScreen } from './components/ExpenseHistoryScreen';
import { AnalyticsScreen } from './components/AnalyticsScreen';
import { CategorySelectionScreen } from './components/CategorySelectionScreen';
import { AddExpenseScreen } from './components/AddExpenseScreen';
import { EditExpenseModal } from './components/EditExpenseModal';
import { WalletModal } from './components/WalletModal';
import { NotificationModal } from './components/NotificationModal';
import { AccountScreen } from './components/AccountScreen';

const MainAppContent: React.FC = () => {
  const {
    activeTab,
    isAddExpenseOpen,
    isSelectCategoryOpen,
    setIsSelectCategoryOpen,
  } = useExpense();

  return (
    <MobileFrame>
      {/* Route-like conditional screens */}
      {isSelectCategoryOpen ? (
        <CategorySelectionScreen />
      ) : isAddExpenseOpen ? (
        <AddExpenseScreen />
      ) : (
        <>
          {activeTab === 'home' && <HomeScreen />}
          {activeTab === 'history' && <ExpenseHistoryScreen />}
          {activeTab === 'analytics' && <AnalyticsScreen />}
          {activeTab === 'account' && <AccountScreen />}
        </>
      )}

      {/* Global Modals */}
      <EditExpenseModal />
      <WalletModal />
      <NotificationModal />
    </MobileFrame>
  );
};

export default function App() {
  return (
    <ExpenseProvider>
      <MainAppContent />
    </ExpenseProvider>
  );
}
