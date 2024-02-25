//
//  Presenter.swift
//  technosparkTest
//
//  Created by book on 24.02.2024.
//

import Charts
import UIKit
import UniformTypeIdentifiers

protocol PresenterInput {
	func didTapAddButton()
	func text(from entry: ChartDataEntry) -> String
}

protocol PresenterOutput: AnyObject {
	func showChooseFile(controller: UIDocumentPickerViewController)
	func showGrafic(data: LineChartData)
}

final class Presenter: NSObject, PresenterInput, UIDocumentPickerDelegate {
	weak var output: PresenterOutput?

	let csvService: CSVServiceProtocol

	init(csvService: CSVServiceProtocol) {
		self.csvService = csvService
	}

	func didTapAddButton() {
		let types = UTType.types(
			tag: "csv",
			tagClass: UTTagClass.filenameExtension,
			conformingTo: nil
		)
		let documentPickerController = UIDocumentPickerViewController(forOpeningContentTypes: types)
		documentPickerController.delegate = self
		output?.showChooseFile(controller: documentPickerController)
	}
	
	func text(from entry: ChartDataEntry) -> String {
		csvService.text(from: entry)
	}

	func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
		guard
			let myURL = urls.first,
			let data = csvService.parse(from: myURL)
		else { return }
		output?.showGrafic(data: data)
	}
}
