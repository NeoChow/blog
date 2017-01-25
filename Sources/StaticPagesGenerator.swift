//
//  File.swift
//  drewag.me
//
//  Created by Andrew J Wagner on 12/25/16.
//
//

import Foundation
import TextTransformers
import SwiftPlusPlus

class StaticPagesGenerator {
    var postsService = PostsService()
    let fileService = FileService.default

    func generate(forDomain domain: String) throws {
        self.removeDirectory(at: "Generated-working")
        self.createDirectory(at: "Generated-working")
        try self.generateSiteDownPage()
        try self.generateIndex()
        try self.generatePosts()
        try self.generateArchive()
        try self.generateSitemap(forDomain: domain)
        try self.generateAtomFeed(forDomain: domain)

        print("Replacing production version...", terminator: "")
        self.removeDirectory(at: "Generated")
        try self.moveItem(from: "Generated-working", to: "Generated")
        print("done")
    }
}

private extension StaticPagesGenerator {
    func removeDirectory(at path: String) {
        self.fileService.removeItem(at: URL(fileURLWithPath: path))
    }

    func createDirectory(at path: String) {
        self.fileService.createDirectory(at: URL(fileURLWithPath: path))
    }

    func write(_ html: String, to path: String) throws {
        try html.write(toFile: path, atomically: true, encoding: .utf8)
    }

    func moveItem(from: String, to: String) throws {
        try self.fileService.moveItem(from: URL(fileURLWithPath: from), to: URL(fileURLWithPath: to))
    }

    func copyFile(from: String, to: String) throws {
        try self.fileService.copyItem(from: URL(fileURLWithPath: from), to: URL(fileURLWithPath: to))
    }

    func generateSiteDownPage() throws {
        print("Generating site down page...", terminator: "")
        let html = try ["Views/header.html", "Views/static-site-down.html"]
            .map(FileContents())
            .reduce(Separator())
            .map(Template(build: { builder in
                builder["title"] = "Site Down"
                builder.buildValues(forKey: "styles", withArray: ["Assets/css/main.css"], build: { file, builder in
                    builder["content"] = ((try? file.map(FileContents()).string()) ?? "") + "#donate {display:none !important}"
                })
            }))
            .string()

        try self.write(html, to: "Generated-working/site-down.html")
        print("done")
    }

    func generateIndex() throws {
        print("Generating index...", terminator: "")
        let (featured, recent) = try self.postsService.loadMainPosts()
        let html = try "Views/home.html"
            .map(FileContents())
            .map(Template(build: { builder in
                func buildPost(post: PublishedPost, builder: TemplateBuilder) {
                    post.buildPublishedReference(to: builder)
                }

                builder.buildValues(forKey: "featured", withArray: featured, build: buildPost)
                builder.buildValues(forKey: "recent", withArray: recent, build: buildPost)
            }))
            .string()

        try self.write(html, to: "Generated-working/home.html")
        print("done")
    }

    func generatePosts() throws {
        for post in try self.postsService.loadAllPublishedPosts() {
            try self.generate(post: post)
        }
    }

    func generate(post: PublishedPost) throws {
        print("Generating \(post.metaInfo.title)...", terminator: "")

        let relativePath = post.permanentRelativePath

        let html = try "Views/post.html"
            .map(FileContents())
            .map(Template(build: { builder in
                post.buildPublishedContent(to: builder, atUrl: URL(fileURLWithPath: relativePath))
            }))
            .string()

        let directory = "Generated-working\(relativePath)"

        self.createDirectory(at: directory)

        let htmlPath = directory + "/content.html"
        try self.write(html, to: htmlPath)

        let imagePath = directory + "/photo.jpg"
        try copyFile(from: post.imageUrl.relativePath, to: imagePath)

        let metaPath = directory + "/meta.json"
        try copyFile(from: post.metaUrl.relativePath, to: metaPath)

        print("done")
    }

    func generateArchive() throws {
        print("Generating archive...")

        let organized = try self.postsService.loadOrganizedPosts()
        for (year, yearDict) in organized.keysAndValues {
            for (month, monthDict) in yearDict.keysAndValues {
                for (day, dayArray) in monthDict.keysAndValues {
                    try self.generateArchive(forDay: day, month: month, year: year, with: dayArray)
                }
                try self.generateArchive(forMonth: month, year: year, with: monthDict)
            }
            try self.generateAchive(forYear: year, with: yearDict)
        }
        try self.generateArchive(with: organized)

        print("done")
    }

    func generateSitemap(forDomain domain: String) throws {
        print("Generating sitemap...", terminator: "")

        let posts = try self.postsService.loadAllPublishedPosts()
        let xml = try "Views/sitemap.xml"
            .map(FileContents())
            .map(Template(build: { builder in
                builder["domain"] = domain
                builder.buildValues(forKey: "posts", withArray: posts, build: { post, builder in
                    builder["link"] = post.permanentRelativePath
                    builder["modified"] = post.modified.railsDate
                })
            }))
            .string()

        try self.write(xml, to: "Generated-working/sitemap.xml")

        print("done")
    }

