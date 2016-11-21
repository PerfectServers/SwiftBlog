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

	routes.add(method: .get, uri: "/", handler: PageHandlers.makeHome)
	routes.add(method: .get, uri: "/{pageid}", handler: PageHandlers.makePage)
	routes.add(method: .get, uri: "/tag/{tag}", handler: PageHandlers.makeTagPage)

	return routes
}
