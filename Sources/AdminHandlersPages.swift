//
//  AdminHandlers.swift
//  SwiftBlog
//
//  Created by Jonathan Guthrie on 2016-11-14.
//
//

import PerfectHTTP
import StORM
import PostgresStORM
import SwiftString

extension BlogAdmin {

	static func returnToList(request: HTTPRequest, _ response: HTTPResponse) {
		// set the HTTP Response status to "302", a temporary redirect
		response.status = .found
		// set the location for the redirect
		response.setHeader(.location, value: "/admin/pages")


		// Signalling that the request is completed
		response.completed()
		
	}

	static func savePageData(_ request: HTTPRequest, _ response: HTTPResponse, page: Page) {
		page.url = request.param(name: "url", defaultValue: "Not Set")!
		page.name = request.param(name: "pagename", defaultValue: "Not Set")!

		for opt in ["type", "intro", "subhead", "datepublished", "metadescription", "script", "heroimage", "heroimagealt"] {
			page.config[opt] = request.param(name: opt, defaultValue: "")!
		}


		let tags = request.param(name: "tags", defaultValue: "")!
		let taglist = tags.split(",")
		var tagassembled = [[String:String]]()
		for tag in taglist {
			if !tag.trimmed().isEmpty {
				tagassembled.append(["tag":tag.trimmed()])
			}
		}
		page.config["tags"] = tagassembled
		do {
			try page.save()
			BlogAdmin.returnToList(request: request, response)
		} catch {
			print("Save Edit page id \(page.id) error - cannot save page: \(error)")
		}

	}


	static func pagesAdminSaveOrder(request: HTTPRequest, _ response: HTTPResponse) {

		let orders = request.params(named: "sort")

		let aPage = Page()
		var orderN = 1
		for p in orders {
			_ = try? aPage.sql("UPDATE page SET displayorder = $1 WHERE id = $2", params: [String(orderN),p])
			orderN += 1
		}

		// return JSON data to client
		do {
			try response.setBody(json: ["order":"complete"])
		} catch {
			print(error)
		}
		response.completed()

	}


	static func pagesAdmin(request: HTTPRequest, _ response: HTTPResponse) {

		let articles = Page()
		let pages = Page()

		let context: [String : Any] = [
			"accountID": request.user.authDetails?.account.uniqueID ?? "",
			"authenticated": request.user.authenticated,
			"token": request.user.authDetails?.sessionID ?? "",
			"title": site.config["title"] as! String,
			"menu": site.config["menu"] as! [Any],
			"pagename": "Pages Admin",
			"components": BlogAdmin.componentList(0),
			"articles": articles.getArticles(),
			"pages": pages.pageList()
		]

		response.render(template: "admin/pages", context: context)

	}

	static func pagesAdminCreate(request: HTTPRequest, _ response: HTTPResponse) {

		let articles = Page()

		// save component.
		if request.method == .post {
			let page = Page()
			BlogAdmin.savePageData(request, response, page: page)
		}
		// end save compoennt


		let context: [String : Any] = [
			"accountID": request.user.authDetails?.account.uniqueID ?? "",
			"authenticated": request.user.authenticated,
			"title": site.config["title"] as! String,
			"menu": site.config["menu"] as! [Any],
			"pagename": "New Page",
			"components": BlogAdmin.componentList(0),
			"articles": articles.getArticles()
		]

		response.render(template: "admin/pageedit", context: context)
		
	}
	
	static func pagesAdminEdit(request: HTTPRequest, _ response: HTTPResponse) {

		let articles = Page()

		let page = Page()
		let id = request.urlVariables["id"] ?? ""
		do {
			try page.get(id)
		} catch {
			print("Edit page id \(id) error - cannot load page: \(error)")
		}

		// save component.
		if request.method == .post {
			BlogAdmin.savePageData(request, response, page: page)
		}
		// end save compoennt


		var context: [String : Any] = [
			"accountID": request.user.authDetails?.account.uniqueID ?? "",
			"authenticated": request.user.authenticated,
			"title": site.config["title"] as! String,
			"menu": site.config["menu"] as! [Any],
			"pagename": "Edit Page",
			"components": BlogAdmin.componentList(0),
			"articles": articles.getArticles(),

			"id": id,
			"name": page.name,
			"url": page.url,
			"config": page.config
		]
		if let obj = page.config["type"] {
			if obj as! String == "article" {
				context["isArticle"] = "selected=\"selected\""
			} else if obj as! String == "general" {
				context["isGeneral"] = "selected=\"selected\""
			} else {
				context["isUnspecified"] = "selected=\"selected\""
			}
		}

		response.render(template: "admin/pageedit", context: context)

	}
	
	static func pagesAdminDelete(request: HTTPRequest, _ response: HTTPResponse) {

		let page = Page()
		let id = request.urlVariables["id"] ?? ""
		do {
			try page.delete(id)
		} catch {
			print("Deleting page id \(id) error - cannot delete page: \(error)")
		}

		BlogAdmin.returnToList(request: request, response)

	}
	
	static func pagesAdminToggle(request: HTTPRequest, _ response: HTTPResponse) {

		let page = Page()
		let id = request.urlVariables["id"] ?? ""
		do {
			try page.get(id)
			if page.state == true { page.state = false } else { page.state = true }
			try page.save()
		} catch {
			print("Toggling page id \(id) error - cannot load page: \(error)")
		}

		BlogAdmin.returnToList(request: request, response)
	}

	static func pagesAdminSaveContent(request: HTTPRequest, _ response: HTTPResponse) {
		// set the JSON content type
		response.setHeader(.contentType, value: "application/json")

		// response data container
		var resp = [String: Any]()


		// process incoming data, with protections in case the params are not supplied
		guard let content = request.param(name: "content") else {
			// set an error response to be returned
			response.status = .badRequest
			resp["error"] = "Please supply values"
			do {
				try response.setBody(json: resp)
			} catch {
				print(error)
			}
			response.completed()
			return
		}


		let page = Page()
		let id = request.urlVariables["id"] ?? ""
		do {
			try page.get(id)

			let sub = Component()
			sub.pageid = page.id
			sub.spot = "body"
			var opts = [(String,Any)]()
			opts.append(("spot","body"))
			opts.append(("pageid",page.id))
			try? sub.find(opts)
			sub.content = content
			try? sub.save()
			resp["saved"] = "ok"

		} catch {
			print("Editing page id \(id) error - cannot load page: \(error)")
			resp["error"] = "\(error)"
		}

		// return JSON data to client
		do {
			try response.setBody(json: resp)
		} catch {
			print(error)
		}
		response.completed()

	}

}
