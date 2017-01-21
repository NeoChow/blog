//
//  FeaturesRouter.swift
//  drewag.me
//
//  Created by Andrew J Wagner on 12/30/16.
//
//

import SwiftServe

struct FeaturesRouter: Router {
    let routes: [Route] = [
        .get("robots.txt", handler: { request in
            return .handled(try request.response(
                textFromFiles: [
                    "Views/robots.txt",
                ],
                contentType: "text/plain",
                textBuild: { builder in
                }
            ))
        }),
        .get("sitemap.xml", handler: { request in
            return .handled(try request.response(
                textFromFiles: [
                    "Generated/sitemap.xml",
                ],
                contentType: "text/xml",
                textBuild: { builder in
                }
            ))
        }),
        .get("feed", handler: { request in
            return .handled(try request.response(
                textFromFiles: [
                    "Generated/feed.xml",
                    ],
                contentType: "application/atom+xml",
                textBuild: { builder in
                }
            ))
        }),
    ]
}
