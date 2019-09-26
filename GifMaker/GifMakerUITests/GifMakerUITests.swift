//
//  GifMakerUITests.swift
//  GifMakerUITests
//
//  Created by Bradley Yin on 9/25/19.
//  Copyright © 2019 bradleyyin. All rights reserved.
//

import XCTest

class GifMakerUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

//    var gifCollectionView: XCUIElement {
//        let collectionView = 
//    }

}
