//
//  PostRouter.swift
//  drewag.me
//
//  Created by Andrew J Wagner on 12/25/16.
//
//

import Foundation
import SwiftServe
import TextTransformers

class PostRouter {
    let baseLocalPath: String

    fileprivate init(baseLocalPath: String) {
        self.baseLocalPath = baseLocalPath
    }

    func imageResponse(to request: Request, forPostAtRelativePath relativePath: String) throws -> ResponseStatus {
        let localURL = URL(fileURLWithPath: self.baseLocalPath).appendingPathComponent(relativePath)
        guard let post = Post(directoryUrl: localURL) else {
            return .unhandled
        }
        return .handled(try request.response(withFileAt: post.imageUrl, status: .ok))
    }
}

class PreviewPostRouter: PostRouter, ParameterizedRouter {
    init() {
        super.init(baseLocalPath: "Posts")
    }

    public var routes: [ParameterizedRoute<String>] { return [
        .get("", handler: { request, postName in
            let localURL = URL(fileURLWithPath: self.baseLocalPath).appendingPathComponent(postName)
            guard let post = Post(directoryUrl: localURL) else {
                return .unhandled
            }
            return .handled(try request.response(
                htmlFromFiles: [
                    "Views/header.html",
                    "Views/post.html",
                    "Views/footer.html",
                ],
                htmlBuild: { builder in
                    builder.buildValues(forKey: "stylesheets", withArray: [
                        "/assets/css/post.css",
                        "/assets/css/prismjs.css",
                    ], build: {$1["link"] = $0})
                    builder.buildValues(forKey: "scripts", withArray: [
                        "/assets/js/prismjs.js",
                    ], build: {$1["link"] = $0})
                    post.buildContent(to: builder, atUrl: request.endpoint)
                }
            ))
        }),
        .get("photo.jpg", handler: { request, postName in
            return try self.imageResponse(to: request, forPostAtRelativePath: postName)
        }),
    ]}
}

class PublishedPostRouter: PostRouter, ParameterizedRouter {
    typealias Param = (((Int, Int), Int), String)

    init() {
        super.init(baseLocalPath: "Generated/posts")
    }

    public var routes: [ParameterizedRoute<Param>] { return [
        .get("", handler: { request, param in
            let month = param.0.0.1 < 10 ? "0\(param.0.0.1)" : "\(param.0.0.1)"
            let day = param.0.1 < 10 ? "0\(param.0.1)" : "\(param.0.1)"
            let relativePath = "\(param.0.0.0)/\(month)/\(day)/\(param.1)"
            let localURL = URL(fileURLWithPath: self.baseLocalPath).appendingPathComponent(relativePath)
            guard let _ = Post(directoryUrl: localURL) else {
                return .unhandled
            }
            return .handled(try request.response(
                htmlFromFiles: [
                    "Views/header.html",
                    localURL.appendingPathComponent("content.html").relativePath,
                    "Views/footer.html",
                ],
                htmlBuild: { builder in
                    builder.buildValues(forKey: "stylesheets", withArray: [
                        "/assets/css/post.css",
                        "/assets/css/prismjs.css",
                    ], build: {$1["link"] = $0})
                    builder.buildValues(forKey: "scripts", withArray: [
                        "/assets/js/prismjs.js",
                    ], build: {$1["link"] = $0})
                }
            ))
        }),
        .get("photo.jpg", handler: { request, param in
            let month = param.0.0.1 < 10 ? "0\(param.0.0.1)" : "\(param.0.0.1)"
            let day = param.0.1 < 10 ? "0\(param.0.1)" : "\(param.0.1)"
            let relativePath = "\(param.0.0.0)/\(month)/\(day)/\(param.1)"
            return try self.imageResponse(to: request, forPostAtRelativePath: relativePath)
        }),
    ]}
}
