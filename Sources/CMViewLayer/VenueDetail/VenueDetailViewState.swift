//
//  VenueDetailViewState.swift
//  CMViewLayer
//
//  Created by Blake Macnair on 2/7/19.
//  Copyright © 2019 Blake Macnair. All rights reserved.
//

import struct CMFourSquareLayer.Venue

enum VenueDetailViewState {
    case ready(Venue)
}

enum VenueDetailViewAction {
    case tappedExit
}

enum VenueDetailCoordinatorRequest {
    case dismissView
}
