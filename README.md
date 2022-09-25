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

# Priority Levels
There are different priority levels for the execution of tasks. If no priority is given to a Task,
then it takes the highest priority level. However, we
can control the priority level for Tasks using a modifier as shown below:
```
Task(priority: .userInitiated) {
    print("USER INITIATED : \(Thread.current) : \(Task.currentPriority)")
} 
```
The higher the TaskPriority number, the more likely it will be prioritized:
```
MEDIUM : <_NSMainThread: 0x600003354000>{number = 1, name = main} : TaskPriority(rawValue: 21)
USER INITIATED : <_NSMainThread: 0x600003354000>{number = 1, name = main} : TaskPriority(rawValue: 25)
HIGH : <_NSMainThread: 0x600003354000>{number = 1, name = main} : TaskPriority(rawValue: 25)
LOW : <_NSMainThread: 0x600003354000>{number = 1, name = main} : TaskPriority(rawValue: 17)
UTILITY : <_NSMainThread: 0x600003354000>{number = 1, name = main} : TaskPriority(rawValue: 17)
BACKGROUND : <_NSMainThread: 0x600003354000>{number = 1, name = main} : TaskPriority(rawValue: 9)
```

If you have a long-runnning operation, then you can let other threads waiting go ahead like this:
```
Task(priority: .userInitiated) {
    
    await Task.yield()
    
    print("USER INITIATED : \(Thread.current) : \(Task.currentPriority)")
}
```

# Cancelling Tasks
If you have a user click through a bunch of pages, you don't want to load images or other data
for the pages the user no longer remains upon. Rather, you need to cancel that Task. 

First grab a reference to the Task. You can do this by defining it up top:
```
task: Task = nil
```
However, that responds in a GenericParameter error (`Generic parameter 'Success' could not be inferred`). Therefore, we 
need to tell it what type of error to make instead. Accomplish this by copying the type shown by `OPTION + CLICKING` an 
object like the below (then you can delete
assignment here):
![Option clicking a task](img/optionClickingTask.png)
So the new declaration of the Task becomes like this:
```
let task:  Task<(), Never>? = nil
```

Then change it to match your code as a `@State` property, and set the Task equal to this:
```
@State private var fetchImageTask: Task<(), Never>? = nil 
...
fetchImageTask = Task {
    await viewModel.fetchImage()
}
```

Now, you can add an `onDissapear` modifier to cancel the referenced task:
```
.onDisappear(perform: {
    fetchImageTask?.cancel()
})
```
However, an even smoother method for this brought into iOS 15 is the `.task` modifier, which 
handles all of the code above, the `@State` code, the `.onAppear`, and `.onDisappear` cancellation code in one stroke:
```
.task {
  await viewModel.fetchImage()
}
```

However, for long-running tasks, we might run into the point, where it does not cancel on its own. For these, we need
to check, if the task was cancelled. For example, you might have a loop like this:
```
for image in imageArray {
    try Task.checkCancellation() 
}
```

# Concurrent Execution
In a Task, most of the time, the code runs serially. However, you can use `async let` to run different asynchronous calls at the same time.
Although, this will execute at the same, it will not add the images to the `@State` property until all of the images finish loading.
```
Task {
    do {
        // Execute at same time
        async let fetchImage1 = fetchImage()
        async let fetchImage2 = fetchImage()
        async let fetchImage3 = fetchImage()
        async let fetchImage4 = fetchImage()
        
        // Await all four at same time
        // If any fail, enter the catch block
        let (image1, image2, image3, image4) = await (try fetchImage1, try fetchImage2, try fetchImage3, try fetchImage4)
        
        // If it makes it here, then the images are here
        self.images.append(contentsOf: [image1, image2, image3, image4])
    catch {
    
    }
}
```

