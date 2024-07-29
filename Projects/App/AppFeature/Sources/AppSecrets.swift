import AppSecrets
import Dependencies
import Foundation

extension AppSecrets: DependencyKey {
  public static let liveValue = AppSecrets.live
  public static let testValue = AppSecrets()
  public static let previewValue = AppSecrets()
}
