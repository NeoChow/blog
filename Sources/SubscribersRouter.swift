//
//  SubscribersRouter.swift
//  drewag.me
//
//  Created by Andrew J Wagner on 12/26/16.
//
//

import SwiftPlusPlus
import SwiftServe

struct SubscribersRouter: Router {
    enum SubscriberField: String, HTMLFormField {
        case email

        static var all: [SubscriberField] = [.email]
    }

    var routes: [Route] = [
        .any("new", handler: { request in
            let form: HTMLForm<SubscriberField> = request.parseForm(process: { form in
                let email: String = try form.requiredValue(for: .email)
                guard email.isValidEmail else {
                    throw SwiftServe.UserReportableError(.badRequest, "Invalid email")
                }
                let connection = DatabaseConnection()
                let service = SubscriberService(connection: connection)
                try service.addSubscriber(withEmail: email)
                form.message = "Subscribed Successfully"
                return nil
            })
            return try request.responseStatus(
                htmlFromFiles: [
                    "Views/header.html",
                    "Views/new-subscriber.html",
                ],
                form: form,
                htmlBuild: { builder in
                    builder.buildValues(forKey: "stylesheets", withArray: ["/assets/css/forms.css"], build: {$1["link"] = $0})
                }
            )
        }),
        .get("unsubscribe", handler: { request in
            return .handled(try request.response(
                htmlFromFiles: [
                    "Views/header.html",
                    "Views/unsubscribe.html",
                    "Views/footer.html",
                ],
                htmlBuild: { builder in
                    builder.buildValues(forKey: "stylesheets", withArray: ["/assets/css/forms.css"], build: {$1["link"] = $0})
                    do {
                        let connection = DatabaseConnection()
                        let service = SubscriberService(connection: connection)
                        guard let token = request.formValues()["token"]
                            , let subscriber = try service.subscriber(withUnsubscribeToken: token)
                            else
                        {
                            builder["error"] = "Invalid Token"
                            return
                        }

                        try service.unsubscribe(subscriber)
                        builder["message"] = "Unsubscribed successfully. You will not recieve any additional emails and your email has been completely removed from our database."
                        builder.buildValues(forKey: "stylesheets", withArray: ["/assets/css/forms.css"], build: {$1["link"] = $0})
                    }
                    catch let error as ReportableResponseError {
                        builder["error"] = error.description
                    }
                    catch let error {
                        builder["error"] = "\(error)"
                    }
                }
            ))
        })
    ]
}
