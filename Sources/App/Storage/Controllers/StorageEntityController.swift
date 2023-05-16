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
            entity.post("image", use: addImage)
            entity.get("image", use: getImage)
            entity.get(use: index)
        }
    }

    /// Query all entities
    func indexAll(req: Request) async throws -> [StorageEntityJson] {
        return try await StorageEntity
            .query(on: req.db)
            .with(\.$location)
            .with(\.$expiration)
            .all()
            .map { $0.getJson() }
    }

    /// Query all entities at a specific location
    func index(req: Request) async throws -> [StorageEntityJson] {
        guard let locationID = UUID(uuidString: req.parameters.get("entityID") ?? "") else {
            throw Abort(.badRequest)
        }

        return try await StorageEntity
            .query(on: req.db)
            .with(\.$location)
            .filter(\.$location.$id == locationID)
            .with(\.$expiration)
            .all()
            .map { $0.getJson() }
    }

    /// Create new entity
    func create(req: Request) async throws -> StorageEntityJson {
        let jsonEntity = try req.content.decode(StorageEntityJson.self)
        let entity = StorageEntity()
        entity.name = jsonEntity.name
        entity.description = jsonEntity.description
        entity.$location.id = jsonEntity.location.id!
        
        if let expirationDate = jsonEntity.expiration {
            let expirationEntity = Expiration(date: expirationDate)
            try await expirationEntity.save(on: req.db)
            entity.$expiration.id = expirationEntity.id
        }
        try await entity.save(on: req.db)
        try await entity.$location.load(on: req.db)
        try await entity.$expiration.load(on: req.db)
        return entity.getJson()
    }

    /// Add image for an entity
    func addImage(req: Request) async throws -> HTTPStatus {
        guard let entity = try await StorageEntity.find(req.parameters.get("entityID"), on: req.db),
              let id = entity.id else {
            throw Abort(.notFound)
        }

        guard let imageData = req.body.data else {
            throw Abort(.badRequest)
        }

        try await req.minio.put(data: imageData, bucket: "mom", key: "\(id).jpg")
        return .accepted
    }

    /// Get image for an entity
    func getImage(req: Request) async throws -> Response {
        guard let entity = try await StorageEntity.find(req.parameters.get("entityID"), on: req.db),
              let id = entity.id else {
            throw Abort(.notFound)
        }

        let imageData = try await req.minio.get(bucket: "mom", key: "\(id).jpg")
        let resp = Response()
        resp.body = Response.Body(data: imageData)

        return resp
    }

    /// Delete an entity
    func delete(req: Request) async throws -> HTTPStatus {
        guard let entity = try await StorageEntity.find(req.parameters.get("entityID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await entity.$expiration.load(on: req.db)
        try await entity.expiration?.delete(on: req.db)
        try await entity.delete(on: req.db)
        return .ok
    }
}
