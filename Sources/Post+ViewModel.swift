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
    func buildContent(to builder: TemplateBuilder, atUrl baseUrl: URL) {
        builder["title"] = self.metaInfo.title
        builder["permaLink"] = self.permanentRelativePath
        builder["published"] = self.metaInfo.published.date
        builder["imageUrl"] = baseUrl.appendingPathComponent("photo.jpg").relativePath
        builder["content"] = self.html
    }

    func buildReference(to builder: TemplateBuilder, link: String? = nil) {
        builder["title"] = self.metaInfo.title
        builder["published"] = self.metaInfo.published.date
        builder["summary"] = self.metaInfo.summary
        builder["imageLink"] = self.permanentRelativeImagePath
        builder["link"] = link ?? self.permanentRelativePath
    }
}
