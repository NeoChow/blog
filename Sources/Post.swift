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
        let published: Date
        let modified: Date
        let author: String
        let isFeatured: Bool
        let imageHeight: Int

        var publishedYearString: String {
            let calendar = Calendar.current
            let units = Set<Calendar.Component>([.year])
            let components = calendar.dateComponents(units, from: self.published)
            return "\(components.year!)"
        }

        var publishedMonthString: String {
            let calendar = Calendar.current
            let units = Set<Calendar.Component>([.month])
            let components = calendar.dateComponents(units, from: self.published)
            return components.month! < 10 ? "0\(components.month!)" : "\(components.month!)"
        }

        var publishedDayString: String {
            let calendar = Calendar.current
            let units = Set<Calendar.Component>([.day])
            let components = calendar.dateComponents(units, from: self.published)
            return components.day! < 10 ? "0\(components.day!)" : "\(components.day!)"
        }

        /*var normalizedTitle: String {
            var output = ""
            var lastCharacterWasValid = true
            for character in self.title.lowercased().characters {
                guard character != "'" && character != "’" else {
                    continue
                }

                let scalars = "\(character)".unicodeScalars
                guard scalars.count == 1 else {
                    continue
                }

                guard CharacterSet.alphanumerics.contains(scalars.first!) else {
                    lastCharacterWasValid = false
                    continue
                }
                if !lastCharacterWasValid {
                    output.append("-")
                }
                output.append("\(character)")
                lastCharacterWasValid = true
            }
            return output
        }*/
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

    var permanentRelativePath: String {
        return "/posts/\(self.metaInfo.publishedYearString)/\(self.metaInfo.publishedMonthString)/\(self.metaInfo.publishedDayString)/\(self.urlTitle)"
    }

    var permanentRelativeImagePath: String {
        return self.permanentRelativePath + "/photo.jpg"
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

extension Post.MetaInfo: DecodableType {
    private struct Keys {
        class title: CoderKey<String> {}
        class summary: CoderKey<String> {}
        class published: CoderKey<String> {}
        class modified: OptionalCoderKey<String> {}
        class author: CoderKey<String> {}
        class featured: CoderKey<Bool> {}
        class image_height: CoderKey<Int> {}
    }

    public init(decoder: DecoderType) throws {
        self.title = try decoder.decode(Keys.title.self)
        self.summary = try decoder.decode(Keys.summary.self)
        let published = try decoder.decode(Keys.published.self).railsDate!
        self.published = published
        self.modified = try decoder.decode(Keys.modified.self)?.railsDate ?? published
        self.author = try decoder.decode(Keys.author.self)
        self.isFeatured = try decoder.decode(Keys.featured.self)
        self.imageHeight = try decoder.decode(Keys.image_height.self)
    }
}
