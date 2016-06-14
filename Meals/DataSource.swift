//
//  DataSource.swift
//  Lunch
//
//  Created by Marco Pehla on 14.06.16.
//  Copyright © 2016 Marco Pehla. All rights reserved.
//

import Foundation

class DataSource {
    
    var locations = [String : [String : [[String:String]]]]()
    var locationURLs = [String : String]()
    var locationSelection = "";
    var currency = ""
    
    func loadData() -> [String : [String : [[String:String]]]] {
        
        // TODO: delegate to DataSource impl.
        // locations with links to the local menues
        let rootURL = "https://www.dropbox.com/s/xze0tpqpc264m5i/locations.json?dl=1"
        var locations = [String : [String : [[String:String]]]]()
        var locationURLs = [String : String]()
        var locationSelection = ""
        
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
            locationSelection = Array(locationURLs.keys)[0]
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
        return locations
    }
    
    func getCurrency() -> String {
        return currency
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
    func cleanUpTheString(s: String) -> String {
        var result = s
        let toDrop = ["(A)", "(B)", "(Z)", "\t"]
        for str in toDrop {
            result = result.stringByReplacingOccurrencesOfString(str, withString: "")
        }
        return result
    }
    
    func enrichWithEmoji(s : String) -> String {
        var result = s;
        let toEnrich = ["Pommes" : "🍟", "Burger" : "🍔", "Pizza" : "🍕", "Hotdog" : "🌭", "HotDog" : "🌭", "Hot Dog" : "🌭", "Eier" : "🍳", "Pasta" : "🍜", "Spaghetti" : "🍝", "Taco" : "🌮", "Burrito" : "🌯", "Sandwich" : "🍞"]
        
        for key in toEnrich.keys {
            // http://stackoverflow.com/questions/14331001/emoji-shrink-on-mobile-safari-and-uiwebview
            // not working in Simulator
            //let emoji = "<span style=\"font-size: 120.0px; font-family: \"AppleColorEmoji\";\">" + toEnrich[key]! + "</span>"
            
            // http://stackoverflow.com/questions/19702013/emojis-wont-scale-beyond-16px-font-size-on-ios-7
            let emoji = toEnrich[key]!
            
            result = result.stringByReplacingOccurrencesOfString(key, withString: key + " " + emoji + "")
        }
        
        return result
        
    }
}