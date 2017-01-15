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

    typealias MonthDict = OrderedDictionary<String, [Post]>
    typealias YearDict = OrderedDictionary<String, MonthDict>
    typealias AllDict = OrderedDictionary<String, YearDict>

    mutating func loadAllPosts() throws -> [Post] {
        if let posts = self.allPosts {
            return posts
        }

        let url = URL(fileURLWithPath: "Posts")
        let fileManager = FileManager.default
        let posts = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            .map({Post(directoryUrl: $0)!})
            .sorted(by: {$0.metaInfo.published.timeIntervalSince($1.metaInfo.published) > 0})
        self.allPosts = posts
        return posts
    }

    mutating func loadOrganizedPosts() throws -> AllDict {
        var organized = AllDict()

        for post in try self.loadAllPosts() {
            let yearString = post.metaInfo.publishedYearString
            let monthString = post.metaInfo.publishedMonthString
            let dayString = post.metaInfo.publishedDayString

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

    mutating func loadMainPosts() throws -> (featured: [Post], recent: [Post]) {
        var featured = [Post]()
        var recent = [Post]()

        for post in try self.loadAllPosts() {
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
