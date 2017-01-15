//
//  YearRouter.swift
//  drewag.me
//
//  Created by Andrew J Wagner on 12/26/16.
//
//

import SwiftServe

struct YearRouter: ParameterizedRouter {
    var routes: [ParameterizedRoute<Int>] = [
        .get("", handler: { request, year in
            return .handled(try request.response(
                htmlFromFiles: [
                    "Views/header.html",
                    "Generated/posts/\(year)/archive.html",
                    "Views/footer.html",
                    ],
                htmlBuild: { builder in
                    builder["title"] = "Posts in \(year)"
                    builder.buildValues(forKey: "stylesheets", withArray: ["/assets/css/home.css"], build: {$1["link"] = $0})
                }
            ))
        }),
        .getWithParam(consumeEntireSubPath: false, router: MonthRouter()),
    ]
}
