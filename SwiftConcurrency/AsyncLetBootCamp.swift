//
//  AsyncLetBootCamp.swift
//  SwiftConcurrency
//
//  Created by Leone on 9/24/22.
//

import SwiftUI

/// From: https://www.youtube.com/watch?v=1OmJJwVF7uQ
struct AsyncLetBootCamp: View {
    
    // Create an array of images
    @State private var images: [UIImage] = []
    
    let url = URL(string: "https://picsum.photos/300")!
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                    }
                }
            }
            .navigationTitle("Async Let 🥳")
            .onAppear {
                // Add something to our images list, so it shows on the screen
                Task {
                    do {
                        // Execute at same time
                        async let fetchImage1 = fetchImage()
                        async let fetchTitle1 = fetchTitle()
                        
                        let (image, title) = await (try fetchImage1, fetchTitle1)
                        
                        
                        
//                        async let fetchImage2 = fetchImage()
//                        async let fetchImage3 = fetchImage()
//                        async let fetchImage4 = fetchImage()
//
//                        // Await all four at same time
//                        // If any fail, enter the catch block
//                        let (image1, image2, image3, image4) = await (try fetchImage1, try fetchImage2, try fetchImage3, try fetchImage4)
//
//                        // If it makes it here, then add all of the images here at once
//                        self.images.append(contentsOf: [image1, image2, image3, image4])
                        
                        // Runs this one first
//                        let image1 = try await fetchImage()
//                        // If the image returns, then add it to the images state property
//
//                        // Then this one
//                        self.images.append(image1)
//
//                        let image2 = try await fetchImage()
//                        self.images.append(image2)
//
//                        let image3 = try await fetchImage()
//                        self.images.append(image3)
//
//                        let image4 = try await fetchImage()
//                        self.images.append(image4)
                        

                    } catch {
                        
                    }
                }
                
                
            }
        }
    }
    
    func fetchTitle() -> String {
        return "NEW TITLE"
    }
    
    
    func fetchImage() async throws -> UIImage {
        do {
            // Call the photo API here
            let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            
            if let image = UIImage(data: data) {
                return image
            }
            else {
                throw URLError(.badURL)
            }
            
        } catch  {
            throw error
        }
    }
    
}

struct AsyncLetBootCamp_Previews: PreviewProvider {
    static var previews: some View {
        AsyncLetBootCamp()
    }
}
