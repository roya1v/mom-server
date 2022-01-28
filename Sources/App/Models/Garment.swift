//
//  Garment.swift
//  
//
//  Created by Mike Shevelinsky on 18.12.2021.
//

import Fluent
import Vapor

final class Garment: Model, Content {
    static let schema = "garments"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "title")
    var title: String

    @Enum(key: "state")
    var state: GarmentState

    @Enum(key: "condition")
    var condition: GarmentCondition

    @Enum(key: "type")
    var type: GarmentType

    @Enum(key: "style")
    var style: GarmentStyle

    init() { }

    init(id: UUID? = nil, title: String, state: GarmentState, condition: GarmentCondition, type: GarmentType, style: GarmentStyle) {
        self.id = id
        self.title = title
        self.state = state
        self.condition = condition
        self.type = type
        self.style = style
    }
}

enum GarmentState: String, Codable {
    case clean
    case inUse
    case laundry
}

enum GarmentCondition: String, Codable {
    case new
    case casual
    case rat
    case recycle
}

enum GarmentType: String, Codable {
    case tShirt
    case sweater
    case pants
    case underwear
    case socks
    case shoes
    case hat
    case accessory
}

enum GarmentStyle: String, Codable {
    case black
    case casual
    case hipster
    case outdated
}
