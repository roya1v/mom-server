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
            location.get(use: arbitraryIndex)
            location.grouped("chain").get(use: index)
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
        guard let parentID = UUID(uuidString: req.parameters.get("locationID") ?? "") else {
            throw Abort(.badRequest)
        }

        return StorageLocation
            .query(on: req.db)
            .with(\.$parent)
            .filter(\.$parent.$id == parentID)
            .all()
    }

    func index(req: Request) async throws -> [StorageLocation] {
        guard let locationID = UUID(uuidString: req.parameters.get("locationID") ?? ""),
              let location = try await StorageLocation
                .query(on: req.db)
                .with(\.$parent)
                .filter(\.$id == locationID)
                .first() else {
            throw Abort(.notFound)
        }

        var chain = [location]

        print("LOCATION PARENT: \(location.parent)")
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

    func create(req: Request) throws -> EventLoopFuture<StorageLocation> {
        let location = try req.content.decode(StorageLocation.self)
        return location.save(on: req.db).map { location }
    }

    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return StorageLocation.find(req.parameters.get("locationID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: .ok)
    }
}
