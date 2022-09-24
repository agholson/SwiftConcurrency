//
//  AsyncAwaitBootCamp.swift
//  SwiftConcurrency
//
//  Created by Leone on 9/18/22.
//

import SwiftUI

class AsyncAwaitBootCampViewModel: ObservableObject {
    @Published var dataArray: [String] = []
    
    func addTitle1() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.dataArray.append("Title1 : \(Thread.current)")
        }
    }
    
    func addTitle2() {
        // Execute this code via a background thread
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            // Simulates expensive call
            let title = "Title2 : \(Thread.current)"
            
            // Updates UI via main thread
            DispatchQueue.main.async {
                self.dataArray.append(title)
                
                let title3 = "Title3 : \(Thread.current)"
                self.dataArray.append(title3)
            }
            
        }
    }
    
    func addAuthor1() async {
        let author1 = "Author1 : \(Thread.current)"
        self.dataArray.append(author1)
        
        // Add delay of two seconds
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        // After delay add the second author
        let author2 = "Author2 : \(Thread.current)"
        
        
        // Update via main thread
        await MainActor.run(body: {
            self.dataArray.append(author2)
            
            let author3 = "Author3 : \(Thread.current)"
            self.dataArray.append(author3)
        })
        
    }
    
    func addSomething() async {
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        let something1 = "Something1 : \(Thread.current)"
        
        // Update via main thread
        await MainActor.run(body: {
            self.dataArray.append(something1)
            
            let something2 = "Something2 : \(Thread.current)"
            self.dataArray.append(something2)
        })
    }
    
}

struct AsyncAwaitBootCamp: View {
    
    @StateObject private var viewModel = AsyncAwaitBootCampViewModel()
    
    var body: some View {
        List {
            // Id represented by hashed value of each string
            ForEach(viewModel.dataArray, id: \.self) { data in
                Text(data)
            }
        }
        .onAppear {
            
            // Use Task for Asynchronous code
            Task {
                await viewModel.addAuthor1()
                
                await viewModel.addSomething()
                
                let finalText = "FINAL TEXT \(Thread.current)"
                viewModel.dataArray.append(finalText)
            }
            
//            viewModel.addTitle1()
//            // Call the second task via the background thread
//            viewModel.addTitle2()
            
        }
    }
}

struct AsyncAwaitBootCamp_Previews: PreviewProvider {
    static var previews: some View {
        AsyncAwaitBootCamp()
    }
}
