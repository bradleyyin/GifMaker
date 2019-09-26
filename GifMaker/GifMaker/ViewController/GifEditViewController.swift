//
//  GifEditViewController.swift
//  GifMaker
//
//  Created by Bradley Yin on 9/25/19.
//  Copyright © 2019 bradleyyin. All rights reserved.
//

import UIKit
import SwiftyGif
import AVKit
import MobileCoreServices
import ImageIO

class GifEditViewController: UIViewController {

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var addTextButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var canvasView: UIView!
    weak var textField: UITextField!
    
    var assetURL: URL?
    let framesPerSecond = 15.0
    var gifController: GifController?
    var tempGifURL = ""
    var textFieldOrigin : CGPoint = CGPoint(x: 100, y: 100)
    //var images: [CGImage]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        print(assetURL)
        guard let url = assetURL else { return }
        generateGif(url: url) {
            guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
            print(self.tempGifURL)
            let fileURL: URL = dir.appendingPathComponent("\(self.tempGifURL)")
            self.imageView.setGifFromURL(fileURL)
        }

        // Do any additional setup after loading the view.
    }
    
    func generateGif(url: URL, completion: @escaping () -> Void) {
        let images = generateImages(url: url)
        generateGifFromImages(images: images, completion: {
            completion()
        })
    }
    
    func generateGifFromImages(images: [CGImage], completion: @escaping () -> Void) {
        tempGifURL = CGImage.animatedGif(from: images, fps: self.framesPerSecond) ?? ""
        print(tempGifURL)
        completion()
    }
    
    func createAndSaveNewGif() {
        DispatchQueue.main.async {
            self.gifController?.createNewGif(name: "", fileURL: self.tempGifURL,completion: {
                self.deleteTempURL()
            })
        }
    }
    
    func deleteTempURL() {
        
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
    
    @IBAction func saveButtonTapped(_ sender: Any) {
    }
    @IBAction func cancelButtonTapped(_ sender: Any) {
        deleteTempURL()
    }
    @IBAction func addTextButtonTapped(_ sender: Any) {
        let textField = UITextField(frame: CGRect(x: 100, y: 100, width: 100, height: 20))
        textField.placeholder = "enter text"
        textField.isUserInteractionEnabled = true
        addTextButton.isHidden = true
        textField.delegate = self
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(textFieldDrag(pan:)))
        textField.addGestureRecognizer(gesture)
        
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.red.cgColor
        self.textField = textField
        canvasView.addSubview(textField)
    }
    
    @objc func textFieldDrag(pan: UIPanGestureRecognizer) {
        print("Being Dragged")
        if pan.state == .began {
            print("panIF")
            textFieldOrigin = pan.location(in: textField)
            print(textFieldOrigin)
        }else {
            print("panELSE")
            let location = pan.location(in: canvasView) // get pan location
            textField.frame.origin = CGPoint(x: location.x - textFieldOrigin.x, y: location.y - textFieldOrigin.y)
            print(textFieldOrigin)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension GifEditViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.textField.endEditing(true)
        return false
    }
}


