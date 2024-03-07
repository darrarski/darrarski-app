# <img src="project/DarrarskiApp/Assets.xcassets/AppIcon.appiconset/Mac 128pt 2x.png" height="128" align="right"> Darrarski.app

![Swift v5.10](https://img.shields.io/badge/swift-v5.9-orange.svg)
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

### Architecture

The application and its components are built using [Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture). Each component of the application contains a state and action definition, as well as a reducer that mutates the state and handles side effects. The `State` clearly defines a data set the given component is operating on. The `Action` provides an interface for all events that the component is handling, like user interactions or receiving a response to a network request.

![Screenshot of Xcode with source code of contact reducer](web/assets/xcode-contact-reducer.png)

### Previews

Each view of the application is implemented in SwiftUI and comes with a preview. The preview is driven by a real `Store` and `Reducer`, but the application dependencies are mocked up for preview purposes. For example, an API client fetch-endpoint dependency immediately returns a JSON file loaded from disk, instead of performing an actual network request. This behavior allows for easier UI development in Xcode, in isolation from the outside world.

![Screenshot of Xcode running feed screen preview](web/assets/xcode-preview-feed.png)

### App icon

The workspace contains a Swift package named `app-icon`. It provides `AppIcon` library with SwiftUI implementation of the icon view. The included preview allows you to see how the icon will look on different platforms. The package also contains an executable - `app-icon-export`. It's used to render the icon and save it as assets for the app. This way of creating an app icon is possible thanks to [SwiftUI App Icon Creator](https://github.com/darrarski/swiftui-app-icon-creator).

![Screenshot of Xcode running app icon preview](web/assets/xcode-preview-app-icon.png)

### Tests

Every feature of the application is covered by unit tests. Each library can be tested in isolation, using the provided build scheme with the same name as the library, like `AppFeature`. All tests of the application can be run from `DarrarskiApp` build scheme.

![Screenshot of Xcode test results](web/assets/xcode-test-results.png)

### Telemetry

The application uses [TelemetryDeck](https://telemetrydeck.com/) to collect anonymous information about how it's being used by the users.

> TelemetryDeck helps app and web developers improve their product by supplying immediate, accurate usage data while users use their app. And the best part: It's all anonymized so users' data stays private!

The fact that all events that can occur in the application are defined by the reducer's actions powers the logic responsible for producing telemetry signals. [`AppTelemetryReducer`](app/Sources/AppFeature/AppTelemetryReducer.swift) is responsible for describing each action in a privacy-aware way and then sending a telemetry signal.

![Screenshot of Xcode console with telemetry logs](web/assets/xcode-telemetry-logs.png)

> [!WARNING]  
> The AppID key required to communicate with TelemetryDeck is **NOT** included in the repository. If you want to use telemetry, you need to set your own key in `app/Sources/AppFeature/Secrets/TelemetryDeckAppID`.

### CI/CD

The project is integrated with [Xcode Cloud](https://developer.apple.com/xcode-cloud/). There are two workflows defined: one that runs tests for each pull request, and one that archives the app and deploys it to TestFlight. For the deployment lane, the [ci_post_clone](ci_scripts/ci_post_clone.sh) script does some extra work. Version tag (e.g. `v1.0.0-123`) is added to the repository, and `WhatToTest` file is created with commit messages since the last tag. This file is automatically picked up by Xcode Cloud and used as release notes on App Store Connect.

![Screenshot of Xcode with cloud workflows](web/assets/xcode-cloud-deploy.png)

## 🛠 Develop

- Use Xcode (version ≥ 15.3).
- Clone the repository or create a fork & clone it.
- Open `DarrarskiApp.xcworkspace` in Xcode.
- Use the `DarrarskiApp` scheme for building and running the app.
- Use other schemes to build or test individual libraries in isolation.
- If you want to contribute, create a pull request containing your changes or bug fixes. Make sure to include tests for new/updated code.

## ☕️ Do you like the project?

I would love to hear if you like my work. I can help you apply any of the solutions used in this repository in your app too! Feel free to reach out to me, or if you just want to say "thanks", you can buy me a coffee.

<a href="https://www.buymeacoffee.com/darrarski" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" height="60" width="217" style="height: 60px !important;width: 217px !important;" ></a>

## 📄 License

Copyright © 2023 Dariusz Rybicki Darrarski

License: [MIT](LICENSE)
