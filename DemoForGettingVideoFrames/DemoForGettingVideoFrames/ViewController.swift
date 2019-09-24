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
    
    let framesPerSecond = 5.0
    var lengthOfGif = 3.0
    var assetURL: URL?
    var images: [CGImage] = []
    var timer: Timer?
    var imageNumber = 0
    
    var imagePicker: UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.mediaTypes = ["public.movie"]
        return imagePicker
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
        let avAssetImageGenerator = AVAssetImageGenerator(asset: AVAsset(url: assetURL))
        var times: [CMTime] = []
        
        for i in 1...Int(framesPerSecond * lengthOfGif) {
            let cmTime = CMTime(value: CMTimeValue(30.0 / framesPerSecond * Double(i)), timescale: 30)
            times.append(cmTime)
        }
        
        avAssetImageGenerator.generateCGImagesAsynchronously(forTimes: times as [NSValue]) { (requestedTime, image, actualTime, result, error) in
            if let error = error {
                print("Error generating image: \(error)")
            }
            if let image = image {
                self.images.append(image)
                print(self.images.count)
                //print(Int(self.framesPerSecond * self.lengthOfGif))
                if self.images.count == Int(self.framesPerSecond * self.lengthOfGif) {
                    let fileURL = CGImage.animatedGif(from: self.images, fps: self.framesPerSecond)
                    print(fileURL)
                    DispatchQueue.main.async {
                        self.imageView.setGifFromURL(fileURL!)
                    }
                }
            }
            
        }
    }
    
//    func setUpLoopImage() {
//        print(1.0 / framesPerSecond)
//        timer = Timer.scheduledTimer(timeInterval: 1.0 / framesPerSecond, target: self, selector: #selector(loopImage), userInfo: nil, repeats: true)
//    }
    
//    @objc func loopImage() {
//        print("timer start")
//        if imageNumber < Int(self.framesPerSecond * self.lengthOfGif - 1) {
//
//            self.imageView.image = UIImage(cgImage: self.images[imageNumber])
//            imageNumber += 1
//            print(imageNumber)
//
//        } else if imageNumber == Int(self.framesPerSecond * self.lengthOfGif - 1) {
//
//            self.imageView.image = UIImage(cgImage: self.images[imageNumber])
//            imageNumber = 0
//            print(imageNumber)
//
//        }
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
        let frameProperties: CFDictionary = [kCGImagePropertyGIFDictionary as String: [(kCGImagePropertyGIFDelayTime as String): 1.0 / fps]] as CFDictionary
        
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

