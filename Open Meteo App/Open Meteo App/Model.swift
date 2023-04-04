//
//  Model.swift
//  Open Meteo App
//
//  Created by apple on 4/2/23.
//

import Foundation

//note - don't need to create struct vars for all key value pairs in downloaded json, but api is sending it,
//       so just create values for all key value pairs

//structs conform to codable protocol so can use json decoder
struct Hourly: Codable{
    
    var time:[String] = [""]
    var temperature_2m:[Float] = [0]
    var rain:[Float] = [0]
    
}

struct HourlyUnit: Codable{
    
    var time:String = ""
    var temperature_2m:String = ""
    var rain:String = ""
    
}


struct WeatherFeed: Codable{

    var latitude:Float = 0
    var longitude:Float = 0
    var generationtime_ms:Float = 0
    var utc_offset_seconds:Int = 0
    var timezone:String = ""
    var timezone_abbreviation:String = ""
    var elevation:Float = 0
    
    var hourly_units:HourlyUnit
    
    var hourly:Hourly
    
}

struct DisplayableData: Identifiable //conform to identifiable so we can traverse it
{
    var id = UUID()
    var city:String = ""
    var temp:String = ""
    var imageName:String = ""
    var degrees:String = ""
    var hourlyTemps:[Float] = [0]  //*index will map directly to time
    var hourlyTimes:[String] = [""]
    
   
}

