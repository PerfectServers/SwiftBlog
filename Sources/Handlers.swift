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


func makeLogin(request: HTTPRequest, _ response: HTTPResponse) {
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

	do {
		// gets all generic compoennts (pageid 0)
		try components.select(columns: [], whereclause: "pageid = $1", params: [0], orderby: [])

		// process incoming array of data
		for row in components.rows() {
			var r = [String: Any]()
			r["\(row.spot)?"] = ["content":row.content]
			componentArray.append(r)
		}
		// set array of data to the highscores property
	} catch {
		print(error)
	}

	let articles = Page(connect!)
	let articleArray = articles.getArticles()

	let context: [String : Any] = [
		"accountID": request.user.authDetails?.account.uniqueID ?? "",
		"authenticated": request.user.authenticated,
		"title": site.config["title"] as! String,
		"menu": site.config["menu"] as! [Any],
		"pagename": "Login",
		"components": componentArray,
		"articles": articleArray
	]

	response.render(template: "login",context: context)
}

func makeHome(request: HTTPRequest, _ response: HTTPResponse) {

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
	do {
		// gets all generic compoennts (pageid 0)
		try components.select(columns: [], whereclause: "pageid = $1", params: [0], orderby: [])

		// process incoming array of data
		for row in components.rows() {
			var r = [String: Any]()
			r["\(row.spot)?"] = ["content":row.content]
			componentArray.append(r)
		}
		// set array of data to the highscores property
	} catch {
		print(error)
	}

//	var articleArray = [[String: Any]]()
	let articles = Page(connect!)
	let articleArray = articles.getArticles()

	let homeArticle = Page(connect!)
	let thisArticle = homeArticle.getPage(link: "", isArticle: true)

//	for row in articles.rows() {
//		var r = [String: Any]()
//		r["name"] = row.name
//		r["url"] = row.url
//		r["config"] = row.config
//		articleArray.append(r)
//	}


//	print("componentArray: \(componentArray)")
//	print("articleArray: \(articleArray)")

//	print(thisArticle)
	let context: [String : Any] = [
		"accountID": request.user.authDetails?.account.uniqueID ?? "",
		"authenticated": request.user.authenticated,
		"title": site.config["title"] as! String,
		"menu": site.config["menu"] as! [Any],
		"pagename": page.name,
		"components": componentArray,
		"articles": articleArray,
		"featured": thisArticle
	]

	response.render(template: "index", context: context)
}


func makePage(request: HTTPRequest, _ response: HTTPResponse) {

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
	do {
		// gets all generic compoennts (pageid 0)
		try components.select(columns: [], whereclause: "pageid = $1", params: [0], orderby: [])

		// process incoming array of data
		for row in components.rows() {
			var r = [String: Any]()
			r["\(row.spot)?"] = ["content":row.content]
			componentArray.append(r)
		}
		// set array of data to the highscores property
	} catch {
		print(error)
	}

	//	var articleArray = [[String: Any]]()
	let articles = Page(connect!)
	let articleArray = articles.getArticles()
	//	for row in articles.rows() {
	//		var r = [String: Any]()
	//		r["name"] = row.name
	//		r["url"] = row.url
	//		r["config"] = row.config
	//		articleArray.append(r)
	//	}


//	print("componentArray: \(componentArray)")
//	print("articleArray: \(articleArray)")

	let context: [String : Any] = [
		"accountID": request.user.authDetails?.account.uniqueID ?? "",
		"authenticated": request.user.authenticated,
		"title": site.config["title"] as! String,
		"menu": site.config["menu"] as! [Any],
		"pagename": page.name,
		"components": componentArray,
		"articles": articleArray
	]

	response.render(template: "index", context: context)
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
