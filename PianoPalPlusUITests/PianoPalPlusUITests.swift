//
//  PianoPalPlusUITests.swift
//  PianoPalPlusUITests
//
//  Created by joshua on 1/1/20.
//  Copyright © 2020 joshua. All rights reserved.
//

import XCTest

class PianoPalPlusUITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        app.buttons["lock"].tap()
        
        let element = app.scrollViews.children(matching: .other).element.children(matching: .other).element(boundBy: 3)
        element.children(matching: .other).element(boundBy: 1).tap()
        element.children(matching: .other).element(boundBy: 5).tap()
        element.children(matching: .other).element(boundBy: 8).tap()
        app.buttons["square.stack.3d.down.dottedline"].tap()
        app.buttons["arrow.right.arrow.left"].tap()
        
        // free play
        snapshot("freePlay")
        
        app.buttons["gear"].tap()
        var tablesQuery = app.tables
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["practice ear training"]/*[[".cells.staticTexts[\"practice ear training\"]",".staticTexts[\"practice ear training\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["interval"]/*[[".cells.staticTexts[\"interval\"]",".staticTexts[\"interval\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.buttons["play"].tap()
        sleep(4) // hack to wait for dismissing animation
        
        // interval training
        snapshot("intervalTraining")
        
        
        let gearButton = app.buttons["gear"]
        gearButton.tap()
        
        tablesQuery = app.tables
        let practiceEarTrainingStaticText = tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["practice ear training"]/*[[".cells.staticTexts[\"practice ear training\"]",".staticTexts[\"practice ear training\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        practiceEarTrainingStaticText.tap()
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["chord type"]/*[[".cells.staticTexts[\"chord type\"]",".staticTexts[\"chord type\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        sleep(4)
        // chord training
        snapshot("chordTraining")
        

        gearButton.tap()
        practiceEarTrainingStaticText.tap()
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["key"]/*[[".cells.staticTexts[\"key\"]",".staticTexts[\"key\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        sleep(4)
        // key training
        snapshot("keyTraining")
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testLaunchPerformance() {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
                XCUIApplication().launch()
            }
        }
    }
}
