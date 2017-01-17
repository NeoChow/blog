//
//  DonateRouter.swift
//  drewag.me
//
//  Created by Andrew J Wagner on 1/16/17.
//
//

import SwiftServe
import Foundation

struct DonateRouter: Router {
    public var routes: [Route] = [
        .get("", handler: { request in
            return .handled(try request.response(
                htmlFromFiles: [
                    "Views/header.html",
                    "Views/donate.html",
                    "Views/footer.html",
                ],
                htmlBuild: { builder in
                    builder["title"] = "Donate"
                    builder["stripeToken"] = StripePublicKey
                    builder.buildValues(forKey: "stylesheets", withArray: ["/assets/css/donate.css"], build: {$1["link"] = $0})
                    builder.buildValues(forKey: "scripts", withArray: ["https://checkout.stripe.com/checkout.js"], build: {$1["link"] = $0})
                }
            ))
        }),
        .post("new", handler: { request in
            let formValues = request.formValues()
            guard let token = formValues["token"] else {
                return .handled(request.response(body: "Error: No token provided", status: .badRequest))
            }

            guard !token.contains("&") && !token.contains("=") else {
                return .handled(request.response(body: "Error: Invalid token", status: .badRequest))
            }

            guard let email = formValues["email"] else {
                return .handled(request.response(body: "Error: No email provided", status: .badRequest))
            }

            guard !email.contains("&") && !email.contains("=") else {
                return .handled(request.response(body: "Error: Invalid email", status: .badRequest))
            }

            guard let amountString = formValues["amount"] else {
                return .handled(request.response(body: "Error: No amount provided", status: .badRequest))
            }

            guard let amount = Int(amountString) else {
                return .handled(request.response(body: "Error: Invalid amount", status: .badRequest))
            }

            do {
                var body = "amount=\(amount)"
                body += "&currency=usd"
                body += "&description=Make a donation to support drewag.me"
                body += "&receipt_email=\(email)"
                body += "&source=\(token)"
                let url = URL(string: "https://api.stripe.com/v1/charges")!
                let factory = ClientFactory.singleton
                let client = try factory.createClient(for: url)
                let stripeRequest = factory.createRequest(
                    withMethod: .post,
                    url: url,
                    headers: ["Content-Type": "application/x-www-form-urlencoded"],
                    username: StripePrivateKey,
                    body: body
                )

                let stripeResponse = client.respond(to: stripeRequest)
                switch stripeResponse.status {
                case .ok:
                    return .handled(request.response(body: "Thank you so much!", status: .created))
                default:
                    if let message = stripeResponse.json?["error"]?["message"]?.string {
                        return .handled(request.response(body: "Unexpected response from stripe: \(message)", status: .internalServerError))
                    }
                    else {
                        return .handled(request.response(body: "Unexpected response from stripe: \(stripeResponse.text ?? "")", status: .internalServerError))
                    }
                }
            }
            catch let error {
                return .handled(request.response(body: "\(error)", status: .created))
            }
        })
    ]
}
