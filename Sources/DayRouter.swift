//
//  DayRouter.swift
//  drewag.me
//
//  Created by Andrew J Wagner on 12/26/16.
//
//

import SwiftServe

struct DayRouter: ParameterizedRouter {
    var routes: [ParameterizedRoute<((Int, Int), Int)>] = [
        .get("", handler: { (request, date: (_: (year: Int, month: Int), day: Int)) in
            let day = date.day < 10 ? "0\(date.day)" : "\(date.day)"
            let month = date.0.month < 10 ? "0\(date.0.month)" : "\(date.0.month)"
            return .handled(try request.response(
                htmlFromFiles: [
                    "Views/header.html",
                    "Generated/posts/\(date.0.year)/\(month)/\(day)/archive.html",
                    "Views/footer.html",
                ],
                htmlBuild: { builder in
                    builder["title"] = "Posts in \(month)/\(day)/\(date.0.year)"
                    builder.buildValues(forKey: "stylesheets", withArray: ["/assets/css/home.css"], build: {$1["link"] = $0})
                }
            ))
        }),
        .getWithParam(consumeEntireSubPath: false, router: PublishedPostRouter()),
    ]
}
