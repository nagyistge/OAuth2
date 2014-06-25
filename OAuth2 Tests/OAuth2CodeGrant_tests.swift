//
//  OAuth2CodeGrant.swift
//  OAuth2
//
//  Created by Pascal Pfiffner on 6/18/14.
//  Copyright (c) 2014 Pascal Pfiffner. All rights reserved.
//

import XCTest
import OAuth2


class OAuth2CodeGrantTests: XCTestCase {
	
	func testInit() {
		//var oauth = OAuth2(settings: NSDictionary())		// TODO: how to test that this raises?
		
		var oauth = OAuth2CodeGrant(settings: [
			"client_id": "abc",
			"client_secret": "xyz",
			"verbose": 1,
			"authorize_uri": "https://auth.ful.io",
			"token_uri": "https://token.ful.io",
			"api_uri": "https://api.ful.io",
		])
		XCTAssertEqualObjects(oauth.clientId, "abc", "Must init `client_id`")
		XCTAssertEqualObjects(oauth.clientSecret, "xyz", "Must init `client_secret`")
		XCTAssertTrue(oauth.verbose, "Set to verbose")
		XCTAssertNil(oauth.scope, "Empty scope")
		
		XCTAssertEqualObjects(oauth.authURL, NSURL(string: "https://auth.ful.io"), "Must init `authorize_uri`")
		XCTAssertEqualObjects(oauth.tokenURL, NSURL(string: "https://token.ful.io"), "Must init `token_uri`")
		XCTAssertEqualObjects(oauth.apiURL, NSURL(string: "https://api.ful.io"), "Must init `api_uri`")
	}
	
	func testAuthorizeURI() {
		var oauth = OAuth2CodeGrant(settings: [
			"client_id": "abc",
			"client_secret": "xyz",
			"authorize_uri": "https://auth.ful.io",
			"token_uri": "https://token.ful.io",
			"api_uri": "https://api.ful.io",
		])
		
		XCTAssertNotNil(oauth.authURL, "Must init `authorize_uri`")
		let comp = NSURLComponents(URL: oauth.authorizeURLWithRedirect("oauth2://callback", scope: nil, params: nil), resolvingAgainstBaseURL: true)
		XCTAssertEqualObjects(comp.host, "auth.ful.io", "Correct host")
		let query = OAuth2CodeGrant.paramsFromQuery(comp.query)
		XCTAssertEqualObjects(query["client_id"], "abc", "Expecting correct `client_id`")
		XCTAssertNil(query["client_secret"], "Must not have `client_secret`")
		XCTAssertEqualObjects(query["response_type"], "code", "Expecting correct `response_type`")
		XCTAssertEqualObjects(query["redirect_uri"], "oauth2://callback", "Expecting correct `redirect_uri`")
		XCTAssertTrue(36 == query["state"]?.utf16count, "Expecting an auto-generated UUID for `state`")
		
		// TODO: test for non-https URLs (must raise)
	}
	
	func testTokenURI() {
		var oauth = OAuth2CodeGrant(settings: [
			"client_id": "abc",
			"client_secret": "xyz",
			"authorize_uri": "https://auth.ful.io",
			"token_uri": "https://token.ful.io",
			"api_uri": "https://api.ful.io",
		])
		
		XCTAssertNotNil(oauth.tokenURL, "Must init `token_uri`")
		let comp = NSURLComponents(URL: oauth.tokenURLWithRedirect("oauth2://callback", code: "pp", params: nil), resolvingAgainstBaseURL: true)
		XCTAssertEqualObjects(comp.host, "token.ful.io", "Correct host")
		
		let query = OAuth2CodeGrant.paramsFromQuery(comp.query)
		XCTAssertEqualObjects(query["client_id"], "abc", "Expecting correct `client_id`")
		XCTAssertEqualObjects(query["client_secret"], "xyz", "Expecting correct `client_secret`")
		XCTAssertEqualObjects(query["code"], "pp", "Expecting correct `code`")
		XCTAssertEqualObjects(query["grant_type"], "authorization_code", "Expecting correct `grant_type`")
		XCTAssertEqualObjects(query["redirect_uri"], "oauth2://callback", "Expecting correct `redirect_uri`")
		XCTAssertTrue(36 == query["state"]?.utf16count, "Expecting an auto-generated UUID for `state`")
		
		// test authURL fallback
		oauth = OAuth2CodeGrant(settings: [
			"client_id": "abc",
			"client_secret": "xyz",
			"authorize_uri": "https://auth.ful.io",
			"api_uri": "https://api.ful.io",
		])
		let comp2 = NSURLComponents(URL: oauth.tokenURLWithRedirect("oauth2://callback", code: "pp", params: nil), resolvingAgainstBaseURL: true)
		XCTAssertEqualObjects(comp2.host, "auth.ful.io", "Correct host")
		
		// TODO: test for non-https URLs (must raise)
	}
	
	func testTokenRequest() {
		var oauth = OAuth2CodeGrant(settings: [
			"client_id": "abc",
			"client_secret": "xyz",
			"authorize_uri": "https://auth.ful.io",
			"token_uri": "https://token.ful.io",
			"api_uri": "https://api.ful.io",
		])
		oauth.redirect = "oauth2://callback"
		
		let req = oauth.tokenRequest("pp")
		let body = NSString(data: req.HTTPBody, encoding: NSUTF8StringEncoding)
		let query = OAuth2CodeGrant.paramsFromQuery(body)
		XCTAssertEqualObjects(query["client_id"], "abc", "Expecting correct `client_id`")
		XCTAssertEqualObjects(query["client_secret"], "xyz", "Expecting correct `client_secret`")
		XCTAssertEqualObjects(query["code"], "pp", "Expecting correct `code`")
		XCTAssertEqualObjects(query["grant_type"], "authorization_code", "Expecting correct `grant_type`")
		XCTAssertEqualObjects(query["redirect_uri"], "oauth2://callback", "Expecting correct `redirect_uri`")
		XCTAssertTrue(36 == query["state"]?.utf16count, "Expecting an auto-generated UUID for `state`")
	}

    /*func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }*/
}