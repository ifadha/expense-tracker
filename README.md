# Expense Tracker

A modern Flutter expense-tracking application built with **Flutter and Dart**, backed by **Google Cloud Firestore**. The app provides transaction management, category-based spending analysis, monthly comparisons, cloud synchronization, and a Material 3 interface.

The Android application is built from `lib/main.dart`. The repository also contains a separate React/Vite prototype under `src/`; it is **not part of the Flutter Android build**.

Developed as a practical assessment project for the **Flutter Developer Internship at CyphLab**.

---

## Features

### Transaction Management

* **Add expenses and income**

  * Title
  * Amount
  * Category
  * Transaction date
  * Wallet
  * Optional note/memo
* **Edit existing transactions**
* **Delete transactions** with confirmation
* Expense and income transaction types
* Persistent cloud storage using Cloud Firestore

### Categories

* Built-in expense categories including:

  * Groceries
  * Travel
  * Transport
  * Rent
  * Insurance
  * Bills
  * Fitness
  * Dining
  * And more
* Category icons and visual styling
* Category search
* Custom category creation

### Dashboard & Monthly Tracking

* Current-month spending total
* Monthly target budget
* Budget progress
* Previous/next month navigation
* Recent transaction overview
* Income and expense summaries

### Transaction History

* Chronological transaction history
* Search transactions by:

  * Title/merchant
  * Notes
  * Wallet
  * Category
* Filter by:

  * Category
  * Date
  * Transaction type
* Transaction types:

  * All
  * Deposit of funds
  * Withdrawal of funds
* CSV export of filtered transactions

### Analytics

* Monthly income vs. expense comparison
* Dual bar chart
* Top spending categories
* Category spending percentages
* Grouped daily transaction history
* Income and expense summary metrics

### Validation & States

* Required-field validation
* Positive amount validation
* Category validation
* Date validation
* Loading states during Firestore operations
* Empty states when no transactions match the current view
* Error states with retry actions

### Preferences

* Multi-currency display support:

  * USD (`$`)
  * EUR (`€`)
  * GBP (`£`)
  * JPY (`¥`)
  * INR (`₹`)
  * CAD (`C$`)
  * LKR (`Rs.`)
* Persisted monthly budget
* Persisted currency selection
* Light/dark theme preference

---

## Screens

### Home

* Monthly navigation
* Current-month spending summary
* Monthly budget progress
* Light/dark theme toggle
* Recent transactions
* Quick access to transaction editing

### Add Transaction

* Expense / Income toggle
* Title and amount fields
* Quick title presets
* Date selection with Today/Yesterday shortcuts
* Native date picker
* Wallet selection
* Notes
* Category selection
* Form validation
* Submission progress state

### Category Selection

* Four-column category grid
* Category search
* Built-in categories
* Custom category creation

### Transaction History

* Complete transaction archive
* Search
* Date filtering
* Category filtering
* Income/expense filtering
* CSV export

### Edit Transaction

* Pre-filled transaction details
* Transaction editing
* Category selection
* Delete action
* Delete confirmation

### Analytics

* Income vs. expense monthly chart
* Income and expense summary cards
* Top spending categories
* Category percentage indicators
* Daily transaction summaries

### Account & Settings

* Profile section
* Currency selection
* Monthly target budget
* Theme preferences

---

## Tech Stack

| Technology                   | Purpose                                      |
| ---------------------------- | -------------------------------------------- |
| **Flutter**                  | Cross-platform application framework         |
| **Dart**                     | Application programming language             |
| **Material 3**               | UI design system                             |
| **Firebase Cloud Firestore** | Cloud database and real-time synchronization |
| **Shared Preferences**       | Local persistence for user preferences       |
| **Intl**                     | Currency and date formatting                 |

### Key Flutter Packages

| Package              |   Version | Purpose                                         |
| -------------------- | --------: | ----------------------------------------------- |
| `firebase_core`      |  `^3.1.0` | Firebase initialization                         |
| `cloud_firestore`    |  `^5.0.1` | Firestore database access and real-time streams |
| `intl`               | `^0.19.0` | Currency and date formatting                    |
| `shared_preferences` |  `^2.3.2` | Persistent local preferences                    |
| `cupertino_icons`    |  `^1.0.8` | Supporting iOS-style icons                      |

---

## Architecture

The Flutter application is organized into separate layers for models, services, screens, reusable widgets, and application configuration.

