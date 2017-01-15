//
//  VisitTrackingRouter.swift
//  drewag.me
//
//  Created by Andrew J Wagner on 1/2/17.
//
//

import SwiftServe

struct VisitTrackingRouter: ParameterizedRouter {
    let routes: [ParameterizedRoute<String>] = [
        .any(handler: { request, route in
            let connection = DatabaseConnection()

            let visit = Visit(
                ip: request.ip,
                route: route,
                method: request.method,
                source: request.formValues()["source"],
                referer: request.headers["referer"]
            )

            try connection.execute(visit.insert)

            return .unhandled
        })
    ]
}
