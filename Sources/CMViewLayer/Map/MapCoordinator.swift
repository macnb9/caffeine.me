//
//  MapCoordinator.swift
//  CMViewLayer
//
//  Created by Blake Macnair on 2/6/19.
//  Copyright © 2019 Blake Macnair. All rights reserved.
//

import RxSwift
import RxCocoa
import RxMKMapView
import MapKit

import CMLocationLayer
import CMFourSquareLayer

final class MapCoordinator: BaseCoordinator<Void> {

    private let navigationController: UINavigationController
    private let viewController: MapViewControllerProtocol & UIViewController
    private let viewModel: MapViewModelProtocol
    private let interactor: MapInteractorProtocol

    private let relay = CMFourSquareRelay()

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController

        let locationRelay = CMLocationRelay()
        let fourSquareRelay = CMFourSquareRelay()

        self.interactor = MapInteractor(locationRelay: locationRelay,
                                        fourSquareRelay: fourSquareRelay)
        self.viewModel = MapViewModel()
        self.viewController = MapViewController()

        super.init()
    }

    override func start() -> Signal<Void> {
        startServices()

        navigationController.pushViewController(self.viewController, animated: true)
        return .never()
    }

    private func startServices() {
        self.viewController.uiEvents
            .bind(to: self.viewModel.actions)
            .disposed(by: disposeBag)

        self.viewModel.state.debug("MODEL STATE")
            .drive(self.viewController.state)
            .disposed(by: disposeBag)

        self.interactor.state.toViewAction().debug("INT ACTION")
            .bind(to: viewModel.actions)
            .disposed(by: disposeBag)

        interactor.startLocationServies()
        interactor.refreshVenues()
    }
}

extension ObservableType where E == MapInteractorState {
    func toViewAction() -> Observable<MapViewAction> {
        return self
            .map { intState -> MapViewAction? in
                guard case .ready(let userPlacemark, let annotations) = intState
                    else { return nil }
                return .locationServicesUpdated(userPlacemark: userPlacemark,
                                                annotations: annotations)
            }
            .filter { $0 != nil }
            .map { $0! }
    }
}
