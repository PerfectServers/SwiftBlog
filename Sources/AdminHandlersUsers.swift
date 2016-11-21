//
//  AdminHandlersUsers.swift
//  SwiftBlog
//
//  Created by Jonathan Guthrie on 2016-11-20.
//
//

import PerfectHTTP
import StORM
import PostgresStORM
import SwiftString
import PerfectTurnstilePostgreSQL
import TurnstileCrypto

extension BlogAdmin {

	static func returnToUserList(request: HTTPRequest, _ response: HTTPResponse) {
		// set the HTTP Response status to "302", a temporary redirect
		response.status = .found
		// set the location for the redirect
		response.setHeader(.location, value: "/admin/users")
		// Signalling that the request is completed
		response.completed()
	}

	@discardableResult
	static func saveUserData(_ request: HTTPRequest, _ response: HTTPResponse, user: AuthAccount) -> AuthAccount {
		let random: Random = URandom()
		var state = false // means it's a save not a create
		if user.uniqueID.isEmpty() {
			user.uniqueID = String(random.secureToken)
			state = true // new user
		}
		user.username = request.param(name: "username", defaultValue: "-")!
		user.email = request.param(name: "email", defaultValue: "")!
		user.firstname = request.param(name: "firstname", defaultValue: "")!
		user.lastname = request.param(name: "lastname", defaultValue: "")!

		let p1 = request.param(name: "password", defaultValue: ".")!
		let p2 = request.param(name: "password2", defaultValue: "..")!

		if !p1.isEmpty && p1 == p2 {
			user.password = BCrypt.hash(password: p1)
		}

		if user.username == "-" {
			return user
		}


		do {
			if state {
				try user.create()
			} else {
				try user.save()
			}
			BlogAdmin.returnToUserList(request: request, response)
		} catch {
			print("Save Edit user id \(user.id) error - cannot save user: \(error)")
		}
		return user
	}

	static func userAdmin(request: HTTPRequest, _ response: HTTPResponse) {

		let users = AuthAccount(connect!)
		try? users.select(whereclause: "", params: [], orderby: ["username"])
		var userArray = [[String: Any]]()

		let articles = Page(connect!)
		for row in users.rows() {
			var r = [String: Any]()
			r["uniqueID"] = row.uniqueID
			r["username"] = row.username
			r["firstname"] = row.firstname
			r["lastname"] = row.lastname
			r["email"] = row.email

			userArray.append(r)
		}


		let context: [String : Any] = [
			"accountID": request.user.authDetails?.account.uniqueID ?? "",
			"authenticated": request.user.authenticated,
			"token": request.user.authDetails?.sessionID ?? "",
			"title": site.config["title"] as! String,
			"menu": site.config["menu"] as! [Any],
			"pagename": "User Admin",
			"components": BlogAdmin.componentList(0),
			"articles": articles.getArticles(),
			"users": userArray
		]

		response.render(template: "admin/users", context: context)
	}


	static func userAdminCreate(request: HTTPRequest, _ response: HTTPResponse) {
		let articles = Page(connect!)

		// save component...
		var user = AuthAccount(connect!)
		if request.method == .post {
			user.uniqueID = ""
			user = BlogAdmin.saveUserData(request, response, user: user)
		}
		// end save compoennt


		let context: [String : Any] = [
			"accountID": request.user.authDetails?.account.uniqueID ?? "",
			"authenticated": request.user.authenticated,
			"title": site.config["title"] as! String,
			"menu": site.config["menu"] as! [Any],
			"pagename": "New User",
			"components": BlogAdmin.componentList(0),
			"articles": articles.getArticles(),

			"username": user.username,
			"email": user.email,
			"firstname": user.firstname,
			"lastname": user.lastname

		]

		response.render(template: "admin/useredit", context: context)

	}

	static func userAdminEdit(request: HTTPRequest, _ response: HTTPResponse) {

		let articles = Page(connect!)

		var user = AuthAccount(connect!)
		let id = request.urlVariables["id"] ?? ""
		do {
			try user.get(id)
		} catch {
			print("Edit user id \(id) error - cannot load user: \(error)")
		}

		// save component...
		if request.method == .post {
			user = BlogAdmin.saveUserData(request, response, user: user)
		}
		// end save compoennt


		let context: [String : Any] = [
			"accountID": request.user.authDetails?.account.uniqueID ?? "",
			"authenticated": request.user.authenticated,
			"title": site.config["title"] as! String,
			"menu": site.config["menu"] as! [Any],
			"pagename": "Edit User",
			"components": BlogAdmin.componentList(0),
			"articles": articles.getArticles(),

			"username": user.username,
			"email": user.email,
			"firstname": user.firstname,
			"lastname": user.lastname
		]
		response.render(template: "admin/useredit", context: context)

	}

	static func userAdminDelete(request: HTTPRequest, _ response: HTTPResponse) {

		let user = AuthAccount(connect!)
		let id = request.urlVariables["id"] ?? ""
		do {
			try user.delete(id)
		} catch {
			print("Deleting user id \(id) error - cannot delete user: \(error)")
		}

		BlogAdmin.returnToUserList(request: request, response)
		
	}



}
