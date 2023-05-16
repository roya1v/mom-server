//
//  Expirable.swift
//  
//
//  Created by Mike Shevelinsky on 16/05/2023.
//

import Fluent
import Vapor
import Foundation

final class Expiration: Model, Content {
    static let schema = "expiration"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "expires_at")
    var expiresAt: Date

    init() { }

    init(date: Date) {
        self.expiresAt = date
    }
}

//final class StorageEntityJson: Content {
//    var id: UUID?
//    var name: String
//    var description: String?
//    var location: StorageLocationJson
//
//    init(from entity: StorageEntity) {
//        self.id = entity.id
//        self.name = entity.name
//        self.description = entity.description
//        self.location = entity.location.getJson()
//    }
//}
