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
        }
    }

    // MARK: - Fetch locations

    func rootIndex(req: Request) async throws -> [StorageLocationJSONRepresentable] {
        if let sql = req.db as? SQLDatabase {
            return try await sql
                .raw("SELECT * FROM storage_locations WHERE parent IS NULL")
                .all(decoding: StorageLocation.self)
                .map { $0.jsonRepresentable() }
        } else {
            throw Abort(.imATeapot)
        }
    }

    func index(req: Request) async throws -> [StorageLocationJSONRepresentable] {
        guard let parentID = UUID(uuidString: req.parameters.get("locationID") ?? "") else {
            throw Abort(.badRequest)
        }

        return try await StorageLocation
            .query(on: req.db)
            .with(\.$parent)
            .filter(\.$parent.$id == parentID)
            .all()
            .compactMap { $0.jsonRepresentable() }
    }

    // MARK: - Fetch chain of locations to location

    func chain(req: Request) async throws -> [StorageLocation] {
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
        }
        while parent != nil {
            chain.append(parent!)
            parent = try await getParent(for: parent!, on: req.db)
        }
        return chain
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

    // MARK: - Create

    func create(req: Request) async throws -> StorageLocationJSONRepresentable {
        let locationRep = try req.content.decode(StorageLocationJSONRepresentable.self)

        let location = StorageLocation(id: nil, tag: locationRep.tag, description: locationRep.description, parentID: locationRep.parent?.id, type: locationRep.type)
        try await location.save(on: req.db)
        return location.jsonRepresentable()
    }

    // MARK: - Delete

    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return StorageLocation.find(req.parameters.get("locationID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db)}
            .transform(to: .ok)
    }
}
