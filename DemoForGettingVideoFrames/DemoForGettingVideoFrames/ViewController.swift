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

class ViewController: UIViewController {
    
    let framesPerSecond = 5
    
    var lengthOfGif = 3
    
    var assetURL: URL?
    
    var images: [CGImage] = []
    
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

    @IBAction func addNewVideoTapped(_ sender: Any) {
        self.present(imagePicker, animated: true)
    }
    
    func generateImages() {
        guard let assetURL = assetURL else { return }
        let avAssetImageGenerator = AVAssetImageGenerator(asset: AVAsset(url: assetURL))
        var times: [CMTime] = []
        
        for i in 1...(framesPerSecond * lengthOfGif) {
            let cmTime = CMTime(value: CMTimeValue(30 / framesPerSecond * i), timescale: 30)
            times.append(cmTime)
        }
        
        avAssetImageGenerator.generateCGImagesAsynchronously(forTimes: times as [NSValue]) { (requestedTime, image, actualTime, result, error) in
            if let error = error {
                print("Error generating image: \(error)")
            }
            if let image = image {
                self.images.append(image)
                print(self.images.count)
            }
            
        }
    }
    
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let url = info[.mediaURL] as? URL else { return }
        
        dismiss(animated: true) {
            self.assetURL = url
            self.generateImages()
//            let player = AVPlayer(url: url)
//            let vcPlayer = AVPlayerViewController()
//            vcPlayer.player = player
//            self.present(vcPlayer, animated: true, completion: nil)
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
    }

}
