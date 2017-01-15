//
//  Subscriber.swift
//  drewag.me
//
//  Created by Andrew J Wagner on 1/1/17.
//
//

import Foundation
import SwiftServe
import SQL

struct Subscriber: TableProtocol {
    enum Field: String, TableField {
        static let tableName = "subscribers"

        case email
        case unsubscribe_token
        case subscribed_date
    }

    let email: String
    let unsubscribeToken: String
    let subscribed: Date

    static func generateUnsubscribeToken() -> String {
        return self.generateRandomString(ofLength: 16)
    }

    static func select(forEmail email: String) -> Select {
        return Subscriber.select(where: Field.email == email.lowercased())
    }

    static func select(forUnsubscribeToken token: String) -> Select {
        return Subscriber.select(where: Field.unsubscribe_token == token)
    }

    init(email: String, unsubscribeToken: String, subscribed: Date) {
        self.email = email.lowercased()
        self.unsubscribeToken = unsubscribeToken
        self.subscribed = subscribed
    }

    init(email: String, unsubscribeToken: String) {
        self.init(email: email, unsubscribeToken: unsubscribeToken, subscribed: Date())
    }

    init<Row: RowProtocol>(row: Row) throws {
        guard let email: String = try row.value("email")
            , let unsubscribeToken: String = try row.value("unsubscribe_token")
            , let subscribedString: String = try row.value("subscribed_date")
            else
        {
            throw UserReportableError(.internalServerError, "Missing subscriber information")
        }

        guard let subscribed = subscribedString.railsDate else {
            throw UserReportableError(.internalServerError, "Malformed subscriber date")
        }

        self.init(email: email, unsubscribeToken: unsubscribeToken, subscribed: subscribed)
    }

    var insert: Insert {
        return Subscriber.insert([
            .email: self.email,
            .unsubscribe_token: self.unsubscribeToken,
            .subscribed_date: self.subscribed.railsDate,
        ])
    }

    var delete: Delete {
        return Subscriber.delete(where: Field.email == self.email)
    }
}

private extension Subscriber {
    static func generateRandomString(ofLength length: Int) -> String {
        let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let allowedCharsCount = UInt32(allowedChars.characters.count)

        var output = ""
        for _ in 0 ..< length {
            #if os(Linux)
                let randomNumber = Int(random()) % Int(allowedCharsCount)
            #else
                let randomNumber = Int(arc4random_uniform(allowedCharsCount))
            #endif
            let index = allowedChars.index(allowedChars.startIndex, offsetBy: randomNumber)
            let newCharacter = allowedChars[index]
            output.append(newCharacter)
        }
        return output
    }
}
