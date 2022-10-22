//
//  AsyncPublisherBootcamp.swift
//  SwiftConcurrency
//
//  Created by Leone on 10/21/22.
//

import SwiftUI
import Combine

class AsyncPublisherDataManager {
    @Published var myData: [String] = []
    
    func addData() async {
        myData.append("Apple")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Cherry")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Bannana")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Watermellon")
    }
    
}

class AsyncPublisherBootcampViewModel: ObservableObject {
    // Makes it, so this always gets updated on the MainActor
    @MainActor @Published var dataArray: [String] = []
    let manager = AsyncPublisherDataManager()
    
    // Used for Combine
    var cancellables = Set<AnyCancellable>()
    
    init() {
        addSubscribers()
    }
    
    // This will update the published dataArray as information comes into it
    // It subscribes to the myDataArray for any changes
    private func addSubscribers() {
        
        Task {
            
            await MainActor.run {
                self.dataArray = ["ONE"]
            }
            
            // Subscribes to the Publisher asynchronously
            // Unlike normal for loop that executes immediately, this one awaits each value first
            for await value in manager.$myData.values {
                await MainActor.run {
//                    self.dataArray = value
                }
                break 
            }
            
            await MainActor.run {
                self.dataArray = ["TWO"]
            }
            
        }
        
        // Set the current class's dataArray equal to myData
//        manager.$myData
//            .receive(on: DispatchQueue.main) // Do this on the main thread
//            .sink { stringArray in
//                self.dataArray = stringArray
//            }
//            .store(in: &cancellables) // Store the subscribers in the cancellables
        
    }
    
    func start() async {
        await manager.addData()
    }
}

struct AsyncPublisherBootcamp: View {
    
    @StateObject private var viewModel = AsyncPublisherBootcampViewModel()
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.dataArray, id: \.self) { word in
                    Text(word)
                        .font(.headline)
                }
            }
        }
        .task {
            await viewModel.start()
        }
    }
}

struct AsyncPublisherBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        AsyncPublisherBootcamp()
    }
}
