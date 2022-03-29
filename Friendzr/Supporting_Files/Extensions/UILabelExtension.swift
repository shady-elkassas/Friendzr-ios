//
//  UILabelExtension.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 10/08/2021.
//

import Foundation
import UIKit

extension UILabel {
    
    /// Strike Label
    func Strike(withText: String) {
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: withText)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: NSMakeRange(0, attributeString.length))
        
        self.attributedText = attributeString
    }
}

extension UILabel {
    
    func addTrailing(with trailingText: String, moreText: String, moreTextFont: UIFont, moreTextColor: UIColor) {
        let readMoreText: String = trailingText + moreText
        
        let lengthForVisibleString: Int = self.vissibleTextLength
        let mutableString: String = self.text!
        let trimmedString: String? = (mutableString as NSString).replacingCharacters(in: NSRange(location: lengthForVisibleString, length: ((self.text?.count)! - lengthForVisibleString)), with: "")
        let readMoreLength: Int = (readMoreText.count)
        let trimmedForReadMore: String = (trimmedString! as NSString).replacingCharacters(in: NSRange(location: ((trimmedString?.count ?? 0) - readMoreLength), length: readMoreLength), with: "") + trailingText
        let answerAttributed = NSMutableAttributedString(string: trimmedForReadMore, attributes: [NSAttributedString.Key.font: self.font ?? UIFont.systemFont(ofSize: 12)])
        let readMoreAttributed = NSMutableAttributedString(string: moreText, attributes: [NSAttributedString.Key.font: moreTextFont, NSAttributedString.Key.foregroundColor: moreTextColor])
        answerAttributed.append(readMoreAttributed)
        self.attributedText = answerAttributed
    }
    
    var vissibleTextLength: Int {
        let font: UIFont = self.font
        let mode: NSLineBreakMode = self.lineBreakMode
        let labelWidth: CGFloat = self.frame.size.width
        let labelHeight: CGFloat = self.frame.size.height
        let sizeConstraint = CGSize(width: labelWidth, height: CGFloat.greatestFiniteMagnitude)
        
        let attributes: [AnyHashable: Any] = [NSAttributedString.Key.font: font]
        let attributedText = NSAttributedString(string: self.text!, attributes: attributes as? [NSAttributedString.Key : Any])
        let boundingRect: CGRect = attributedText.boundingRect(with: sizeConstraint, options: .usesLineFragmentOrigin, context: nil)
        
        if boundingRect.size.height > labelHeight {
            var index: Int = 0
            var prev: Int = 0
            let characterSet = CharacterSet.whitespacesAndNewlines
            repeat {
                prev = index
                if mode == NSLineBreakMode.byCharWrapping {
                    index += 1
                } else {
                    index = (self.text! as NSString).rangeOfCharacter(from: characterSet, options: [], range: NSRange(location: index + 1, length: self.text!.count - index - 1)).location
                }
            } while index != NSNotFound && index < self.text!.count && (self.text! as NSString).substring(to: index).boundingRect(with: sizeConstraint, options: .usesLineFragmentOrigin, attributes: attributes as? [NSAttributedString.Key : Any], context: nil).size.height <= labelHeight
            return prev
        }
        return self.text!.count
    }
}

extension StringProtocol {
    var html2AttributedString: NSAttributedString? {
        Data(utf8).html2AttributedString
    }
    var html2String: String {
        html2AttributedString?.string ?? ""
    }
    
}

