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
    var dataLoaded = false
    
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
            dataLoaded = true
            completion()
        } catch {
            fatalError("Error loading from Core Data: \(error)")
        }
    }
    
    func deleteGif(gif: Gif, context: NSManagedObjectContext = CoreDataStack.shared.mainContext, completion: @escaping () -> Void) {
		// this doesn't appear to delete the gif on disk, just the core data reference. is that handled elsewhere?
        context.performAndWait {
            guard !gifs.isEmpty, let index = gifs.firstIndex(of: gif) else { return }
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
