//
//  UserRespons.swift
//  Notes
//
//  Created by JoyDev on 28.11.2023.
//

import Foundation

struct UsersResponse: Decodable {
    let page, perPage, total, totalPages: Int
    let data: [UserDataModel]
    let support: SupportModel

    enum CodingKeys: String, CodingKey {
        case page
        case perPage = "per_page"
        case total
        case totalPages = "total_pages"
        case data, support
    }
}

struct UserDataModel: Decodable {
    let login, email, password: String

    enum CodingKeys: String, CodingKey {
        case login, email, password
    }
}

struct SupportModel: Decodable {
    let url: String
    let text: String
}

