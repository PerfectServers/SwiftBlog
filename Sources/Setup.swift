//
//  Setup.swift
//  SwiftBlog
//
//  Created by Jonathan Guthrie on 2016-11-12.
//
//

import PerfectTurnstilePostgreSQL
import PostgresStORM

let site = Site()
func setupSystem() {
	// Set up the Authentication table
	let auth = AuthAccount()
	try? auth.setup()

	// Connect the AccessTokenStore
	tokenStore = AccessTokenStore()
	try? tokenStore?.setup()

	// Page table
	let page = Page()
	try? page.setupTable()

	// Component table
	let component = Component()
	try? component.setupTable()

	// Site table... also sets up site vars
	try? site.setupTable()
	site.getSiteInfo()

}
