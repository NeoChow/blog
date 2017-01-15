//
//  PreviewRouter.swift
//  drewag.me
//
//  Created by Andrew J Wagner on 12/23/16.
//
//

import Foundation
import SwiftServe
import TextTransformers

struct PreviewRouter: Router {
    public var routes: [Route] = [
        .get("", handler: { request in
            var service = PostsService()
            let (featured, recent) = try service.loadMainPosts()
            return .handled(try request.response(
                htmlFromFiles: [
                    "Views/header.html",
                    "Views/home.html",
                    "Views/footer.html",
                ],
                htmlBuild: { builder in
                    func buildPost(post: Post, builder: TemplateBuilder) {
                        post.buildReference(to: builder, link: "preview/" + post.directoryUrl.lastPathComponent)
                    }

                    builder.buildValues(forKey: "stylesheets", withArray: ["/assets/css/home.css"], build: {$1["link"] = $0})
                    builder.buildValues(forKey: "featured", withArray: featured, build: buildPost)
                    builder.buildValues(forKey: "recent", withArray: recent, build: buildPost)
                }
            ))
        }),
        .getWithParam(consumeEntireSubPath: false, router: PreviewPostRouter()),
    ]
}
