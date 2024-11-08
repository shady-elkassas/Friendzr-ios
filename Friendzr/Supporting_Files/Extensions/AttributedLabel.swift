//
//  AttributedLabel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 28/03/2022.
//

import UIKit

@IBDesignable
open class AttributedLabel: UIView {
    public enum ContentAlignment: Int {
        case center
        case top
        case bottom
        case left
        case right
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight

        func alignOffset(viewSize: CGSize, containerSize: CGSize) -> CGPoint {
            let xMargin = viewSize.width - containerSize.width
            let yMargin = viewSize.height - containerSize.height

            switch self {
            case .center:
                return CGPoint(x: max(xMargin / 2, 0), y: max(yMargin / 2, 0))
            case .top:
                return CGPoint(x: max(xMargin / 2, 0), y: 0)
            case .bottom:
                return CGPoint(x: max(xMargin / 2, 0), y: max(yMargin, 0))
            case .left:
                return CGPoint(x: 0, y: max(yMargin / 2, 0))
            case .right:
                return CGPoint(x: max(xMargin, 0), y: max(yMargin / 2, 0))
            case .topLeft:
                return CGPoint(x: 0, y: 0)
            case .topRight:
                return CGPoint(x: max(xMargin, 0), y: 0)
            case .bottomLeft:
                return CGPoint(x: 0, y: max(yMargin, 0))
            case .bottomRight:
                return CGPoint(x: max(xMargin, 0), y: max(yMargin, 0))
            }
        }
    }

    /// default is `0`.
    @IBInspectable
    open var numberOfLines: Int {
        get { return container.maximumNumberOfLines }
        set {
            container.maximumNumberOfLines = newValue
            setNeedsDisplay()
        }
    }
    /// default is `Left`.
    open var contentAlignment: ContentAlignment = .left {
        didSet { setNeedsDisplay() }
    }
    /// `lineFragmentPadding` of `NSTextContainer`. default is `0`.
    @IBInspectable
    open var padding: CGFloat {
        get { return container.lineFragmentPadding }
        set {
            container.lineFragmentPadding = newValue
            setNeedsDisplay()
        }
    }
    /// default is system font 17 plain.
    open var font = UIFont.systemFont(ofSize: 17) {
        didSet { setNeedsDisplay() }
    }
    /// default is `ByTruncatingTail`.
    open var lineBreakMode: NSLineBreakMode {
        get { return container.lineBreakMode }
        set {
            container.lineBreakMode = newValue
            setNeedsDisplay()
        }
    }
    /// default is nil (text draws black).
    @IBInspectable
    open var textColor: UIColor? {
        didSet { setNeedsDisplay() }
    }
    /// default is nil.
    open var paragraphStyle: NSParagraphStyle? {
        didSet { setNeedsDisplay() }
    }
    /// default is nil.
    open var shadow: NSShadow? {
        didSet { setNeedsDisplay() }
    }
    /// default is nil.
    open var attributedText: NSAttributedString? {
        didSet { setNeedsDisplay() }
    }
    /// default is nil.
    @IBInspectable
    open var text: String? {
        get {
            return attributedText?.string
        }
        set {
            if let value = newValue {
                attributedText = NSAttributedString(string: value)
            } else {
                attributedText = nil
            }
        }
    }
    /// Support for constraint-based layout (auto layout)
    /// If nonzero, this is used when determining -intrinsicContentSize for multiline labels
    open var preferredMaxLayoutWidth: CGFloat = 0

    /// If need to use intrinsicContentSize set true.
    /// Also should call invalidateIntrinsicContentSize when intrinsicContentSize is cached. When text was changed for example.
    public var usesIntrinsicContentSize = false

    var mergedAttributedText: NSAttributedString? {
        if let attributedText = attributedText {
            return mergeAttributes(attributedText)
        }
        return nil
    }

    let container = NSTextContainer()
    let layoutManager = NSLayoutManager()

    public override init(frame: CGRect) {
        super.init(frame: frame)

        isOpaque = false
        contentMode = .redraw
        lineBreakMode = .byTruncatingTail
        padding = 0
        layoutManager.addTextContainer(container)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        isOpaque = false
        contentMode = .redraw
        lineBreakMode = .byTruncatingTail
        padding = 0
        layoutManager.addTextContainer(container)
    }

    open override func setNeedsDisplay() {
        if Thread.isMainThread {
            super.setNeedsDisplay()
        }
    }

    open override var intrinsicContentSize: CGSize {
        if usesIntrinsicContentSize {
            let width = preferredMaxLayoutWidth == 0 ? bounds.width : preferredMaxLayoutWidth
            let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
            return sizeThatFits(size)
        } else {
            return bounds.size
        }
    }

    open override func draw(_ rect: CGRect) {
        guard let attributedText = mergedAttributedText else {
            return
        }

        let storage = NSTextStorage(attributedString: attributedText)
        storage.addLayoutManager(layoutManager)

        container.size = rect.size
        let frame = layoutManager.usedRect(for: container)
        let point = contentAlignment.alignOffset(viewSize: rect.size, containerSize: frame.integral.size)

        let glyphRange = layoutManager.glyphRange(for: container)
        layoutManager.drawBackground(forGlyphRange: glyphRange, at: point)
        layoutManager.drawGlyphs(forGlyphRange: glyphRange, at: point)
    }

    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let attributedText = mergedAttributedText else {
            return .zero
        }

        let storage = NSTextStorage(attributedString: attributedText)
        storage.addLayoutManager(layoutManager)

        container.size = size
        let frame = layoutManager.usedRect(for: container)
        return frame.integral.size
    }

    open override func sizeToFit() {
        super.sizeToFit()

        let width = preferredMaxLayoutWidth == 0 ? CGFloat.greatestFiniteMagnitude : preferredMaxLayoutWidth
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        frame.size = sizeThatFits(size)
    }

    func mergeAttributes(_ attributedText: NSAttributedString) -> NSAttributedString {
        let attrString = NSMutableAttributedString(attributedString: attributedText)

        attrString.addAttribute(.font, attr: font)

        if let textColor = textColor {
            attrString.addAttribute(.foregroundColor, attr: textColor)
        }

        if let paragraphStyle = paragraphStyle {
            attrString.addAttribute(.paragraphStyle, attr: paragraphStyle)
        }

        if let shadow = shadow {
            attrString.addAttribute(.shadow, attr: shadow)
        }

        return attrString
    }

}

extension NSMutableAttributedString {
    @discardableResult
    func addAttribute(_ attrName: NSAttributedString.Key, attr: AnyObject, in range: NSRange? = nil) -> Self {
        let range = range ?? NSRange(location: 0, length: length)
        enumerateAttribute(attrName, in: range, options: .reverse) { object, range, pointer in
            if object == nil {
                addAttributes([attrName: attr], range: range)
            }
        }

        return self
    }
}

