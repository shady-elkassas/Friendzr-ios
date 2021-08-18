//
//  EventDetailsVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 17/08/2021.
//

import UIKit
import Charts
import SwiftUI

class EventDetailsVC: UIViewController {

    @IBOutlet weak var chartContainerView: UIView!
    @IBOutlet weak var pieChartView: PieChartView!
    
    var child = UIHostingController(rootView: CircleView())

//    var pieChart = PieChartView()
    var numbers:[Double] = [1,2,3]
    var genders:[String] = ["Men","Women","Other"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        child.view.translatesAutoresizingMaskIntoConstraints = false
        child.view.frame = chartContainerView.bounds
        chartContainerView.addSubview(child.view)

//        setChart(months: genders, numbers: numbers)
//        chartContainerView.cornerRadiusView(radius: 21)
    }
    
    func setChart(months: [String], numbers: [Double]) {
        pieChartView.delegate = self

        var entries = [ChartDataEntry]()
        for i in 0..<numbers.count {
            entries.append(ChartDataEntry(x: Double(i), y: numbers[i]))
        }
        
        let set = PieChartDataSet(entries: entries)
        set.colors = ChartColorTemplates.colorful()
        let data = PieChartData(dataSet: set)
        pieChartView.data = data
        set.drawValuesEnabled = true
        pieChartView.backgroundColor = .white
        
    }
}

extension EventDetailsVC :ChartViewDelegate {
    
}
