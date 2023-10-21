//
//  AnimalRowView.swift
//  PetFinder
//
//  Created by Iustin Bulimar on 21.10.2023.
//

import SwiftUI

struct PetRowView: View {
    var animal: Animal
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: animal.photos?.first?.small ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Color.gray
                    .overlay {
                        Image(systemName: "photo.fill")
                        
                    }
            }
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            Text(animal.name ?? "N/A")
                .font(.headline)
                .padding(10)
        }
    }
}

#Preview {
    PetRowView(animal: .mock())
}
