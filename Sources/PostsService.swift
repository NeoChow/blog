//
//  PostService.swift
//  drewag.me
//
//  Created by Andrew J Wagner on 12/23/16.
//
//

import Foundation
import SwiftPlusPlus
import TextTransformers

struct PostsService {
    private var allPosts: [Post]?

    typealias MonthDict = OrderedDictionary<String, [PublishedPost]>
    typealias YearDict = OrderedDictionary<String, MonthDict>
    typealias AllDict = OrderedDictionary<String, YearDict>

    mutating func loadAllPosts() throws -> [Post] {
        if let posts = self.allPosts {
            return posts
        }

        let url = URL(fileURLWithPath: "Posts")
        let posts = try FileService.default.contentsOfDirectory(at: url, skipHiddenFiles: true)
            .map({try Post(directoryUrl: $0)})
            .sorted(by: {($0.metaInfo.published ?? Date.distantFuture).timeIntervalSince($1.metaInfo.published ?? Date.distantFuture) > 0})
        self.allPosts = posts
        return posts
    }

    mutating func loadAllPublishedPosts() throws -> [PublishedPost] {
        return try self.loadAllPosts()
            .filter({$0.metaInfo.published != nil})
            .map({try PublishedPost(post: $0, published: $0.metaInfo.published!)})
    }

    mutating func loadAllUnpublishedPosts() throws -> [Post] {
        return try self.loadAllPosts().filter({$0.metaInfo.published == nil})
    }

    mutating func loadAllUnnotifiedPosts() throws -> [PublishedPost] {
        return try self.loadAllPublishedPosts()
            .filter({$0.metaInfo.notified == nil})
    }

    mutating func loadOrganizedPosts() throws -> AllDict {
        var organized = AllDict()

        for post in try self.loadAllPublishedPosts() {
            let yearString = post.publishedYearString
            let monthString = post.publishedMonthString
            let dayString = post.publishedDayString

            var yearDict = organized[yearString] ?? YearDict()
            var monthDict = yearDict[monthString] ?? MonthDict()
            var dayArray = monthDict[dayString] ?? []
            dayArray.append(post)
            monthDict[dayString] = dayArray
            yearDict[monthString] = monthDict
            organized[yearString] = yearDict
        }

        return organized
    }

    mutating func loadMainPosts() throws -> (featured: [PublishedPost], recent: [PublishedPost]) {
        var featured = [PublishedPost]()
        var recent = [PublishedPost]()

        for post in try self.loadAllPublishedPosts() {
            if post.metaInfo.isFeatured {
                featured.append(post)
            }
            else if recent.count < 10 {
                recent.append(post)
            }
        }

        return (featured: featured, recent: recent)
    }
}
