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
        garments.put(use: update)
        garments.group(":garmentID") { garment in
            garment.delete(use: delete)
        }
    }

    func index(req: Request) throws -> EventLoopFuture<[Garment]> {
        return Garment.query(on: req.db).all()
    }

    func create(req: Request) throws -> EventLoopFuture<Garment> {
        let garment = try req.content.decode(Garment.self)
        return garment.save(on: req.db).map { garment }
    }

    func update(req: Request) async throws -> HTTPStatus {
        let garment = try req.content.decode(Garment.self)
        guard let test = try await Garment.find(garment.id, on: req.db) else {
            throw Abort(.notFound)
        }
        test.state = garment.state
        try await test.update(on: req.db)
        return .accepted
    }

    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return Garment.find(req.parameters.get("garmentID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: .ok)
    }
}
