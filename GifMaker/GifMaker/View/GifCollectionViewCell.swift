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
    @IBOutlet weak var nameLabel: UILabel!
    
    var gif: Gif? {
        didSet {
            updateViews()
        }
    }
    
    private func updateViews() {
        guard let gif = gif, let appendingURL = gif.appendingURL else { return }
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        print("making cell")
        print(dir)
        let fileURL: URL = dir.appendingPathComponent("\(appendingURL)")
        imageView.setGifFromURL(fileURL)
        nameLabel.text = "test"
    }
    
}
