//
//  Components.swift
//  SwiftBlog
//
//  Created by Jonathan Guthrie on 2016-11-12.
//
//

import StORM
import PostgresStORM

class Component: PostgresStORM {
	var id			= 0
	var pageid		= 0
	var spot		= ""					// the spot it slots into
	var config		= [String: Any]()		// component level config
	var content		= ""

	// Set the table name
	override open func table() -> String {
		return "component"
	}

	override func to(_ this: StORMRow) {
		id			= this.data["id"] as? Int ?? 0
		pageid		= this.data["pageid"] as? Int ?? 0
		spot		= this.data["spot"] as! String
		if let configObj = this.data["config"] {
			self.config = (configObj as? [String:Any])!
		}
		content		= this.data["content"] as! String
	}

	func rows() -> [Component] {
		var rows = [Component]()
		for i in 0..<self.results.rows.count {
			let row = Component()
			row.to(self.results.rows[i])
			rows.append(row)
		}
		return rows
	}

}
