//
//  ResultTableViewController.swift
//  PokerLog
//
//  Created by Mike Mailian on 17.01.2021.
//

import UIKit
import RealmSwift
import AAInfographics

class ResultTableViewController: UITableViewController {
    
    @IBOutlet var timePeriodSegment: UISegmentedControl!
    @IBOutlet var chartViewBox: UIView!
    @IBOutlet var resultLabel: UILabel!
    @IBOutlet var winRateLabel: UILabel!
    @IBOutlet var sessionAverageLabel: UILabel!
    @IBOutlet var resultViewBox: UIView!
    @IBOutlet var chartBox: UIView!
    
    let realm = try! Realm()
    
    let sessionCard  = SessionCard()
    
    var data:[Double] = []
    var sessionDate:[String] = []
    
    var dataForGraph:[Double] = [0]
    
    let aaChartView = AAChartView()
    let aaChartModel = AAChartModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundView = UIImageView(image: UIImage(named: "Background.png"))
                
        // Transparent Navigation Bar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
        resultViewBox.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        resultViewBox.layer.borderWidth = 1
        resultViewBox.layer.cornerRadius = 10
        
        chartBox.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        chartBox.layer.borderWidth = 1
        chartBox.layer.cornerRadius = 10
        
     
        
        // Draw chart for the 1 time.
        appendData()
        drawChartView()
        timePeriodSegment.selectedSegmentIndex = 4
        // Making segmented control text color = white.
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        timePeriodSegment.setTitleTextAttributes(titleTextAttributes, for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let result: Int = realm.objects(SessionCard.self).sum(ofProperty: "profit")
        let hours: Int = realm.objects(SessionCard.self).sum(ofProperty: "timePlayed")
        
        showResultAndWinrate(result: result, hours: hours, sessionAverage: calcAverage(result: result, hours: hours))
        
        self.data.removeAll()
        self.sessionDate.removeAll()
        
        //FIXME: - Bad decision
        dataForGraph.removeAll()
        dataForGraph.append(0)
        
        self.appendData()
        timePeriodSegment.selectedSegmentIndex = 4
        DispatchQueue.main.async {
            self.reloadChartWith()
        }
    }
    
    // appending data for chart.
    func appendData() {
        let profit = realm.objects(SessionCard.self).sorted(byKeyPath: "sortDate", ascending: true).value(forKey: "profit") as! [Double]
        let date = realm.objects(SessionCard.self).sorted(byKeyPath: "sortDate", ascending: true).value(forKey: "date") as! [String]
        // Iterating through Realm Objects.
        for i in 0..<realm.objects(SessionCard.self).count {
            data.append(profit[i])
            sessionDate.append(date[i])
        }
    }
    
    @IBAction func segmentedControlAction(_ sender: UISegmentedControl) {
        let currentDate = Calendar.current.date(byAdding: .minute, value: 1, to: sessionCard.sortDate)!
        // Calculating what period to filter in months and show in data
        func showDynamicData (months: Int) {
            self.data.removeAll()
            self.sessionDate.removeAll()
            let lastMounthCount = Calendar.current.date(byAdding: .month, value: months, to: currentDate)!
            
            let result: Int = realm.objects(SessionCard.self).filter("sortDate BETWEEN {%@, %@}", lastMounthCount, currentDate).sum(ofProperty: "profit")
            let hours: Int = realm.objects(SessionCard.self).filter("sortDate BETWEEN {%@, %@}", lastMounthCount, currentDate).sum(ofProperty: "timePlayed")
            
            let data = realm.objects(SessionCard.self).filter("sortDate BETWEEN {%@, %@}", lastMounthCount, currentDate).sorted(byKeyPath: "sortDate", ascending: true).value(forKey: "profit") as! [Double]
            
            let categories = realm.objects(SessionCard.self).filter("sortDate BETWEEN {%@, %@}", lastMounthCount, currentDate).sorted(byKeyPath: "sortDate", ascending: true).value(forKey: "date") as! [String]
            
            //FIXME: - Bad decision
            dataForGraph.removeAll()
            dataForGraph.append(0)
            
            //show dynamic winrate
            showResultAndWinrate(result: result, hours: hours, sessionAverage: calcAverage(result: result, hours: hours))
            self.data.append(contentsOf: data)
            self.sessionDate.append(contentsOf: categories)
            reloadChartWith()
            
        }
        
        switch sender.selectedSegmentIndex {
        case 0:
            showDynamicData(months: -1)
        case 1:
            showDynamicData(months: -3)
        case 2:
            showDynamicData(months: -6)
        case 3:
            showDynamicData(months: -12)
        default:
            data.removeAll()
            sessionDate.removeAll()
            
            //FIXME: - Bad decision
            dataForGraph.removeAll()
            dataForGraph.append(0)
            
            appendData()
            reloadChartWith()
        }
    }
    
