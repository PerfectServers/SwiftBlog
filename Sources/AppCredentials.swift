//
//  AppCredentials.swift
//  PerfectAuthTemplate-PostgreSQL
//
//  Created by Jonathan Guthrie on 2016-11-12.
//
//

import PerfectLib

import StORM
import PostgresStORM

import JSONConfig



struct AppCredentials {
	var clientid = ""
	var clientsecret = ""
}

func makeCreds() {
	if let config = JSONConfig(name: "\(fileRoot)ApplicationConfiguration.json") {
		let dict = config.getValues()!
		httpPort = dict["httpport"] as! Int
		connect = PostgresConnect(
			host:		dict["postgreshost"] as! String,
			username:	dict["postgresuser"] as! String,
			password:	dict["postgrespwd"] as! String,
			database:	dict["postgresdbname"] as! String,
			port:		dict["postgresport"] as! Int
		)
	} else {
		print("Unable to get Configuration")
		connect = PostgresConnect(
			host: "localhost",
			username: "perfect",
			password: "perfect",
			database: "perfect_testing",
			port: 5432
		)

	}

}
