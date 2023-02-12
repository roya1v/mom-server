//
//  StorageController.swift
//  
//
//  Created by Mike Shevelinsky on 24.01.2022.
//

import Fluent
import Vapor
import FluentSQL

struct StorageController: RouteCollection {

    func boot(routes: RoutesBuilder) throws {
        let storage = routes.grouped("storage")

        try storage.register(collection: StorageLocationController())
        try storage.register(collection: StorageEntityController())
    }
}
