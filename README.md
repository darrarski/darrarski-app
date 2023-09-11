# Darrarski App

![Swift v5.9](https://img.shields.io/badge/swift-v5.9-orange.svg)
![platforms iOS, macOS](https://img.shields.io/badge/platforms-iOS,_macOS-blue.svg)

iOS & macOS SwiftUI application about my work and services.

## 📖 Documentation

_not yet_

## 🏛 Project structure

Use Xcode workspace for development, the whole project is structured in it.

```
DarrarskiApp ---------------- Xcode workspace
 ├─ README.md --------------- this file
 ├─ DarrarskiApp ------------ Xcode project
 │   └─ DarrarskiApp -------- iOS & macOS application target
 ├─ app --------------------- swift package with the app source code
 │   ├─ AppFeature ---------- root app feature library
 │   ├─ AppShared ----------- library with shared source code
 │   ├─ ContactFeature ------ contact feature library
 │   ├─ FeedFeature --------- feed feature library
 │   ├─ Mastodon ------------ Mastodon client library
 │   └─ ProjectsFeature ----- projects feature library
 ├─ app-icon ---------------- swift package for app icon
 │   ├─ app-icon-export ----- executable, generates app icons assets
 │   └─ AppIcon ------------- library with app icon implementation
 ├─ scripts ----------------- swift package with developer scripts
 │   └─ projects-csv2json --- executable, generates projects JSON from CSV
 ├─ test-plans -------------- group with Xcode test plans
 │   ├─ DarrarskiApp -------- app full test plan
 │   ├─ AppFeature ---------- feature library test plans
 │   └─ ... 
 ├─ web --------------------- group with web server files
 └─ ci_scripts -------------- group with scripts used by Xcode Cloud
```

## 🛠 Develop

- Use Xcode (version ≥ 15.0).
- Clone the repository or create a fork & clone it.
- Open `DarrarskiApp.xcworkspace` in Xcode.
- Use the `DarrarskiApp` scheme for building and running the app.
- Use other schemes to build or test individual libraries in isolation.
- If you want to contribute, create a pull request containing your changes or bug fixes. Make sure to include tests for new/updated code.

## ☕️ Do you like the project?

<a href="https://www.buymeacoffee.com/darrarski" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" height="60" width="217" style="height: 60px !important;width: 217px !important;" ></a>

## 📄 License

Copyright © 2023 Dariusz Rybicki Darrarski

License: [MIT](LICENSE)
