import AppIcon
import AppIconCreator
import Foundation

var exportURL = URL(fileURLWithPath: #file)
exportURL.deleteLastPathComponent()
exportURL.deleteLastPathComponent()
exportURL.deleteLastPathComponent()
exportURL.deleteLastPathComponent()
exportURL.appendPathComponent("project")
exportURL.appendPathComponent("DarrarskiApp")
exportURL.appendPathComponent("Assets.xcassets")
exportURL.appendPathComponent("AppIcon.appiconset")

[IconImage]
  .images(for: AppIconView(.iOS), with: [.iOS_App_Store])
  .forEach { $0.save(to: exportURL) }

[IconImage]
  .images(for: AppIconView(.macOS), with: .macOS)
  .forEach { $0.save(to: exportURL) }
