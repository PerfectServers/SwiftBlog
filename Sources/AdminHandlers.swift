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

class BlogAdmin {

	static func componentList(_ pageid: Int) -> [[String: Any]] {
		var componentArray = [[String: Any]]()
		let components = Component(connect!)
		do {
			// gets all generic compoennts (pageid 0)
			try components.select(columns: [], whereclause: "pageid = $1", params: [pageid], orderby: [])

			// process incoming array of data
			for row in components.rows() {
				if row.content.isEmpty == false {
					var r = [String: Any]()
					r["\(row.spot)?"] = ["content":row.content]
					componentArray.append(r)
				}
			}
			// set array of data to the highscores property
		} catch {
			print(error)
		}

		return componentArray
	}

	static func makeLogin(request: HTTPRequest, _ response: HTTPResponse) {
		let page = Page(connect!)
		// set the cursor (number of results to return, and offset from start)
		let pageCursor = StORMCursor(limit: 1, offset: 0)

		do {
			try page.select(columns: [], whereclause: "url = $1", params: ["/"], orderby: [], cursor: pageCursor)
		} catch {
			print(error)
		}

		let componentArray = BlogAdmin.componentList(0)

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

	static func siteAdmin(request: HTTPRequest, _ response: HTTPResponse) {

		// save component...
		if request.method == .post {
			let thisSite = Site(connect!)
			thisSite.id = site.id
			thisSite.url = request.param(name: "url", defaultValue: "Not Set")!
			//{"menu": [{"link": "/one", "name": "One"}, {"link": "/two", "name": "Two"}, {"link": "/dragons", "name": "Three"}], "title": "Relatable Rachel"}
			thisSite.config["title"] = request.param(name: "title", defaultValue: "Not Set")!


			let menunames = request.params(named: "menuname")
			let menulinks = request.params(named: "menulink")

			var menuOptions = [[String: String]]()
			for i in 0..<10 {
				if menunames[i].characters.count > 0 {
					var
					this = [String:String]()
					this["name"] = menunames[i]
					this["link"] = menulinks[i]
					menuOptions.append(this)
				}
			}
//			thisSite.config["menu"] = site.config["menu"]
			thisSite.config["menu"] = menuOptions
			try? thisSite.save()

			// also need to save subhead component
			let sub = Component(connect!)
			var opts = [(String,Any)]()
				opts.append(("spot","subhead"))
				opts.append(("pageid",0))
			try? sub.find(opts)
			sub.content = request.param(name: "subhead", defaultValue: "Not Set")!
			try? sub.save()

			// also need to save about
			let about = Component(connect!)
			var optsAbout = [(String,Any)]()
			optsAbout.append(("spot","about"))
			optsAbout.append(("pageid",0))
			try? about.find(optsAbout)
			about.content = request.param(name: "about", defaultValue: "Not Set")!
			try? about.save()

			site.getSiteInfo()
		}
		// end save compoennt


		let componentArray = BlogAdmin.componentList(0)

		let articles = Page(connect!)
		let articleArray = articles.getArticles()

		var menu = [[String:String]]()
		for ob in site.config["menu"] as! [[String:String]] {
			menu.append(ob)
		}
		for _ in menu.count..<10 {
			menu.append(["link":"","name":""])
		}

		let context: [String : Any] = [
			"accountID": request.user.authDetails?.account.uniqueID ?? "",
			"authenticated": request.user.authenticated,
			"title": site.config["title"] as! String,
			"menu": site.config["menu"] as! [Any],
			"menudata": menu,
			"url": site.url,
			"pagename": "Site Admin",
			"components": componentArray,
			"articles": articleArray
		]

		response.render(template: "admin/site", context: context)
	}

	static func siteSocial(request: HTTPRequest, _ response: HTTPResponse) {

		// save component...
		if request.method == .post {

			for obj in ["twitter", "facebook", "instagram", "email", "googleanalytics", "gtmcode", "disqus"] {

				// also need to save subhead component
				let sub = Component(connect!)
				sub.spot = obj
				var opts = [(String,Any)]()
				opts.append(("spot",obj))
				opts.append(("pageid",0))
				try? sub.find(opts)
				sub.content = request.param(name: obj, defaultValue: "Not Set")!
				try? sub.save()

			}

		}
		// end save compoennt


		let componentArray = BlogAdmin.componentList(0)

		let articles = Page(connect!)
		let articleArray = articles.getArticles()


		let context: [String : Any] = [
			"accountID": request.user.authDetails?.account.uniqueID ?? "",
			"authenticated": request.user.authenticated,
			"title": site.config["title"] as! String,
			"menu": site.config["menu"] as! [Any],
			"pagename": "Site Social & Analytics",
			"components": componentArray,
			"articles": articleArray
		]

		response.render(template: "admin/social", context: context)
	}


	static func userAdmin(request: HTTPRequest, _ response: HTTPResponse) {

		// save component...
//		if request.method == .post {
//			let thisSite = Site(connect!)
//			thisSite.id = site.id
//			thisSite.url = request.param(name: "url", defaultValue: "Not Set")!
//			//{"menu": [{"link": "/one", "name": "One"}, {"link": "/two", "name": "Two"}, {"link": "/dragons", "name": "Three"}], "title": "Relatable Rachel"}
//			thisSite.config["title"] = request.param(name: "title", defaultValue: "Not Set")!
//			thisSite.config["menu"] = site.config["menu"]
//			try? thisSite.save()
//
//			// also need to save subhead component
//			let sub = Component(connect!)
//			var opts = [(String,Any)]()
//			opts.append(("spot","subhead"))
//			opts.append(("pageid",0))
//			try? sub.find(opts)
//			sub.content = request.param(name: "subhead", defaultValue: "Not Set")!
//			try? sub.save()
//
//			// also need to save about
//			let about = Component(connect!)
//			var optsAbout = [(String,Any)]()
//			optsAbout.append(("spot","about"))
//			optsAbout.append(("pageid",0))
//			try? about.find(optsAbout)
//			about.content = request.param(name: "about", defaultValue: "Not Set")!
//			try? about.save()
//
//			site.getSiteInfo()
//		}
		// end save compoennt


		let componentArray = BlogAdmin.componentList(0)

		let articles = Page(connect!)
		let articleArray = articles.getArticles()

		let users = [[String:String]]()
//		for ob in site.config["menu"] as! [[String:String]] {
//			menu.append(ob)
//		}
//		for _ in menu.count..<10 {
//			menu.append(["link":"","name":""])
//		}

		let context: [String : Any] = [
			"accountID": request.user.authDetails?.account.uniqueID ?? "",
			"authenticated": request.user.authenticated,
			"title": site.config["title"] as! String,
			"menu": site.config["menu"] as! [Any],
			"users": users,
			"pagename": "User Admin",
			"components": componentArray,
			"articles": articleArray
		]

		response.render(template: "admin/users", context: context)
	}

}
