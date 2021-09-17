//
//  NewsViewModel.swift
//  StocksApp
//
//  Created by Григорий Толкачев on 17.09.2021.
//

import Foundation

struct NewsData: Codable {
    let id: String?
    let guid: String?
    let publishedOn: Int?
    let imageurl: String?
    let title: String?
    let url: String?
    let source, body, tags, categories: String?
    let upvotes, downvotes: String?
    let lang: Lang?
    let sourceInfo: SourceInfo?

    enum CodingKeys: String, CodingKey {
        case id, guid
        case publishedOn = "published_on"
        case imageurl, title, url, source, body, tags, categories, upvotes, downvotes, lang
        case sourceInfo = "source_info"
    }
}

enum Lang: String, Codable {
    case en = "EN"
}

struct SourceInfo: Codable {
    let name: String?
    let lang: Lang?
    let img: String?
}

//NEWS
struct News: Codable {
    let data: [NewsData]?

    enum CodingKeys: String, CodingKey {
        case data = "Data"

    }
}
