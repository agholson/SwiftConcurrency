#  SwiftConcurrency
Swift Concurrency notes from Swiftful Thinking: 
https://www.youtube.com/watch?v=ss50RX7F7nE&list=PLwvDm4Vfkdphr2Dl4sY4rS9PLzPdyi8PM&index=2


# Code to Call an Image Asnychronously
From: https://www.youtube.com/watch?v=9fXI6o39jLQ&list=PLwvDm4Vfkdphr2Dl4sY4rS9PLzPdyi8PM&index=4
Code that handles a data response containing an image from an API:
```
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
```

Code that asynchronously fetches the image:
```
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
```
Code that calls an image asynchronously in the ViewModel:
```
class DownloadImageAsyncViewModel: ObservableObject {
    
    // Initialize an empty image
    @Published var image: UIImage? = nil
    
    // Reference the image loader
    let loader = DownloadAsyncImageLoader()
    // Set cancellable for combine
    var cancellables = Set<AnyCancellable>()
    
    func fetchImage() async {
        // If you do not care about the image, you can execute the code safely like this
        let image = try? await loader.downloadWithAsync()
        
        // Runs in something similar to the main thread
        await MainActor.run {
            // Set this as the image
            self.image = image
            
        }
    }
}
``` 

Code within the View itself, which allows us to call the image:
```
.onAppear {
    // Task needed to asnychronously call this image
    Task {
        await viewModel.fetchImage()
    }
}
```
