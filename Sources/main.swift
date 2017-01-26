import Foundation
import SwiftServe
import CommandLineParser

var DatabasePassword = ""
var StripePublicKey = ""
var StripePrivateKey = ""

struct MainRouter: Router {
    public var routes: [Route] = [
        .get(router: FaviconRouter()),
        .get("google85833a31c04058e9.html", handler: { request in
            return .handled(try request.response(withFileAt: "Views/google-webmaster-tools-verification.html", status: .ok))
        }),
        .get(".well-known", subRoutes: [
            .get("apple-developer-merchantid-domain-association", handler: { request in
                return .handled(try request.response(withFileAt: "Views/apple-pay-verification", status: .ok))
            }),
        ]),

        //.anyWithParam(consumeEntireSubPath: true, router: VisitTrackingRouter()),

        .get("assets", router:  AssetRouter()),
        .any("subscribers", router: SubscribersRouter()),

        .any("donate", router: DonateRouter()),
        .any("contact", router: ContactRouter()),
        .any(router: FeaturesRouter()),
        .any(router: PagesRouter()),
        .any(router: PublishedRouter()),
        .any("preview", router: PreviewRouter()),

        .anyWithParam(consumeEntireSubPath: true, handler: { (request, path: String) in
            return .handled(try request.response(
                htmlFromFiles: [
                    "Views/header.html",
                    "Views/not-found.html",
                ],
                status: .notFound,
                htmlBuild: { builder in
                    builder["path"] = path
                }
            ))
        })
    ]
}

#if os(Linux)
    srandom(UInt32(Date().timeIntervalSince1970))
#endif

let parser = Parser(arguments: CommandLine.arguments)

parser.command(named: "server", handler: ServerCommand.handler)
parser.command(named: "regenerate", handler: RegenerateCommand.handler)
parser.command(named: "publish", handler: PublishCommand.handler)
parser.command(named: "notify", handler: NotifyCommand.handler)

do {
    try parser.parse()
}
catch {
    print("\(error)")
}
