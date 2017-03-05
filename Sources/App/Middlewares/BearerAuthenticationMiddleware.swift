//
//  BearerAuthenticationMiddleware.swift
//  Hello
//
//  Created by Daniel Martín Prieto on 05/03/2017.
//
//

import Vapor
import HTTP

// Middleware that tries to authenticate the user with a bearer authorization header request
class BearerAuthenticationMiddleware: Middleware {
    
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        guard let bearer = request.auth.header?.bearer else {
            throw Abort.badRequest
        }
        try request.auth.login(bearer, persist: false)
        return try next.respond(to: request)
    }
}
