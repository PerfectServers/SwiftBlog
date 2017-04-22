//
//  Setup.swift
//  SwiftBlog
//
//  Created by Jonathan Guthrie on 2016-11-12.
//
//

import PerfectTurnstilePostgreSQL
import PostgresStORM
import TurnstileCrypto
import Turnstile

let site = Site()
func setupSystem() {
	// Set up the Authentication table
	let auth = AuthAccount()
	auth.setup()

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

extension AuthAccount {
	func setup() {
		do {
			try super.setup()
			try findAll()
			if rows().count == 0 {
				let r = URandom()
				let p = r.secureToken
				id(r.secureToken)
				username = "Admin"
				password = BCrypt.hash(password: p)
				print("No user accounts, createing default login 'Admin' with password '\(p)'")
				try create()
			}
		} catch {
			print("Error: \(error)")
		}
	}
}
