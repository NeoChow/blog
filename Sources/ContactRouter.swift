//
//  ContactRouter.swift
//  drewag.me
//
//  Created by Andrew J Wagner on 1/25/17.
//
//

import Foundation
import SwiftServe
import SwiftPlusPlus

struct ContactRouter: Router {
    enum ContactField: String, HTMLFormField {
        case email
        case name
        case subject
        case customSubject
        case description

        static var all: [ContactField] = [.email, .name, .subject, .customSubject, .description]
    }

    let routes: [Route] = [
        .any("", handler: { request in
            let form: HTMLForm<ContactField> = request.parseForm(process: { form in
                let fromEmail: String = try form.requiredValue(for: .email)
                guard fromEmail.isValidEmail else {
                    throw UserReportableError(.badRequest, "Invalid email")
                }

                let description = try form.requiredValue(for: .description)
                    .replacingOccurrences(of: "\n", with: "<br />")
                guard !description.isEmpty else {
                    throw UserReportableError(.badRequest, "Message is required")
                }

                var body = "From: \(try form.requiredValue(for: .name))"
                body += "\nSubject: \(try form.requiredValue(for: .subject))"
                if let customSubject = form.value(for: .customSubject) {
                    body += " - \(customSubject)"
                }
                body += "\nMessage:"
                body += "\n\(description)"
                let email = Email(
                    to: "contact-blog@drewag.me",
                    subject: "Blog Contact Form Message",
                    from: fromEmail,
                    plainBody: body
                )
                guard email.send() else {
                    throw UserReportableError(.internalServerError, "Unknown error")
                }
                form.message = "Message Sent Successfully"
                form.clear(field: .description)
                return nil
            })
            return try request.responseStatus(
                htmlFromFiles: [
                    "Views/header.html",
                    "Views/contact.html",
                    "Views/footer.html",
                ],
                form: form,
                htmlBuild: { builder in
                    builder.buildValues(forKey: "stylesheets", withArray: ["/assets/css/forms.css", "/assets/css/contact.css"], build: {$1["link"] = $0})
                }
            )
        })
    ]
}
