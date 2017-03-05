import Vapor
import Fluent
import Auth

// Utils

extension Abort {
    
    static var unauthorized: Abort {
        return .custom(status: .unauthorized, message: "Unauthorized")
    }
    
    static var forbidden: Abort {
        return .custom(status: .forbidden, message: "Forbidden")
    }
    
}

// App

let drop = Droplet()

// Database

// - Driver
drop.database = Database(MemoryDriver()) // Note we're using an in memory database

// - Tables
drop.preparations += User.self
drop.preparations += Message.self

// Auth middleware tied to our User entity
drop.middleware += AuthMiddleware(user: User.self)

// Controllers

// - Users
drop.resource("users", UserController())

// - Messages, protected under our Bearer authentication middleware
let protect = ProtectMiddleware(error: Abort.unauthorized)
drop.grouped(BearerAuthenticationMiddleware(), protect).resource("messages", MessageController())

drop.run()
