//
//  EGF2.swift
//  EGF2
//
//  Created by EGF2GEN on 06.12.16.
//  Copyright © 2016 EigenGraph. All rights reserved.
//

import Foundation
import EGF2

var Graph: EGF2Graph = {
    let graph = EGF2Graph(name: "EGF2")!
    graph.serverURL = URL(string: "http://guide.eigengraph.com/v1/")
    graph.maxPageSize = 50
    graph.defaultPageSize = 25
    graph.showCacheLogs = true
    graph.isObjectPaginationMode = false;
    graph.idsWithModelTypes = [
		"03": EGFUser.self,
		"06": EGFFile.self,
		"10": EGFCustomerRole.self,
		"11": EGFAdminRole.self,
		"12": EGFPost.self,
		"13": EGFComment.self
	]
    return graph
}()

// MARK:- Simple objects
class EGFDimension: NSObject {
	var width: Int = 0
	var height: Int = 0

	func requiredFields() -> [String] {
		return [
			"width",
			"height"
		]
	}
}

class EGFKeyValue: NSObject {
	var key: String?
	var value: String?

	func requiredFields() -> [String] {
		return [
			"key",
			"value"
		]
	}
}

class EGFHumanName: NSObject {
	var use: String?
	var given: String?
	var prefix: String?
	var suffix: String?
	var middle: String?
	var family: String?

	func requiredFields() -> [String] {
		return [
			"use",
			"given",
			"prefix",
			"suffix",
			"middle",
			"family"
		]
	}
}

class EGFResize: NSObject {
	var url: String?
	var dimensions: EGFDimension?

	func requiredFields() -> [String] {
		return [
			"url",
			"dimensions"
		]
	}
}

class EGFTime: NSObject {
	var minute: Int = 0
	var second: Int = 0
	var hour: Int = 0

	func requiredFields() -> [String] {
		return [
			"minute",
			"second",
			"hour"
		]
	}
}

class EGFEdge: NSObject {
	var src: String?
	var name: String?
	var dst: String?

	func requiredFields() -> [String] {
		return [
			"src",
			"name",
			"dst"
		]
	}
}

class EGFDate: NSObject {
	var dayOfWeek: Int = 0
	var year: Int = 0
	var month: Int = 0
	var day: Int = 0

	func requiredFields() -> [String] {
		return [
			"dayOfWeek",
			"year",
			"month",
			"day"
		]
	}
}

// MARK:- Base graph object
class EGFGraphObject: NSObject {
	var modifiedAt: Date?
	var id: String?
	var deletedAt: Date?
	var createdAt: Date?

	func editableFields() -> [String] {
		return []
	}

	func requiredFields() -> [String] {
		return [
			"modifiedAt",
			"id",
			"createdAt"
		]
	}
}

// MARK:- Common objects
class EGFPost: EGFGraphObject {
	var creator: String?
	var creatorObject: EGFUser?
	var image: String?
	var imageObject: EGFFile?
	var desc: String?

	override func editableFields() -> [String] {
		return super.editableFields() + [
			"desc"
		]
	}

	override func requiredFields() -> [String] {
		return super.requiredFields() + [
			"creator",
			"image",
			"desc"
		]
	}
}

class EGFFile: EGFGraphObject {
	var url: String?
	var hosted: Bool = false
	var standalone: Bool = true
	var dimensions: EGFDimension?
	var uploadUrl: String?
	var title: String?
	var size: Int = 0
	var resizes = [EGFResize]()
	var uploaded: Bool = false
	var mimeType: String?
	var user: String?
	var userObject: EGFUser?

	override func editableFields() -> [String] {
		return super.editableFields() + [
			"title",
			"mimeType"
		]
	}

	override func requiredFields() -> [String] {
		return super.requiredFields() + [
			"url",
			"mimeType",
			"user"
		]
	}
}

class EGFCustomerRole: EGFGraphObject {
	var user: String?
	var userObject: EGFUser?


	override func requiredFields() -> [String] {
		return super.requiredFields() + [
			"user"
		]
	}
}

class EGFComment: EGFGraphObject {
	var creator: String?
	var creatorObject: EGFUser?
	var post: String?
	var postObject: EGFPost?
	var text: String?

	override func editableFields() -> [String] {
		return super.editableFields() + [
			"text"
		]
	}

	override func requiredFields() -> [String] {
		return super.requiredFields() + [
			"creator",
			"post",
			"text"
		]
	}
}

class EGFAdminRole: EGFGraphObject {
	var user: String?
	var userObject: EGFUser?


	override func requiredFields() -> [String] {
		return super.requiredFields() + [
			"user"
		]
	}
}

class EGFUser: EGFGraphObject {
	var email: String?
	var system: String?
	var noPassword: Bool = false
	var name: EGFHumanName?
	var verified: Bool = false

	override func editableFields() -> [String] {
		return super.editableFields() + [
			"name"
		]
	}

	override func requiredFields() -> [String] {
		return super.requiredFields() + [
			"email",
			"system",
			"name"
		]
	}
}

