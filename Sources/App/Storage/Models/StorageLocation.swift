//
//  File.swift
//  
//
//  Created by Mike Shevelinsky on 24.01.2022.
//

import Fluent
import Vapor
import Foundation

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

    init() { }

    init(id: UUID? = nil, tag: String, description: String?, parentID: UUID?, type: StorageType) {
        self.id = id
        self.tag = tag
        self.description = description
        self.$parent.id = parentID
        self.type = type
    }

    func jsonRepresentable() -> StorageLocationJSONRepresentable {
        return StorageLocationJSONRepresentable(with: self)
    }
}

final class StorageLocationJSONRepresentable: Content {
    var id: UUID?

    var tag: String

    var description: String?

    var parent: StorageLocationJSONRepresentable?

    var type: StorageType

    init(with location: StorageLocation) {
        self.id = location.id
        self.tag = location.tag
        self.description = location.description
        self.type = location.type
        if let parent2 = location.parent {
            self.parent = StorageLocationJSONRepresentable(with: parent2)
        }
    }

    func toLocation() -> StorageLocation {
        let location = StorageLocation(tag: tag, description: description, parentID: nil, type: type)
        return location
    }
}

enum StorageType: String, Codable {
    case room
    case furniture
    case box
    case other
}
