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
    var gifs: [Gif] = []
    
    init() {
        loadFromCoreData()
    }
    
    func createNewGif(name: String, fileURL: String, completion: @escaping() -> Void) {
        let gif = Gif(name: name, url: fileURL)
        gifs.append(gif)
        saveToPersistence()
        completion()
    }
    
    func loadFromCoreData(context: NSManagedObjectContext = CoreDataStack.shared.mainContext, completion: @escaping () -> Void = {}) {
        let fetchRequest: NSFetchRequest<Gif> = Gif.fetchRequest()
        do {
            let gifs = try context.fetch(fetchRequest)
            self.gifs = gifs
            completion()
        } catch {
            fatalError("Error loading from Core Data: \(error)")
        }
    }
    
    func deleteGif(gif: Gif, context: NSManagedObjectContext = CoreDataStack.shared.mainContext, completion: @escaping () -> Void) {
        context.performAndWait {
            guard gifs.count > 0, let index = gifs.firstIndex(of: gif) else { return }
            context.delete(gif)
            gifs.remove(at: index)
            saveToPersistence()
            completion()
        }
    }

    private func saveToPersistence() {
        do {
            try CoreDataStack.shared.mainContext.save()
        } catch {
            fatalError("Error saving to persistence: \(error)")
        }
    }
}
