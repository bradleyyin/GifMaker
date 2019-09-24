//
//  GifCollectionViewController+NSFetchResultsControllerDelegate.swift
//  GifMaker
//
//  Created by Bradley Yin on 9/24/19.
//  Copyright © 2019 bradleyyin. All rights reserved.
//

import Foundation
import CoreData

extension GifsCollectionViewController:NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        if type == NSFetchedResultsChangeType.insert {
            print("Insert Object: \(newIndexPath)")
            
            if (collectionView?.numberOfSections)! > 0 {
                
                if collectionView?.numberOfItems( inSection: newIndexPath!.section ) == 0 {
                    self.shouldReloadCollectionView = true
                } else {
                    blockOperations.append(
                        BlockOperation(block: { [weak self] in
                            if let this = self {
                                DispatchQueue.main.async {
                                    this.collectionView!.insertItems(at: [newIndexPath!])
                                }
                            }
                        })
                    )
                }
                
            } else {
                self.shouldReloadCollectionView = true
            }
        }
        else if type == NSFetchedResultsChangeType.update {
            print("Update Object: \(indexPath)")
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        DispatchQueue.main.async {
                            
                            this.collectionView!.reloadItems(at: [indexPath!])
                        }
                    }
                })
            )
        }
        else if type == NSFetchedResultsChangeType.move {
            print("Move Object: \(indexPath)")
            
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        DispatchQueue.main.async {
                            this.collectionView!.moveItem(at: indexPath!, to: newIndexPath!)
                        }
                    }
                })
            )
        }
        else if type == NSFetchedResultsChangeType.delete {
            print("Delete Object: \(indexPath)")
            if collectionView?.numberOfItems( inSection: indexPath!.section ) == 1 {
                self.shouldReloadCollectionView = true
            } else {
                blockOperations.append(
                    BlockOperation(block: { [weak self] in
                        if let this = self {
                            DispatchQueue.main.async {
                                this.collectionView!.deleteItems(at: [indexPath!])
                            }
                        }
                    })
                )
            }
        }
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        if type == NSFetchedResultsChangeType.insert {
            print("Insert Section: \(sectionIndex)")
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        DispatchQueue.main.async {
                            this.collectionView!.insertSections(NSIndexSet(index: sectionIndex) as IndexSet)
                        }
                    }
                })
            )
        }
        else if type == NSFetchedResultsChangeType.update {
            print("Update Section: \(sectionIndex)")
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        DispatchQueue.main.async {
                            this.collectionView!.reloadSections(NSIndexSet(index: sectionIndex) as IndexSet)
                        }
                    }
                })
            )
        }
        else if type == NSFetchedResultsChangeType.delete {
            print("Delete Section: \(sectionIndex)")
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        DispatchQueue.main.async {
                            this.collectionView!.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet)
                        }
                    }
                })
            )
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        // Checks if we should reload the collection view to fix a bug @ http://openradar.appspot.com/12954582
        if (self.shouldReloadCollectionView) {
            DispatchQueue.main.async {
                self.collectionView.reloadData();
            }
        } else {
            DispatchQueue.main.async {
                self.collectionView!.performBatchUpdates({ () -> Void in
                    for operation: BlockOperation in self.blockOperations {
                        operation.start()
                    }
                }, completion: { (finished) -> Void in
                    self.blockOperations.removeAll(keepingCapacity: false)
                })
            }
        }
    }
    
    
}
