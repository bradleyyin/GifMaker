//
//  CGImage+Resize.swift
//  GifMaker
//
//  Created by Bradley Yin on 9/26/19.
//  Copyright © 2019 bradleyyin. All rights reserved.
//

import Foundation
import CoreGraphics

// based on solution in https://stackoverflow.com/a/55906075/11412070
extension CGImage {
    private func resize(to newSize: CGSize) -> CGImage? {
        guard let colorSpace = self.colorSpace else { return nil }
        
        let width = Int(newSize.width)
        let height = Int(newSize.height)
        
        guard let context = CGContext(data: nil,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: bitsPerComponent,
                                      bytesPerRow: bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: bitmapInfo.rawValue) else { return nil }
        context.interpolationQuality = .high
        let rect = CGRect(origin: CGPoint.zero, size: newSize)
        context.draw(self, in: rect)
        
        return context.makeImage()
    }
}
