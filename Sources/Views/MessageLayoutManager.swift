//
//  MessageLayoutManager.swift
//  MessageKit
//
//  Created by Bokyung Kwon on 2021/06/22.
//  Copyright © 2021 MessageKit. All rights reserved.
//

import UIKit

open class MessageLayoutManager: NSLayoutManager {
    @available(iOS 13.0, *)
    open override func showCGGlyphs(_ glyphs: UnsafePointer<CGGlyph>,
                               positions: UnsafePointer<CGPoint>,
                                   count glyphCount: Int,
                                    font: UIFont,
                              textMatrix: CGAffineTransform,
                              attributes: [NSAttributedString.Key : Any] = [:],
                              in CGContext: CGContext) {

        if let foregroundColor = attributes[NSAttributedString.Key.foregroundColor] as? UIColor {
            CGContext.setFillColor(foregroundColor.cgColor)
        }

        super.showCGGlyphs(glyphs, positions: positions, count: glyphCount, font: font, textMatrix: textMatrix, attributes: attributes, in: CGContext)
    }
}
