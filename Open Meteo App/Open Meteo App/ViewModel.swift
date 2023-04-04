//
//  ViewModel.swift
//  Open Meteo App
//
//  Created by apple on 4/2/23.
//

import Foundation


final class ViewModel: ObservableObject{
    
    
    @Published var displayableDataArray: [DisplayableData] = [] //this is the property that view will listen to to react to changes
    
    var weatherFeedArray: [WeatherFeed] = []
    var isCelcius:Bool = true
    
    var hasError = false
   // var isRefreshing = false
    
    func fetchWeather()
    {
        weatherFeedArray.removeAll()
        displayableDataArray.removeAll()
        
        
        // /////////////////////////////////////////////////////////////////////////
        let date = Date()
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let theDate = dateFormatter.string(from: date)
        
        // /////////////////////////////////////////////////////////////////////////
        
        if(self.isCelcius == true){
            
            //*worth noting: just keeping this very simple; Normally I wouldn't hard code a string in function, but just do it for simple app assignment
            
            self.fetch(urlString:"https://api.open-meteo.com/v1/forecast?latitude=40.71&longitude=-74.01&hourly=temperature_2m,rain&start_date=\(theDate)&end_date=\(theDate)")    //New York
            self.fetch(urlString:"https://api.open-meteo.com/v1/forecast?latitude=32.78&longitude=-96.81&hourly=temperature_2m,rain&start_date=\(theDate)&end_date=\(theDate)")    //Dallas
            self.fetch(urlString:"https://api.open-meteo.com/v1/forecast?latitude=25.77&longitude=-80.19&hourly=temperature_2m,rain&start_date=\(theDate)&end_date=\(theDate)")    //Miami
        }
        else{
            self.fetch(urlString:"https://api.open-meteo.com/v1/forecast?latitude=40.71&longitude=-74.01&hourly=temperature_2m,rain&temperature_unit=fahrenheit&start_date=\(theDate)&end_date=\(theDate)")    //New York
            self.fetch(urlString:"https://api.open-meteo.com/v1/forecast?latitude=32.78&longitude=-96.81&hourly=temperature_2m,rain&temperature_unit=fahrenheit&start_date=\(theDate)&end_date=\(theDate)")    //Dallas
            self.fetch(urlString:"https://api.open-meteo.com/v1/forecast?latitude=25.77&longitude=-80.19&hourly=temperature_2m,rain&temperature_unit=fahrenheit&start_date=\(theDate)&end_date=\(theDate)")    //Miami
        }
    }
    
    
    func fetch(urlString:String)
    {
        if let url = URL(string: urlString){   //unwrap url
            
            URLSession
                .shared
                .dataTask(with: url) { [weak self](data, response,error) in
                    
                    DispatchQueue.main.async { //need on main thread; publishing changes from background thread isnt allowed
                        
                        if let error = error{  //unrap error if is one
                            print(error)
                            self?.hasError = true
                        }else{
                            let decoder = JSONDecoder() //using json decoder to do the work for us
                            
                            if let data = data,
                               let feed = try? decoder.decode(WeatherFeed.self, from: data){
                                
                                
                                self?.updateDisplayableData(feed: feed)   //get the data we need to display to user
                                self?.weatherFeedArray.append(feed)   //don't need to, but just save all data returned by api
                                
                                //print( feed )
                            }else{
                                self?.hasError = true
                                //print("failed to decode")
                            }
                        }
                    }
                    
                    
                }.resume()
        }
        
        
    }
    
    func updateDisplayableData(feed:WeatherFeed){
        
        var newElem:DisplayableData = DisplayableData.init()  //create a new structure
        
        // //////////////////////////////////////////////////////////////////////////
        // Populate city name
        
        //since city name is not returned by api via json, just use latitude to populate city name
        if(feed.latitude == 40.710335){
            newElem.city = "NewYork"}
        else if(feed.latitude == 32.784855){
            newElem.city = "Dallas"}
        else if(feed.latitude == 25.772915){
            newElem.city = "Maimi"}
        else{
            newElem.city = "Unknown"
        }
        
        // /////////////////////////////////////////////////////////////////////////
        //Populate current temperature
        
        let date = Date()
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "HH"     //*take advantage of direct mapping between time and array index of json; getting current hour; this will work bc HH is 24 hour format
        
        //var test = Int(dateFormatter.string(from: date))!
        
        let currentTemp:Float = feed.hourly.temperature_2m[Int(dateFormatter.string(from: date))!].rounded()
        newElem.temp = String(currentTemp) + feed.hourly_units.temperature_2m
        
        
        // /////////////////////////////////////////////////////////////////////////
        //Populate image name
        
        if(feed.hourly.rain[Int(dateFormatter.string(from: date))!] == 0){
            newElem.imageName = "sun"
        }
        else if(feed.hourly.rain[Int(dateFormatter.string(from: date))!] < 1){
            newElem.imageName = "lightRain"
        }
        else{
            newElem.imageName = "heavyRain"
        }
        
        // /////////////////////////////////////////////////////////////////////////
        //Populate degrees
        newElem.degrees = feed.hourly_units.temperature_2m
        
        
        // /////////////////////////////////////////////////////////////////////////
       
        
        // Populate hourly temperature array
        
        newElem.hourlyTemps = feed.hourly.temperature_2m
        
        var i = 0
        while(i < newElem.hourlyTemps.count)
        {
            newElem.hourlyTemps[i] = newElem.hourlyTemps[i].rounded()
            i+=1
        }
        
        
        // /////////////////////////////////////////////////////////////////////////
        //Populate hourly times
        newElem.hourlyTimes = feed.hourly.time
        
        //First shave off the date portion. This leaves us with military time and ready to be displayed on a phone with 24hr format
        i = 0
        while(i < newElem.hourlyTimes.count)
        {
            newElem.hourlyTimes[i] = String(newElem.hourlyTimes[i].suffix(5))
            i+=1
        }
        
        
        //There is a template specifier for NSDateFormatter that fits this need. This specifier is j and you can get it through the dateFormatFromTemplate:options:locale: method of NSDateFormatter.
        //The formatter returns h a if the locale is set to 12H, else HH if it's set to 24H, so you can easily check if the output string contains a or not. This relies on the locale property
        //of the formatter that you should set to NSLocale.currentLocale() for getting the system's current locale:
        
        let locale = NSLocale.current
        let formatter : String = DateFormatter.dateFormat(fromTemplate: "j", options:0, locale:locale)!
        if formatter.contains("a")
        {
            //phone is set to 12 hours
            
            i = 0
            while(i < newElem.hourlyTimes.count)
            {
                dateFormatter.dateFormat = "H:mm"
                let date12 = dateFormatter.date(from: newElem.hourlyTimes[i])!

                dateFormatter.dateFormat = "h:mm a"
                newElem.hourlyTimes[i] = dateFormatter.string(from: date12)  //converting 24 hour to 12 hour format
                
                i+=1
            }
            
        }
        else
        {
            //phone is set to 24 hours - tested, working changing iphone simulator to local France
            //already converted earlier
        }
        
        
        // //////////////////////////////////////////////////////////////////////////////////////////////
        // //////////////////////////////////////////////////////////////////////////////////////////////
        
        self.displayableDataArray.append(newElem)    //add populated structure to published array
    }
    
}


