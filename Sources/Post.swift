//
//  Post.swift
//  drewag.me
//
//  Created by Andrew J Wagner on 12/23/16.
//
//

import Foundation
import SwiftPlusPlus
import TextTransformers

class Post {
    let directoryUrl: URL

    struct MetaInfo {
        let title: String
        let summary: String
        let author: String
        let isFeatured: Bool
        let imageHeight: Int

        var published: Date?
        var notified: Date?
        var modified: Date?
    }

    lazy var metaInfo: MetaInfo = {
        do {
            let object = try FileService.default.jsonObject(at: self.metaUrl)
            return try NativeTypesDecoder.decodableTypeFromObject(object, mode: .saveLocally)
        }
        catch let error as UserReportableError {
            return MetaInfo(error: error)
        }
        catch {
            fatalError("\(error)")
        }
    }()

    lazy var html: String = {
        return (try? self.contentsUrl.relativePath
            .map(FileContents())
            .map(Markdown())
            .string()
        ) ?? ""
    }()

    var urlTitle: String {
        let components = self.directoryUrl.lastPathComponent.components(separatedBy: "-")
        return components[1 ..< components.count].joined(separator: "-")
    }

    var imageUrl: URL {
        return self.directoryUrl.appendingPathComponent("photo.jpg")
    }

    var metaUrl: URL {
        return self.directoryUrl.appendingPathComponent("meta.json")
    }

    func markPublished() throws {
        self.metaInfo.published = Date()
        try self.saveMeta()
    }

    func markNotified() throws {
        self.metaInfo.notified = Date()
        try self.saveMeta()
    }

    init?(directoryUrl: URL) {
        guard FileService.default.fileExists(at: directoryUrl) else {
            return nil
        }

        self.directoryUrl = directoryUrl
    }
}

fileprivate extension Post {
    var contentsUrl: URL {
        return self.directoryUrl.appendingPathComponent("content.md")
    }
}

extension Post.MetaInfo {
    fileprivate init(error: UserReportableError) {
        self.title = "Error Loading: \(error.alertTitle)"
        self.summary = error.alertMessage
        self.published = Date.distantPast
        self.modified = Date.distantPast
        self.author = "Error Post"
        self.isFeatured = true
        self.imageHeight = 0
    }
}

private extension Post {
    func saveMeta() throws {
        let object = NativeTypesEncoder.objectFromEncodable(self.metaInfo, mode: .saveLocally)
        let data = try JSONSerialization.data(withJSONObject: object, options: .prettyPrinted)
        try data.write(to: self.metaUrl, options: .atomic)
    }
}

extension Post.MetaInfo: CodableType {
    private struct Keys {
        class title: CoderKey<String> {}
        class summary: CoderKey<String> {}
        class published: OptionalCoderKey<String> {}
        class notified: OptionalCoderKey<String> {}
        class modified: OptionalCoderKey<String> {}
        class author: CoderKey<String> {}
        class featured: CoderKey<Bool> {}
        class image_height: CoderKey<Int> {}
    }

    public init(decoder: DecoderType) throws {
        self.title = try decoder.decode(Keys.title.self)
        self.summary = try decoder.decode(Keys.summary.self)
        let published = try decoder.decode(Keys.published.self)?.iso8601DateTime
        self.published = published
        self.modified = try decoder.decode(Keys.modified.self)?.iso8601DateTime
        self.notified = try decoder.decode(Keys.notified.self)?.iso8601DateTime
        self.author = try decoder.decode(Keys.author.self)
        self.isFeatured = try decoder.decode(Keys.featured.self)
        self.imageHeight = try decoder.decode(Keys.image_height.self)
    }

    func encode(_ encoder: EncoderType) {
        encoder.encode(self.title, forKey: Keys.title.self)
        encoder.encode(self.summary, forKey: Keys.summary.self)
        encoder.encode(self.published?.iso8601DateTime, forKey: Keys.published.self)
        encoder.encode(self.author, forKey: Keys.author.self)
        encoder.encode(self.isFeatured, forKey: Keys.featured.self)
        encoder.encode(self.imageHeight, forKey: Keys.image_height.self)
        if let notified = self.notified {
            encoder.encode(notified.iso8601DateTime, forKey: Keys.notified.self)
        }
        if let modified = self.modified {
            encoder.encode(modified.iso8601DateTime, forKey: Keys.modified.self)
        }
    }
}
