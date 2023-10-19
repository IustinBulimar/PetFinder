//
//  Models.swift
//  PetFinder
//
//  Created by Iustin Bulimar on 19.10.2023.
//

import Foundation


struct AnimalResponse: Codable {
    let animals: [Animal]
    let pagination: Pagination
}

struct Animal: Codable, Identifiable, Equatable {
    let id: Int
    let organizationId: String?
    let url: String?
    let type: String?
    let species: String?
    let breeds: Breed?
    let colors: AnimalColor?
    let age: String?
    let gender: String?
    let size: String?
    let coat: String?
    let attributes: Attributes?
    let environment: Environment?
    let tags: [String]?
    let name: String?
    let description: String?
    let photos: [Photo]?
    let videos: [Video]?
    let status: String?
    let published_at: String?
    let contact: Contact?
    
    static func == (lhs: Animal, rhs: Animal) -> Bool {
        lhs.id == rhs.id
    }
}

struct Breed: Codable {
    let primary: String?
    let secondary: String?
    let mixed: Bool?
    let unknown: Bool?
}

struct AnimalColor: Codable {
    let primary: String?
    let secondary: String?
    let tertiary: String?
}

struct Attributes: Codable {
    let spayedNeutered: Bool?
    let houseTrained: Bool?
    let declawed: Bool?
    let specialNeeds: Bool?
    let shotsCurrent: Bool?
}

struct Environment: Codable {
    let children: Bool?
    let dogs: Bool?
    let cats: Bool?
}

struct Photo: Codable {
    let small: String?
    let medium: String?
    let large: String?
    let full: String?
}

struct Video: Codable {
    let embed: String?
}

struct Contact: Codable {
    let email: String?
    let phone: String?
    let address: Address
}

struct Address: Codable {
    let address1: String?
    let address2: String?
    let city: String?
    let state: String?
    let postcode: String?
    let country: String?
    
    var fullAdress: String {
        "\(address1 ?? address2 ?? ""), \(city ?? ""), \(state ?? ""), \(postcode ?? ""), \(country ?? "")"
    }
}

struct Pagination: Codable {
    let countPerPage: Int
    let totalCount: Int
    let currentPage: Int
    let totalPages: Int
}

