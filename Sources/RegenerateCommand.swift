//
//  RegenerateCommand.swift
//  drewag.me
//
//  Created by Andrew J Wagner on 1/24/17.
//
//

import CommandLineParser

struct RegenerateCommand {
    static func handler(parser: Parser) throws {
        let domain = parser.string(named: "domain")
        let databasePassword = parser.string(named: "database_password")
        try parser.parse()
        DatabasePassword = databasePassword.parsedValue

        let generator = StaticPagesGenerator()
        do {
            let newPosts = try generator.generateReturningNewPosts(forDomain: domain.parsedValue)

            let connection = DatabaseConnection()
            var service = SubscriberService(connection: connection)

            for post in newPosts {
                print("Send notification for \(post.metaInfo.title) (y/N)?", terminator: "")
                switch readLine(strippingNewline: true) ?? "" {
                case "y":
                    try service.notify(for: post, atDomain: domain.parsedValue)
                default:
                    break
                }
            }
        }
        catch let error {
            print("error\n\(error)")
        }
    }
}
