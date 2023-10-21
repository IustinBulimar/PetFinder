//
//  ContentView.swift
//  PetFinder
//
//  Created by Iustin Bulimar on 19.10.2023.
//

import SwiftUI

struct PetsView: View {
    @ObservedObject var viewModel: PetsViewModel
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.animals) { animal in
                    NavigationLink {
                        PetDetailsView(viewModel: viewModel)
                            .onAppear {
                                viewModel.selectAnimal(animal)
                            }
                            .onDisappear {
                                viewModel.removeSeletion()
                            }
                    } label: {
                        PetRowView(animal: animal)
                    }
                    .onAppear {
                        if viewModel.almostReachedBottom(animal: animal) {
                            viewModel.getNextAnimalPage()
                        }
                    }
                }
            }
            .navigationTitle("Find a pet")
            .alert(isPresented: $viewModel.showErrorAlert, error: viewModel.error) {}
        }
    }
}

#Preview {
    PetsView(viewModel: PetsViewModel())
}


