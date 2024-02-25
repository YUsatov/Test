//
//  CSVService.swift
//  technosparkTest
//
//  Created by book on 24.02.2024.
//

import Charts
import SwiftCSV

protocol CSVServiceProtocol {
	func parse(from url: URL) -> LineChartData?
	func text(from entry: ChartDataEntry) -> String
}

final class CSVService: CSVServiceProtocol {
	private let factory = ChartDatasetFactory()

	func parse(from url: URL) -> LineChartData? {
		guard let csvFile = try? CSV<Named>(url: url) else { return nil }
		let lineChartEntries = csvFile.rows.map { row in
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
			let date = dateFormatter.date(from: row["time"] ?? "")?.timeIntervalSince1970
			return ChartDataEntry(
				x: date ?? 0,
				y: Double(row["hr"] ?? "") ?? 0
			)
		}
		let dataSet = factory.makeChartDataset(colorAsset: .first, entries: lineChartEntries)
		let data = LineChartData(dataSet: dataSet)
		return data
	}
	
	func text(from entry: ChartDataEntry) -> String {
		"\(prittyDate(from: entry.x))\n\(Int(entry.y))"
	}
	
	private func prittyDate(from timeInterval: TimeInterval) -> String {
		let date = Date(timeIntervalSince1970: timeInterval)
		let formatter = DateFormatter()
		formatter.timeStyle = .medium
		return formatter.string(from: date)
	}
}

private struct ChartDatasetFactory {
	enum DataColor {
		case first
		case second
		case third

		var color: UIColor {
			switch self {
			case .first:
				return UIColor(
					red: 56/255,
					green: 58/255,
					blue: 209/255,
					alpha: 1
				)
			case .second:
				return UIColor(
					red: 235/255,
					green: 113/255,
					blue: 52/255,
					alpha: 1
				)
			case .third:
				return UIColor(
					red: 52/255,
					green: 235/255,
					blue: 143/255,
					alpha: 1
				)
			}
		}
	}

	func makeChartDataset(
		colorAsset: DataColor,
		entries: [ChartDataEntry]
	) -> LineChartDataSet {
		let dataSet = LineChartDataSet(entries: entries, label: "")
		dataSet.drawHorizontalHighlightIndicatorEnabled = false
		dataSet.highlightLineWidth = 2
		dataSet.highlightColor = colorAsset.color
		dataSet.setColor(colorAsset.color)
		dataSet.lineWidth = 3
		dataSet.mode = .cubicBezier
		dataSet.drawValuesEnabled = false
		dataSet.drawCirclesEnabled = false
		dataSet.drawFilledEnabled = true
		return dataSet
	}
}
