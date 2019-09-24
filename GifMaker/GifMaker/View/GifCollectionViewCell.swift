//
//  GifCollectionViewCell.swift
//  GifMaker
//
//  Created by Bradley Yin on 9/24/19.
//  Copyright © 2019 bradleyyin. All rights reserved.
//

import UIKit

class GifCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    var gif: Gif?
    
    private func updateViews() {
        guard let gif = gif else { return }
        
    }
    
}
