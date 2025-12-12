# iOS App Boilerplate

**Skip weeks of setup. Start building your app today.**

A production-ready iOS starter template with everything you need to ship a real app. Built with SwiftUI and iOS 17+ best practices.

Created by **Ken Kai** | [YouTube @kenkaidoesai](https://youtube.com/@kenkaidoesai) | [Skool Community](https://www.skool.com/kenkai)

---

## What You Get

- **Auth System** - Login, signup, forgot password, biometrics (Face ID/Touch ID)
- **Onboarding Flow** - Beautiful page-based intro screens
- **Network Layer** - Modern async/await API client with error handling
- **Secure Storage** - Keychain for tokens, UserDefaults for preferences
- **Database** - SwiftData ready for offline storage
- **Theme System** - Dark/light mode that just works
- **UI Components** - Buttons, loading states, error views, empty states
- **Navigation** - Type-safe routing throughout the app
- **Testing** - Unit tests + UI tests already configured
- **Code Quality** - SwiftLint keeps your code clean

## Who This Is For

- Developers who want to skip boilerplate setup
- Founders building their first iOS app
- Anyone tired of starting from scratch every time

## Requirements

- Mac with **Xcode 15+** installed
- iOS 17.0+ target

---

## Quick Start (5 minutes)

### Step 1: Get Homebrew

Open Terminal and paste:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Already have Homebrew? Skip this.

### Step 2: Install XcodeGen

```bash
brew install xcodegen
```

### Step 3: Clone This Repo

```bash
git clone https://github.com/kenkai/kens-ios-app.git
cd kens-ios-app
```

### Step 4: Generate the Xcode Project

```bash
xcodegen generate
```

### Step 5: Open and Run

```bash
open BoilerplateApp.xcodeproj
```

Press `Cmd + R` in Xcode to run the app.

---

## Make It Yours

1. Open `project.yml`
2. Change `name: BoilerplateApp` to your app name
3. Change `bundleIdPrefix: com.yourcompany` to your identifier
4. Run `xcodegen generate` again
5. Done

---

## Project Structure

```
BoilerplateApp/
├── App/           # App startup
├── Core/          # Infrastructure (network, storage, navigation)
├── Features/      # Your app screens (Home, Settings, Auth, etc.)
├── Services/      # Business logic (AuthService, etc.)
└── Resources/     # Images, colors, assets
```

---

## Connect

- **YouTube**: [@kenkaidoesai](https://youtube.com/@kenkaidoesai)
- **Community**: [skool.com/kenkai](https://www.skool.com/kenkai)

---

MIT License - Use it however you want.
