//
//  TaskBootCamp.swift
//  SwiftConcurrency
//
//  Created by Leone on 9/18/22.
//

import SwiftUI

/// From: https://www.youtube.com/watch?v=fTtaEYo14jI
class TaskBootCampViewModel: ObservableObject {
    
    @Published var image: UIImage? = nil
    @Published var image2: UIImage? = nil
    
    func fetchImage() async {
        try? await Task.sleep(nanoseconds: 5_000_000_000)
        do {
            guard let url = URL(string: "https://picsum.photos/1000") else { return }
            
            let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            
            await MainActor.run(body: {
                self.image = UIImage(data: data)
                print("IMAGE RETURNED")
            })
                        
        } catch  {
            print(error.localizedDescription)
        }
    }
    
    func fetchImage2() async {
        do {
            guard let url = URL(string: "https://picsum.photos/1000") else { return }
            
            let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            
            await MainActor.run(body: {
                self.image2 = UIImage(data: data)
            })
            
            
        } catch  {
            print(error.localizedDescription)
        }
    }
    
}

struct TaskBootCampHomeView: View {
    
    var body: some View {
        NavigationView {
            NavigationLink("CLICK ME 🤓") {
                TaskBootCamp()
            }
        }
    }
}

struct TaskBootCamp: View {
    
    @StateObject private var viewModel = TaskBootCampViewModel()
    
    // Reference the Task below
//    let task: Task<(), Never>? = nil
    @State private var fetchImageTask: Task<(), Never>? = nil
    
    var body: some View {
        VStack(spacing: 40) {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
            if let image2 = viewModel.image2 {
                Image(uiImage: image2)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
        }
        .task {
            await viewModel.fetchImage()
        }
        .onDisappear(perform: {
            fetchImageTask?.cancel()
        })
//        .onAppear {
//            fetchImageTask = Task {
//                await viewModel.fetchImage()
//            }
//            //            Task {
//            //                print(Thread.current)
//            //                print(Task.currentPriority)
//            //                await viewModel.fetchImage2()
//            //            }
//            //            Task(priority: .high) {
//            //                print("HIGH : \(Thread.current) : \(Task.currentPriority)")
//            //            }
//            //            Task(priority: .medium) {
//            //                print("MEDIUM : \(Thread.current) : \(Task.currentPriority)")
//            //            }
//            //            Task(priority: .low) {
//            //                print("LOW : \(Thread.current) : \(Task.currentPriority)")
//            //            }
//            //
//            //            Task(priority: .utility) {
//            //                print("UTILITY : \(Thread.current) : \(Task.currentPriority)")
//            //            }
//            //
//            //            Task(priority: .background) {
//            //                print("BACKGROUND : \(Thread.current) : \(Task.currentPriority)")
//            //            }
//            
//            
//        }
        
        
    }
}

struct TaskBootCamp_Previews: PreviewProvider {
    static var previews: some View {
        TaskBootCamp()
    }
}
