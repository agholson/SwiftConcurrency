//
//  DoCatchTryThrowsBootCamp.swift
//  SwiftConcurrency
//
//  Created by Leone on 9/11/22.
//
// From: https://www.youtube.com/watch?v=ss50RX7F7nE&list=PLwvDm4Vfkdphr2Dl4sY4rS9PLzPdyi8PM&index=2

import SwiftUI


/// Simulates calls to the database or server
class DoCatchTryThrowsBootCampDataManager {
    
    // Simulates a failure to return the data
    let isActive: Bool = true
    
    func getTitle() -> (title: String?, error: Error?) {
        if isActive {
            return ("NEW TEXT", nil)
        }
        else {
            return (nil, URLError(.badURL))
        }
        
    }
    
    /// Returns a Result of string with success or FAILURE the error message
    func getTitle2() -> Result<String, Error> {
        if isActive {
            return .success("NEW TEXT")
        }
        else {
            return .failure(URLError(.badURL))
        }
        
    }
    
    func getTitle3() throws -> String {
//        if isActive {
//            return "NEW TEXT"
//        }
//        else {
            throw URLError(.badServerResponse)
//        }
    }
    
    func getTitle4() throws -> String {
        if isActive {
            return "FINAL TEXT"
        }
        else {
            throw URLError(.badServerResponse)
        }
    }
    
}

class DoCatchTryThrowsBootCampViewModel: ObservableObject {
    
    @Published var text: String = "Starting text."
    
    // Normally used dependency injection here
    let manager = DoCatchTryThrowsBootCampDataManager()
    
    func fetchTitle() {
        /*
        // Returns a tuple now
        let returnedValue = manager.getTitle()
        
        // If the title exists, then set it to that text
        if let newTitle = returnedValue.title {
            self.text = newTitle
        }
        else if let newError = returnedValue.error {
            // Set this property equal to the error here
            self.text = newError.localizedDescription
        }
         */
        
        /*
     let result = manager.getTitle2()
        switch result {
        case .success(let newTitle):
            self.text = newTitle
        case .failure(let error):
            self.text = error.localizedDescription
            
        }
         */
        
//        let newTitle = try? manager.getTitle3()
//
//        if let title = newTitle {
//            self.text = title
//        }
        
        do {
            let newTitle = try? manager.getTitle3()
            
            // If it exists
            if let newTitle = newTitle {
                self.text = newTitle
            }
            
            let finalTitle = try manager.getTitle4()
            
            self.text = finalTitle
            
        // Give this a name
        } catch {
            self.text = error.localizedDescription
        }
    }
    
}

struct DoCatchTryThrowsBootCamp: View {
    
    @StateObject private var viewModel = DoCatchTryThrowsBootCampViewModel()
    
    
    var body: some View {
        
        Text(viewModel.text)
            .foregroundColor(.white)
            .frame(width: 300, height: 300)
            .background(.blue)
            .onTapGesture {
                // Call method from view model on tap
                viewModel.fetchTitle()
            }
    }
}

struct DoCatchTryThrowsBootCamp_Previews: PreviewProvider {
    static var previews: some View {
        DoCatchTryThrowsBootCamp()
    }
}
