//
//  ViewController.swift
//  DemoForGettingVideoFrames
//
//  Created by Bradley Yin on 9/23/19.
//  Copyright © 2019 bradleyyin. All rights reserved.
//

import UIKit
import AVKit
import MobileCoreServices
import ImageIO
import SwiftyGif

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    let framesPerSecond = 15.0
    var lengthOfGif = 3.0
    var assetURL: URL?
    
    var timer: Timer?
    
    
    
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
        loadGif()
        // Do any additional setup after loading the view.
    }
    
    func loadGif() {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let url = dir.appendingPathComponent("4E53F0DC-C1EE-46EE-9A52-B7A6429A1410animated.gif")
        imageView.setGifFromURL(url)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }

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
                            self.imageView.setGifFromURL(url)
                            //self.setUpLoopImage(images: images)
                        }
                    }
                }
                
            }
        }


        
    }
    
//    func setUpLoopImage(images: [CGImage]) {
//        print(1.0 / framesPerSecond)
//        var imageNumber = 0
//        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / framesPerSecond, repeats: true, block: { _ in
//            print("timer start")
//            if imageNumber < Int(self.framesPerSecond * self.lengthOfGif - 1) {
//
//                self.imageView.image = UIImage(cgImage: images[imageNumber])
//                imageNumber += 1
//                print(imageNumber)
//
//            } else if imageNumber == Int(self.framesPerSecond * self.lengthOfGif - 1) {
//
//                self.imageView.image = UIImage(cgImage: images[imageNumber])
//                imageNumber = 0
//                print(imageNumber)
//
//            }
//        })
//    }
    
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let url = info[.mediaURL] as? URL else { return }
        
        dismiss(animated: true) {
            self.assetURL = url
            self.generateImages()
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
    }

}

extension CGImage {
    static func animatedGif(from images: [CGImage], fps: Double) -> URL? {
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
                return fileURL
            }
        }
        return nil
    }
}

