//
//  NotificationService.swift
//  drewag.me
//
//  Created by Andrew J Wagner on 1/17/17.
//
//

import SwiftPlusPlus

struct NotificationService {
    func notify(type: String, message: String) {
        let email = Email(
            to: "notifications-blog@drewag.me",
            subject: "Notification: \(type)",
            from: "blog notifications<donotreply@drewag.me>",
            HTMLBody: "<h1>\(type)</h1><p>\(message)</p>"
        )
        email.send()
    }
}
