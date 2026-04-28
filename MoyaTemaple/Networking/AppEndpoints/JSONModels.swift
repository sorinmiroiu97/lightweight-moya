//
//  JSONModels.swift
//  MoyaTemplate
//
//  Created by Sorin Miroiu on 25.04.2026.
//

import Foundation

struct PlaceholderPost: Codable, Sendable, Identifiable {
    let id: Int?
    let userId: Int
    let title: String
    let body: String
}

struct PlaceholderComment: Codable, Sendable, Identifiable {
    let id: Int
    let postId: Int
    let name: String
    let email: String
    let body: String
}

struct PlaceholderUser: Codable, Sendable, Identifiable {
    let id: Int
    let name: String
    let username: String
    let email: String
}

struct CreatePostBody: Codable, Sendable, Identifiable {
    var id: Int {
        userId
    }

    let userId: Int
    let title: String
    let body: String
}

struct PlaceholderAlbum: Codable, Sendable, Identifiable {
    let id: Int
    let userId: Int
    let title: String
}

struct PlaceholderTodo: Codable, Sendable, Identifiable {
    let id: Int
    let userId: Int
    let title: String
    let completed: Bool
}
