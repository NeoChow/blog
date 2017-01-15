import Foundation
import SwiftServe
import CommandLineParser
import SwiftServeKitura

var DatabasePassword = ""

struct MainRouter: Router {
    public var routes: [Route] = [
        .anyWithParam(consumeEntireSubPath: true, router: VisitTrackingRouter()),

        .get("assets", router:  AssetRouter()),
        .any("subscribers", router: SubscribersRouter()),
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
    try parser.parse()
    DatabasePassword = databasePassword.parsedValue
    try KituraServer(port: port.parsedValue, router: MainRouter()).start()
}

parser.command(named: "regenerate") { parser in
    let domain = parser.string(named: "domain")
    try parser.parse()

    let generator = StaticPagesGenerator()
    do {
        let newPosts = try generator.generateReturningNewPosts()

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
