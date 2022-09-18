//
//  AsyncAwaitBootCamp.swift
//  SwiftConcurrency
//
//  Created by Leone on 9/18/22.
//

import SwiftUI

class AsyncAwaitBootCampViewModel: ObservableObject {
    
}

struct AsyncAwaitBootCamp: View {
    
    @StateObject private var viewModel = AsyncAwaitBootCampViewModel()
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct AsyncAwaitBootCamp_Previews: PreviewProvider {
    static var previews: some View {
        AsyncAwaitBootCamp()
    }
}
