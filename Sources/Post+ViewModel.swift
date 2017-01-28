//
//  Post+ViewModel.swift
//  drewag.me
//
//  Created by Andrew J Wagner on 12/25/16.
//
//

import Foundation
import TextTransformers

extension Post {
    func buildPreviewContent(to builder: TemplateBuilder, atUrl baseUrl: URL) throws {
        builder["title"] = self.metaInfo.title
        builder["published"] = self.metaInfo.published?.date ?? "Unpublished"
        builder["isoPublished"] = self.metaInfo.published?.iso8601DateTime ?? "Unpublished"
        builder["isoModified"] = self.metaInfo.modified?.iso8601DateTime ?? "Unpublished"
        builder["summary"] = self.metaInfo.summary
        builder["imageUrl"] = baseUrl.appendingPathComponent("photo.jpg").relativePath
        builder["content"] = try self.loadHtml()
        builder["imageHeight"] = "\(self.metaInfo.imageHeight)"
    }


    func buildPreviewReference(to builder: TemplateBuilder) {
        builder["title"] = self.metaInfo.title
        builder["published"] = self.metaInfo.published?.date ?? "Unpublished"
        builder["summary"] = self.metaInfo.summary
        builder["imageLink"] = "preview/" + self.directoryUrl.lastPathComponent + "/photo.jpg"
        builder["link"] = "preview/" + self.directoryUrl.lastPathComponent
    }
}

extension PublishedPost {
    func buildPublishedContent(to builder: TemplateBuilder, atUrl baseUrl: URL) throws {
        try self.buildPreviewContent(to: builder, atUrl: baseUrl)
        builder["permaLink"] = self.permanentRelativePath
    }

    func buildPublishedReference(to builder: TemplateBuilder) {
        self.buildPreviewReference(to: builder)
        builder["imageLink"] = self.permanentRelativeImagePath
        builder["link"] = self.permanentRelativePath
    }
}
