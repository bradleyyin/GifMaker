//
//  GifsCollectionViewController.swift
//  GifMaker
//
//  Created by Bradley Yin on 9/24/19.
//  Copyright © 2019 bradleyyin. All rights reserved.
//

import UIKit
import AVKit
import MobileCoreServices
import ImageIO
import CoreData

private let reuseIdentifier = "GifCell"

class GifsCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let framesPerSecond = 15.0
    var lengthOfGif = 3.0
    var assetURL: URL?
    
    var timer: Timer?
    
    let gifController = GifController()
    
    var blockOperations: [BlockOperation] = []
    var shouldReloadCollectionView = false
    
    var imagePicker: UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.videoMaximumDuration = 10
        imagePicker.mediaTypes = ["public.movie"]
        return imagePicker
    }
    
//    lazy var fetchedResultsController: NSFetchedResultsController<Gif> = {
//        let fetchRequest: NSFetchRequest<Gif> = Gif.fetchRequest()
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
//
//        let moc = CoreDataStack.shared.mainContext
//        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
//
//        frc.delegate = self
//
//        try! frc.performFetch()
//
//        return frc
//    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("before reload")
        collectionView.reloadData()
        print("reload")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return gifController.gifs.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? GifCollectionViewCell else {
            fatalError("cannot load gif collection view cell")
        }
        
        let gif = gifController.gifs[indexPath.row]
        cell.gif = gif
    
        return cell
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: 100, height: 100)
//    }
    

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
    deinit {
        for operation: BlockOperation in blockOperations {
            operation.cancel()
        }
        blockOperations.removeAll(keepingCapacity: false)
    }

}

extension GifsCollectionViewController {
    
    @IBAction func addNewVideoTapped(_ sender: Any) {
        self.present(imagePicker, animated: true)
    }
    
    func generateImages() {
        guard let assetURL = assetURL else { return }
        let asset = AVAsset(url: assetURL)
        let videoLength = asset.duration.seconds
        lengthOfGif = videoLength
        print("length: \(videoLength), \(lengthOfGif)")
        let avAssetImageGenerator = AVAssetImageGenerator(asset: asset)
        avAssetImageGenerator.requestedTimeToleranceAfter = .zero
        avAssetImageGenerator.requestedTimeToleranceBefore = .zero
        avAssetImageGenerator.appliesPreferredTrackTransform = true
        var times: [NSValue] = []
        var lastTime: CMTime = CMTime.zero
        var images: [CGImage] = []
        
        for i in 1...Int(framesPerSecond * lengthOfGif) {
            let cmTime = CMTime(value: CMTimeValue(60.0 / framesPerSecond * Double(i)), timescale: 60)
            let value = NSValue(time: cmTime)
            times.append(value)
            lastTime = cmTime
            print("time \(i)")
        }
        print("all time done")
        
        DispatchQueue.global().async {
            avAssetImageGenerator.generateCGImagesAsynchronously(forTimes: times) { (requestedTime, image, actualTime, result, error) in
                if let error = error {
                    print("Error generating image: \(error)")
                    return
                }
                
                print("RequestedTime: \(requestedTime)")
                
                
                if let image = image {
                    images.append(image)
                    print(images.count)
                    if requestedTime == lastTime {
                        // last frame, finish
                        print("We finished!!!")
                        let fileURL = CGImage.animatedGif(from: images, fps: self.framesPerSecond)
                        print(fileURL)
                        guard let url = fileURL else { return }
                        DispatchQueue.main.async {
                            //self.imageView.setGifFromURL(url)
                            //self.setUpLoopImage(images: images)
                            self.gifController.createNewGif(name: "", fileURL: url,completion: {
                                self.collectionView.reloadData()
                            })
                        }
                    }
                }
                
            }
        }
        
        
        
    }
    
}
extension GifsCollectionViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let url = info[.mediaURL] as? URL else { return }
        
        dismiss(animated: true) {
            self.assetURL = url
            self.generateImages()
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension CGImage {
    static func animatedGif(from images: [CGImage], fps: Double) -> String? {
        let fileProperties: CFDictionary = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String: 0]]  as CFDictionary
        let frameProperties: CFDictionary = [kCGImagePropertyGIFDictionary as String: [(kCGImagePropertyGIFDelayTime as String): (1.0 / fps)]] as CFDictionary
        
        let documentsDirectoryURL: URL? = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let uuid = UUID().uuidString
        let fileURL: URL? = documentsDirectoryURL?.appendingPathComponent("\(uuid)animated.gif")
        
        if let url = fileURL as CFURL? {
            if let destination = CGImageDestinationCreateWithURL(url, kUTTypeGIF, images.count, nil) {
                CGImageDestinationSetProperties(destination, fileProperties)
                for image in images {
                    CGImageDestinationAddImage(destination, image, frameProperties)
                }
                if !CGImageDestinationFinalize(destination) {
                    print("Failed to finalize the image destination")
                }
                print("Url = \(fileURL)")
                return "\(uuid)animated.gif"
            }
        }
        return nil
    }
}

