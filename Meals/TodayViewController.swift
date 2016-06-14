//
//  TodayViewController.swift
//  Meals
//
//  Created by Marco Pehla on 17.12.15.
//  Copyright © 2015 Marco Pehla. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet var label: UILabel!
    
    var dataSource = DataSource()
    var cantenaLocations = [String : [String : [[String:String]]]]()
    
    func showMealsOfToday() {
        label.text = getMealsOfToday()
    }
    
    func getMealsOfToday() -> String {
        let CR = "\n"
        let currency = "€"
        var meals = ""
        
        
        if(cantenaLocations.isEmpty) {
            cantenaLocations = dataSource.loadData()
        } else {
            // TODO check if today's meal is available, otherwise reload data
            
            
        }
        
        // build the menue
        // using the data structure
        for (location, menue) in cantenaLocations {
            
            // order dates
            var datesOrdered = [String]()
            for date in menue.keys {
                datesOrdered.append(date)
            }
            datesOrdered.sortInPlace({ (value1: String, value2: String) -> Bool in return value1 < value2 })
            
            for date in datesOrdered {
                let foods = menue[date]
                
                for food in foods! {
                    for (var name, price) in food {
                        
                        name = dataSource.cleanUpTheString(name)
                        name = dataSource.enrichWithEmoji(name)
                        
                        
                        if (date == dataSource.today()) {
                            meals += "🍽 \(name), \(price) " +  currency + CR
                        }
                        
                    }
                }
            }
        }
        
        return meals
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view from its nib.
        
        showMealsOfToday()
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        completionHandler(NCUpdateResult.NewData)
    }
    
}
