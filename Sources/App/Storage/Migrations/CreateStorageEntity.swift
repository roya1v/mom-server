//
//  CreateStorageEntity.swift
//  
//
//  Created by Mike Shevelinsky on 28.01.2022.
//

import Fluent

struct CreateStorageEntity: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(StorageEntity.schema)
            .id()
            .field("name", .string, .required)
            .field("description", .string)
            .field("location", .uuid, .references(StorageLocation.schema, "id"), .required)
            .field("expiration", .uuid, .references(Expiration.schema, "id", onDelete: .setNull))
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(StorageEntity.schema).delete()
    }
}
