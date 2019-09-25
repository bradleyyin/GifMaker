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
    
    let gifController = GifController()
    
    var imagePicker: UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.videoMaximumDuration = 10
        imagePicker.mediaTypes = ["public.movie"]
        return imagePicker
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.reloadData()
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

}

extension GifsCollectionViewController {
    
    @IBAction func addNewVideoTapped(_ sender: Any) {
        self.present(imagePicker, animated: true)
    }
    
    func generateGif(url: URL, completion: @escaping () -> Void) {
        let images = generateImages(url: url)
        generateGifFromImages(images: images, completion: {
            completion()
        })
    }
    
    func generateGifFromImages(images: [CGImage], completion: @escaping () -> Void) {
        
        let fileURL = CGImage.animatedGif(from: images, fps: self.framesPerSecond)
        print(fileURL)
        guard let url = fileURL else { return }
        DispatchQueue.main.async {
            self.gifController.createNewGif(name: "", fileURL: url,completion: {
                completion()
            })
        }
    }
    
    func generateImages(url: URL) -> [CGImage] {
        let asset = AVAsset(url: url)
        let videoLength = asset.duration.seconds
        let avAssetImageGenerator = AVAssetImageGenerator(asset: asset)
        avAssetImageGenerator.requestedTimeToleranceAfter = .zero
        avAssetImageGenerator.requestedTimeToleranceBefore = .zero
        avAssetImageGenerator.appliesPreferredTrackTransform = true
        var times: [NSValue] = []
        var lastTime: CMTime = CMTime.zero
        var images: [CGImage] = []
        var done = false
        
        for i in 1...Int(framesPerSecond * videoLength) {
            let cmTime = CMTime(value: CMTimeValue(60.0 / framesPerSecond * Double(i)), timescale: 60)
            let value = NSValue(time: cmTime)
            times.append(value)
            lastTime = cmTime
        }
        DispatchQueue.global().async {
            avAssetImageGenerator.generateCGImagesAsynchronously(forTimes: times) { (requestedTime, image, actualTime, result, error) in
                if let error = error {
                    print("Error generating image: \(error)")
                    return
                }
                if let image = image {
                    images.append(image)
                    print(images.count)
                    if requestedTime == lastTime {
                        // last frame, finish
                        print("We finished!!!")
                       done = true
                    }
                }
            }
        }
        while done == false {
            //wait
        }
        return images
    }
    
}
extension GifsCollectionViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let url = info[.mediaURL] as? URL else { return }
        
        dismiss(animated: true) {
            self.generateGif(url: url,completion: {
                self.collectionView.reloadData()
            })
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

