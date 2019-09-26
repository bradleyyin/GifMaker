//
//  GiftEditViewControllerTests.swift
//  GifMakerTests
//
//  Created by Bradley Yin on 9/26/19.
//  Copyright © 2019 bradleyyin. All rights reserved.
//

import Foundation
import XCTest
@testable import GifMaker

class GiftEditViewControllerTests: XCTestCase {
    func testGenerateImages() {
        let gifEditViewController = GifEditViewController()
        let url = URL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")!
        let images = gifEditViewController.generateImages(url: url)
        XCTAssertTrue(images.count == 901)
    }
    func testGenerateGifFromImages() {
        let gifEditViewController = GifEditViewController()
        gifEditViewController.gifController = GifController()
        gifEditViewController.gifController?.gifs = []
        let url = URL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")!
        let images = gifEditViewController.generateImages(url: url)
        let didFinished = expectation(description: "didFinished")
        var appedingURL = ""
        gifEditViewController.generateGifFromImages(images: images, completion: { url in
            appedingURL = url
            didFinished.fulfill()
        })
        wait(for: [didFinished], timeout: 30)
        XCTAssertTrue(appedingURL.contains("animated.gif"))
    }
    
    func testAnimatedGif() {
        let gifEditViewController = GifEditViewController()
        gifEditViewController.gifController = GifController()
        gifEditViewController.gifController?.gifs = []
        let url = URL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")!
        let images = gifEditViewController.generateImages(url: url)
        let urlString = CGImage.animatedGif(from: images, fps: 15)!
        XCTAssertTrue(urlString.contains("animated.gif"))
    }

    func testGenerateGif() {
        let gifEditViewController = GifEditViewController()
        gifEditViewController.gifController = GifController()
        gifEditViewController.gifController?.gifs = []
        let didFinished = expectation(description: "didFinished")
        let url = URL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")!
        gifEditViewController.generateGif(url: url) {
            didFinished.fulfill()
        }
        wait(for: [didFinished], timeout: 30)
        XCTAssertTrue(gifEditViewController.tempGifURL.contains("animated.gif"))
    }
}
