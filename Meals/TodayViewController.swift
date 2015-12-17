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
    
    func showMealsOfToday() {
        let CR = "\n"
        var meals = ""
        
        // build the menue
        meals += "° Schnitzel mit Pommes 🍟" + CR
        meals += "° Salat mit Tomaten" + CR
        
        label.text = meals
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
