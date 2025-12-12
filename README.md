# iOS App Boilerplate

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

You need a Mac. That's it. Follow these steps in order.

### 1. Install Xcode (Required)

1. Open **App Store** on your Mac
2. Search "Xcode"
3. Click **Get** (it's free, ~7GB download)
4. Wait for it to install
5. Open Xcode once, accept the license agreement

### 2. Install Homebrew (Required)

Open **Terminal** (search "Terminal" in Spotlight) and paste:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Press Enter and follow the prompts. This takes a few minutes.

### 3. Install XcodeGen (Required)

In Terminal, paste:

```bash
brew install xcodegen
```

---

## Get Started

### Step 1: Download This Project

In Terminal:

```bash
git clone https://github.com/KenKaiii/kens-ios-app.git
cd kens-ios-app
```

### Step 2: Generate the Xcode Project

```bash
xcodegen generate
```

### Step 3: Open in Xcode

```bash
open BoilerplateApp.xcodeproj
```

### Step 4: Run the App

1. In Xcode, click the play button (▶️) at the top left
2. Or press `Cmd + R`
3. Pick a simulator (iPhone 15 recommended)
4. The app will launch in the simulator

---

## Make It Your Own

1. Open `project.yml` in any text editor
2. Change `name: BoilerplateApp` to `name: YourAppName`
3. Change `com.yourcompany` to your own (like `com.kenkai`)
4. In Terminal, run `xcodegen generate` again
5. Done - it's now your app

---

## Project Structure

```
BoilerplateApp/
├── App/           # App startup
├── Core/          # Infrastructure
├── Features/      # Your screens
├── Services/      # Business logic
└── Resources/     # Images & assets
```

---

## Connect

- **YouTube**: [@kenkaidoesai](https://youtube.com/@kenkaidoesai)
- **Community**: [skool.com/kenkai](https://www.skool.com/kenkai)

---

MIT License - Use it however you want.
