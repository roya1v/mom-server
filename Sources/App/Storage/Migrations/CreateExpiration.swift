//
//  CreateStorageEntity.swift
//
//
//  Created by Mike Shevelinsky on 28.01.2022.
//

import Fluent

struct CreateExpiration: AsyncMigration {
    func prepare(on database: Database) async throws {
        return try await database.schema(Expiration.schema)
            .id()
            .field("expires_at", .datetime, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        return try await database.schema(Expiration.schema).delete()
    }
}
