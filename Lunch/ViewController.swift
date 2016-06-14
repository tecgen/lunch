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
    @IBOutlet var progressView: UIProgressView!
    
    var dataSource = DataSource()
    var cantenaLocations = [String : [String : [[String:String]]]]()
    var currency = ""
    var viewMenueOfToday = true
    
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
    
    var counter:Int = 0 {
        didSet {
            let fractionalProgress = Float(counter) / 100.0
            let animated = counter != 0
            
            progressView.setProgress(fractionalProgress, animated: animated)
        }
    }
    
    func startCount() {
        self.counter = 0
        for _ in 0..<100 {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), {
                sleep(1)
                dispatch_async(dispatch_get_main_queue(), {
                    self.counter += 1
                    return
                })
            })
        }
    }
    
    @IBAction func refresh() {
        startCount()
        cantenaLocations = dataSource.loadData()
        showContent()
        counter = 0
    }
    
    func generateHtml() -> String {
        var html = "<html><head><style>html {font-size: 200%; color: #134094; } body {font-family: Verdana, 'Lucida Sans Unicode', sans-serif;} h1,h2,h3,h4,div { text-shadow: 0px 0px 6px rgba(0, 0, 0, 0.4); } p {color:blue;} .date { font-weight:bold; margin-top: 1em; margin-bottom: 1em; } </style></head><body><h1>Kantine</h1>"
        
        // using the data structure
        for (location, menue) in cantenaLocations {
            html += "<h2>" + location + "</h2>"
            
            // order dates
            var datesOrdered = [String]()
            for date in menue.keys {
                datesOrdered.append(date)
            }
            datesOrdered.sortInPlace({ (value1: String, value2: String) -> Bool in return value1 < value2 })
            
            // following is not ordered by date! why?
            // for (date, foods) in menue
            // „Items in a Dictionary may not necessarily be iterated in the same order as they were inserted. The contents of a Dictionary are inherently unordered, and iterating over them does not guarantee the order in which they will be retrieved.“ (Apple Inc. „The Swift Programming Language.“)
            
            for date in datesOrdered {
                let foods = menue[date]
                
                if(!viewMenueOfToday) {
                    html += "<div class=\"date\">" + date + "</div>"
                }
                html += "<ul>"
                
                for food in foods! {
                    for (var name, price) in food {
                        
                        name = dataSource.cleanUpTheString(name)
                        name = dataSource.enrichWithEmoji(name)
                        
                        if(viewMenueOfToday) {
                            if (date == dataSource.today()) {
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

    override func viewDidLoad() {
        super.viewDidLoad()
        progressView.setProgress(0, animated: true)
        
        //showContent()
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