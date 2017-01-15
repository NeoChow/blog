//
//  MonthRouter.swift
//  drewag.me
//
//  Created by Andrew J Wagner on 12/26/16.
//
//

import SwiftServe

struct MonthRouter: ParameterizedRouter {
    var routes: [ParameterizedRoute<(Int, Int)>] = [
        .get("", handler: { (request, date: (year: Int, month: Int)) in
            let month = date.month < 10 ? "0\(date.month)" : "\(date.month)"
            return .handled(try request.response(
                htmlFromFiles: [
                    "Views/header.html",
                    "Generated/posts/\(date.year)/\(month)/archive.html",
                    "Views/footer.html",
                ],
                htmlBuild: { builder in
                    builder["title"] = "Posts on \(month)/\(date.year)"
                    builder.buildValues(forKey: "stylesheets", withArray: ["/assets/css/home.css"], build: {$1["link"] = $0})
                }
            ))
        }),
        .getWithParam(consumeEntireSubPath: false, router: DayRouter()),
    ]
}
