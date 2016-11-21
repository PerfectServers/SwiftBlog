import PerfectHTTP
import PerfectTurnstilePostgreSQL

// This function creates the routes
// Handlers are in Handlers.swift

public func makeAdminRoutes() -> Routes {
	var routes = Routes()

	routes.add(method: .get, uri: "/admin/login", handler: BlogAdmin.makeLogin)
	routes.add(method: .get, uri: "/admin/logout", handler: AuthHandlersWeb.logoutHandler)


	// Site
	routes.add(method: .get, uri: "/admin/site", handler: BlogAdmin.siteAdmin)
	routes.add(method: .post, uri: "/admin/site", handler: BlogAdmin.siteAdmin)

	routes.add(method: .get, uri: "/admin/social", handler: BlogAdmin.siteSocial)
	routes.add(method: .post, uri: "/admin/social", handler: BlogAdmin.siteSocial)


	// Pages
	routes.add(method: .get, uri: "/admin/pages", handler: BlogAdmin.pagesAdmin)
	routes.add(method: .post, uri: "/admin/pages/saveorder", handler: BlogAdmin.pagesAdminSaveOrder)

	routes.add(method: .get, uri: "/admin/pages/new", handler: BlogAdmin.pagesAdminCreate)
	routes.add(method: .post, uri: "/admin/pages/new", handler: BlogAdmin.pagesAdminCreate)

	routes.add(method: .get, uri: "/admin/pages/{id}/edit", handler: BlogAdmin.pagesAdminEdit)
	routes.add(method: .post, uri: "/admin/pages/{id}/edit", handler: BlogAdmin.pagesAdminEdit)
	routes.add(method: .post, uri: "/admin/pages/{id}/save", handler: BlogAdmin.pagesAdminSaveContent)

	routes.add(method: .get, uri: "/admin/pages/{id}/delete", handler: BlogAdmin.pagesAdminDelete)
	routes.add(method: .post, uri: "/admin/pages/{id}/delete", handler: BlogAdmin.pagesAdminDelete)

	routes.add(method: .get, uri: "/admin/pages/{id}/toggle", handler: BlogAdmin.pagesAdminToggle)


	// Users
	routes.add(method: .get, uri: "/admin/users", handler: BlogAdmin.userAdmin)
	routes.add(method: .post, uri: "/admin/users", handler: BlogAdmin.userAdmin)

	routes.add(method: .get, uri: "/admin/users/new", handler: BlogAdmin.userAdminCreate)
	routes.add(method: .post, uri: "/admin/users/new", handler: BlogAdmin.userAdminCreate)

	routes.add(method: .get, uri: "/admin/users/{id}/edit", handler: BlogAdmin.userAdminEdit)
	routes.add(method: .post, uri: "/admin/users/{id}/edit", handler: BlogAdmin.userAdminEdit)

	routes.add(method: .get, uri: "/admin/users/{id}/delete", handler: BlogAdmin.userAdminDelete)
	routes.add(method: .post, uri: "/admin/users/{id}/delete", handler: BlogAdmin.userAdminDelete)
	

	return routes
}
