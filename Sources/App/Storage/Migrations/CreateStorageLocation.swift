//
//  CreateStorageLocation.swift
//  
//
//  Created by Mike Shevelinsky on 24.01.2022.
//

import Fluent

struct CreateStorageLocation: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(StorageLocation.schema)
            .id()
            .field("tag", .string, .required)
            .field("description", .string)
            .field("parent", .uuid, .references(StorageLocation.schema, "id"))
            .foreignKey("parent", references: StorageLocation.schema, "id", onDelete: .cascade)
            .field("type", .string, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(StorageLocation.schema).delete()
    }
}
