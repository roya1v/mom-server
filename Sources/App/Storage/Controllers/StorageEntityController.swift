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

    // MARK: - Locations

    func indexAll(req: Request) async throws -> [StorageEntityJSONRepresentable] {
        return try await StorageEntity
            .query(on: req.db)
            .with(\.$location)
            .all()
            .map { $0.jsonRepresentable() }
    }

    func index(req: Request) async throws -> [StorageEntityJSONRepresentable] {
        guard let locationID = UUID(uuidString: req.parameters.get("locationID") ?? "") else {
            throw Abort(.badRequest)
        }

        return try await StorageEntity
            .query(on: req.db)
            .with(\.$location)
            .filter(\.$location.$id == locationID)
            .all()
            .map { $0.jsonRepresentable() }
    }

    func create(req: Request) throws -> EventLoopFuture<StorageEntity> {
        let entity = try req.content.decode(StorageEntity.self)
        return entity.save(on: req.db).map { entity }
    }

    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return StorageEntity.find(req.parameters.get("entityID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: .ok)
    }
}
