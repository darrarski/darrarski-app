# <img src="project/DarrarskiApp/Assets.xcassets/AppIcon.appiconset/Mac 128pt 2x.png" height="128" align="right"> Darrarski.app

![Swift v5.9](https://img.shields.io/badge/swift-v5.9-orange.svg)
![platforms iOS, macOS](https://img.shields.io/badge/platforms-iOS,_macOS-blue.svg)

Hello, my name is Dariusz and this is the iOS & macOS SwiftUI application about my work and services.

[<img src="web/assets/appstore.png" width="200" alt="Download on the App Store">](https://apps.apple.com/app/darrarski/id6463758169)
[<img src="web/assets/testflight.png" width="200" alt="Available on TestFlight">](https://testflight.apple.com/join/sGoIvYtI) 

<img src="web/assets/darrarski-app-no-icon-1280x640.png" alt="Darrarski.app screenshots">

## 📖 Documentation

Darrarski.app is as an example of a modular iOS & macOS application built with [Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture). The repository contains Xcode Workspace, in which all the source code is organized.

### Project structure

The whole project is organized within Xcode workspace, which should be used for development.

```
DarrarskiApp ---------------- Xcode workspace
 ├─ README.md --------------- this file
 ├─ DarrarskiApp ------------ Xcode project
 │   └─ DarrarskiApp -------- iOS & macOS application target
 ├─ app --------------------- swift package with the app source code
 │   ├─ AppFeature ---------- root app feature library
 │   ├─ AppShared ----------- library with shared source code
 │   ├─ ContactFeature ------ contact screen feature library
 │   ├─ FeedFeature --------- feed screen feature library
 │   ├─ Mastodon ------------ Mastodon client library
 │   └─ ProjectsFeature ----- projects screen feature library
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

### Libraries

Individual features of the application are implemented as libraries produced by Swift packages.

| Library | Description |
|:--|:--|
| [AppFeature](app/Sources/AppFeature) | Root feature of the application. Manages application state and presents split view or tabs navigation UI, depending on platform and device.
| [AppShared](app/Sources/AppShared) | Contains source code shared between other libraries.
| [ContactFeature](app/Sources/ContactFeature) | Contains contact screen UI, as well as the logic responsible for loading contact information from the backend.
| [FeedFeature](app/Sources/FeedFeature) | Implements social feed screen, based on posts fetched from Mastodon. Presents statuses and boosts with attachments.
| [Mastodon](app/Sources/Mastodon) | Provides models and API client for Mastodon network. Implements only a small subset of the API endpoints, that are needed by the app.
| [ProjectFeature](app/Sources/ProjectsFeature) | Implements screen with a list of projects. Each project, with some basic information about it, is presented on a grid. The list is fetched from the backend.

### Previews

Each view of the application is implemented in SwiftUI and comes with a preview. The preview is driven by a real `Store` and `Reducer`, but the application dependencies are mocked up for preview purposes. For example, an API client fetch-endpoint dependency immediately returns a JSON file loaded from disk, instead of performing an actual network request. This behavior allows for easier UI development in Xcode, in isolation from the outside world.

![Screenshot of Xcode running feed screen preview](web/assets/xcode-preview-feed.png)

### App icon

_app-icon package, AppIcon library, app-icon-export executable_

### Tests

_unit tests, test plans, schemes_

### Telemetry

_TelemetryDeck, AppTelemetryReducer_

### CI/CD

_Xcode Cloud, tests, deployment, version tags, generating WhatToTest_

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
