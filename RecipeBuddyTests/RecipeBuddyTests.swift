//
//  RecipeBuddyTests.swift
//  RecipeBuddyTests
//
//  Created by rostadhi akbar on 14/08/25.
//

import XCTest
@testable import RecipeBuddy


final class RecipeBuddyTests: XCTestCase {

    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }

    func testExample() throws {
        //MARK: - Check the json file
        guard let url = Bundle.main.url(forResource: "Recipe", withExtension: "json") else {
            XCTFail("File not found")
            return
        }
        
        //MARK: - Check the data
        let data = try Data(contentsOf: url)
        XCTAssertFalse(data.isEmpty, "data cannot empty")
        
        //MARK: - Testing decode
        let decoder = JSONDecoder()
        let decodeRecipe = try decoder.decode([RecipeModel].self, from: data)
        
        XCTAssertGreaterThan(decodeRecipe.count, 0)
        
        let firstRecipe = decodeRecipe[0]
        XCTAssertNotNil(firstRecipe.imageURL, "image URL should not be nil")
        XCTAssertFalse(firstRecipe.ingredients.isEmpty, "ingredient should exist")
        XCTAssertFalse(firstRecipe.title.isEmpty, "title should exist")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
