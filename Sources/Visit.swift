//
//  Visit.swift
//  drewag.me
//
//  Created by Andrew J Wagner on 1/2/17.
//
//

import Foundation
import SwiftServe
import SQL

struct Visit: TableProtocol {
    enum Field: String, TableField {
        static let tableName = "visits"

        case ip
        case route
        case method
        case time
        case source
        case referer
    }

    let ip: String
    let route: String
    let method: HTTPMethod
    let time: Date
    let source: String?
    let referer: String?

    init(ip: String, route: String, method: HTTPMethod, source: String?, referer: String?) {
        self.ip = ip
        self.route = route
        self.method = method
        self.time = Date()
        self.source = source
        self.referer = referer
    }

    var insert: Insert {
        return Visit.insert([
            .ip: self.ip,
            .route: self.route,
            .method: self.method.rawValue,
            .time: self.time.iso8601DateTime,
            .source: self.source,
            .referer: self.referer,
        ])
    }
}
