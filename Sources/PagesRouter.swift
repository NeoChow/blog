//
//  PagesRouter.swift
//  drewag.me
//
//  Created by Andrew J Wagner on 12/30/16.
//
//

import SwiftServe

struct PagesRouter: Router {
    let routes: [Route] = [
        .get("privacy-policy", handler: { request in
            return .handled(try request.response(
                htmlFromFiles: [
                    "Views/header.html",
                    "Views/privacy-policy.html",
                    "Views/footer.html",
                ],
                htmlBuild: { builder in
                    builder["title"] = "Privacy Policy"
                }
            ))
        }),
        .get("about-me", handler: { request in
            return .handled(try request.response(
                htmlFromFiles: [
                    "Views/header.html",
                    "Views/about-me.html",
                    "Views/footer.html",
                    ],
                htmlBuild: { builder in
                    builder["title"] = "About Me"
                    builder.buildValues(forKey: "stylesheets", withArray: ["/assets/css/about-me.css"], build: {$1["link"] = $0})
                }
            ))
        }),
    ]
}
