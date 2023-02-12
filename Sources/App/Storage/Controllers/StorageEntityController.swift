//
//  StorageEntity.swift
//  
//
//  Created by Mike Shevelinsky on 28.01.2022.
//

import Fluent
import Vapor
import FluentSQL

struct StorageEntityController: RouteCollection {

    func boot(routes: RoutesBuilder) throws {
        let entities = routes.grouped("entities")
        entities.get(use: indexAll)
        entities.post(use: create)
        entities.group(":entityID") { entity in
            entity.delete(use: delete)
        }
        entities.group(":locationID") { entity in
            entity.get(use: index)
        }
    }

    /// Query all entities
    func indexAll(req: Request) async throws -> [StorageEntityJson] {
        return try await StorageEntity
            .query(on: req.db)
            .with(\.$location)
            .all()
            .map { $0.getJson() }
    }

    /// Query all entities at a specific location
    func index(req: Request) async throws -> [StorageEntityJson] {
        guard let locationID = UUID(uuidString: req.parameters.get("locationID") ?? "") else {
            throw Abort(.badRequest)
        }

        return try await StorageEntity
            .query(on: req.db)
            .with(\.$location)
            .filter(\.$location.$id == locationID)
            .all()
            .map { $0.getJson() }
    }

    /// Create new entity
    func create(req: Request) async throws -> StorageEntity {
        let entity = try req.content.decode(StorageEntity.self)
        try await entity.save(on: req.db)
        return entity
    }

    /// Delete a specific entity
    func delete(req: Request) async throws -> HTTPStatus {
        guard let entity = try await StorageEntity.find(req.parameters.get("entityID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await entity.delete(on: req.db)
        return .ok
    }
}
