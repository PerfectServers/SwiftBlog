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

		PostgresConnector.host			= dict["postgreshost"] as! String
		PostgresConnector.username		= dict["postgresuser"] as! String
		PostgresConnector.password		= dict["postgrespwd"] as! String
		PostgresConnector.database		= dict["postgresdbname"] as! String
		PostgresConnector.port			= dict["postgresport"] as! Int

	} else {
		print("Unable to get Configuration")

		PostgresConnector.host			= "localhost"
		PostgresConnector.username		= "perfect"
		PostgresConnector.password		= "perfect"
		PostgresConnector.database		= "perfect_testing"
		PostgresConnector.port			= 5432

	}

}
