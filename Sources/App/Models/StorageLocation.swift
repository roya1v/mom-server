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

    //TODO: - Add type
}
