//
//  DownloadImageAsync.swift
//  SwiftConcurrency
//
//  Created by Leone on 9/12/22.
//

import SwiftUI
import Combine

class DownloadAsyncImageLoader {
    
    let url = URL(string: "https://picsum.photos/200")!
    
    func handleResponse(data: Data?, response: URLResponse?) -> UIImage? {
        guard
            let data = data,
            let image = UIImage(data: data),
            let response = response as? HTTPURLResponse,
            // If the above are not there, and the response is not a 2xx code, then return
            response.statusCode <= 200 && response.statusCode < 300 else {
                // If error, then return nil
                return nil
            }
        // If successful, then call the completionHandler with the image
        return image
    }
    
    func downloadWithEscaping(completionHandler: @escaping (_ image: UIImage?, _ error: Error?) -> ()) {
        // The data task launches as soon as it reaches the code, the portion in braces, executes once data gets returned
        // With weak self, if user is on another page, then don't load this
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            // Returns an image or an optional image
            let image = self?.handleResponse(data: data, response: response)
            
            // If successful, then call the completionHandler with the image
            completionHandler(image, error)
            
        }
        .resume() // Makes start
    }
    
    func downloadWithCombine() -> AnyPublisher<UIImage?, Error> {
        URLSession.shared.dataTaskPublisher(for: url)
            .map(handleResponse)
            .mapError({ $0 }) // Map URLError to the generic error
            .eraseToAnyPublisher()
    }
    
    // Make this an async function with the following keyword
    // Throws keyword, allows us to throw an error from here
    func downloadWithAsync() async throws -> UIImage? {
        do {
            // Tell the compiler to suspend this task, because its response will arrive later
            let (data, response) = try await URLSession.shared.data(from: url, delegate: nil)
            // Return the UIImage
            return handleResponse(data: data, response: response)
        } catch {
            // If we get an error, we throw it outside this method
            throw error
        }
    }
    
}

class DownloadImageAsyncViewModel: ObservableObject {
    
    // Initialize an empty image
    @Published var image: UIImage? = nil
    
    // Reference the image loader
    let loader = DownloadAsyncImageLoader()
    // Set cancellable for combine
    var cancellables = Set<AnyCancellable>()
    
    func fetchImage() async {
        // Combine code
        /*
        // Download the image here
        //        loader.downloadWithEscaping { [weak self] image, error in
        //            // if the image returned
        //            DispatchQueue.main.async {
        //                self?.image = image
        //            }
        //        }
        loader.downloadWithCombine()
            .receive(on: DispatchQueue.main) // Apply received value to main thread
            .sink { _ in
                
            } receiveValue: { [weak self] image in
                
                self?.image = image
                
            }
            .store(in: &cancellables) // Store in this set
        */
        
        // If you do not care about the image, you can execute the code safely like this
        let image = try? await loader.downloadWithAsync()
        
        // Set this as the image
        await MainActor.run {
            self.image = image
        }

    }
    
}

struct DownloadImageAsync: View {
    
    @StateObject var viewModel = DownloadImageAsyncViewModel()
    
    var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
            }
        }
        .onAppear {
            // Task needed to asnychronously call this image
            Task {
                await viewModel.fetchImage()
            }
        }
    }
}

struct DownloadImageAsync_Previews: PreviewProvider {
    static var previews: some View {
        DownloadImageAsync()
    }
}
