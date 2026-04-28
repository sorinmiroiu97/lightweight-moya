//
//  JSONPlaceholderEndpoint.swift
//  MoyaTemaple
//
//  Created by Sorin Miroiu on 25.04.2026.
//

import Foundation

enum JSONPlaceholderEndpoint: Endpoint {
    case getPosts
    case getComments(postId: Int)
    case createPost(body: CreatePostBody)
    case getUsers
    case getAlbums(userId: Int)
    case getTodos(userId: Int)

    var baseUrlPath: String {
        "https://jsonplaceholder.typicode.com"
    }

    var route: String {
        switch self {
        case .getPosts:
            "/posts"
        case .getComments:
            "/comments"
        case .createPost:
            "/posts"
        case .getUsers:
            "/users"
        case .getAlbums:
            "/albums"
        case .getTodos:
            "/todos"
        }
    }

    var urlParams: [String: Any]? {
        switch self {
        case .getComments(let postId):
            ["postId": postId]
        case .getAlbums(let userId):
            ["userId": userId]
        case .getTodos(let userId):
            ["userId": userId]
        default:
            nil
        }
    }

    var body: Data? {
        get throws {
            switch self {
            case .createPost(let body):
                try JSONEncoder().encode(body)
            default:
                nil
            }
        }
    }

    var httpMethod: HTTPMethod {
        switch self {
        case .getPosts,
                .getComments,
                .getUsers,
                .getAlbums,
                .getTodos:
                .get
        case .createPost:
                .post
        }
    }
}
