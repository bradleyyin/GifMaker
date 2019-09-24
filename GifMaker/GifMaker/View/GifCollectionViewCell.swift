//
//  GifCollectionViewCell.swift
//  GifMaker
//
//  Created by Bradley Yin on 9/24/19.
//  Copyright © 2019 bradleyyin. All rights reserved.
//

import UIKit
import SwiftyGif

class GifCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    var gif: Gif?
    
    private func updateViews() {
        guard let gif = gif, let appendingURL = gif.appendingURL else { return }
        guard let documentsDirectoryURL: URL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else { return }
        
        let fileURL: URL = documentsDirectoryURL.appendingPathComponent("\(appendingURL)animated.gif")
        imageView.setGifFromURL(fileURL)
    }
    
}
