//
//  UserController.swift
//  Hello
//
//  Created by Daniel Martín Prieto on 05/03/2017.
//
//

import Foundation
import Vapor
import HTTP

// The user controller only allows creating a new user

final class UserController: ResourceRepresentable {
    
    fileprivate func create(request: Request) throws -> ResponseRepresentable {
        var user = try request.user()
        try user.save()
        return user
    }
    
    func makeResource() -> Resource<User> {
        return Resource(store: create)
    }
}

extension Request {
    
    fileprivate func user() throws -> User {
        guard let json = json else { throw Abort.badRequest }
        return try User(json: json)
    }
    
    func authUser() throws -> User {
        return try auth.user() as! User
    }
}
