# Expense Tracker

A modern, responsive mobile expense tracking application built with **Flutter** and **Dart**, backed by **Google Cloud Firestore**. The app provides real-time transaction tracking, categorical spending analysis, interactive monthly comparisons, and persistent cloud synchronization with an intuitive Material 3 user interface.

The Android application is built from `lib/main.dart`. The repository also contains a separate React/Vite prototype under `src/`; it is not part of the Flutter Android build.

Developed as a practical assessment project for the **Flutter Developer Internship at CyphLab**.

---

## Features

The following features are fully implemented in the current codebase:

- **Add Expenses & Income**: Record financial transactions with title, numerical amount, category selection, transaction date, payment wallet, and optional notes/memo.
- **Edit Expenses**: Modify existing transaction details (title, amount, category, date, wallet, notes) with instant updates written back to Cloud Firestore.
- **Delete Expenses**: Safely remove transactions with an interactive confirmation modal to prevent accidental data loss.
- **Expense Categories**: Comprehensive built-in category catalog (Groceries, Travel, Transport, Rent, Insurance, Bills, Fitness, Dining, etc.) with custom icon containers and colors, plus a modal to create new custom categories.
- **Firebase Cloud Firestore Storage**: Real-time cloud persistence using Firestore collections (`expenses`), synchronizing data reactively across sessions via Dart `Stream<List<Expense>>`.
- **Monthly Expense Total**: Dynamic calculation of the selected month's spending and progress against the saved target budget.
- **Expense History**: Chronological transaction feed displaying grouped transactions with payment badges, category identifiers, and color-coded transaction amounts.
- **Category & Date Filtering**: Filter transaction history by category chips, transaction type (All, Deposit of funds, Withdrawal of funds), or specific date filter.
- **Keyword Search**: Real-time query search across merchant/title, notes, wallet account, and category names.
- **Form Validation**: Strict client-side checks verifying positive amounts (> $0), required title inputs, valid category selection, and valid ISO date formats before enabling submission.
- **Loading, Empty, and Error States**:
  - `LoadingStateWidget`: Centered progress indicators during cloud data synchronization.
  - `EmptyStateWidget`: Clean illustrations and call-to-action buttons when no transactions exist for the selected month or filter.
  - `ErrorStateWidget`: Graceful error notifications with retry actions when network or Firestore operations encounter issues.
- **Analytics & Dual Bar Chart**: Monthly Income vs. Expense totals and top spending categories calculated from Firestore transactions.
- **CSV Data Export**: Export filtered transactions directly to downloadable CSV files.
- **Multi-Currency Support**: Switch display currencies (USD `$`, EUR `€`, GBP `£`, JPY `¥`, INR `₹`, CAD `C$`, LKR `Rs.`) with selection persisted across app launches.
- **Saved Preferences**: Monthly target budget and light/dark theme persist across app launches.

---

## Screens

1. **Home Screen (`home_screen.dart`)**:
   - Month navigation pill selector (previous/next month switching).
   - "This Month Spend" hero card and saved monthly budget progress.
   - A compact light/dark theme toggle.
   - Quick-access Recent Transactions list with tap-to-edit interactions.

2. **Add Expense Screen (`add_expense_screen.dart`)**:
   - Header with Expense / Income segment toggle.
   - Form fields for Title (with one-tap quick preset tags), Amount, Date (with "Today" / "Yesterday" presets and native calendar picker), Wallet selection, and Note.
   - Horizontal category chip carousel with a "View All" link directing to the full Category Selection screen.
   - Primary action button with reactive validation and progress indicator.

3. **Category Selection Screen (`category_selection_screen.dart`)**:
   - Clean 4-column icon grid showing categories with distinct colors and glyphs.
   - Real-time search filter bar to quickly locate categories.
   - "+ Add" category modal dialog allowing users to create custom categories with tailored colors.

4. **Expense History Screen (`expense_history_screen.dart`)**:
   - Full transaction archive with search bar, date filter picker, and CSV export action.
   - Filter pills for All, Deposit of funds (income), and Withdrawal of funds (expense).
   - Category filter chip strip and empty state handler when zero records match filters.

5. **Edit Expense Screen (`edit_expense_screen.dart`)**:
   - Bottom-sheet dialog to edit any transaction property with pre-filled inputs.
   - In-line category selector grid.
   - Permanent delete button with confirmation step.

