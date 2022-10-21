//
//  SendableBootcamp.swift
//  SwiftConcurrency
//
//  Created by Leone on 10/21/22.
//

import SwiftUI

actor CurrentUserManager {
    
    func updateDatabase(userInfo: MyClassUserInfo) {
        
    }
}

// Conforming to the Sendable protocol means we can safely send values of this type to concurrent code
struct MyUserInfo: Sendable {
    let name: String
    
}

// Final class prevents other classes from inheriting from this class, which allows
// it to conform to the sendable protocol
final class MyClassUserInfo: @unchecked Sendable {
   private  var name: String
    
    let queue = DispatchQueue(label: "com.MyAppName.MyClassUserInfo")
    
    // Create an initializer for the class as required
    init(name: String) {
        self.name = name
    }
    
    func updateName(newName: String) {
        // Only update the code on its own queue (lock)
        queue.async {
            self.name = newName
        }
    }
}

class SendableBootcampViewModel: ObservableObject {
    let manager = CurrentUserManager()
    
    func updateCurrentUserInfo() async {
        let info = MyClassUserInfo(name: "USER INFO")
        await manager.updateDatabase(userInfo: info)
    }
}

struct SendableBootcamp: View {
    
    @StateObject private var viewModel = SendableBootcampViewModel()
    
    var body: some View {
        Text("Test")
            .task {
                await viewModel.updateCurrentUserInfo()
            }
    }
}

struct SendableBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        SendableBootcamp()
    }
}
