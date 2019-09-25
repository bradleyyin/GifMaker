//
//  GifCollectionViewControllerTests.swift
//  GifMakerTests
//
//  Created by Bradley Yin on 9/25/19.
//  Copyright © 2019 bradleyyin. All rights reserved.
//

import Foundation
import XCTest
@testable import GifMaker

class GifCollectionViewControllerTests: XCTestCase {
    func testGifControllerSucessfulInit() {
        let gifCollectionViewController = GifsCollectionViewController()
        XCTAssertTrue(gifCollectionViewController.gifController.gifs.count >= 0) 
    }
    func testGenerateImages() {
        let gifCollectionViewController = GifsCollectionViewController()
        let url = URL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")!
        let images = gifCollectionViewController.generateImages(url: url)
        XCTAssertTrue(images.count == 901)
    }
    func testGenerateGifFromImages() {
        let gifCollectionViewController = GifsCollectionViewController()
        gifCollectionViewController.gifController.gifs = []
        let url = URL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")!
        let images = gifCollectionViewController.generateImages(url: url)
        let didFinished = expectation(description: "didFinished")
        gifCollectionViewController.generateGifFromImages(images: images, completion: {
            didFinished.fulfill()
        })
        wait(for: [didFinished], timeout: 30)
        XCTAssertEqual(1, gifCollectionViewController.gifController.gifs.count)
    }
    
    func testAnimatedGif() {
        let gifCollectionViewController = GifsCollectionViewController()
        gifCollectionViewController.gifController.gifs = []
        let url = URL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")!
        let images = gifCollectionViewController.generateImages(url: url)
        let urlString = CGImage.animatedGif(from: images, fps: 15)!
        XCTAssertTrue(urlString.contains("animated.gif"))
    }
    
    func testGenerateGif() {
        let gifCollectionViewController = GifsCollectionViewController()
        gifCollectionViewController.gifController.gifs = []
        let didFinished = expectation(description: "didFinished")
        let url = URL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")!
        gifCollectionViewController.generateGif(url: url) {
            didFinished.fulfill()
        }
        wait(for: [didFinished], timeout: 30)
        XCTAssertEqual(1, gifCollectionViewController.gifController.gifs.count)
    }
    
   
}
