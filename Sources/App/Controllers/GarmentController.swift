//
//  GarmentController.swift
//  
//
//  Created by Mike Shevelinsky on 18.12.2021.
//

import Fluent
import Vapor

struct GarmentController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let garments = routes.grouped("garments")
        garments.get(use: index)
        garments.post(use: create)
    }

    func index(req: Request) throws -> EventLoopFuture<[Garment]> {
        return Garment.query(on: req.db).all()
    }

    func create(req: Request) throws -> EventLoopFuture<Garment> {
        let garment = try req.content.decode(Garment.self)
        return garment.save(on: req.db).map { garment }
    }
}
