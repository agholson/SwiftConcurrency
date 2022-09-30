//
//  CheckedContinuationBootcamp.swift
//  SwiftConcurrency
//
//  Created by Leone on 9/26/22.
//

import SwiftUI

class CheckedContinuationBootcampNetworkManager {
    
    // Returns data that we parse elsewhere
    func getData(url: URL) async throws -> Data {
        do {
            let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            return data
        } catch  {
            // Catch any error, throw it back to the app
            throw error
        }
    }
    
    func getData2(url: URL) async throws -> Data {
        // Suspends asnychronous context, so it can run non-asynchronous code
        // Must call resume on the continuation at least once
        return try await withCheckedThrowingContinuation { continuation in
            URLSession.shared.dataTask(with: url) { data, response, error in
                // If data never received, then continuation never takes place
                if let data = data {
                    // When it finishes here, it continues the task originally in, or resume the continuation and exit this completion handler
                    continuation.resume(returning: data)
                }
                // Handle the error, if data did not come back
                else if let error = error {
                    continuation.resume(throwing: error)
                }
                // Else if no data returned, and no error returned, then handle this
                else {
                    continuation.resume(throwing: URLError(.badServerResponse   ))
                }
            }
            .resume() // Executes the DataTask here
        }
    }
    
    func getHeartImageFromDatabase(completionHandler: @escaping (_ image: UIImage) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            // Call completionHandler here
            completionHandler(UIImage(systemName: "heart.fill")!)
        }
    }
    
    func getHeartImageFromDatabase() async -> UIImage {
        // Wait for the continuation to return a UIImage
        return await withCheckedContinuation { continuation in
            
            // Call the image above
            getHeartImageFromDatabase { image in
                continuation.resume(returning: image)
            }
            
        }
        
    }
    
}

class CheckedContinuationBootcampViewModel: ObservableObject {
    // Optional UIImage
    @Published var image: UIImage? = nil
    
    // Reference the network manager above
    let networkManager = CheckedContinuationBootcampNetworkManager()
    
    func getImage() async  {
        // If it cannot set this up, then return
        guard let url = URL(string: "https://picsum.photos/300") else { return }
        
        do {
//            let data = try await networkManager.getData(url: url)
            let data = try await networkManager.getData2(url: url)
            
            // If it can make an image from the data
            if let image = UIImage(data: data) {
                // Then assign it to the image property
                await MainActor.run {
                    self.image = image
                }
            }
            
        } catch {
            print(error)
        }
    }
    
//    func getHeartImage() async {
//        networkManager.getHeartImageFromDatabase { [weak self] image in
//            self?.image = image
//        }
//    }
    func getHeartImage() async {
//        let image = await networkManager.getHeartImageFromDatabase()
//        self.image = image
        self.image = await networkManager.getHeartImageFromDatabase()
    }
    
}

/// From: https://www.youtube.com/watch?v=Tw_WLMIfEPQ
struct CheckedContinuationBootcamp: View {
    
    @StateObject private var viewModel = CheckedContinuationBootcampViewModel()
    
    var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
            else {
                VStack {
                    Image(systemName: "x.circle.fill")
                        .resizable()
                        .foregroundColor(.red)
                        .frame(width: 100, height: 100)
                        .scaledToFit()
                    Text("Failed to load image")
                        .foregroundColor(.secondary)
                }
            }
        }
        .task {
//            await viewModel.getImage()
            await viewModel.getHeartImage()
        }
    }
}

struct CheckedContinuationBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        CheckedContinuationBootcamp()
    }
}
