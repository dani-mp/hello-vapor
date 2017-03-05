//
//  Message.swift
//  Hello
//
//  Created by Daniel Martín Prieto on 05/03/2017.
//
//

import Foundation
import Vapor

struct Message {
    var id: Node?
    var exists: Bool = false
    
    let text: String
    var userId: Node?
}

extension Message: Model {
    
    // We don't want mistakes accessing different properties/fields
    fileprivate struct Meta {
        let entity: String
        let id: String
        let text: String
        let userId: String
    }
    
    fileprivate static let meta = Meta(entity: "messages", id: "id", text: "text", userId: "user_id")
    
    init(node: Node, in context: Context) throws {
        self.id = try node.extract(Message.meta.id)
        self.text = try node.extract(Message.meta.text)
        self.userId = try node.extract(Message.meta.userId)
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            Message.meta.id: id,
            Message.meta.text: text,
            Message.meta.userId: userId
        ])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create(Message.meta.entity, closure: { messages in
            messages.id()
            messages.string(Message.meta.text)
            messages.parent(User.self, optional: false) // A message must belong to a user
        })
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(Message.meta.entity)
    }
    
}

extension Message {
    
    // Nice helper to get the message's user object
    func user() throws -> User? {
        return try parent(userId, nil, User.self).get()
    }
}
