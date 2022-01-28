//
//  File.swift
//  
//
//  Created by Mike Shevelinsky on 24.01.2022.
//

import Fluent
import Vapor

final class StorageLocation: Model, Content {
    static let schema = "storage_locations"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "tag")
    var tag: String

    @OptionalField(key: "description")
    var description: String?

    @OptionalParent(key: "parent")
    var parent: StorageLocation?

    @Enum(key: "type")
    var type: StorageType
}

enum StorageType: String, Codable {
    case room
    case furniture
    case box
    case other
}
