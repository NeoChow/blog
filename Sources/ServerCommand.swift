//
//  ServerCommand.swift
//  drewag.me
//
//  Created by Andrew J Wagner on 1/24/17.
//
//

import CommandLineParser
import SwiftServeKitura

struct ServerCommand {
    static func handler(parser: Parser) throws {
        let port = parser.int(named: "port")
        let databasePassword = parser.string(named: "database_password")
        let publicKey = parser.string(named: "stripe_public_key")
        let privateKey = parser.string(named: "stripe_private_key")

        try parser.parse()

        DatabasePassword = databasePassword.parsedValue
        StripePublicKey = publicKey.parsedValue
        StripePrivateKey = privateKey.parsedValue

        print("Staring Server...")
        try KituraServer(port: port.parsedValue, router: MainRouter()).start()
    }
}
