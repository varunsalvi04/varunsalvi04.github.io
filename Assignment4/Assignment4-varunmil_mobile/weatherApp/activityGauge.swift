import SwiftUI
import Highcharts
import UIKit

class GaugeController: UIViewController {
    
    var weatherData: (precipitation: Double, humidity: Double, cloudCover: Double)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let chartView = HIChartView(frame: view.bounds)
        chartView.plugins = ["solid-gauge"]
        
        let options = HIOptions()
        
        let chart = HIChart()
        chart.type = "solidgauge"
        chart.height = "110%"
        options.chart = chart
        
        let title = HITitle()
        title.text = "WEATHER DATA"
        title.style = HICSSObject()
        title.style.fontSize = "24px"
        options.title = title
        
        let tooltip = HITooltip()
        tooltip.backgroundColor = HIColor(rgba: 0, green: 0, blue: 0, alpha: 0)
        tooltip.borderWidth = 0
        tooltip.shadow = HIShadowOptionsObject()
        tooltip.shadow.opacity = 0
        tooltip.style = HICSSObject()
        tooltip.style.fontSize = "16px"
        tooltip.valueSuffix = "%"
        tooltip.pointFormat = "{series.name}<br><span style=\"font-size:2em; color: {point.color}; font-weight: bold\">{point.y}</span>"
        tooltip.positioner = HIFunction(jsFunction: "function (labelWidth) { return { x: (this.chart.chartWidth - labelWidth) / 2, y: (this.chart.plotHeight / 2) + 15 }; }")
        options.tooltip = tooltip
        
        let pane = HIPane()
        pane.startAngle = 0
        pane.endAngle = 360
        
        let background1 = HIBackground()
        background1.backgroundColor = HIColor(rgba: 130, green: 238, blue: 106, alpha: 0.35)
        background1.outerRadius = "112%"
        background1.innerRadius = "88%"
        background1.borderWidth = 0
        
        let background2 = HIBackground()
        background2.backgroundColor = HIColor(rgba: 106, green: 165, blue: 231, alpha: 0.35)
        background2.outerRadius = "87%"
        background2.innerRadius = "63%"
        background2.borderWidth = 0
        
        let background3 = HIBackground()
        background3.backgroundColor = HIColor(rgba: 230, green: 52, blue: 56, alpha: 0.35)
        background3.outerRadius = "62%"
        background3.innerRadius = "38%"
        background3.borderWidth = 0
        
        pane.background = [
            background1, background2, background3
        ]
        
        options.pane = [pane]
        
        
        let yAxis = HIYAxis()
        yAxis.min = 0
        yAxis.max = 100
        yAxis.lineWidth = 0
        
        // Fix: Remove ticks
        yAxis.tickPositions = []
        
        // Fix: Remove labels
        let labels = HILabels()
        labels.enabled = false
        yAxis.labels = labels
        options.yAxis = [yAxis]
        
        let plotOptions = HIPlotOptions()
        plotOptions.solidgauge = HISolidgauge()
        let dataLabels = HIDataLabels()
        dataLabels.enabled = false
        plotOptions.solidgauge.dataLabels = [dataLabels]
        plotOptions.solidgauge.linecap = "round"
        plotOptions.solidgauge.stickyTracking = false
        plotOptions.solidgauge.rounded = true
        options.plotOptions = plotOptions
        
        let precipitationGauge = HISolidgauge()
        precipitationGauge.name = "Precipitation"
        let precipitationData = HIData()
        precipitationData.color = HIColor(rgba: 137, green: 206, blue: 62, alpha: 1)
        precipitationData.radius = "112%"
        precipitationData.innerRadius = "88%"
        precipitationData.y = NSNumber(value: weatherData!.precipitation)
        precipitationGauge.data = [precipitationData]
        
        let humidityGauge = HISolidgauge()
        humidityGauge.name = "Humidity"
        let humidityData = HIData()
        humidityData.color = HIColor(rgba: 106, green: 165, blue: 231, alpha: 1)
        humidityData.radius = "87%"
        humidityData.innerRadius = "63%"
        humidityData.y = NSNumber(value: weatherData!.humidity)
        humidityGauge.data = [humidityData]
        
        let cloudCoverGauge = HISolidgauge()
        cloudCoverGauge.name = "Cloud Cover"
        let cloudCoverData = HIData()
        cloudCoverData.color = HIColor(rgba: 229, green: 121, blue: 118, alpha: 1)
        cloudCoverData.radius = "62%"
        cloudCoverData.innerRadius = "38%"
        cloudCoverData.y = NSNumber(value: weatherData!.cloudCover)
        cloudCoverGauge.data = [cloudCoverData]
        
        options.series = [precipitationGauge, humidityGauge, cloudCoverGauge]
        
        chartView.options = options
        
        self.view.addSubview(chartView)
    }
    
}



struct GaugeView: UIViewControllerRepresentable {
    
    let weatherData: (precipitation: Double, humidity: Double, cloudCover: Double)
    
    func makeUIViewController(context: Context) -> GaugeController {
        let controller = GaugeController()
        controller.weatherData = weatherData
        return controller
    }
    
    func updateUIViewController(_ uiViewController: GaugeController, context: Context) {
    }
}
