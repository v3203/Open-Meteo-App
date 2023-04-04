//
//  DetailView.swift
//  Open Meteo App
//
//  Created by apple on 4/3/23.
//

import SwiftUI

struct DetailView: View{
    
    var cityToDisplay: DisplayableData
    
    var body: some View {
        VStack{
            HStack{
                VStack(alignment: .leading, spacing: 5){
                    Text(cityToDisplay.city)
                    Text(cityToDisplay.temp)
                }
                
                Image(cityToDisplay.imageName)
                    .resizable()
                    .frame(width:70, height: 70, alignment: .center)
            }
      
            
            List(0..<cityToDisplay.hourlyTemps.count) { i in
                HStack(alignment: .center){
                        Text(cityToDisplay.hourlyTimes[i])
                        Spacer()
                        Text(String(cityToDisplay.hourlyTemps[i])+cityToDisplay.degrees)
                }
                
            }
        }
    }
    
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(cityToDisplay: .init())
    }
}
