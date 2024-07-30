import AppIcon
import AppIconCreator
import Foundation

let exportURL = URL(
  filePath: "../../../../Projects/App/DarrarskiApp/Resources/Assets.xcassets/AppIcon.appiconset",
  relativeTo: URL(filePath: #filePath)
)

[IconImage]
  .images(for: AppIconView(.iOS), with: [.iOS_App_Store])
  .forEach { $0.save(to: exportURL) }

[IconImage]
  .images(for: AppIconView(.macOS), with: .macOS)
  .forEach { $0.save(to: exportURL) }
