//
//  AnimalDetailsView.swift
//  PetFinder
//
//  Created by Iustin Bulimar on 21.10.2023.
//

import SwiftUI

struct PetDetailsView: View {
    @ObservedObject var viewModel: PetsViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                GeometryReader { geo in
                    AsyncImage(url: URL(string: viewModel.selectedAnimal?.photos?.first?.large ?? "")) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Color.gray
                            .overlay {
                                Image(systemName: "photo.fill")
                            }
                    }
                    .frame(width: geo.size.width, height: 300)
                    .clipped()
                }
                .frame(height: 300)
                
                VStack(alignment: .leading) {
                    Text(viewModel.selectedAnimal?.name ?? "N/A")
                        .font(.title)
                    Text(viewModel.selectedAnimal?.breeds?.primary ?? "N/A")
                    Text(viewModel.selectedAnimal?.size ?? "N/A")
                    Text(viewModel.selectedAnimal?.gender ?? "N/A")
                    Text(viewModel.selectedAnimal?.status ?? "N/A")
                    Text(String(format: "%.2f Km away", viewModel.distanceToSelectedAnimal ?? 0))
                }
                .padding()
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Animal Details")
        }
    }
}

#Preview {
    let viewModel = PetsViewModel()
    viewModel.selectAnimal(.mock())
    return PetDetailsView(viewModel: viewModel)
}
