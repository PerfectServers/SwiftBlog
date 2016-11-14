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
			self.config = (configObj as? [String:Any])!
//			do {
//				try self.config = ((configObj as? String ?? "").jsonDecode() as? [String:Any])!
//			} catch {
//				print("Error decoding component config (\(id)): \(error)")
//			}
		}
		if let stateObj = this.data["state"] {
			if stateObj as! Bool == false {
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

	func getArticles() -> [[String: Any]] {
		//config @> '{"type":"article"}'::jsonb
		try? select(whereclause: "config @> '{\"type\":\"article\"}'::jsonb", params: [], orderby: ["id"])
		var articleArray = [[String: Any]]()

		for row in rows() {
			var r = [String: Any]()
			r["name"] = row.name
			r["url"] = row.url
			if let datepublished = row.config["datepublished"] {
				r["datepublished"] = datepublished as! String
			}
			if let subhead = row.config["subhead"] {
				r["subhead"] = subhead as! String
			}
			if let intro = row.config["intro"] {
				r["intro"] = intro as! String
			}
			if let tags = row.config["tags"] {
				r["tags"] = (tags as? [Any])!
			}

//			r["config"] = row.config
			articleArray.append(r)
		}
		
		return articleArray

		
	}

	func getPage(link: String, isArticle: Bool) -> [String: Any] {
		var article = [String: Any]()

		var whereclause = [String]()
		var params = [String]()
		let cursor = StORMCursor(limit: 1, offset: 0)
		if isArticle == true {
			whereclause.append("config @> '{\"type\":\"article\"}'::jsonb")
		}
		if link.isEmpty == false {
			whereclause.append("url = $1")
			params.append(link)
		}

		try? select(whereclause: whereclause.joined(separator: " AND "), params: params, orderby: ["id DESC"], cursor: cursor)

		if results.cursorData.totalRecords == 0 {
			return article
		}

		for row in rows() {
			// only ever max 1
			article["id"] = row.id
			article["name"] = row.name
			article["url"] = row.url
			if let datepublished = row.config["datepublished"] {
				article["datepublished"] = datepublished as! String
			}
			if let subhead = row.config["subhead"] {
				article["subhead"] = subhead as! String
			}
			if let tags = row.config["tags"] {
				article["tags"] = (tags as? [Any])!
			}

			// get components
			let components = Component(connect!)
			try? components.select(whereclause: "pageid = $1", params: [row.id], orderby: [])
			var cRowData = [[String: Any]]()
			for cRow in components.rows() {
				var thisRow = [String: Any]()
				thisRow["spot"] = cRow.spot
				thisRow["config"] = cRow.config
				thisRow["content"] = cRow.content
				cRowData.append(["\(cRow.spot)?": thisRow])
			}
			article["components"] = cRowData
		}

		return article
		
		
	}



}
