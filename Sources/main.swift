import Foundation
import SwiftServe
import CommandLineParser
import SwiftServeKitura

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

parser.command(named: "server") { parser in
    let port = parser.int(named: "port")
    let databasePassword = parser.string(named: "database_password")
    let publicKey = parser.string(named: "stripe_public_key")
    let privateKey = parser.string(named: "stripe_private_key")

    try parser.parse()

    DatabasePassword = databasePassword.parsedValue
    StripePublicKey = publicKey.parsedValue
    StripePrivateKey = privateKey.parsedValue

    print("Staring Server...")
    try KituraServer(port: port.parsedValue, router: MainRouter()).start()
}

parser.command(named: "regenerate") { parser in
    let domain = parser.string(named: "domain")
    let databasePassword = parser.string(named: "database_password")
    try parser.parse()
    DatabasePassword = databasePassword.parsedValue

    let generator = StaticPagesGenerator()
    do {
        let newPosts = try generator.generateReturningNewPosts(forDomain: domain.parsedValue)

        let connection = DatabaseConnection()
        var service = SubscriberService(connection: connection)

        for post in newPosts {
            print("Send notification for \(post.metaInfo.title) (y/N)?", terminator: "")
            switch readLine(strippingNewline: true) ?? "" {
            case "y":
                try service.notify(for: post, atDomain: domain.parsedValue)
            default:
                break
            }
        }
    }
    catch let error {
        print("error\n\(error)")
    }
}

do {
    try parser.parse()
}
catch {
    print("\(error)")
}
