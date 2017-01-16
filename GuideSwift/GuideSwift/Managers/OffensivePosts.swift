//
//  OffensivePosts.swift
//  GuideSwift
//
//  Created by LuzanovRoman on 29.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

import Foundation

enum OffensiveState {
    case isNotOffensive
    case isOffensive
    case isUnknown
}

class OffensivePosts {
    static let shared = OffensivePosts()

    fileprivate var notOffensivePostsIds = [String]()
    fileprivate var offensivePostsIds = [String]()
    fileprivate var checkingIds = [String]()
    fileprivate var addingIds = [String]()
    fileprivate var currentUserId: String?
    fileprivate let edge = "offended"

    func startSession() {
        Graph.userObject { (object, _) in
            self.currentUserId = (object as? EGFUser)?.id
        }
    }

    func stopSession() {
        notOffensivePostsIds.removeAll()
        offensivePostsIds.removeAll()
        checkingIds.removeAll()
        addingIds.removeAll()
        currentUserId = nil
    }

    func offensiveState(forPost post: EGFPost) -> OffensiveState {
        guard let postId = post.id, let userId = currentUserId else { return .isUnknown }

        if checkingIds.contains(postId) {
            return .isUnknown
        }
        if addingIds.contains(postId) || offensivePostsIds.contains(postId) {
            return .isOffensive
        }
        if notOffensivePostsIds.contains(postId) {
            return .isNotOffensive
        }
        checkingIds.append(postId)
        Graph.doesObject(withId: userId, existForSource: postId, onEdge: edge) { (exists, error) in
            self.checkingIds.remove(postId)

            if let _ = error { return }

            if exists {
                self.offensivePostsIds.append(postId)
            } else {
                self.notOffensivePostsIds.append(postId)
            }
        }
        return .isUnknown
    }

    func markAsOffensive(post: EGFPost, completion: @escaping () -> Void) {
        guard let postId = post.id, let userId = currentUserId else {
            completion()
            return
        }
        addingIds.append(postId)
        Graph.addObject(withId: userId, forSource: postId, toEdge: edge) { (_, error) in
            self.addingIds.remove(postId)

            if error == nil {
                self.offensivePostsIds.append(postId)
                self.notOffensivePostsIds.remove(postId)
            }
            completion()
        }
    }
}
