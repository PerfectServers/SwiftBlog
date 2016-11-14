//
//  Site.swift
//  SwiftBlog
//
//  Created by Jonathan Guthrie on 2016-11-12.
//
//

import StORM
import PostgresStORM
import PerfectLib

class Site: PostgresStORM {
	var id			= 0
	var url			= ""					// base URL of system
	var config		= [String: Any]()		// site level config

	// Set the table name
	override open func table() -> String {
		return "site"
	}

	// Need to do this because of the nature of Swift's introspection
	override func to(_ this: StORMRow) {
		id			= this.data["id"] as? Int ?? 0
		url			= this.data["url"] as! String

		config["opt"] = "x"
		config["donkey"] = "kong"

		if let configObj = this.data["config"] {
			self.config = (configObj as? [String:Any])!
		}
	}

	func rows() -> [Site] {
		var rows = [Site]()
		for i in 0..<self.results.rows.count {
			let row = Site()
			row.to(self.results.rows[i])
			rows.append(row)
		}
		return rows
	}

	func getSiteInfo() {
		let cursor = StORMCursor(limit: 1, offset: 0)
		try? select(whereclause: "id > $1", params: [0], orderby: ["id DESC"], cursor: cursor)
		print(url)
	}
}
