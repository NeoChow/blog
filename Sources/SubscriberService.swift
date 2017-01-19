//
//  SubscriberService.swift
//  drewag.me
//
//  Created by Andrew J Wagner on 1/1/17.
//
//

import Foundation
import SwiftServe
import SwiftPlusPlus
import TextTransformers

struct SubscriberService {
    let connection: DatabaseConnection

    private var allSubscribers: [Subscriber]? = nil

    init(connection: DatabaseConnection) {
        self.connection = connection
    }

    func addSubscriber(withEmail email: String) throws {
        guard try self.subscriber(withEmail: email) == nil else {
            return
        }
        var token: String
        repeat {
            token = Subscriber.generateUnsubscribeToken()
        } while try self.subscriber(withUnsubscribeToken: token) != nil

        let subscriber = Subscriber(email: email, unsubscribeToken: token)
        try self.connection.execute(subscriber.insert)

        NotificationService().notify(type: "User Subscribed", message: "Their email is: '\(subscriber.email)'. Hopefully this IS a pattern!")
    }

    func unsubscribe(_ subscriber: Subscriber) throws {
        try self.connection.execute(subscriber.delete)

        NotificationService().notify(type: "User Unsubscribed", message: "Their email was: \(subscriber.email)'. Hopefully this is NOT a pattern!")
    }

    func subscriber(withUnsubscribeToken token: String) throws -> Subscriber? {
        let result = try self.connection.execute(Subscriber.select(forUnsubscribeToken: token))

        guard result.count == 1 else {
            return nil
        }

        return try Subscriber(row: result[0])
    }

    func subscriber(withEmail email: String) throws -> Subscriber? {
        let result = try self.connection.execute(Subscriber.select(forEmail: email))

        guard result.count == 1 else {
            return nil
        }

        return try Subscriber(row: result[0])
    }

    mutating func loadAllSubscribers() throws -> [Subscriber] {
        if let subscribers = self.allSubscribers {
            return subscribers
        }

        let results = try self.connection.execute(Subscriber.select)
        let subscribers = try results.map({try Subscriber(row: $0)})
        self.allSubscribers = subscribers
        return subscribers
    }

    mutating func notify(for post: Post, atDomain domain: String) throws {
        for subscriber in try self.loadAllSubscribers() {
            let html = try "Views/post-notification-email.html"
                .map(FileContents())
                .map(Template(build: { builder in
                    post.buildReference(to: builder)
                    builder["domain"] = domain
                    builder["unsubscribeToken"] = subscriber.unsubscribeToken
                }))
                .string()
            let email = Email(
                to: subscriber.email,
                subject: "drewag.me: \(post.metaInfo.title)",
                from: "drewag.me notifications<donotreply@drewag.me>",
                HTMLBody: html
            )
            email.send()
        }
    }
}
