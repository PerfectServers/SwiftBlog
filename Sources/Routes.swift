//
//  Routes.swift
//  SwiftBlog
//
//  Created by Jonathan Guthrie on 2016-11-12.
//
//

import PerfectHTTP
import PerfectTurnstilePostgreSQL

// This function creates the routes
// Handlers are in Handlers.swift

public func makeRoutes() -> Routes {
	var routes = Routes()

	routes.add(method: .get, uri: "/", handler: makeHome)
	routes.add(method: .get, uri: "/admin/login", handler: makeLogin)
	routes.add(method: .get, uri: "/admin/logout", handler: AuthHandlersWeb.logoutHandler)
	routes.add(method: .get, uri: "/{pageid}", handler: makePage)
//	routes.add(method: .get, uri: "/app/news/{id}", handler: getWebNewsDetail)

	return routes
}
