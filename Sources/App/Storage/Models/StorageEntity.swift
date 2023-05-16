//
//  StorageEntity.swift
//  
//
//  Created by Mike Shevelinsky on 28.01.2022.
//

import Fluent
import Vapor
import Foundation

final class StorageEntity: Model, Content {
    static let schema = "storage_entity"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @OptionalField(key: "description")
    var description: String?

    @Parent(key: "location")
    var location: StorageLocation

    @OptionalParent(key: "expiration")
    var expiration: Expiration?

    func getJson() -> StorageEntityJson {
        return StorageEntityJson(from: self)
    }
}

final class StorageEntityJson: Content {
    var id: UUID?
    var name: String
    var description: String?
    var location: StorageLocationJson
    var expiration: Date?

    init(from entity: StorageEntity) {
        self.id = entity.id
        self.name = entity.name
        self.description = entity.description
        self.location = entity.location.getJson()
        self.expiration = entity.expiration?.expiresAt
    }
}