6. **Analytics Screen (`analytics_screen.dart`)**:
   - Dual bar chart comparing monthly income and expenses with interactive value tooltips.
   - High-level metric summary cards for Income and Expenses.
   - Top Categories progress bars highlighting proportional spending.
   - Grouped daily history list showing daily net totals.

7. **Account & Settings Screen (`account_screen.dart`)**:
   - Ifadha profile.
   - Persisted currency selection and monthly target budget editor.
   - Persisted light/dark theme selection from Home.

---

## Tech Stack

- **Framework**: [Flutter](https://flutter.dev/) (SDK `>=3.0.0 <4.0.0`, Material 3 design system)
- **Language**: [Dart](https://dart.dev/)
- **Backend & Database**: [Firebase Cloud Firestore](https://firebase.google.com/docs/firestore)
- **State Management & Data Flow**: Stateful widgets, reactive Streams (`Stream<List<Expense>>`), and repository service architecture.

### Key Flutter Packages Used

| Package | Version | Purpose |
| :--- | :--- | :--- |
| `firebase_core` | `^3.1.0` | Core Firebase app initialization and platform coordination |
| `cloud_firestore` | `^5.0.1` | Cloud Firestore database client, snapshots, and query streams |
| `intl` | `^0.19.0` | Currency and date/time formatting utilities |
| `shared_preferences` | `^2.3.2` | Persisted currency, monthly budget, and theme settings |
| `cupertino_icons` | `^1.0.8` | Supporting iOS-style glyphs and fallback system icons |

---

## Project Structure

```
lib/
├── main.dart                   # Application entry point & service injection
├── app/
│   ├── app.dart                # MaterialApp configuration, title & theme binding
│   ├── routes.dart             # Named routing definitions & onGenerateRoute factory
│   └── theme.dart              # Material 3 colors, typography & component themes
├── models/
│   ├── category.dart           # ExpenseCategory model, icons & color mapping
│   └── expense.dart            # Expense domain model with Firestore serialization
├── services/
│   ├── expense_service.dart    # Cloud Firestore CRUD, real-time streams & aggregations
│   └── firebase_config.dart    # Isolated Firebase initialization layer
├── utils/
│   ├── constants.dart          # Palette colors, default categories & configuration
│   └── validators.dart         # Form validation rules (amount, title, category, date)
├── screens/
│   ├── main_nav_screen.dart    # Bottom navigation shell with floating action button
│   ├── home/
│   │   └── home_screen.dart    # Dashboard overview & monthly summary
│   ├── expenses/
│   │   ├── add_expense_screen.dart        # Transaction creation form
│   │   ├── edit_expense_screen.dart       # Edit / Delete modal bottom sheet
│   │   ├── category_selection_screen.dart # 4-column category picker & creator
│   │   ├── expense_history_screen.dart    # Filterable transaction archive
│   │   └── expense_details_screen.dart    # Detailed single transaction view
│   ├── analytics/
│   │   └── analytics_screen.dart          # Dual bar chart & spending analytics
│   └── account/
│       └── account_screen.dart            # Settings, currency & monthly budget
└── widgets/
    ├── category_selector.dart  # Horizontal category chip selector
    ├── expense_card.dart       # Transaction row card with badges & indicators
    ├── monthly_summary.dart    # Header card with spend totals & percentage trend
    ├── spending_chart.dart     # Custom dual-bar comparison chart
    ├── loading_state.dart      # Reusable loading indicator
    ├── empty_state.dart        # Reusable empty list placeholder
    └── error_state.dart        # Reusable error banner with retry trigger
```

---

## Firebase Setup

This application connects to a Firebase Cloud Firestore project. To run this project against your own Firebase project:

1. **Create a Firebase Project**:
   - Go to the [Firebase Console](https://console.firebase.google.com/) and create a new project.
   - Under **Build**, select **Firestore Database** and create a database in **Test mode** (or apply the security rules provided in `firestore.rules`).

2. **Configure Platform Credentials**:
   - **Android**: Register your Android application package name (e.g., `com.example.lumina_expense_tracker`), download `google-services.json`, and place it in `android/app/`.
   - **iOS**: Register your iOS bundle ID, download `GoogleService-Info.plist`, and place it in `ios/Runner/`.
   - **FlutterFire CLI (Recommended)**:
     ```bash
     dart pub global activate flutterfire_cli
     flutterfire configure
     ```
     This automatically registers all platforms and creates `lib/firebase_options.dart`.

3. **Collection Structure**:
   - The app reads and writes documents to the `expenses` collection.
   - Document fields:
     - `title` (String, required)
     - `amount` (Number, required)
     - `category` / `categoryId` (String, required)
     - `date` (Timestamp or ISO 8601 String, required)
     - `note` (String, optional)
     - `type` (String, `"expense"` or `"income"`)
     - `wallet` (String)
     - `recurring` (Boolean)
     - `createdAt` (Timestamp)
     - `updatedAt` (Timestamp)

Firebase client configuration files contain Google API keys required by Firebase clients; these are not server credentials, but should be restricted to the intended applications and APIs in Google Cloud Console. Keys already committed to Git history require console-side rotation/restriction; removing a value from the current file alone does not remediate historical exposure.

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>= 3.0.0`)
- [Dart SDK](https://dart.dev/get-dart)
- [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/) with Flutter and Dart extensions
- Android Emulator, iOS Simulator, or connected physical device with USB debugging enabled

### Setup Instructions (Windows / VS Code)

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd lumina_expense_tracker
   ```

2. **Open the project in VS Code**:
   ```bash
   code .
   ```

3. **Install dependencies**:
   ```bash
   flutter pub get
   ```

4. **Verify your Flutter environment**:
   ```bash
   flutter doctor
   ```
   Ensure that the Android toolchain and connected devices show green checkmarks.

5. **Start your device**:
   - Open Android Studio Device Manager and launch an emulator, or connect a physical phone via USB.
   - In VS Code, verify the target device appears in the bottom status bar.

6. **Run the application**:
   ```bash
   flutter run -d <android-device-id>
   ```
   Press `r` in the terminal for hot reload, or `R` for hot restart.

---

## Usage

- **Add an Expense**: Tap the center floating action button (`+`) in the bottom navigation bar. Choose Expense or Income, input a title and amount, select a category, pick a date, and tap **Add Expense**.
- **Select a Category**: Tap any category pill in the horizontal selector, or tap **View All** to navigate to the 4-column Category Selection screen with real-time search. Tap "+ Add" to create a custom category.
- **View Expenses**: The **Home** screen displays recent transactions for the selected month. Navigate between months using the left/right chevrons in the top date pill.
- **Filter and Search Expenses**: Tap the **Transactions** tab. Use the search bar to query by merchant name or note, tap the calendar icon to filter by date, or tap filter pills (**All**, **Deposit of funds**, **Withdrawal of funds**) and category chips.
- **Edit an Expense**: Tap any transaction card in the Home or Transactions list to open the Edit modal. Adjust fields and tap **Update Expense**.
- **Delete an Expense**: In the Edit modal, tap the trash can icon in the header, then confirm by tapping **Yes, Delete**.
- **View Monthly Totals**: The Home dashboard displays "This Month Spend" and progress against the saved target budget.
- **View Analytics**: Tap the **Analytics** tab to view the dual bar chart (Income vs. Expense), top category percentage bars, and grouped daily history logs.

---

## AI Tools Used

This project was developed with assistance from modern AI development tools:

- **Google AI Studio**: Used for application implementation, code generation, debugging, architectural structuring, and documentation assistance.
- **Google Stitch**: Used for UI/UX exploration, mobile design layouts, color palette harmony, and visual design direction.
- **ChatGPT**: Used for initial development planning, technical guidance, debugging, architectural review, and Flutter/Firebase pattern validation.

All AI-assisted outputs were systematically reviewed, manually edited, tested, and integrated to ensure clean code quality, reliable execution, and adherence to project requirements.

---

## Assessment Notes

This project was developed and submitted as part of the practical assessment for the **Flutter Developer Internship at CyphLab**. It showcases:
- Clean Dart and Flutter project architecture (separation of models, services, screens, and widgets).
- Material 3 aesthetic implementation faithful to mobile design principles.
- Real-time cloud database integration using Google Cloud Firestore.
- Complete CRUD workflow handling loading, empty, and error edge cases.

---

## Future Improvements

Potential enhancements planned for future releases:
- **Firebase Authentication**: User accounts with email/password and Google Sign-In to allow multiple users to manage distinct isolated ledgers.
- **Multi-Account Syncing**: Dynamic bank account synchronization and multi-wallet balance transfers.
- **Receipt Attachment**: Uploading receipt images using Firebase Cloud Storage and OCR text extraction.
- **Recurring Schedules**: Background scheduled jobs to automatically post recurring subscriptions on billing dates.
