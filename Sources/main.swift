//
//  main.swift
//  SwiftBlog
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
import PerfectLogger

import StORM
import PostgresStORM
import PerfectTurnstilePostgreSQL
import PerfectRequestLogger
import TurnstilePerfect

//StORMdebug = true

let pturnstile = TurnstilePerfectRealm()

let webRoot = "./webroot"

LogFile.location = "./log.txt"

LogFile.info("Starting SwiftBlog")

#if os(Linux)
	let fileRoot = "/perfect-deployed/swiftblog/"
	var httpPort = 80
#else
	let fileRoot = ""
	var httpPort = 8181
	RequestLogFile.location = "./webLog.log"
#endif

LogFile.info("httpPort: \(httpPort)")


let apiRoute = "/api/v1/"

// set up creds
makeCreds()
setupSystem()

// Create HTTP server.
let server = HTTPServer()

// Register authentication routes and handlers
let authWebRoutes = makeWebAuthRoutes()

// Add the routes to the server.
server.addRoutes(authWebRoutes)
server.addRoutes(makeRoutes())
server.addRoutes(makeAdminRoutes())


let httplogger = RequestLogger()

server.setRequestFilters([(httplogger, .high)])
server.setResponseFilters([(httplogger, .low)])



// add routes to be checked for auth
var authenticationConfig = AuthenticationConfig()
//authenticationConfig.include("/api/v1/check")
authenticationConfig.include("/admin/*")
authenticationConfig.exclude("/admin/login")
authenticationConfig.exclude("/admin/register")

let authFilter = AuthFilter(authenticationConfig)

// Note that order matters when the filters are of the same priority level
server.setRequestFilters([pturnstile.requestFilter])
server.setResponseFilters([pturnstile.responseFilter])
server.setRequestFilters([(authFilter, .high)])



// Set a listen port
server.serverPort = UInt16(httpPort)

// Set a document root.
server.documentRoot = webRoot


do {
	LogFile.info("HTTP Server starting")
	// Launch the HTTP server.
	try server.start()
} catch PerfectError.networkError(let err, let msg) {
	print("Network error thrown: \(err) \(msg)")
}
