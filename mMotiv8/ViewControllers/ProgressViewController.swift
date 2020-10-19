//
//  ProgressViewController.swift
//  mMotiv8
//
//  Created by UF on 23/01/19.
//  Copyright © 2019 UF. All rights reserved.
//

import UIKit
import Charts

class ProgressViewController: UIViewController {
    
    @IBOutlet weak var lineChartView: LineChartView!
    
    var gradientLayer : CAGradientLayer!
    var sortedPPMValues :  [(key: String, value: Int)]!
    var displayedPPMValues : [(key: String, value: Int)]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        lineChartView.noDataText = ""

        setupNavigationBar()
        getPPMValuesFromServer()
    }
    
    //MARK: Private Methods
    private func setupNavigationBar(){
        
        let barBtnNavigation : UIBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "navIcon"), style: .plain, target: navigationDrawerController(), action: #selector(NavigationDrawerController.toggleDrawer))
        self.navigationItem.leftBarButtonItem = barBtnNavigation
        self.navigationItem.title = "Progress Report"
    }
    
    private func getPPMValuesFromServer(){
        
        ActivityIndicator.showIndicator(onView: self.view, withDescription: nil, Mode: .View);
        
        WebserviceManager.getPPMValues { (success, error, data) in
            
            if(success){
                
                let ppmValues = PPMValuesParser.returnParsedValues(dataArray: data)

                DispatchQueue.main.async {
                    
                    ActivityIndicator.hide()
                    
                    self.displayChart(ppmValues: ppmValues)
                }
            }
            else
            {
                DispatchQueue.main.async {
                    
                    ActivityIndicator.hide()
                    
                    let alert = UIAlertController(title: "mMotiv8", message: error, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    private func displayChart(ppmValues : [String : Int]!){
    
        if ppmValues != nil && ppmValues.keys.count > 0{
            
            sortedPPMValues = ppmValues.sorted(by: { DateFormatter.shortDateTimeFormat().date(from: $0.0)!  <  DateFormatter.shortDateTimeFormat().date(from: $1.0)! })
            
            if sortedPPMValues.count > 0{
                
                displayedPPMValues = [(key: String, value: Int)]()
                
                let data = LineChartData()

                var values = Array<ChartDataEntry>()
                var positiveValues = Array<ChartDataEntry>()
                var negativeValues = Array<ChartDataEntry>()
                
                var displayIndex = 0
                
                for index in 0..<sortedPPMValues.count{
                    
                    let ppmDict = sortedPPMValues[index]
                    let val = ppmDict.value
                    
                    if val == 0{
                        
                        if values.count > 0{
                            
                            let line = LineChartDataSet(values: values, label: nil)
                            line.colors = [UIColor.customDarkGray]
                            line.lineWidth = 2
                            line.drawCirclesEnabled = false
                            line.drawValuesEnabled = false
                            line.axisDependency = .left
                            line.drawFilledEnabled = true
                            line.fillColor = UIColor.customDarkGray
                            line.fillAlpha = 0.1
                            
                            data.addDataSet(line)
                            
                            values = Array<ChartDataEntry>()
                        }
                    }
                    else if val > 5{
                        
                        let entry = ChartDataEntry(x: Double(displayIndex), y: Double(val))
                        positiveValues.append(entry)
                        values.append(entry)
        
                        displayedPPMValues.append(ppmDict)
                        displayIndex += 1
                    }
                    else
                    {
                        let entry = ChartDataEntry(x: Double(displayIndex), y: Double(val))
                        negativeValues.append(entry)
                        values.append(entry)

                        displayedPPMValues.append(ppmDict)
                        displayIndex += 1
                    }
                }
                
                if values.count > 0{
                    
                    let line = LineChartDataSet(values: values, label: nil)
                    line.colors = [UIColor.customDarkGray]
                    line.lineWidth = 2
                    line.drawCirclesEnabled = false
                    line.drawValuesEnabled = false
                    line.axisDependency = .left
                    line.drawFilledEnabled = true
                    line.fillColor = UIColor.customDarkGray
                    line.fillAlpha = 0.1
                    
                    data.addDataSet(line)
                }
                
                
                let positiveCircles = LineChartDataSet(values: positiveValues, label: nil)
                positiveCircles.lineWidth = 0
                positiveCircles.drawCirclesEnabled = true
                positiveCircles.drawValuesEnabled = false
                positiveCircles.circleColors = [UIColor.customDarkGray]
                positiveCircles.circleHoleColor = UIColor.red
                positiveCircles.axisDependency = .left
                positiveCircles.circleHoleRadius = 6
                
                let negativeCircles = LineChartDataSet(values: negativeValues, label: nil)
                negativeCircles.lineWidth = 0
                negativeCircles.drawCirclesEnabled = true
                negativeCircles.drawValuesEnabled = false
                negativeCircles.circleColors = [UIColor.customDarkGray]
                negativeCircles.circleHoleColor = UIColor.green
                negativeCircles.axisDependency = .left
                negativeCircles.circleHoleRadius = 6
                
                data.addDataSet(positiveCircles)
                data.addDataSet(negativeCircles)
                
                let xAxis = lineChartView.xAxis
                xAxis.labelPosition = .bottom
                xAxis.wordWrapEnabled = true
                xAxis.labelTextColor = UIColor.black
                xAxis.labelFont = UIFont.init(name: CustomFonts.FontName.Montserrat_Regular.rawValue, size: 10)!
                xAxis.axisLineColor = UIColor.customDarkGray
                xAxis.valueFormatter = self
                xAxis.gridLineWidth = 1
                xAxis.gridColor = UIColor.customDarkGray.withAlphaComponent(0.5)
                xAxis.gridLineDashLengths = [2,3]
                xAxis.granularity = 1
                xAxis.labelCount = displayedPPMValues.count
                xAxis.axisMaximum = data.xMax + 0.5
                xAxis.axisMinimum = data.xMin - 0.5
                
                let yAxis = lineChartView.leftAxis
                yAxis.axisMinimum = 0
                yAxis.axisMaximum = 31
                yAxis.labelTextColor = UIColor.black
                yAxis.labelFont = UIFont.init(name: CustomFonts.FontName.Montserrat_Regular.rawValue, size: 12)!
                yAxis.axisLineColor = UIColor.customDarkGray
                yAxis.drawGridLinesEnabled = true
                yAxis.gridLineWidth = 1
                yAxis.gridColor = UIColor.customDarkGray.withAlphaComponent(0.5)
                yAxis.gridLineDashLengths = [2,3]
                yAxis.granularity = 2
                yAxis.spaceTop = 0.5
                yAxis.labelCount = 30/2

                lineChartView.rightAxis.enabled = false
                lineChartView.highlightPerDragEnabled = false
                lineChartView.highlightPerTapEnabled = false
                lineChartView.legend.enabled = false
                
                lineChartView.data = data
                lineChartView.setScaleEnabled(false)
                
                //For mantaining lable spacing
                //            let width = self.lineChartView.bounds.width > self.lineChartView.bounds.height ? self.lineChartView.bounds.height : self.lineChartView.bounds.width
                //            let labelWidth = width/CGFloat(sortedPPMValues.count)
                let zoomScale : CGFloat = CGFloat(Double(sortedPPMValues.count)*1.5/10.0)
                lineChartView.zoom(scaleX: zoomScale, scaleY: 0, xValue: data.xMax, yValue: 0, axis: .left)
                
                lineChartView.extraBottomOffset = 15
                lineChartView.insetsLayoutMarginsFromSafeArea = true
            }
        }
        else
        {
            lineChartView.noDataFont = UIFont.init(name: CustomFonts.FontName.Montserrat_Regular.rawValue, size: 16)
            lineChartView.noDataTextColor = UIColor.customDarkGray
            lineChartView.noDataText = "No PPM values to display."
            lineChartView.notifyDataSetChanged()
        }
    }
}

extension ProgressViewController: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return displayedPPMValues![min(max(Int(value), 0), displayedPPMValues.count - 1)].key
    }
}
