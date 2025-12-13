# Ken's iOS App

**Skip weeks of setup. Start building your app today.**

A production-ready iOS starter template with everything you need to ship a real app.

Created by **Ken Kai** | [YouTube @kenkaidoesai](https://youtube.com/@kenkaidoesai) | [Skool Community](https://www.skool.com/kenkai)

---

## What You Get

- Auth System (login, signup, Face ID)
- Onboarding Flow
- Network Layer
- Secure Storage
- Database
- Dark/Light Mode
- UI Components
- Navigation
- Tests

---

## Prerequisites

You need a Mac with **Xcode** installed. That's it.

1. Open **App Store** on your Mac
2. Search "Xcode"
3. Click **Get** (it's free, ~7GB download)
4. Wait for it to install
5. Open Xcode once and accept the license agreement

---

## Get Started

### Step 1: Download This Project

Open **Terminal** (search "Terminal" in Spotlight) and paste:

```bash
git clone https://github.com/KenKaiii/kens-ios-app.git
cd kens-ios-app
```

### Step 2: Open in Xcode

```bash
open KensIOSApp.xcodeproj
```

### Step 3: Run the App

1. In Xcode, click the play button at the top left
2. Or press `Cmd + R`
3. Pick a simulator (iPhone 16 recommended)
4. The app will launch in the simulator

---

## Project Structure

```
KensIOSApp/
├── App/           # App startup
├── Core/          # Infrastructure
├── Features/      # Your screens
├── Services/      # Business logic
└── Resources/     # Images & assets
```

---

## Advanced: Modifying Project Settings

This project uses [XcodeGen](https://github.com/yonaskolb/XcodeGen) to manage project settings via `project.yml`. If you need to add new targets, change build settings, or modify the project structure:

```bash
# Install XcodeGen (one-time)
brew install xcodegen

# Regenerate the Xcode project after editing project.yml
xcodegen generate
```

---

## Connect

- **YouTube**: [@kenkaidoesai](https://youtube.com/@kenkaidoesai)
- **Community**: [skool.com/kenkai](https://www.skool.com/kenkai)

---

MIT License - Use it however you want.
