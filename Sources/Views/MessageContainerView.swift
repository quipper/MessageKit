/*
 MIT License

 Copyright (c) 2017-2019 MessageKit

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import UIKit

open class MessageContainerView: UIImageView {

    // MARK: - Properties

    open var style: MessageStyle = .none {
        didSet {
            applyMessageStyle()
        }
    }

    // MARK: - Methods
    private func applyMessageStyle() {
        switch style {
        case .leftBubble, .rightBubble:
            layer.cornerRadius = 4
            layer.borderColor = UIColor.clear.cgColor
            layer.borderWidth = 0
            layer.mask = maskLayer(style: style, roundedRect: bounds)

        case .announcement:
            layer.cornerRadius = 30
            layer.borderColor = UIColor.clear.cgColor
            layer.borderWidth = 0
            layer.mask = nil

        case .warning(let borderColor):
            layer.cornerRadius = 6
            layer.borderColor = borderColor.cgColor
            layer.borderWidth = 1
            layer.mask = nil

        case .none:
            layer.borderColor = UIColor.clear.cgColor
            layer.borderWidth = 0
            layer.mask = nil
        }
    }

    private func maskLayer(style: MessageStyle, roundedRect: CGRect) -> CAShapeLayer {
        let roundingCorners: UIRectCorner
        switch style {
        case .leftBubble:
            roundingCorners = [.topRight, .bottomLeft, .bottomRight]
        case .rightBubble:
            roundingCorners = [.topLeft, .bottomLeft, .bottomRight]
        default:
            fatalError("This style never calls this function.")
        }

        let maskPath = UIBezierPath(roundedRect: roundedRect,
                                    byRoundingCorners: roundingCorners,
                                    cornerRadii: CGSize(width: 10, height: 0))
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        return maskLayer
    }
}
