//
//  WeatherView.swift
//  Open Meteo App
//
//  Created by apple on 4/3/23.
//

import SwiftUI

struct WeatherView: View {
    
    @StateObject private var vm = ViewModel()
    
    
    var body: some View {
        
        NavigationView{
            VStack{
                HStack{
                    Button(action: {
                        vm.isCelcius = true
                        vm.fetchWeather()
                    }, label: {Text("C")
                            .padding(.horizontal, 25)
                            .padding(.vertical, 1)
                            .border(Color.blue, width:1)
                            .font(.title)
                    })
                    Button(action: {
                        vm.isCelcius = false
                        vm.fetchWeather()
                    }, label: {Text("F")
                            .padding(.horizontal, 25)
                            .padding(.vertical, 1)
                            .border(Color.blue, width:1)
                            .font(.title)
                    })
                }.frame(maxWidth: .infinity, alignment: .trailing)
                    .padding()
                
                
                List(vm.displayableDataArray){ item in
                    NavigationLink(destination: DetailView(cityToDisplay: item) , label:{
                        HStack(alignment: .center){
                            VStack(alignment: .leading, spacing: 5){
                                Text(item.city)
                                Text(item.temp)
                            }
                            
                            Spacer()
                            
                            Image(item.imageName)
                                .resizable()
                                .frame(width:70, height: 70, alignment: .center)
                            
                        }
                    })
            
                }.navigationTitle("Weather")
                    .onAppear(perform: vm.fetchWeather) //begin fetching
            }
           
        }
    }
}

struct WeatherView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherView()
    }
}
