import Foundation

struct TSVParser {
  func parse(_ string: String) -> [[String: String]] {
    var result: [[String: String]] = []

    // 行ごとに分割し、タブを含む行だけを残す
    let lines: [String] = string.split(separator: "\n").filter {
      $0.contains("\t")
    }.map { String($0) }

    // 行が空でないことを確認
    guard !lines.isEmpty else { return result }

    // ヘッダー行を取得
    let header = lines[0].split(separator: "\t").map { String($0) }

    // データ行をパース
    for i in 1..<lines.count {
      let row = lines[i].split(separator: "\t").map { String($0) }
      var currentRow: [String: String] = [:]
      for j in 0..<row.count {
        if j < header.count {
          currentRow[header[j]] = row[j]
        }
      }
      result.append(currentRow)
    }
    return result
  }
}
