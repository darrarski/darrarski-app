import Foundation
import SwiftCSV

let scriptURL = URL(filePath: #filePath)
let csvURL = URL(filePath: "../../../../web/projects.csv", relativeTo: scriptURL)
let jsonURL = URL(filePath: "../../../../web/projects.json", relativeTo: scriptURL)
let csv: CSV = try EnumeratedCSV(url: csvURL, loadColumns: false)
var projects: [[String: Any]] = []

extension Collection {
  var nonEmpty: Self? { isEmpty ? nil : self }
}

for row in csv.rows {
  var project: [String: Any] = [:]
  project["date"] = row[0].trimmingCharacters(in: .whitespaces).nonEmpty
  project["type"] = row[1].trimmingCharacters(in: .whitespaces).nonEmpty
  project["name"] = row[2].trimmingCharacters(in: .whitespaces).nonEmpty
  project["tags"] = row[3].components(separatedBy: ",")
    .compactMap { $0.trimmingCharacters(in: .whitespaces).nonEmpty }
    .nonEmpty
  project["url"] = row[4].trimmingCharacters(in: .whitespaces).nonEmpty
  projects.append(project)
}

let jsonData = try JSONSerialization.data(withJSONObject: projects, options: [
  .prettyPrinted, .sortedKeys, .withoutEscapingSlashes
])
try jsonData.write(to: jsonURL)
