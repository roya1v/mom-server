//
//  GarmentController.swift
//  
//
//  Created by Mike Shevelinsky on 18.12.2021.
//

import Fluent
import Vapor
import Network
import SotoS3

struct GarmentController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let garments = routes.grouped("garments")
        garments.get(use: index)
        garments.post(use: create)
        garments.put(use: update)
        garments.group(":garmentID") { garment in
            garment.delete(use: delete)
            garment.grouped("image").post(use: addImage)
            garment.grouped("image").get(use: getImage)
        }
    }

    func addImage(req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("garmentID"),
              let _ = try? await Garment.find(UUID(uuidString: id), on: req.db) else {
            return .notFound
        }

        try await req.minio.put(data: req.body.data!, bucket: "garment", key: "\(id).jpg")
        return .accepted
    }

    func getImage(req: Request) async throws -> Response {
        guard let id = req.parameters.get("garmentID"),
              let _ = try? await Garment.find(UUID(uuidString: id), on: req.db) else {
            return Response(status: .notFound)
        }

        let imageData = try await req.minio.get(bucket: "garment", key: "\(id).jpg")
        let resp = Response()
        resp.body = Response.Body(data: imageData)

        return resp
    }

    func index(req: Request) throws -> EventLoopFuture<[Garment]> {
        return Garment
            .query(on: req.db)
            .sort(\.$state)
            .sort(\.$type)
            .all()
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
