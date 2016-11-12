//
//  Pages.swift
//  SwiftBlog
//
//  Created by Jonathan Guthrie on 2016-11-12.
//
//

import StORM
import PostgresStORM

class Page: PostgresStORM {
	var id			= 0
	var name		= ""
	var url			= ""					// sliugified name by default
	var config		= [String: Any]()		// page level config
	var state		= false					// visible, not visible

	// Set the table name
	override open func table() -> String {
		return "page"
	}

	// Need to do this because of the nature of Swift's introspection
	override func to(_ this: StORMRow) {
		id			= this.data["id"] as? Int ?? 0
		name		= this.data["name"] as! String
		url			= this.data["url"] as! String
		if let configObj = this.data["config"] {
			do {
				try self.config = ((configObj as? String ?? "").jsonDecode() as? [String:Any])!
			} catch {
				print("Error decoding component config (\(id)): \(error)")
			}
		}
		if let stateObj = this.data["state"] {
			if stateObj == "false" {
				state = false
			} else {
				state = true
			}
		}
	}

	func rows() -> [Page] {
		var rows = [Page]()
		for i in 0..<self.results.rows.count {
			let row = Page()
			row.to(self.results.rows[i])
			rows.append(row)
		}
		return rows
	}

}
