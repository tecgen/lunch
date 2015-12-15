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
    
    var viewMenueOfToday = true;
    
    // locations with links to the local menues
    var rootURL = "https://www.dropbox.com/s/xze0tpqpc264m5i/locations.json?dl=1"
    
    
    @IBAction func segmentControl(sender: UISegmentedControl, forEvent event: UIEvent) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            viewMenueOfToday = true
        case 1:
            viewMenueOfToday = false
        default:
            viewMenueOfToday = true
        }
        refresh();
    }
    
    @IBAction func refresh() {
        loadContent()
    }
    
    
   
    func loadContent() {
        webview.scalesPageToFit = true
        
        let html = self.generateHTML();
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
        let toDrop = ["(A)", "(B)", "(Z)"]
        for str in toDrop {
            s = s.stringByReplacingOccurrencesOfString(str, withString: "")
        }
        return s
    }
    
    func generateHTML() -> String {
        var html = "<html><head><style>html {font-size: 200%; color: #134094; } body {font-family: Verdana, 'Lucida Sans Unicode', sans-serif;} h1,h2,h3,h4 { text-shadow: 0px 0px 3px rgba(0, 0, 0, 0.4); } p {color:blue;} .date { font-weight:bold; margin-top: 1em; margin-bottom: 1em; } </style></head><body><h1>Kantine</h1>"
        
        do {
            let jsonLocation = try NSJSONSerialization.JSONObjectWithData(self.getJSON(rootURL), options: .AllowFragments)
            
            for anItem in jsonLocation as! [Dictionary<String, AnyObject>] {
                let location = anItem["name"] as! String
                let mealURL = anItem["url"] as! String
                let currency = anItem["currency"] as! String
                
                html += "<h2>" + location + "</h2>"
                
                let jsonMeal = try NSJSONSerialization.JSONObjectWithData(self.getJSON(mealURL), options: .AllowFragments)
                
                var day = "";
                var listStarted = false
                
                for localMeal in jsonMeal as! [Dictionary<String, AnyObject>] {
                    let meal = localMeal["foods"] as! String
                    var mealDate = localMeal["date"] as! String
                    let mealPrice = localMeal["price"] as! Double
                    
                    // drop everything but the date e.g. 2015-12-01
                    let index : String.Index = mealDate.startIndex.advancedBy(10)
                    mealDate = mealDate.substringToIndex(index)
                    
                    
                    // just show the date once per meal
                    if (day != mealDate) {
                        day = mealDate;
                        
                        // only in week view
                        if(!viewMenueOfToday) {
                            html += "<div class=\"date\">" + day + "</div>"
                        }
                    }
                    
                    if (!listStarted) {
                        html += "<ul>"
                        listStarted = true;
                    }
                    
                    if(viewMenueOfToday) {
                        if (mealDate == self.today()) {
                            html += "<li>" + cleanUpTheString(meal) + ", \(mealPrice)0 " +  currency + " </li>"
                        } else {
                            // don't show the meal of another day than today
                        }
                    } else {
                        html += "<li>" + meal + ", \(mealPrice)0 " +  currency + " </li>"
                    }
                    
                }
                html += "</ul>"
            }
            
        } catch let error as NSError {
            print("Failed to load: \(error.localizedDescription)")
        }
        
        html.appendContentsOf("</body></html>")
        return html
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadContent()
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