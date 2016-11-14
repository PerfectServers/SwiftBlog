//
//  Setup.swift
//  SwiftBlog
//
//  Created by Jonathan Guthrie on 2016-11-12.
//
//

import PerfectTurnstilePostgreSQL
import PostgresStORM

let site = Site(connect!)
func setupSystem() {
	// Set up the Authentication table
	let auth = AuthAccount(connect!)
	auth.setup()

	// Connect the AccessTokenStore
	tokenStore = AccessTokenStore(connect!)
	tokenStore?.setup()

	// Page table
	let page = Page(connect!)
	try? page.setupTable()

	// Component table
	let component = Component(connect!)
	try? component.setupTable()

	// Site table... also sets up site vars
	try? site.setupTable()
	site.getSiteInfo()

}
