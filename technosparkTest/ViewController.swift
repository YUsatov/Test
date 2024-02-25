
//  ViewController.swift
//  technosparkTest
//
//  Created by book on 20.02.2024.

import Charts
import SnapKit

final class ViewController: UIViewController, PresenterOutput {
	var presenter: PresenterInput? {
		didSet {
			circleMarker.presenter = presenter
		}
	}
	
	private let circleMarker = CircleMarker()
	
	private let chartLine: LineChartView = {
		let chart = LineChartView()
		chart.xAxis.drawGridLinesEnabled = false
		chart.leftAxis.drawGridLinesEnabled = false
		chart.rightAxis.drawGridLinesEnabled = false
		chart.drawGridBackgroundEnabled = false
		chart.xAxis.drawLabelsEnabled = false
		chart.leftAxis.drawLabelsEnabled = false
		chart.rightAxis.drawLabelsEnabled = false
		chart.legend.enabled = false
		chart.xAxis.enabled = false
		chart.leftAxis.enabled = false
		chart.rightAxis.enabled = false
		chart.drawBordersEnabled = false
		chart.minOffset = 16
		chart.drawMarkers = true
			
		return chart
	}()
	
	private let buttonFile: UIButton = {
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.isUserInteractionEnabled = true
		button.backgroundColor = .systemBlue
		button.setTitle("Open File", for: .normal)
		button.layer.cornerRadius = 10
		button.layer.shadowColor = UIColor.black.cgColor
		button.layer.shadowOffset = .init(width: 4, height: 4)
		button.layer.shadowOpacity = 0.7
		button.layer.shadowRadius = 4
		return button
	}()
		
		
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		chartLine.marker = circleMarker
		buttonFile.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
		
		view.addSubview(buttonFile)
		view.addSubview(chartLine)
		chartLine.snp.makeConstraints {
			$0.right.left.equalToSuperview()
			$0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
		}
		buttonFile.snp.makeConstraints {
			$0.top.equalTo(chartLine.snp.bottom)
			$0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
			$0.centerX.equalToSuperview()
			$0.width.equalTo(100)
		}
	}
	
	func showChooseFile(controller: UIDocumentPickerViewController) {
		present(controller, animated: true)
	}

	func showGrafic(data: LineChartData) {
		chartLine.data = data
	}
	
	@objc private func buttonPressed() {
		presenter?.didTapAddButton()
	}
}

private final class CircleMarker: MarkerView {
	private var labelText: String = ""
	private let attrs: [NSAttributedString.Key: AnyObject] = {
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.alignment = .center
		return [
			.font: UIFont.systemFont(ofSize: 10),
			.foregroundColor: UIColor.black,
			.paragraphStyle: paragraphStyle
		]
	}()
	
	
	var presenter: PresenterInput?

	override func draw(context: CGContext, point: CGPoint) {
		super.draw(context: context, point: point)
		
		let labelWidth = labelText.size(withAttributes: attrs).width + 10
		let labelHeight = labelText.size(withAttributes: attrs).height + 4

		var rectangle = CGRect(x: point.x, y: point.y, width: labelWidth, height: labelHeight)
		let halfRectangleWidth = rectangle.width / 2.0
		switch point.x {
		case 0...halfRectangleWidth:
			break
		case (UIScreen.main.bounds.width - halfRectangleWidth)...Double.infinity:
			rectangle.origin.x -= rectangle.width
		default:
			rectangle.origin.x -= halfRectangleWidth
		}
		
		let spacing: CGFloat = 20
		rectangle.origin.y -= rectangle.height + spacing

		let clipPath = UIBezierPath(roundedRect: rectangle, cornerRadius: 6.0).cgPath
		context.addPath(clipPath)
		context.setFillColor(UIColor.white.cgColor)
		context.setStrokeColor(UIColor.black.cgColor)
		context.closePath()
		context.drawPath(using: .fillStroke)

		labelText.draw(with: rectangle, options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
	}
	
	override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
		labelText = presenter?.text(from: entry) ?? ""
	}
}
