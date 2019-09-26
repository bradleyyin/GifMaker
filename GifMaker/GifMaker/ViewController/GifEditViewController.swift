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
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var addTextButton: UIButton!
    @IBOutlet weak var canvasView: UIView!
    
    weak var imageTextField: UITextField!
    
    var assetURL: URL?
    let framesPerSecond = 15.0
    var gifController: GifController?
    var tempGifURL = ""
    var textFieldOrigin : CGPoint = CGPoint(x: 100, y: 100)
    var finalTextFieldPoint: CGPoint = CGPoint.zero
    
    var images: [CGImage]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        self.images = images
        generateGifFromImages(images: images, completion: { url in
            self.tempGifURL = url
            completion()
        })
    }
    
    func generateGifFromImages(images: [CGImage], completion: @escaping (String) -> Void) {
        let url = CGImage.animatedGif(from: images, fps: self.framesPerSecond) ?? ""
        completion(url)
    }
    
    func createAndAddNewGif(url: String, completion: @escaping () -> Void) {
        guard let text = textField.text else { return }
        gifController?.createNewGif(name: text, fileURL: url, completion: {
            self.deleteTempURL()
            completion()
        })
    }
    
    func deleteTempURL() {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        print(self.tempGifURL)
        let fileURL: URL = dir.appendingPathComponent("\(self.tempGifURL)")
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            fatalError("unable to delete temp file")
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
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        guard let text = textField.text else { return }
        if imageTextField == nil {
            self.gifController?.createNewGif(name: text, fileURL: tempGifURL, completion: {
                self.dismiss(animated: true, completion: nil)
            })
        } else {
            generateGifWithText {
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        
    }
    @IBAction func cancelButtonTapped(_ sender: Any) {
        deleteTempURL()
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func addTextButtonTapped(_ sender: Any) {
        let textField = UITextField(frame: CGRect(x: 100, y: 100, width: 200, height: 40))
        textField.placeholder = "enter text"
        textField.isUserInteractionEnabled = true
        addTextButton.isHidden = true
        textField.delegate = self
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(textFieldDrag(pan:)))
        textField.addGestureRecognizer(gesture)
        textField.font = UIFont(name: "Helvetica", size: 50)
        self.imageTextField = textField
        canvasView.addSubview(textField)
    }
    
    @objc func textFieldDrag(pan: UIPanGestureRecognizer) {
        print("Being Dragged")
        if pan.state == .began {
            print("panIF")
            textFieldOrigin = pan.location(in: imageTextField)
            print(textFieldOrigin)
        }else {
            print("panELSE")
            let location = pan.location(in: canvasView) // get pan location
            imageTextField.frame.origin = CGPoint(x: location.x - textFieldOrigin.x, y: location.y - textFieldOrigin.y)
            finalTextFieldPoint = imageTextField.frame.origin
            print(finalTextFieldPoint)
        }
    }

    func textToImage(drawText: NSString, inImage: UIImage, atPoint: CGPoint) -> CGImage? {

        // Setup the font specific variables
        let textColor = UIColor.black
        let textFont = UIFont(name: "Helvetica", size: 50)!

        // Setup the image context using the passed image
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(inImage.size, false, scale)

        // Setup the font attributes that will be later used to dictate how the text should be drawn
        let textFontAttributes = [
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.foregroundColor: textColor,
        ]

        // Put the image into a rectangle as large as the original image
        inImage.draw(in: CGRect(origin: CGPoint.zero, size: inImage.size))

        // Create a point within the space that is as bit as the image
        let rect = CGRect(origin: atPoint, size: inImage.size)

        // Draw the text into an image
        drawText.draw(in: rect, withAttributes: textFontAttributes)

        // Create a new image out of the images we have created
        let newImage = UIGraphicsGetImageFromCurrentImageContext()

        // End the context now that we have the image we need
        UIGraphicsEndImageContext()

        //Pass the image back up to the caller
        let newCGImage = newImage?.cgImage
        return newCGImage

    }

    func generateGifWithText(completion: @escaping () -> Void) {
        guard let images = images, let text = imageTextField.text else { return }
        var newImages: [CGImage] = []
        for image in images {
            let uiImage = UIImage(cgImage: image)
            guard let imageWithText = textToImage(drawText: text as NSString, inImage: uiImage, atPoint: CGPoint(x: finalTextFieldPoint.x + 20, y: finalTextFieldPoint.y)) else { continue }
            newImages.append(imageWithText)
        }
        generateGifFromImages(images: newImages) { url in
            self.createAndAddNewGif(url: url, completion: {
                completion()
            })

        }
    }

}
extension GifEditViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}


