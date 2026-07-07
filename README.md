# SpendWise - Personal Finance Tracker App

## Overview

SpendWise is a comprehensive personal finance management application built with Flutter, designed to help users track their income, expenses, and loans efficiently. The app features a modern Material 3 interface with a unified dashboard that displays net balance, category-wise summaries, and loan statuses.

## Features

- **Track Expenses, Incomes, and Loans with dynamic categories**
- **View Net Balance and Summaries on the unified dashboard**
- **Dark Theme (Default) and Light Theme support**
- **Clean Material 3 UI aesthetics**
- **Local SQLite Database Storage for privacy**

## Project Structure

The project follows a structured architecture with clear separation of concerns:

```bash
lib/
├── core/
│   ├── utils/             # Constants and helper functions
│   └── services/          # Core services (e.g., database)
├── features/
│   ├── auth/              # Authentication related screens and logic
│   ├── dashboard/         # Main dashboard and summaries
│   ├── expenses/          # Expense tracking
│   ├── incomes/           # Income tracking
│   ├── loans/             # Loan management
│   ├── profile/           # User profile and settings
│   └── reports/           # Financial reports and analytics
├── models/                # Data models
├── providers/             # State management (Riverpod)
├── routes/                # Navigation configuration
└── widgets/               # Reusable UI components
```

## Getting Started

### Prerequisites

- Flutter SDK (>= 3.0.0)
- Dart SDK (>= 2.12.0)
- Android Studio or VS Code
- Android SDK for building APK

### Installation

1. Clone the repository:

   ```bash
   git clone <repository-url>
   cd mahad_expense_tracker
   ```

2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Run the app:

   ```bash
   flutter run
   ```

### Build for Android

   ```bash
   flutter build apk --release
   ```

### Build for Web

   ```bash
   flutter build web
   ```

## Usage

- **Authentication**: Sign up or log in to access the app. The app uses Firebase Authentication for secure login.
- **Dashboard**: The main screen displays your net balance (Income - Expenses), recent transactions, and quick stats.
- **Transactions**: Add, edit, or delete expenses and incomes with custom categories.
- **Loans**: Manage loans with details like borrower, amount, rate, and duration.
- **Settings**: Toggle between dark and light themes, configure notifications, and manage profile.

## Technology Stack

- **Framework**: Flutter
- **Language**: Dart
- **State Management**: Riverpod
- **Database**: SQLite (sqflite)
- **Authentication**: Firebase Authentication
- **UI**: Material 3, cupertino_icons

## License

This project is developed as part of the Hunarmand Punjab program.