extension Data {
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return  nil
        }
    }
    var html2String: String { html2AttributedString?.string ?? "" }
}

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension UILabel {
    var isTruncatedText: Bool {
        guard let height = textHeight else {
            return false
        }
        return height > bounds.size.height
    }
    
    var textHeight: CGFloat? {
        guard let labelText = text else {
            return nil
        }
        let attributes: [NSAttributedString.Key: UIFont] = [.font: font]
        let labelTextSize = (labelText as NSString).boundingRect(
            with: CGSize(width: frame.size.width, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: attributes,
            context: nil
        ).size
        return ceil(labelTextSize.height)
    }
    
    @discardableResult
    func setExpandActionIfPossible(_ text: String, textColor: UIColor? = nil) -> NSRange? {
        guard isTruncatedText, let visibleString = visibleText else {
            return nil
        }
        let defaultTruncatedString = "... "
        let fontAttribute: [NSAttributedString.Key: UIFont] = [.font: font]
        let expandAttributedString: NSMutableAttributedString = NSMutableAttributedString(
            string: defaultTruncatedString,
            attributes: fontAttribute
        )
        let customExpandAttributes: [NSAttributedString.Key: Any] = [
            .font: font as Any,
            .foregroundColor: (textColor ?? self.textColor) as Any
        ]
        let customExpandAttributedString = NSAttributedString(string: "\(text)", attributes: customExpandAttributes)
        expandAttributedString.append(customExpandAttributedString)
        
        let visibleAttributedString = NSMutableAttributedString(string: visibleString, attributes: fontAttribute)
        guard visibleAttributedString.length > expandAttributedString.length else {
            return nil
        }
        let changeRange = NSRange(location: visibleAttributedString.length - expandAttributedString.length, length: expandAttributedString.length)
        visibleAttributedString.replaceCharacters(in: changeRange, with: expandAttributedString)
        attributedText = visibleAttributedString
        return changeRange
    }
    
    var visibleText: String? {
        guard isTruncatedText,
            let labelText = text,
            let lastIndex = truncationIndex else {
            return nil
        }
        let visibleTextRange = NSRange(location: 0, length: lastIndex)
        guard let range = Range(visibleTextRange, in: labelText) else {
            return nil
        }
        return String(labelText[range])
    }
    
    //https://stackoverflow.com/questions/41628215/uitextview-find-location-of-ellipsis-in-truncated-text/63797174#63797174
    var truncationIndex: Int? {
        guard let text = text, isTruncatedText else {
            return nil
        }
        let attributes: [NSAttributedString.Key: UIFont] = [.font: font]
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let textContainer = NSTextContainer(
            size: CGSize(width: frame.size.width,
                         height: CGFloat.greatestFiniteMagnitude)
        )
        textContainer.maximumNumberOfLines = numberOfLines
        textContainer.lineBreakMode = lineBreakMode

        let layoutManager = NSLayoutManager()
        layoutManager.addTextContainer(textContainer)

        let textStorage = NSTextStorage(attributedString: attributedString)
        textStorage.addLayoutManager(layoutManager)

        //Determine the range of all Glpyhs within the string
        var glyphRange = NSRange()
        layoutManager.glyphRange(
            forCharacterRange: NSMakeRange(0, attributedString.length),
            actualCharacterRange: &glyphRange
        )

        var truncationIndex = NSNotFound
        //Iterate over each 'line fragment' (each line as it's presented, according to your `textContainer.lineBreakMode`)
        var i = 0
        layoutManager.enumerateLineFragments(
            forGlyphRange: glyphRange
        ) { rect, usedRect, textContainer, glyphRange, stop in
            if (i == self.numberOfLines - 1) {
                //We're now looking at the last visible line (the one at which text will be truncated)
                let lineFragmentTruncatedGlyphIndex = glyphRange.location
                if lineFragmentTruncatedGlyphIndex != NSNotFound {
                    truncationIndex = layoutManager.truncatedGlyphRange(inLineFragmentForGlyphAt: lineFragmentTruncatedGlyphIndex).location
                }
                stop.pointee = true
            }
            i += 1
        }
        return truncationIndex
    }
    
    //https://stackoverflow.com/questions/1256887/create-tap-able-links-in-the-nsattributedstring-of-a-uilabel
    private func getIndex(from point: CGPoint) -> Int? {
        guard let attributedString = attributedText, attributedString.length > 0 else {
            return nil
        }
        let textStorage = NSTextStorage(attributedString: attributedString)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        let textContainer = NSTextContainer(size: frame.size)
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = numberOfLines
        textContainer.lineBreakMode = lineBreakMode
        layoutManager.addTextContainer(textContainer)

        let index = layoutManager.characterIndex(
            for: point,
            in: textContainer,
            fractionOfDistanceBetweenInsertionPoints: nil
        )
        return index
    }
    
    func didTapInRange(_ point: CGPoint, targetRange: NSRange) -> Bool {
        guard let indexOfPoint = getIndex(from: point) else {
            return false
        }
        return indexOfPoint > targetRange.location &&
            indexOfPoint < targetRange.location + targetRange.length
    }
}
