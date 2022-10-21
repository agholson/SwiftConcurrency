//
//  GlobalActorBootcamp.swift
//  SwiftConcurrency
//
//  Created by Leone on 10/14/22.
//

import SwiftUI

@globalActor struct MyFirstGlobalActor {
    
    static var shared = MyNewDataManager()
}

actor MyNewDataManager {
    
    func getDataFromDatabase() -> [String] {
        return ["One", "Two", "Three", "Four", "Five"]
    }
}

class GlobalActorBootcampViewModel: ObservableObject {
    
    @MainActor @Published var dataArray: [String] = []
    
    // Access the actor via a reference to the singleton
    let manager = MyFirstGlobalActor.shared
    
    // Only allow this to run within the global actor via isolation
//    @MyFirstGlobalActor
//    func getData() async {
//    @MainActor
    func getData() {
        // HEAVY COMPLEX METHODS
        Task {
            // Get the array of strings from the database
            let data = await manager.getDataFromDatabase()
            
            // Wait until you can run on the MainActor, then run this code
            await MainActor.run {
                self.dataArray  = data
            }
        }
       
    }
}

struct GlobalActorBootcamp: View {
    
    @StateObject private var viewModel = GlobalActorBootcampViewModel()
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.dataArray, id: \.self) {
                    Text($0)
                        .font(.headline)
                }
            }
        }
        .task { // Task runs on the main actor
        // Need to await to enter actor
            viewModel.getData()
            
        }
    }
}

struct GlobalActorBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        GlobalActorBootcamp()
    }
}