```text
lib/
├── main.dart
│
├── app/
│   ├── app.dart
│   ├── routes.dart
│   └── theme.dart
│
├── models/
│   ├── category.dart
│   └── expense.dart
│
├── services/
│   ├── expense_service.dart
│   └── firebase_config.dart
│
├── utils/
│   ├── constants.dart
│   └── validators.dart
│
├── screens/
│   ├── main_nav_screen.dart
│   │
│   ├── home/
│   │   └── home_screen.dart
│   │
│   ├── expenses/
│   │   ├── add_expense_screen.dart
│   │   ├── edit_expense_screen.dart
│   │   ├── category_selection_screen.dart
│   │   ├── expense_history_screen.dart
│   │   └── expense_details_screen.dart
│   │
│   ├── analytics/
│   │   └── analytics_screen.dart
│   │
│   └── account/
│       └── account_screen.dart
│
└── widgets/
    ├── category_selector.dart
    ├── expense_card.dart
    ├── monthly_summary.dart
    ├── spending_chart.dart
    ├── loading_state.dart
    ├── empty_state.dart
    └── error_state.dart
```

Firestore data is exposed through reactive Dart streams, allowing transaction changes to be reflected in the application UI.

---

## Firebase

The application uses **Cloud Firestore** for transaction persistence and real-time data synchronization.

The primary collection is:

```text
expenses
```

Transactions contain fields such as:

```text
title
amount
category
categoryId
date
note
type
wallet
createdAt
updatedAt
```

### Firebase Configuration

To connect the project to a Firebase project:

1. Create a Firebase project.
2. Enable **Cloud Firestore**.
3. Register the Android application using the package ID:

```text
com.example.lumina_expense_tracker
```

4. Place the generated `google-services.json` in:

```text
android/app/
```

5. Configure the required Firebase project settings.
6. Run:

```bash
flutter pub get
```

The project already contains Firebase initialization for the configured application.

> **Security note:** Firestore security rules should be reviewed and appropriately restricted before using the application with sensitive or production data. The current application does not implement user authentication or per-user data isolation.

---

## Getting Started

### Prerequisites

* Flutter SDK
* Dart SDK
* Android Studio or VS Code
* Flutter and Dart VS Code extensions
* Android emulator or physical Android device

### Clone the Repository

```bash
git clone <repository-url>
cd expense-tracker
```

### Install Dependencies

```bash
flutter pub get
```

### Check the Flutter Environment

```bash
flutter doctor
```

### Check Available Devices

```bash
flutter devices
```

### Run on Android

```bash
flutter run -d <android-device-id>
```

For development, Flutter hot reload can be triggered by pressing:

```text
r
```

Hot restart:

```text
R
```

### Build a Release APK

```bash
flutter build apk --release
```

The generated APK is located at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

---

## Usage

### Add a Transaction

1. Tap the central `+` button.
2. Select **Expense** or **Income**.
3. Enter a title and amount.
4. Select a category.
5. Choose the transaction date.
6. Select a wallet.
7. Optionally add a note.
8. Submit the transaction.

### Edit a Transaction

Select a transaction from the Home or Transactions screen and modify the required fields.

### Delete a Transaction

Open a transaction and select the delete action. Confirm the deletion when prompted.

### Filter Transactions

Open the Transactions screen and use:

* Search
* Date filtering
* Category filtering
* Transaction type filtering

### View Analytics

Open the **Analytics** tab to view:

* Monthly income
* Monthly expenses
* Income vs. expense comparison
* Top spending categories
* Daily transaction summaries

### Export Transactions

Use the CSV export action from the Transactions screen to export the currently filtered transaction data.

---

## AI-Assisted Development

AI development tools were used as part of the development workflow:

* **Google AI Studio** — implementation assistance, code generation, debugging, architectural structuring, and documentation.
* **Google Stitch** — UI/UX exploration and visual design direction.
* **ChatGPT** — development planning, technical guidance, debugging, and Flutter/Firebase pattern review.

AI-generated output was reviewed, modified, tested, and integrated during development.

---

## Assessment

This project was developed as part of the practical assessment for the **Flutter Developer Internship at CyphLab**.

The implementation demonstrates:

* Flutter and Dart application development
* Material 3 UI implementation
* Firebase Cloud Firestore integration
* Create, read, update, and delete transaction workflows
* Transaction filtering and search
* Form validation
* Loading, empty, and error states
* Monthly spending analysis
* Data visualization
* CSV export
* Persistent application preferences

---

## Future Improvements

Potential future enhancements include:

* **Firebase Authentication**

  * Email/password authentication
  * Google Sign-In
  * User-specific transaction data
* **Multi-account and wallet management**
* **Receipt image attachments**
* **Firebase Cloud Storage integration**
* **OCR-based receipt data extraction**
* **Recurring transaction scheduling**
* **Background processing for scheduled transactions**
