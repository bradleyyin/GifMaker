//
//  GifController.swift
//  GifMaker
//
//  Created by Bradley Yin on 9/24/19.
//  Copyright © 2019 bradleyyin. All rights reserved.
//

import Foundation
import CoreData

class GifController {
//    var gifs: [Gif] = []
//    
//    init() {
//        loadFromCoreData()
//    }
    
    func createNewGif(name: String, fileURL: String) {
        Gif(name: name, url: fileURL)
        saveToPersistence()
    }
    
//    func loadFromCoreData(context: NSManagedObjectContext = CoreDataStack.shared.mainContext) -> [Gif] {
//        let fetchRequest: NSFetchRequest<Gif> = Gif.fetchRequest()
//        do {
//            let gifs = try context.fetch(fetchRequest)
//            return gifs
//        } catch {
//            fatalError("Error loading from Core Data: \(error)")
//        }
//    }
//
    private func saveToPersistence() {
        do {
            try CoreDataStack.shared.mainContext.save()
        } catch {
            fatalError("Error saving to persistence: \(error)")
        }
    }
}
