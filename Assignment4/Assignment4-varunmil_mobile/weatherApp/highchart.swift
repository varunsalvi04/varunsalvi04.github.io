import Highcharts
import UIKit
import SwiftUI


class HighchartView: UIView {
    
    
    var chartData: [[Any]] = []
    
    private var chartView: HIChartView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupChart()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupChart()
    }
    
    public func setupChart() {
        chartView = HIChartView(frame: bounds)
        guard let chartView = chartView else { return }
        
        let options = HIOptions()
        
        let chart = HIChart()
        chart.type = "arearange"
        chart.scrollablePlotArea = HIScrollablePlotArea()
        chart.scrollablePlotArea.minWidth = 350
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
        tooltip.shared = true
        tooltip.valueSuffix = "°C"
        tooltip.xDateFormat = "%A, %b %e"
        options.tooltip = tooltip
        
        let legend = HILegend()
        legend.enabled = false
        options.legend = legend
        
//        print(temperatureRange)
        let temperatures = HIArearange()
        temperatures.name = "Temperatures"
        temperatures.data = chartData
        print(chartData)
        
        // Create gradient color correctly
        let gradientColor = HIColor(linearGradient: [
            "x1": 0,
            "y1": 0,
            "x2": 0,
            "y2": 1
        ], stops: [
            [0, "#DED1B8"],
            [1, "#CED3D4"]
        ])

        temperatures.fillColor = gradientColor


        
        options.series = [temperatures]
        
        chartView.options = options
        addSubview(chartView)
    }
    
       
    
    override func layoutSubviews() {
        super.layoutSubviews()
        chartView?.frame = bounds
    }
}

struct HighchartViewRepresentable: UIViewRepresentable {
    var data: [[Any]]
    
    func makeUIView(context: Context) -> HighchartView {
                let highChartTempView = HighchartView(frame: .zero)
        highChartTempView.chartData =  data
        return highChartTempView;
    }
    
    func updateUIView(_ uiView: HighchartView, context: Context) {
        // Handle updates if necessary
        
        // Update data if it changes
                uiView.chartData = data
                uiView.setupChart()
    }
    
    
}


