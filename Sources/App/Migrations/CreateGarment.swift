//
//  CreateGarment.swift
//  
//
//  Created by Mike Shevelinsky on 18.12.2021.
//

import Fluent

struct CreateGarment: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Garment.schema)
            .id()
            .field("title", .string, .required)
            .field("state", .string, .required)
            .field("condition", .string, .required)
            .field("type", .string, .required)
            .field("style", .string, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Garment.schema).delete()
    }
}
