//
//  GifController.swift
//  GifMaker
//
//  Created by Bradley Yin on 9/24/19.
//  Copyright © 2019 bradleyyin. All rights reserved.
//

import Foundation

class GifController {
    func createNewGif(name: String, fileURL: String) {
       Gif(name: name, url: fileURL)
        saveToPersistence()
    }
    
    private func saveToPersistence() {
        do {
            try CoreDataStack.shared.mainContext.save()
        } catch {
            fatalError("Error saving to persistence: \(error)")
        }
    }
}
