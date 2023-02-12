//
//  StorageLocationController.swift
//  
//
//  Created by Mike Shevelinsky on 28.01.2022.
//

import Fluent
import Vapor
import FluentSQL

struct StorageLocationController: RouteCollection {

    func boot(routes: RoutesBuilder) throws {
        let location = routes.grouped("location")
        location.get(use: rootIndex)
        location.post(use: create)
        location.group(":locationID") { location in
            location.get(use: index)
            location.grouped("chain").get(use: chain)
            location.delete(use: delete)
            location.post("image", use: addImage)
            location.get("image", use: getImage)
        }
    }

    /// Query root locations
    func rootIndex(req: Request) async throws -> [StorageLocationJson] {
        if let sql = req.db as? SQLDatabase {
            return try await sql
                .raw("SELECT * FROM storage_locations WHERE parent IS NULL")
                .all(decoding: StorageLocation.self)
                .map { $0.getJson() }
        } else {
            throw Abort(.imATeapot)
        }
    }

    /// Query child locations of a location
    func index(req: Request) async throws -> [StorageLocationJson] {
        guard let parentID = UUID(uuidString: req.parameters.get("locationID") ?? "") else {
            throw Abort(.badRequest)
        }

        return try await StorageLocation
            .query(on: req.db)
            .with(\.$parent)
            .filter(\.$parent.$id == parentID)
            .all()
            .compactMap { $0.getJson() }
    }

    /// Query a chain of location till a location
    func chain(req: Request) async throws -> [StorageLocationJson] {
        guard let locationID = UUID(uuidString: req.parameters.get("locationID") ?? ""),
              let location = try await StorageLocation
                .query(on: req.db)
                .with(\.$parent)
                .filter(\.$id == locationID)
                .first() else {
            throw Abort(.notFound)
        }

        var chain = [location]
        var parent = try await getParent(for: location, on: req.db)
        if parent == nil {
            return [location]
                .map { $0.getJson() }
        }
        while parent != nil {
            chain.append(parent!)
            parent = try await getParent(for: parent!, on: req.db)
        }
        return chain
            .map { $0.getJson() }
    }

    private func getParent(for location: StorageLocation, on db: Database) async throws -> StorageLocation? {
        guard let id = location.parent?.id else {
            return nil
        }
        return try await StorageLocation
            .query(on: db)
            .with(\.$parent)
            .filter(\.$id == id)
            .first()
    }

    /// Create new location
    func create(req: Request) async throws -> StorageLocationJson {
        let locationRep = try req.content.decode(StorageLocationJson.self)

        let location = StorageLocation(id: nil, tag: locationRep.tag, description: locationRep.description, parentID: locationRep.parent?.id, type: locationRep.type)
        try await location.save(on: req.db)
        return location.getJson()
    }

    /// Add image for a location
    func addImage(req: Request) async throws -> HTTPStatus {
        guard let location = try await StorageLocation.find(req.parameters.get("locationID"), on: req.db),
              let id = location.id else {
            throw Abort(.notFound)
        }

        guard let imageData = req.body.data else {
            throw Abort(.badRequest)
        }

        try await req.minio.put(data: imageData, bucket: "mom", key: "\(id).jpg")
        return .accepted
    }

    /// Get image for a location
    func getImage(req: Request) async throws -> Response {
        guard let location = try await StorageLocation.find(req.parameters.get("locationID"), on: req.db),
              let id = location.id else {
            throw Abort(.notFound)
        }

        let imageData = try await req.minio.get(bucket: "mom", key: "\(id).jpg")
        let resp = Response()
        resp.body = Response.Body(data: imageData)

        return resp
    }

    /// Delete a location
    func delete(req: Request) async throws -> HTTPStatus {
        guard let location = try await StorageLocation.find(req.parameters.get("locationID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await location.delete(on: req.db)
        return .ok
    }
}
