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


        let location = storage.grouped("location")
        location.get(use: rootIndex)
        location.post(use: create)
        location.group(":locationID") { location in
            location.get(use: arbitraryIndex)
        }
    }

    // MARK: - Locations

    func rootIndex(req: Request) throws -> EventLoopFuture<[StorageLocation]> {
        if let sql = req.db as? SQLDatabase {
            return sql
                .raw("SELECT * FROM storage_locations WHERE parent IS NULL")
                .all(decoding: StorageLocation.self)
        } else {
            throw Abort(.imATeapot)
        }
    }

    func arbitraryIndex(req: Request) throws -> EventLoopFuture<[StorageLocation]> {
        guard let parentID = UUID(uuidString: req.parameters.get("locationID")) else {
            throw Abort(.badRequest)
        }

        return StorageLocation
            .query(on: req.db)
            .with(\.$parent)
            .filter(\.$parent.$id == parentID)
            .all()
    }

    func create(req: Request) throws -> EventLoopFuture<StorageLocation> {
        let location = try req.content.decode(StorageLocation.self)
        return location.save(on: req.db).map { location }
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
