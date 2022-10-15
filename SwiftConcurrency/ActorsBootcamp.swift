//
//  ActorsBootcamp.swift
//  SwiftConcurrency
//
//  Created by Leone on 10/9/22.
//

import SwiftUI

class MyDataManager {
    // Make this class a singleton (not recommended like this)
    static let instance = MyDataManager()
    private init() {}
    
    var data: [String] = []
    // Create custom queue to handle the race conditions, and label in the debug logs
    //    private let queue = DispatchQueue(label: "com.MyApp.MyDataManager")
    // Queues are the same thing as locks in programs
    let lock = DispatchQueue(label: "com.MyApp.MyDataManager")
    
    // Escaping closure captures non-escaping parameter 'completionHandler' - need to declare the completionHandler as escaping
    func getRandomData(completionHandler: @escaping (_ title: String?) -> ()) { // Returns Void now, except completionHandler returned
        // Uses the queue above in the debugger
        lock.async {
            self.data.append(UUID().uuidString)
            print(Thread.current)
            
            // Return a random element from the array
            //            return self.data.randomElement()
            // Returns the data via the completionHandler here
            completionHandler(self.data.randomElement())
        }
        
        
    }
}

actor MyActorDataManager {
    // Make this class a singleton (not recommended like this)
    static let instance = MyActorDataManager()
    private init() {}
    
    var data: [String] = []
    
    nonisolated let myRandomText = "asdfsdfa"
    
    func getRandomData() -> String? { // Returns Void now, except completionHandler returned
        self.data.append(UUID().uuidString)
        print(Thread.current)
        return self.data.randomElement()
    }
    // Allows it to not be asynchronous/ thread safe
    nonisolated func getSavedData() -> String {
        return "NEW DATA"
    }
    
}

struct HomeView: View {
    // Get reference to the data manager
    let manager = MyActorDataManager.instance
    
    @State private var text: String = ""
    
    // Run a timer publishing every one second on the main thread, which starts immediately with autoconnect
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.8)
                .ignoresSafeArea()
            
            Text(text)
                .font(.headline)
            
        }
        .onAppear(perform: {
            Task {
                let newString = await manager.getSavedData()
            }
        }
        )
        // Every 0.1 seconds we receive new value from the timer publisher
        .onReceive(timer) { _ in // Does nothing with new value
            
            Task {
                // Call the asynchronous function
                if let title = await manager.getRandomData() {
                    await MainActor.run(body: {
                        self.text = title
                    })
                }
            }
            
            // Update this action in background thread
            //            DispatchQueue.global(qos: .background).async {
            //                manager.getRandomData { title in
            //                    // Call function in shared class between home and BrowseView, which returns a random UUID from the manager
            //                    if let data = title {
            //                        // Return to main thread to update the UI
            //                        DispatchQueue.main.async {
            //                            self.text = data
            //                        }
            //                    }
            //                }
            //
            //            }
            
            
        }
    }
}

struct BrowseView: View {
    let manager = MyActorDataManager.instance
    // This timer updates even faster at a 100th of a second
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    @State var text: String = ""
    
    var body: some View {
        ZStack {
            Color.yellow.opacity(0.8)
                .ignoresSafeArea()
            Text(text)
            
        }
        .onReceive(timer) { _ in
            Task {
                // Call the asynchronous function
                if let title = await manager.getRandomData() {
                    await MainActor.run(body: {
                        self.text = title
                    })
                }
            }
            
            //            DispatchQueue.global(qos: .default).async {
            //
            //                manager.getRandomData { title in
            //                    // Once the title returns here from the completion handler
            //                    if let data = title {
            //                        // Return to main thread for update
            //                        DispatchQueue.main.async {
            //                            // Update with a random UUID
            //                            self.text = data
            //                        }
            //
            //                    }
            //                }
            //
            //            }
            
        }
    }
}

// Old asnychronous style
//struct BrowseView: View {
//    let manager = MyDataManager.instance
//    // This timer updates even faster at a 100th of a second
//    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
//    @State var text: String = ""
//
//    var body: some View {
//        ZStack {
//            Color.yellow.opacity(0.8)
//                .ignoresSafeArea()
//            Text(text)
//
//        }
//        .onReceive(timer) { _ in
//            DispatchQueue.global(qos: .default).async {
//
//                manager.getRandomData { title in
//                    // Once the title returns here from the completion handler
//                    if let data = title {
//                        // Return to main thread for update
//                        DispatchQueue.main.async {
//                            // Update with a random UUID
//                            self.text = data
//                        }
//
//                    }
//                }
//
//            }
//
//        }
//    }
//}

struct ActorsBootcamp: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            BrowseView()
                .tabItem {
                    Label("Browse", systemImage: "magnifyingglass")
                }
        }
    }
}

struct ActorsBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        ActorsBootcamp()
    }
}
