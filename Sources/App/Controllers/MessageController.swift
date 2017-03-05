//
//  MessageController.swift
//  Hello
//
//  Created by Daniel Martín Prieto on 05/03/2017.
//
//

import Foundation
import Vapor
import HTTP

// Messages CRUD for the authenticated user

final class MessageController: ResourceRepresentable {
    
    fileprivate func index(request: Request) throws -> ResponseRepresentable {
        let user = try request.authUser()
        return try JSON(node: user.messages().makeNode())
    }
    
    fileprivate func create(request: Request) throws -> ResponseRepresentable {
        let user = try request.authUser()
        var message = try request.message()
        message.userId = user.id
        try message.save()
        return try Response(status: .created, json: message.makeJSON())
    }
    
    fileprivate func show(request: Request, message: Message) throws -> ResponseRepresentable {
        let user = try request.authUser()
        guard user.id == message.userId else {
            throw Abort.forbidden
        }
        return message
    }
    
    fileprivate func update(request: Request, message: Message) throws -> ResponseRepresentable {
        let user = try request.authUser()
        guard user.id == message.userId else {
            throw Abort.forbidden
        }
        var newMessage = try request.message()
        newMessage.id = message.id
        newMessage.exists = message.exists
        newMessage.userId = user.id
        try newMessage.save()
        return newMessage
    }
    
    fileprivate func delete(request: Request, message: Message) throws -> ResponseRepresentable {
        let user = try request.authUser()
        guard user.id == message.userId else {
            throw Abort.forbidden
        }
        try message.delete()
        return Response(status: .noContent)
    }
    
    func makeResource() -> Resource<Message> {
        return Resource(index: index, store: create, show: show, modify: update, destroy: delete)
    }
}

extension Request {
    
    fileprivate func message() throws -> Message {
        guard let json = json else { throw Abort.badRequest }
        return try Message(node: json)
    }
}
