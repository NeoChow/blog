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
        try parser.parse()

        let generator = StaticPagesGenerator()
        do {
            try generator.generate(forDomain: domain.parsedValue)
        }
        catch let error {
            print("error\n\(error)")
        }
    }
}
