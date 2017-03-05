//
//  User.swift
//  Hello
//
//  Created by Daniel Martín Prieto on 04/03/2017.
//
//

import Foundation
import Vapor
import Auth
import Turnstile
import TurnstileCrypto

struct User {
    var id: Node?
    var exists: Bool = false
    
    let username: String
    let accessToken: String
}

extension User: Model {
    
    // We don't want mistakes accessing different properties/fields
    fileprivate struct Meta {
        let entity: String
        let id: String
        let username: String
        let accessToken: String
    }
    
    fileprivate static let meta = Meta(entity: "users", id: "id", username: "username", accessToken: "access_token")
    
    // Checks if the username is already taken
    fileprivate static func isUniqueUsername(_ username: String) throws -> Bool {
        return try User.query().filter(User.meta.username, username).first() == nil
    }
    
    // Creates a unique random secure token
    // Maybe using `UUID().uuidString` would have been a better idea...
    fileprivate static func uniqueAccessToken() throws -> String {
        while true {
            let token = URandom().secureToken
            if try User.query().filter(User.meta.accessToken, token).first() == nil {
                return token
            }
        }
    }
    
    // Creates a user from a JSON payload
    // Gets the username from the JSON and, if it wasn't taken, gives it a unique access token
    init(json: JSON) throws {
        let username = try json.extract(User.meta.username) as String
        guard try User.isUniqueUsername(username) else {
            throw AccountTakenError()
        }
        self.username = username
        self.accessToken = try User.uniqueAccessToken()
    }
    
    init(node: Node, in context: Context) throws {
        self.id = try node.extract(User.meta.id)
        self.username = try node.extract(User.meta.username)
        self.accessToken = try node.extract(User.meta.accessToken)
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            User.meta.id: id,
            User.meta.username: username,
            User.meta.accessToken: accessToken
        ])
    }
    
    static func prepare(_ database: Database) throws {
        try database.create(User.meta.entity, closure: { users in
            users.id()
            users.string(User.meta.username)
            users.string(User.meta.accessToken)
        })
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(User.meta.entity)
    }
}

extension User: Auth.User {
    
    // Handles authentication for credentials of AccessToken type
    static func authenticate(credentials: Credentials) throws -> Auth.User {
        switch credentials {
        case let accessToken as AccessToken:
            guard let user = try User.query().filter(User.meta.accessToken, accessToken.string).first() else {
                throw IncorrectCredentialsError()
            }
            return user
        default:
            throw UnsupportedCredentialsError()
        }
    }
    
    // Registration is already supported via user creation
    static func register(credentials: Credentials) throws -> Auth.User {
        throw Abort.badRequest
    }
    
}

extension User {
    
    // Nice helper to get the user's messages
    func messages() throws -> [Message] {
        return try children(nil, Message.self).all()
    }
}

