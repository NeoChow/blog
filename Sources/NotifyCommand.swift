//
//  NotifyCommand.swift
//  drewag.me
//
//  Created by Andrew J Wagner on 1/24/17.
//
//

import CommandLineParser

struct NotifyCommand {
    static func handler(parser: Parser) throws {
        let domain = parser.string(named: "domain")
        let databasePassword = parser.string(named: "database_password")
        try parser.parse()
        DatabasePassword = databasePassword.parsedValue

        let connection = DatabaseConnection()
        var postsService = PostsService()

        let unnotified = try postsService.loadAllUnnotifiedPosts()

        guard !unnotified.isEmpty else {
            print("All published posts have been notified")
            return
        }

        var toNotify = [PublishedPost]()
        for post in unnotified {
            print("Send notification for \(post.metaInfo.title) (y/N)?", terminator: "")
            switch readLine(strippingNewline: true) ?? "" {
            case "y":
                toNotify.append(post)
            default:
                break
            }
        }

        guard toNotify.count > 0 else {
            return
        }

        var subscriberService = SubscriberService(connection: connection)
        try subscriberService.notify(for: toNotify, atDomain: domain.parsedValue)

        for post in toNotify {
            try post.markNotified()
        }
    }
}
