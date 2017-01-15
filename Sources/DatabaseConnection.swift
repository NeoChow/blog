//
//  DatabaseConnection.swift
//  drewag.me
//
//  Created by Andrew J Wagner on 12/31/16.
//
//

import PostgreSQL

public final class DatabaseConnection {
    public static var databaseName = "blog"

    fileprivate let connection = Connection(info: Connection.ConnectionInfo(
        host: "localhost",
        port: 5432,
        databaseName: DatabaseConnection.databaseName,
        username: "blog_service",
        password: DatabasePassword
    ))
    fileprivate var isConnected: Bool = false

    public init() {}

    public func execute(_ query: Select) throws -> Result {
        return try self.connect().execute(query)
    }

    @discardableResult
    public func execute(_ query: Update) throws -> Result {
        return try self.connect().execute(query)
    }

    @discardableResult
    public func execute(_ query: Insert, returnInsertedRows: Bool = false) throws -> Result {
        return try self.connect().execute(query)
    }

    @discardableResult
    public func execute(_ query: Delete) throws -> Result {
        return try self.connect().execute(query)
    }

    public func execute(_ string: String) throws -> Result {
        return try self.connect().execute(string)
    }
}

private extension DatabaseConnection {
    func connect() throws -> Connection {
        guard !self.isConnected else {
            return self.connection
        }

        try self.connection.open()
        self.isConnected = true
        return self.connection
    }
}