    func calcAverage(result: Int, hours: Int) -> Int  {
        if result != 0 && hours != 0 {
            return result/realm.objects(SessionCard.self).count
        } else {
            return 0
        }
    }
    
    func showResultAndWinrate(result: Int, hours: Int, sessionAverage: Int) {
        var winRate = 0
        
        if result != 0 && hours != 0 {
            let myWinRate = result/hours
            winRate = myWinRate
        }
        if result > 0 {
            resultLabel.text = "+\(result)"
            winRateLabel.text = "+\(winRate)"
            sessionAverageLabel.text = "+\(sessionAverage)"
            resultLabel.textColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
            winRateLabel.textColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
            sessionAverageLabel.textColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)

        } else if result < 0 {
            resultLabel.text = String(result)
            winRateLabel.text = String(winRate)
            sessionAverageLabel.text = String(sessionAverage)
            resultLabel.textColor = #colorLiteral(red: 0.968627451, green: 0.3607843137, blue: 0.3921568627, alpha: 1)
            winRateLabel.textColor = #colorLiteral(red: 0.968627451, green: 0.3607843137, blue: 0.3921568627, alpha: 1)
            sessionAverageLabel.textColor = #colorLiteral(red: 0.968627451, green: 0.3607843137, blue: 0.3921568627, alpha: 1)
        } else {
            resultLabel.text = String(result)
            winRateLabel.text = String(winRate)
            sessionAverageLabel.text = String(sessionAverage)
            resultLabel.textColor = #colorLiteral(red: 0.4156862745, green: 0.5254901961, blue: 0.8078431373, alpha: 1)
            winRateLabel.textColor = #colorLiteral(red: 0.4156862745, green: 0.5254901961, blue: 0.8078431373, alpha: 1)
            sessionAverageLabel.textColor = #colorLiteral(red: 0.4156862745, green: 0.5254901961, blue: 0.8078431373, alpha: 1)
        }
    }
    
    //FIXME: - Bad decision
    func showCorrectGraph() {
        for i in 0..<data.count {
            let newNumber = dataForGraph[i] + data[i]
            dataForGraph.append(Double(newNumber))
        }
    }

}

//MARK: - CHART SETTINGS AND RELOAD METHODS.
extension ResultTableViewController {
    // Draw chart for the 1 time with settings.
    func drawChartView() {
        showCorrectGraph()
        dataForGraph.remove(at: 0)
        
        let chartViewHeight = chartViewBox.frame.height
        let chartViewWidth = chartViewBox.frame.width
        aaChartView.frame.size.height = chartViewHeight
        aaChartView.frame.size.width = chartViewWidth
        aaChartView.bounds = chartViewBox.bounds
        chartViewBox.addSubview(aaChartView)
        
        aaChartView.scrollEnabled = false
        aaChartView.isClearBackgroundColor = true
        aaChartModel
            .chartType(.areaspline)
            .axesTextColor("white")
            .markerSymbol(.circle)
            .animationType(.easeInOutQuad)
            .animationDuration(1000)
            .legendEnabled(false)
            .xAxisLabelsEnabled(false)
            .categories(sessionDate)
            .colorsTheme(["#6A86CE"])
            .series([
                AASeriesElement()
                    .name("💰 ")
                    .data(dataForGraph)
            ])
        aaChartView.aa_drawChartWithChartModel(aaChartModel)
    }
    
    // Reload method with filtered data.
    func reloadChartWith() {
        showCorrectGraph()
        dataForGraph.remove(at: 0)
        self.aaChartModel
            .categories(sessionDate)
            .series([
                AASeriesElement()
                    .name("💰 ")
                    .data(dataForGraph)
            ])
        self.aaChartView.aa_refreshChartWholeContentWithChartModel(self.aaChartModel)
    }
    
    
}