    func generateAtomFeed(forDomain domain: String) throws {
        print("Generating atom feed...", terminator: "")

        let posts = try self.postsService.loadAllPublishedPosts()
        let xml = try "Views/feed.xml"
            .map(FileContents())
            .map(Template(build: { builder in
                func buildPost(post: PublishedPost, builder: TemplateBuilder) {
                    post.buildPublishedReference(to: builder)
                }

                builder["domain"] = domain
                builder["mostRecentUpdated"] = posts.first?.modified.iso8601DateTime
                builder.buildValues(forKey: "posts", withArray: posts, build: { post, builder in
                    builder["title"] = post.metaInfo.title
                    builder["permaLink"] = post.permanentRelativePath
                    builder["modified"] = post.modified.iso8601DateTime
                    builder["description"] = post.metaInfo.summary
                    builder["publishedYear"] = post.published.year
                    builder["content"] = post.html.data(using: .utf8)?.base64EncodedString()
                    builder["summary"] = post.metaInfo.summary
                })
            }))
            .string()

        try self.write(xml, to: "Generated-working/feed.xml")

        print("done")
    }

    func build(day: String, month: String, year: String, posts: [PublishedPost]) -> (_ builder: TemplateBuilder) -> () {
        return { builder in
            func buildPost(post: PublishedPost, builder: TemplateBuilder) {
                builder["dayLink"] = "/posts/\(year)/\(month)/\(day)"
                post.buildPublishedReference(to: builder)
            }

            builder["day"] = posts.first?.published.date
            builder["dayLink"] = "/posts/\(year)/\(month)/\(day)"
            builder.buildValues(forKey: "posts", withArray: posts, build: buildPost)
        }
    }

    func build(month: String, year: String, posts: PostsService.MonthDict) -> (_ builder: TemplateBuilder) -> () {
        return { builder in
            builder["month"] = posts.values.first?.first?.published.month
            builder["monthLink"] = "/posts/\(year)/\(month)"
            builder.buildValues(forKey: "posts", withArray: posts.keysAndValues, build: { (params, builder) in
                self.build(day: params.0, month: month, year: year, posts: params.1)(builder)
            })
        }
    }

    func build(year: String, posts: PostsService.YearDict) -> (_ builder: TemplateBuilder) -> () {
        return { builder in
            builder["year"] = year
            builder["yearLink"] = "/posts/\(year)"
            builder.buildValues(forKey: "posts", withArray: posts.keysAndValues, build: { (params, builder) in
                self.build(month: params.0, year: year, posts: params.1)(builder)
            })
        }
    }

    func build(posts: PostsService.AllDict) -> (_ builder: TemplateBuilder) -> () {
        return { builder in
            builder.buildValues(forKey: "posts", withArray: posts.keysAndValues, build: { (params, builder) in
                self.build(year: params.0, posts: params.1)(builder)
            })
        }
    }

    func generateArchive(forDay day: String, month: String, year: String, with array: [PublishedPost]) throws {
        print("Generating achive for \(year)/\(month)/\(day)...", terminator: "")

        let html = try "Views/day-archive.html"
            .map(FileContents())
            .map(Template(build: self.build(day: day, month: month, year: year, posts: array)))
            .string()
        try self.write(html, to: "Generated-working/posts/\(year)/\(month)/\(day)/archive.html")

        print("done")
    }

    func generateArchive(forMonth month: String, year: String, with dict: PostsService.MonthDict) throws {
        print("Generating achive for \(year)/\(month)...", terminator: "")

        let html = try "Views/month-archive.html"
            .map(FileContents())
            .map(Template(build: self.build(month: month, year: year, posts: dict)))
            .string()
        try self.write(html, to: "Generated-working/posts/\(year)/\(month)/archive.html")

        print("done")
    }

    func generateAchive(forYear year: String, with dict: PostsService.YearDict) throws {
        print("Generating achive for \(year)...", terminator: "")

        let html = try "Views/year-archive.html"
            .map(FileContents())
            .map(Template(build: self.build(year: year, posts: dict)))
            .string()
        try self.write(html, to: "Generated-working/posts/\(year)/archive.html")

        print("done")
    }

    func generateArchive(with dict: PostsService.AllDict) throws {
        print("Generating achive for all...", terminator: "")

        let html = try "Views/archive.html"
            .map(FileContents())
            .map(Template(build: self.build(posts: dict)))
            .string()
        try self.write(html, to: "Generated-working/posts/archive.html")

        print("done")
    }
}
