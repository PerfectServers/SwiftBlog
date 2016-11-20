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
	var id				= 0
	var name			= ""
	var url				= ""					// slugified name by default
	var config			= [String: Any]()		// page level config
	var state			= false					// visible, not visible
	var displayorder	= 0

	// Set the table name
	override open func table() -> String {
		return "page"
	}

	// Need to do this because of the nature of Swift's introspection
	override func to(_ this: StORMRow) {
		id				= this.data["id"] as? Int ?? 0
		name			= this.data["name"] as! String
		url				= this.data["url"] as! String
		displayorder	= this.data["displayorder"] as? Int ?? 0
		if let configObj = this.data["config"] {
			self.config = (configObj as? [String:Any])!
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
		try? select(whereclause: "config @> '{\"type\":\"article\"}'::jsonb AND state = $1", params: ["true"], orderby: ["displayorder","id"])
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

			articleArray.append(r)
		}
		
		return articleArray

		
	}

	func getPage(link: String, isArticle: Bool) -> [String: Any] {
		var article = [String: Any]()

		var whereclause = [String]()
		var params = [String]()
		let cursor = StORMCursor(limit: 1, offset: 0)

//		whereclause.append("state = $1")
//		params.append("true")

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
			if let script = row.config["script"] {
				article["script"] = script as! String
			}
			if let heroimage = row.config["heroimage"] {
				article["heroimage?"] = ["content":heroimage]
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

	func getPageData() -> [String: Any] {
		var article = [String: Any]()
		let foundRows = rows()
		if foundRows.count == 0 {

			article["name"] = "Page not found"

		} else {
			for row in foundRows {
				// only ever max 1
				article["id"] = row.id
				article["name"] = row.name
				article["url"] = row.url
				if let datepublished = row.config["datepublished"] {
					article["datepublished"] = datepublished as! String
				}
				if let script = row.config["script"] {
					article["script"] = script as! String
				}
				var heroimagealt = ""
				if let heroimagealtt = row.config["heroimagealt"] {
					heroimagealt = heroimagealtt as! String
				}

				if let heroimage = row.config["heroimage"] {
					article["heroimage?"] = ["image":heroimage, "alt":heroimagealt]
				}

				if let subhead = row.config["subhead"] {
					article["subhead"] = subhead as! String
				}
				if let tags = row.config["tags"] {
					article["tags"] = (tags as? [Any])!
				}

				// get components
				var gotBody = false
				let components = Component(connect!)
				try? components.select(whereclause: "pageid = $1", params: [row.id], orderby: [])
				var cRowData = [[String: Any]]()
				for cRow in components.rows() {
					var thisRow = [String: Any]()
					thisRow["spot"] = cRow.spot
					thisRow["config"] = cRow.config
					thisRow["content"] = cRow.content
					if cRow.spot == "body" {
						gotBody = true
					}
					cRowData.append(["\(cRow.spot)?": thisRow])
				}
				if gotBody == false {
					var r = [String: Any]()
					r["body?"] = ["content":""]
					cRowData.append(r)
				}
				article["components"] = cRowData
			}
		}

		return article
		
		
	}


	func pageList() -> [[String: Any]] {
		//config @> '{"type":"article"}'::jsonb
		try? select(whereclause: "", params: [], orderby: ["displayorder","id DESC"])
		var pageArray = [[String: Any]]()

		for row in rows() {
			var r = [String: Any]()
			r["id"] = row.id
			r["name"] = row.name
			if row.url.startsWith("/") {
				r["url"] = row.url
			} else {
				r["url"] = "/\(row.url)"
			}
			if row.state == true { r["state"] = "Active" } else { r["state"] = "Inactive" }
			if let datepublished = row.config["datepublished"] {
				r["datepublished"] = datepublished as! String
			} else {
				r["datepublished"] = ""
			}
			if let type = row.config["type"] {
				r["type"] = type as! String
			} else {
				r["type"] = "unspecified"
			}

			pageArray.append(r)
		}
		return pageArray
	}
	


}
