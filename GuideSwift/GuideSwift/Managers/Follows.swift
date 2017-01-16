//
//  Follows.swift
//  GuideSwift
//
//  Created by LuzanovRoman on 23.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

import Foundation
import EGF2

enum FollowState {
    case isMe
    case isUnknown
    case isFollow
    case isNotFollow
}

class Follows {
    static let shared = Follows()

    fileprivate var users = [EGFUser]()
    fileprivate var adding = [EGFUser]()
    fileprivate var removing = [EGFUser]()
    fileprivate var edge = "follows"
    fileprivate var currentUserId: String?
    fileprivate var isDownloading = false
    fileprivate var isDownloaded = false
    fileprivate var isObserving = false
    fileprivate var token = 0
    fileprivate var timer: Timer?

    func startObserving() {
        Graph.userObject { (object, _) in
            guard let user = object as? EGFUser, let userId = user.id else { return }
            let object = Graph.notificationObject(forSource: userId, andEdge: self.edge)
            NotificationCenter.default.addObserver(self, selector: #selector(self.edgeCreated(notification:)), name: .EGF2EdgeCreated, object: object)
            NotificationCenter.default.addObserver(self, selector: #selector(self.edgeRemoved(notification:)), name: .EGF2EdgeRemoved, object: object)
            NotificationCenter.default.addObserver(self, selector: #selector(self.edgeRefreshed), name: .EGF2EdgeRefreshed, object: object)
            self.isObserving = true
            self.currentUserId = userId
            self.timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.checkDownloading), userInfo: nil, repeats: true)
            self.loadNextPage()
        }
    }

    func stopObserving() {
        NotificationCenter.default.removeObserver(self)
        users.removeAll()
        adding.removeAll()
        removing.removeAll()
        currentUserId = nil
        isObserving = false
        isDownloaded = false
        timer?.invalidate()
        timer = nil
    }

    func followState(forUser user: EGFUser) -> FollowState {
        guard let followId = user.id else { return .isUnknown }
        if let userId = currentUserId, userId == followId { return .isMe }
        if let _ = self.adding.first(where: {$0.id == followId}) { return .isFollow }
        if let _ = self.removing.first(where: {$0.id == followId}) { return .isNotFollow }
        if let _ = self.users.first(where: {$0.id == followId}) { return .isFollow }
        return isDownloaded ? .isNotFollow : .isUnknown
    }

    func follow(user: EGFUser, completion: @escaping () -> Void) {
        guard let followId = user.id, let userId = currentUserId else {
            completion()
            return
        }
        // Can't add user while removing him
        if let _ = self.removing.first(where: {$0.id == followId}) {
            completion()
            return
        }
        adding.append(user)
        Graph.addObject(withId: followId, forSource: userId, toEdge: edge) { (_, error) in
            guard let index = self.adding.index(of: user) else { return }
            self.adding.remove(at: index)

            if error == nil {
                self.users.insert(user, at: 0)
            }
            completion()
        }
    }

    func unfollow(user: EGFUser, completion: @escaping () -> Void) {
        guard let followId = user.id, let userId = currentUserId else {
            completion()
            return
        }
        // Can't remove user while adding him
        if let _ = self.adding.first(where: {$0.id == followId}) {
            completion()
            return
        }
        removing.append(user)
        Graph.deleteObject(withId: followId, forSource: userId, fromEdge: edge) { (_, error) in
            guard let index = self.removing.index(of: user) else { return }
            self.removing.remove(at: index)

            if error == nil {
                if let existUser = self.users.first(where: {$0.id == followId}), let index = self.users.index(of: existUser) {
                    self.users.remove(at: index)
                }
            }
            completion()
        }
    }

    @objc fileprivate func edgeCreated(notification: NSNotification) {
        guard let userId = notification.userInfo?[EGF2EdgeObjectIdInfoKey] as? String else { return }
        // Ignore if user already is in the list
        if let _ = users.first(where: {$0.id == userId}) { return }

        Graph.object(withId: userId) { (object, _) in
            guard let user = object as? EGFUser else { return }
            self.users.insert(user, at: 0)
        }
    }

    @objc fileprivate func edgeRemoved(notification: NSNotification) {
        guard let userId = notification.userInfo?[EGF2EdgeObjectIdInfoKey] as? String else { return }
        guard let user = users.first(where: {$0.id == userId}), let index = users.index(of: user) else { return }
        users.remove(at: index)
    }

    @objc fileprivate func edgeRefreshed(notification: NSNotification) {
        token += 1
        isDownloaded = false
        users.removeAll()
        loadNextPage()
    }

    fileprivate func loadNextPage() {
        guard let userId = currentUserId else { return }

        let localToken = token

        isDownloading = true
        Graph.objects(forSource: userId, edge: edge, after: users.last?.id) { (objects, count, _) in
            self.isDownloading = false

            // Avoid getting old data
            if localToken != self.token { return }

            guard let nextUsers = objects as? [EGFUser] else { return }
            self.users.append(contentsOf: nextUsers)

            if self.users.count == count {
                self.isDownloaded = true
            } else {
                self.loadNextPage()
            }
        }
    }

    @objc fileprivate func checkDownloading() {
        if isDownloading { return }
        if isDownloaded {
            timer?.invalidate()
            timer = nil
            return
        }
        loadNextPage()
    }
}
