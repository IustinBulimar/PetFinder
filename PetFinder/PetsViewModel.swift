//
//  ViewModel.swift
//  PetFinder
//
//  Created by Iustin Bulimar on 19.10.2023.
//

import Foundation
import RxSwift

class PetsViewModel: ObservableObject {
    @Published var animals: [Animal] = []
    @Published var selectedAnimal: Animal?
    @Published var distanceToSelectedAnimal: Double?
    @Published var showErrorAlert: Bool = false
    
    var error: AppError? {
        didSet {
            showErrorAlert = true
        }
    }
    var currentPagination: Pagination? = nil
    var isFetchingNextPage = false
    
    let api = PetAPI(session: .shared)
    let locationManager = LocationManager()
    let disposeBag = DisposeBag()
    
    init() {
        getNextAnimalPage()
    }
    
    func almostReachedBottom(animal: Animal) -> Bool {
        animal == animals[animals.count - 5]
    }
    
    func getNextAnimalPage() {
        guard !isFetchingNextPage else { return }
        let currentPage = currentPagination?.currentPage ?? 0
        let totalPages = currentPagination?.totalPages ?? 1
        
        guard currentPage < totalPages else { return }
        
        isFetchingNextPage = true
        api.getAnimals(type: "cat", page: currentPage + 1)
            .observe(on: MainScheduler.instance)
            .subscribe { animalResponse in
                self.animals += animalResponse.animals
                self.currentPagination = animalResponse.pagination
                self.isFetchingNextPage = false
            } onError: { error in
                self.error = error as? AppError ?? .generic
                self.isFetchingNextPage = false
            }
            .disposed(by: disposeBag)
    }
    
    func selectAnimal(_ animal: Animal) {
        selectedAnimal = animal
        
        let fullAddress = animal.contact?.address.fullAdress ?? ""
        return locationManager.distance(to: fullAddress)
            .observe(on: MainScheduler.instance)
            .subscribe { distance in
                self.distanceToSelectedAnimal = distance / 1000.0
            } onError: { error in
                self.error = error as? AppError ?? .generic
            }
            .disposed(by: disposeBag)
    }
    
    func removeSeletion() {
        selectedAnimal = nil
        distanceToSelectedAnimal = nil
    }
    
}
