//
//  PetFinderApp.swift
//  PetFinder
//
//  Created by Iustin Bulimar on 19.10.2023.
//

import SwiftUI

@main
struct PetFinderApp: App {
    @StateObject var viewModel = PetsViewModel()
    
    var body: some Scene {
        WindowGroup {
            PetsView(viewModel: viewModel)
        }
    }
}
