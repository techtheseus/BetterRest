//
//  ContentView.swift
//  BetterRest
//
//  Created by whybhav on 05/06/22.
//
import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 0
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var idealWakeTime: String {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount + 1))
            
            let sleepTime = wakeUp - prediction.actualSleep
            return(sleepTime.formatted(date: .omitted, time: .shortened))
            
        } catch {
            return("Sorry, there was a problem calculating your bedtime.")
        }
    }
    
    var body: some View {
        NavigationView {
            
            Form {
                Section {
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                } header: {
                    Text("When do you want to wake up?")
                        .font(.headline)
                }
                
                Section {
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                } header: {
                    Text("Desired amount of sleep")
                        .font(.headline)
                }
                
                Section {
                    Picker(coffeeAmount == 0 ? "Number of cup" : "Number of cups", selection: $coffeeAmount) {
                        ForEach(1..<21) {
                            Text($0 , format: .number)
                        }
                    }
                } header: {
                    Text("Daily coffee intake")
                    .font(.headline)
                }
                
                Section {
                    Text(idealWakeTime)
                        .font(.largeTitle)
                } header: {
                    Text("Your ideal bedtime is")
                        .font(.headline)
                }
            }
            .navigationTitle("BetterRest")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
