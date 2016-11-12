//
//  main.swift
//  PerfectAuthTemplate
//	PostgreSQL version
//
//  Created by Jonathan Guthrie on 2016-11-12.
//	Copyright (C) 2015 PerfectlySoft, Inc.
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Perfect.org open source project
//
// Copyright (c) 2015 - 2016 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
//

import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

import StORM
import PostgresStORM
import PerfectTurnstilePostgreSQL


let pturnstile = TurnstilePerfectRealm()

let webRoot = "./webroot"
#if os(Linux)
	let fileRoot = "/perfect-deployed/perfectauthtemplate-postgresql/"
	var httpPort = 80
#else
	let fileRoot = ""
	var httpPort = 8181
#endif

let apiRoute = "/api/v1/"

// set up creds
makeCreds()


// Set up the Authentication table
let auth = AuthAccount(connect!)
auth.setup()

// Connect the AccessTokenStore
tokenStore = AccessTokenStore(connect!)
tokenStore?.setup()


// Create HTTP server.
let server = HTTPServer()

// Register authentication routes and handlers
let authWebRoutes = makeWebAuthRoutes()
//let authJSONRoutes = makeJSONAuthRoutes(apiRoute)

// Add the routes to the server.
server.addRoutes(authWebRoutes)
//server.addRoutes(authJSONRoutes)


// Register your own routes and handlers
var routes = Routes()
routes.add(method: .get, uri: "/", handler: {
		request, response in
		response.setHeader(.contentType, value: "text/html")
		response.appendBody(string: "<html><title>Hello, world!</title><body>Hello, world!</body></html>")
		response.completed()
	}
)

// Add the routes to the server.
server.addRoutes(routes)

// add routes to be checked for auth
var authenticationConfig = AuthenticationConfig()
//authenticationConfig.include("/api/v1/check")
authenticationConfig.exclude("/login")
authenticationConfig.exclude("/register")

let authFilter = AuthFilter(authenticationConfig)

// Note that order matters when the filters are of the same priority level
server.setRequestFilters([pturnstile.requestFilter])
server.setResponseFilters([pturnstile.responseFilter])

server.setRequestFilters([(authFilter, .high)])



// Set a listen port
server.serverPort = UInt16(httpPort)

// Set a document root.
// This is optional. If you do not want to serve static content then do not set this.
// Setting the document root will automatically add a static file handler for the route /**
server.documentRoot = webRoot


do {
	// Launch the HTTP server.
	try server.start()
} catch PerfectError.networkError(let err, let msg) {
	print("Network error thrown: \(err) \(msg)")
}
