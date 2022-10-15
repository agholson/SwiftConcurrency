//
//  StructClassActorBootcamp.swift
//  SwiftConcurrency
//
//  Created by Leone on 10/1/22.
//

import SwiftUI


actor StructClassActorBootcampDataManager {
    func getDataFromDatabase() {
        
    }
}

class StructClassActorBootcampViewModel: ObservableObject {
    @Published var title: String = ""
    
    init() {
        print("ViewModel INIT")
    }
    
}

struct StructClassActorBootcampHomeView: View {
    @State private var isActive: Bool = false
    
    var body: some View {
        StructClassActorBootcamp(isActive: isActive)
            .onTapGesture {
                // Make it the opposite value on a tap
                isActive.toggle()
            }
    }
}

// From: https://www.youtube.com/watch?v=-JLenSTKEcA
struct StructClassActorBootcamp: View {
    
    @StateObject private var viewModel = StructClassActorBootcampViewModel()
    
    let isActive: Bool
    
    init(isActive: Bool) {
        self.isActive = isActive
        print("View INIT")
    }
    
    
    var body: some View {
        Text("Hello, World!")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            .background(isActive ? .red : .blue)
//            .onAppear {
//                runTest()
//            }
    }
}


struct StructClassActorBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        StructClassActorBootcamp(isActive: true)
    }
}

extension StructClassActorBootcamp {
    
    private func runTest() {
        print("Test started")
        structTest1()
        printDivider()
        classTest1()
        printDivider()
        actorTest1()
        //        structTest2()
        //        printDivider()
        //        classTest2()
    }
    
    
    
    private func printDivider() {
        print("""

        -----------------------------------------

""")
    }
    
    private func structTest1() {
        print("structTest1")
        let objectA = MyStruct(title: "Starting title!")
        print("ObjectA: ", objectA.title)
        
        print("Passed the VALUES of objectA to objectB")
        var objectB = objectA
        
        print("ObjectB: ", objectB.title)
        
        // Create totally new struct here with a different title
        objectB.title = "Second title"
        print("ObjectB title changed")
        
        print("ObjectA: ", objectA.title)
        print("ObjectB: ", objectB.title)
    }
    
    private func classTest1() {
        print("classTest1")
        let objectA = MyClass(title: "Starting title!")
        print("ObjectA: ", objectA.title)
        
        print("Pass the REFERENCES from objectA to objectB")
        let objectB = objectA
        print("ObjectB: ", objectB.title)
        
        // Changes the title inside the object
        objectB.title = "Second title"
        print("ObjectB title changed")
        
        print("ObjectA: ", objectA.title)
        print("ObjectB: ", objectB.title)
    }
    
    private func actorTest1() {
        // Jump into async environment with Task
        Task {
            print("actorTest1")
            let objectA = MyActor(title: "Starting title!")
            await print("ObjectA: ", objectA.title)
            
            await print("Pass the REFERENCES from objectA to objectB")
            let objectB = objectA
            await print("ObjectB: ", objectB.title)
            
            // Must use method within the actor to change the title
            await objectB.updateTitle(newTitle: "Second title!")
            print("ObjectB title changed")
            
            await print("ObjectA: ", objectA.title)
            await print("ObjectB: ", objectB.title)
        }
        
    }
    
}

struct MyStruct {
    var title: String
}


/// Immutable struct
struct CustomStruct {
    let title: String
    
    // Returns new struct with the given string
    func updateTitle(newTitle: String) -> CustomStruct {
        CustomStruct(title: newTitle)
    }
}

/// Changes entire objet versus only the title
struct MutatingStruct {
    // If this is private, then must include an init method. Can only set it here
    private(set) var title: String
    
    init(title: String) {
        self.title = title
    }
    
    // Only way to change the title, where it creates new objects with new values
    mutating func updateTitle(newTitle: String) {
        title = newTitle
    }
}


extension StructClassActorBootcamp {
    
    private func structTest2() {
        print("structTest2")
        
        var struct1 = MyStruct(title: "Title1")
        print("Struct1: ", struct1.title)
        struct1.title = "Title2"
        print("Struct1: ", struct1.title)
        
        var struct2 = CustomStruct(title: "Title1")
        print("Struct2: ", struct2.title)
        // Change the struct properties wtihout making it muttable
        struct2 = CustomStruct(title: "Title2")
        print("Struct2: ", struct2.title)
        
        var struct3 = CustomStruct(title: "Title3")
        print("Struct3: ", struct3.title)
        // Change the title
        struct3 = struct3.updateTitle(newTitle: "Title2")
        print("Struct3: ", struct3.title)
        
        var struct4 = MutatingStruct(title: "Title1")
        print("Struct4: ", struct4.title)
        struct4.updateTitle(newTitle: "Title2")
        print("Struct4: ", struct4.title)
    }
}

class MyClass {
    var title: String
    
    init(title: String) {
        self.title = title
    }
    
    // When changing title goes inside object, then changes the value of this attribute
    func updateTitle(newTitle: String) {
        title = newTitle
    }
    
}

actor MyActor {
    var title: String
    
    init(title: String) {
        self.title = title
    }
    
    // When changing title goes inside object, then changes the value of this attribute
    func updateTitle(newTitle: String) {
        title = newTitle
    }
    
}

extension StructClassActorBootcamp {
    private func classTest2() {
        print("classTest2")
        
        let class1 = MyClass(title: "Title1")
        print("Class1: ", class1.title)
        class1.title = "Title2"
        print("Class1: ", class1.title)
        
        let class2 = MyClass(title: "Title1")
        print("Class2: ", class2.title)
        class2.updateTitle(newTitle:  "Title2")
        print("Class2: ", class2.title)
        
    }
}
