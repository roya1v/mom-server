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
        entities.get(use: index)
        entities.post(use: create)
        entities.group(":entityID") { entity in
            entity.delete(use: delete)
        }
    }

    // MARK: - Locations

    func index(req: Request) throws -> EventLoopFuture<[StorageEntity]> {
        return StorageEntity
            .query(on: req.db)
            .all()
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
