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
        super.setUp()
        continueAfterFailure = false
        app.launch()
    }

    var gifCollectionView: XCUIElement {
        let collectionView = app.collectionViews["GifsCollectionViewController.collectionView"]
        XCTAssertTrue(collectionView.exists)
        return collectionView
    }
    
    var addGifButton: XCUIElement {
        let button = app.buttons["GifsCollectionViewController.addButton"]
        XCTAssertTrue(button.exists)
        return button
    }
    
    var gifEditImageView: XCUIElement {
        let imageView = app.images["GifEditViewController.imageView"]
        XCTAssertTrue(imageView.exists)
        return imageView
    }
    
    func testAddButtonDisplayProperly() {
        XCTAssertTrue(addGifButton.isHittable)
        XCTAssertTrue(addGifButton.isEnabled)
    }
    
    func testAddButtonDisplayImagePicker() {
        addGifButton.tap()
        XCTAssertTrue(app.navigationBars["Moments"].otherElements["Moments"].isHittable)
    }
    
    func testImagePickerCanPickVideo() {
        addGifButton.tap()
        XCTAssertTrue(app.navigationBars["Moments"].otherElements["Moments"].isHittable)
        sleep(3)
        let cell = app.collectionViews.element(boundBy: 0).cells.element(boundBy: 0)
        XCTAssertTrue(cell.isHittable)
        cell.tap()
        sleep(3)
        let choose = app.buttons.element(boundBy: 2)
        XCTAssertTrue(choose.isHittable)
        XCTAssertTrue(choose.isEnabled)
    }
    
    func testChoosingVideoPresentEditVC() {
        addGifButton.tap()
        XCTAssertTrue(app.navigationBars["Moments"].otherElements["Moments"].isHittable)
        sleep(3)
        let cell = app.collectionViews.element(boundBy: 0).cells.element(boundBy: 0)
        XCTAssertTrue(cell.isHittable)
        cell.tap()
        sleep(3)
        let choose = app.buttons.element(boundBy: 2)
        XCTAssertTrue(choose.isHittable)
        XCTAssertTrue(choose.isEnabled)
        
        choose.tap()
        sleep(15)
        XCTAssertTrue(gifEditImageView.exists)
    }
    
    func testSelectCollectionCellPresentActionSheet() {
        let cell1 = gifCollectionView.cells.firstMatch
        cell1.tap()
        
        sleep(3)
        XCTAssertTrue(app.sheets.firstMatch.isHittable)
    }

}
