import Highcharts
import UIKit
import SwiftUI

extension Date {
    func currentTimeMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}

class HighChartController: UIViewController {
    var chartData: [[Any]] = [[]]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let chartView = HIChartView(frame: view.bounds)
        
        let options = HIOptions()
        
        let chart = HIChart()
        chart.type = "arearange"
        //    chart.zoomType = "x"
        chart.scrollablePlotArea = HIScrollablePlotArea()
        chart.scrollablePlotArea.minWidth = 50
        chart.scrollablePlotArea.scrollPositionX = 1
        options.chart = chart
        
        let title = HITitle()
        title.text = "Temperature variation by day"
        options.title = title
        
        let xAxis = HIXAxis()
        xAxis.type = "datetime"
        xAxis.accessibility = HIAccessibility()
        xAxis.accessibility.rangeDescription = "Range: Jan 1st 2017 to Dec 31 2017."
        options.xAxis = [xAxis]
        
        let yAxis = HIYAxis()
        yAxis.title = HITitle()
        options.yAxis = [yAxis]
        
        let tooltip = HITooltip()
        //     tooltip.crosshairs = true
        tooltip.shared = true
        tooltip.valueSuffix = "°C"
        tooltip.xDateFormat = "%A, %b %e"
        options.tooltip = tooltip
        
        let legend = HILegend()
        legend.enabled = false
        options.legend = legend
        
        let temperatures = HIArearange()
        temperatures.name = "Temperatures"
        temperatures.data = chartData
        
        options.series = [temperatures]
        
        chartView.options = options
        
        self.view.addSubview(chartView)
    }
    
    private func getData() -> [Any] {
        return [
            [1483232400000, 1.4, 4.7],
            [1483318800000, -1.3, 1.9],
            [1483405200000, -0.7, 4.3],
            [1483491600000, -5.5, 3.2],
            [1483578000000, -9.9, -6.6]
        ]
    }
    
}


struct NewHighchartView: UIViewControllerRepresentable {
    var data: [[Any]]
    func makeUIViewController(context: Context) -> HighChartController {
        let highChartController = HighChartController()
        highChartController.chartData = data
        return highChartController
    }
    
    func updateUIViewController(_ uiViewController: HighChartController, context: Context) {
        // No updates needed for now
    }
}
