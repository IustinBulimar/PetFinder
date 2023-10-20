//
//  AnimalResponse+Mock.swift
//  PetFinder
//
//  Created by Iustin Bulimar on 20.10.2023.
//

import Foundation

extension Animal {
    static func mock() -> Animal {
        guard let animalResponse = try? getMock(forType: AnimalResponse.self),
           let animal = animalResponse.animals.first else {
            fatalError("Could not load Animal mock")
        }
        return animal
    }
}
