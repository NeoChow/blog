//
//  PublishedRouter.swift
//  drewag.me
//
//  Created by Andrew J Wagner on 12/26/16.
//
//

import Foundation
import SwiftServe
import SwiftPlusPlus
import TextTransformers

struct PublishedRouter: Router {
    public var routes: [Route] = [
        .get("", handler: { request in
            return .handled(try request.response(
                htmlFromFiles: [
                    "Views/header.html",
                    "Generated/home.html",
                    "Views/footer.html",
                ],
                htmlBuild: { builder in
                    builder["title"] = "Home"
                    builder.buildValues(forKey: "stylesheets", withArray: ["/assets/css/home.css"], build: {$1["link"] = $0})
                }
            ))
        }),
        .get("posts", subRoutes: [
            .get("", handler: { request in
                return .handled(try request.response(
                    htmlFromFiles: [
                        "Views/header.html",
                        "Generated/posts/archive.html",
                        "Views/footer.html",
                    ],
                    htmlBuild: { builder in
                        builder["title"] = "All Posts"
                        builder.buildValues(forKey: "stylesheets", withArray: ["/assets/css/home.css"], build: {$1["link"] = $0})
                    }
                ))
            }),
            .get("tags", subRoutes: [
                .getWithParam(consumeEntireSubPath: false, handler: { (request, rawTag: String) in
                    let url = URL(fileURLWithPath: "Generated/posts/tags/\(rawTag).html")
                    guard FileService.default.fileExists(at: url) else {
                        return .unhandled
                    }
                    return .handled(try request.response(
                        htmlFromFiles: [
                            "Views/header.html",
                            url.relativePath,
                            "Views/footer.html",
                        ],
                        htmlBuild: { builder in
                            builder["title"] = "\(rawTag) Posts"
                            builder.buildValues(forKey: "stylesheets", withArray: ["/assets/css/home.css"], build: {$1["link"] = $0})
                        }
                    ))
                })
            ]),
            .getWithParam(consumeEntireSubPath: false, router: YearRouter()),
            .getWithParam(consumeEntireSubPath: false, handler: { (request, title: String) in
                do {
                    let redirectEndpoint = try "OldPermalinks/\(title)".map(FileContents()).string()
                    if !redirectEndpoint.isEmpty {
                        return .handled(request.response(redirectingTo: "\(redirectEndpoint)"))
                    }
                }
                catch {}

                return .unhandled
            }),
        ]),
    ]
}
