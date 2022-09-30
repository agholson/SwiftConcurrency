//
//  TaskGroupBootcamp.swift
//  SwiftConcurrency
//
//  Created by Leone on 9/25/22.
//

import SwiftUI

class TaskGroupBootcampDataManager {
    
    func fetchImagesWithAsnycLet() async throws -> [UIImage] {
        
            async let fetchImage1 = fetchImage(urlString: "https://picsum.photos/300")
            async let fetchImage2 = fetchImage(urlString: "https://picsum.photos/300")
            async let fetchImage3 = fetchImage(urlString: "https://picsum.photos/300")
            async let fetchImage4 = fetchImage(urlString: "https://picsum.photos/300")
            
            let (image1, image2, image3, image4) = await (try fetchImage1, try fetchImage2, try fetchImage3, try fetchImage4)
            
            return [image1, image2, image3, image4]
       
    }
    
    func fetchImagesWithTaskGroup() async throws -> [UIImage] {
        // Create an array of strings
        let urlStrings = [
            "https://picsum.photos/300",
            "https://picsum.photos/300",
            "https://picsum.photos/300",
            "https://picsum.photos/300",
            "https://picsum.photos/300",
        ]
        
       // Return from the outer function the images as well - of portion tells it what to return from the inner function
        return try await withThrowingTaskGroup(of: UIImage?.self) { group in
            // Create blank array to hold returned images
            var images: [UIImage] = []
            
            // Tell compiler how many elements to reserve for this array
            images.reserveCapacity(urlStrings.count)
            
            // Loop through the URLs
            for urlString in urlStrings {
                // Add a groupTask for each one
                group.addTask(priority: .high) {
                    try? await self.fetchImage(urlString: urlString)
                }
            }
            
            // Waits for all the tasks to return, if any fail, then it does not run
            for try await image in group {
                if let image = image {
                    // Whenever one comes through, it immediately enters group, add it
                   images.append(image)
                }
            }
            
            // Waits for all the images to be added, then returns
            return images
        }
    }
    
    /// Tries to asnychronously fetch an image for a given URL. As a private function, it can only be called from inside a manager
    /// - Parameter:
    private func fetchImage(urlString: String) async throws -> UIImage {
        // Create a URL from the passed string
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            
            // If the image loaded successfully, then return it
            if let image = UIImage(data: data) {
                return image
            }
            else {
                // Throw this specific error
                throw URLError(.badServerResponse)
            }
            
        } catch  {
            // Throw error here
            throw error
        }
    }
}

class TaskGroupBootcampViewModel: ObservableObject {
    
    @Published var images: [UIImage] = []
    // Should inject instead
    let manager = TaskGroupBootcampDataManager()
    
    func getImages() async {
        // Optional try, because do not care about error message, if returned properly
//        if let images = try? await manager.fetchImagesWithAsnycLet() {
        if let images = try? await manager.fetchImagesWithTaskGroup() {
            
            await MainActor.run(body: {
                // Then set it to the images
                self.images.append(contentsOf: images) // Add an array to an array as individual elements
            })
           
            
        }
     
       
    }
    
}

struct TaskGroupBootcamp: View {
    
    @StateObject private var viewModel = TaskGroupBootcampViewModel()
    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(viewModel.images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                    }
                }
            }
            .navigationTitle("Task Group 🎉")
            .task {
                await viewModel.getImages()
            }
        }
    }
}

struct TaskGroupBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        TaskGroupBootcamp()
    }
}
