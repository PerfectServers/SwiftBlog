//
//  Handlers.swift
//  SwiftBlog
//
//  Created by Jonathan Guthrie on 2016-11-12.
//
//

import PerfectHTTP
import StORM
import PostgresStORM
import SwiftString
import PerfectLogger

class PageHandlers {

	static func makeHome(request: HTTPRequest, _ response: HTTPResponse) {
		// set up container object for results
		let page = Page(connect!)
		let components = Component(connect!)
		// set the cursor (number of results to return, and offset from start)
		let pageCursor = StORMCursor(limit: 1, offset: 0)

		var componentArray = [[String: Any]]()
		do {
			try page.select(columns: [], whereclause: "url = $1", params: ["/"], orderby: [], cursor: pageCursor)
		} catch {
			print(error)
		}
		var disqus = ""
		do {
			// gets all generic compoennts (pageid 0)
			try components.select(columns: [], whereclause: "pageid = $1", params: [0], orderby: [])

			// process incoming array of data
			for row in components.rows() {
				var r = [String: Any]()
				r["\(row.spot)?"] = ["content":row.content]
				componentArray.append(r)

				if row.spot == "disqus" {
					disqus = row.content
				}
			}
			// set array of data to the highscores property
		} catch {
			print(error)
		}

		let articles = Page(connect!)
		let articleArray = articles.getArticles()

		let homeArticle = Page(connect!)
		let thisArticle = homeArticle.getPage(link: "", isArticle: true)

		let contextAccountID = request.user.authDetails?.account.uniqueID ?? ""

		let contextAuthenticated = request.user.authenticated

		let contextTitle = "\(site.config["title"]!)"

		var contextMenu = [Any]()
		if let contextMenuis = site.config["menu"] {
			contextMenu = contextMenuis as! [Any]
		}

		var context: [String : Any] = [
			"accountID": contextAccountID,
			"authenticated": contextAuthenticated,
			"title": contextTitle,
			"menu": contextMenu,
			"siteurl": site.url,
			"pagename": page.name,
			"components": componentArray,
			"articles": articleArray,
			"featured": thisArticle
		]

		if !disqus.isEmpty {
			context["disqus?"] = ["content":disqus, "link":homeArticle.url]
		}

		response.render(template: "index", context: context)
	}


	static func makePage(request: HTTPRequest, _ response: HTTPResponse) {

		// set up container object for results
		let page = Page(connect!)
		let components = Component(connect!)
		// set the cursor (number of results to return, and offset from start)
		let pageCursor = StORMCursor(limit: 1, offset: 0)

		let pageid = request.urlVariables["pageid"] ?? ""


		var componentArray = [[String: Any]]()
		do {
			try page.select(columns: [], whereclause: "url = $1", params: [pageid], orderby: [], cursor: pageCursor)
		} catch {
			print(error)
		}
		var disqus = ""
		do {
			// gets all generic compoennts (pageid 0)
			try components.select(columns: [], whereclause: "pageid = $1", params: [0], orderby: [])

			// process incoming array of data
			for row in components.rows() {
				var r = [String: Any]()
				r["\(row.spot)?"] = ["content":row.content]
				componentArray.append(r)

				if row.spot == "disqus" {
					disqus = row.content
				}

			}
		} catch {
			print(error)
		}
		if page.id == 0 {
			var r = [String: Any]()
			r["body?"] = ["content":"Page not found"]
			componentArray.append(r)
		}
		let articles = Page(connect!)
		let articleArray = articles.getArticles()


		var context: [String : Any] = [
			"accountID": request.user.authDetails?.account.uniqueID ?? "",
			"token": request.user.authDetails?.sessionID ?? "",
			"authenticated": request.user.authenticated,
			"title": site.config["title"] as! String,
			"menu": site.config["menu"] as! [Any],
			"siteurl": site.url,
			"pagename": page.name,
			"components": componentArray,
			"articles": articleArray,
			"page": page.getPageData()
		]
		if !disqus.isEmpty {
			context["disqus?"] = ["content":disqus, "link":page.url]
		}
		response.render(template: "page", context: context)
	}

}

//func getWebNewsDetail(request: HTTPRequest, _ response: HTTPResponse) {
//
//	let id = request.urlVariables["id"] ?? ""
//
//	// set up container object for results
//	let news = News(connect!)
//	do {
//		try news.get(id)
//	} catch {
//		print(error)
//	}
//	let context: [String : Any] = [
//		"accountID": request.user.authDetails?.account.uniqueID ?? "",
//		"authenticated": request.user.authenticated,
//		"headline": news.headline,
//		"subhead": news.subhead,
//		"body": news.body
//	]
//	response.render(template: "newsdetail", context: context)
//}
//
