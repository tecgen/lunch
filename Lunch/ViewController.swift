//
//  ViewController.swift
//  Lunch
//
//  Created by Marco Pehla on 21.09.15.
//  Copyright © 2015 Marco Pehla. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var display: UILabel!
    @IBOutlet var webview: UIWebView!
    
    var locations = [String : [String : [[String:String]]]]()
    var locationURLs = [String : String]()
    var currency = "";
    var locationSelection = "";
    
    var viewMenueOfToday = true
    
    // locations with links to the local menues
    var rootURL = "https://www.dropbox.com/s/xze0tpqpc264m5i/locations.json?dl=1"
    
    
    @IBAction func segmentControl(sender: UISegmentedControl, forEvent event: UIEvent) {
        
        switch sender.selectedSegmentIndex {
        case 0: // today
            viewMenueOfToday = true
        case 1: // week
            viewMenueOfToday = false
        default:
            viewMenueOfToday = true
        }
        showContent()
    }
    
    @IBAction func refresh() {
        
        loadData()
        showContent()
    }
    
    func loadData() {
        
        // only reload when no local data is available
        if(locationURLs.keys.isEmpty) {
            do {
                let jsonLocation = try NSJSONSerialization.JSONObjectWithData(self.getJSON(rootURL), options: .AllowFragments)
            
                for anItem in jsonLocation as! [Dictionary<String, AnyObject>] {
                    let location = anItem["name"] as! String
                    let mealURL = anItem["url"] as! String
                
                    // add to locale data structure
                    locationURLs[location] = mealURL
                    currency = anItem["currency"] as! String
                }
            
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
        }
            
        if locationSelection.isEmpty {
            // use the first location when not selected
            self.locationSelection = Array(locationURLs.keys)[0]
        }
       
        // initialise keys in map for all known locations, but ...
        for location in locationURLs.keys {
            locations[location] = nil
        }
        
        // define data structure: day / list of foods
        var menueOfDay = [String : [[String:String]]]()
        
        do {
            // get only data for the currently selected location
            let jsonMeal = try NSJSONSerialization.JSONObjectWithData(self.getJSON(locationURLs[locationSelection]!), options: .AllowFragments)
        
            for localMeal in jsonMeal as! [Dictionary<String, AnyObject>] {
                let meal = localMeal["foods"] as! String
                var mealDate = localMeal["date"] as! String
                let mealPrice = localMeal["price"] as! Double
            
                // drop everything but the date e.g. 2015-12-01
                let index : String.Index = mealDate.startIndex.advancedBy(10)
                mealDate = mealDate.substringToIndex(index)
                
                
                // if the menue of the current day is not filled
                
                if(menueOfDay[mealDate] == nil) {
                    menueOfDay[mealDate] = [[String:String]]()
                }
            
                var food = [String : String]()
                food[meal] = "\(mealPrice)0" //FIXME: 0.99 values
                
                // get list of foods and append current one
                menueOfDay[mealDate]?.append(food)
            }

            locations[locationSelection] = menueOfDay
        } catch let error as NSError {
            print("Failed to load: \(error.localizedDescription)")
        }
        
    }
    
    func generateHtml() -> String {
        var html = "<html><head><style>html {font-size: 200%; color: #134094; } body {font-family: Verdana, 'Lucida Sans Unicode', sans-serif;} h1,h2,h3,h4,div { text-shadow: 0px 0px 6px rgba(0, 0, 0, 0.4); } p {color:blue;} .date { font-weight:bold; margin-top: 1em; margin-bottom: 1em; } </style></head><body><h1>Kantine</h1>"
        
        // using the data structure
        for (location, menue) in locations {
            html += "<h2>" + location + "</h2>"
            
            // order dates
            var datesOrdered = [String]()
            for date in menue.keys {
                datesOrdered.append(date)
            }
            datesOrdered.sortInPlace({ (value1: String, value2: String) -> Bool in return value1 < value2 })
            
            // following is not ordered by date! why?
            // for (date, foods) in menue
            for date in datesOrdered {
                let foods = menue[date]
                
                if(!viewMenueOfToday) {
                    html += "<div class=\"date\">" + date + "</div>"
                }
                html += "<ul>"
                
                for food in foods! {
                    for (var name, price) in food {
                        
                        name = self.cleanUpTheString(name)
                        name = self.enrichWithEmoji(name)
                        
                        if(viewMenueOfToday) {
                            if (date == self.today()) {
                                html += "<li>\(name), \(price) " +  currency + "</li>"
                            }
                        } else {
                            html += "<li>\(name), \(price) " +  currency + "</li>"
                        }
                    }//for-food
                }//for-foods
                html += "</ul>"
            }//for-date
        }//for-location
        html += "</body></html>"
        return html;
    }//end-method
    
   
    func showContent() {
        webview.scalesPageToFit = true
        
        let html = self.generateHtml();
        webview.loadHTMLString(html, baseURL: nil);
        
        // remote page need to use https in iOS 9
        // workaround:
        // https://forums.developer.apple.com/thread/3544
        // doc:
        // https://developer.apple.com/library/prerelease/ios/technotes/App-Transport-Security-Technote/index.html
        
        // webview.loadRequest(NSURLRequest(URL: NSURL(string: website)!))
        webview.delegate = self
    }

    func getJSON(urlToRequest: String) -> NSData {
        return NSData(contentsOfURL: NSURL(string: urlToRequest)!)!
    }
    
    /**
     * get today's date as string
     */
    func today() -> String {
        let now = NSDate()
        let formatter  = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.stringFromDate(now)
    }
    
    /**
     * clean up the string by dropping misleading characters
     */
    func cleanUpTheString(var s: String) -> String {
        let toDrop = ["(A)", "(B)", "(Z)", "\t"]
        for str in toDrop {
            s = s.stringByReplacingOccurrencesOfString(str, withString: "")
        }
        return s
    }
    
    func enrichWithEmoji(var s : String) -> String {
        let toEnrich = ["Pommes" : "🍟", "Burger" : "🍔", "Pizza" : "🍕", "Hotdog" : "🌭", "HotDog" : "🌭", "Hot Dog" : "🌭", "Eier" : "🍳", "Pasta" : "🍜", "Spaghetti" : "🍝", "Taco" : "🌮", "Burrito" : "🌯", "Sandwich" : "🍞"]
        
        for key in toEnrich.keys {
            // http://stackoverflow.com/questions/14331001/emoji-shrink-on-mobile-safari-and-uiwebview
            // not working in Simulator
            //let emoji = "<span style=\"font-size: 120.0px; font-family: \"AppleColorEmoji\";\">" + toEnrich[key]! + "</span>"
            
            // http://stackoverflow.com/questions/19702013/emojis-wont-scale-beyond-16px-font-size-on-ios-7
            let emoji = "<span style=\"-webkit-transform: scale(2); position: absolute;\">" + toEnrich[key]! + "</span>"
            
            
            //let emoji = toEnrich[key]!
            s = s.stringByReplacingOccurrencesOfString(key, withString: key + "&nbsp;" + emoji + "&nbsp;&nbsp;&nbsp;")
        }
        
        return s

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        refresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        print("Webview fail with error \(error)");
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return true;
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
    }

}