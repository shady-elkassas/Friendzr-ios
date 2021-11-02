//
//  SimpleDataModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 23/08/2021.
//

import Foundation
import MessageKit
import InputBarAccessoryView
import MapKit
import CoreLocation
import AVFoundation

struct UserSender: SenderType,Equatable {
    var senderId: String = ""
    var displayName: String = ""
    var photoURL:UIImageView = UIImageView()
    
    init(senderId:String,photoURL:String,displayName:String) {
        self.senderId = senderId
        self.displayName = displayName
        self.photoURL.sd_setImage(with: URL(string: photoURL), placeholderImage: UIImage(named: "placeholder"))
    }
}

final internal class SimpleDataModel {

    static let shared = SimpleDataModel()

    private init() {}

    enum MessageTypes: String, CaseIterable {
        case Text
        case AttributedText
        case Photo
        case PhotoFromURL = "Photo from URL"
        case Video
        case Audio
        case Emoji
        case Location
        case Url
        case Phone
        case Custom
        case ShareContact
    }
    
    let system = UserSender(senderId: "000001", photoURL: "", displayName: "system")
    let nathan = UserSender(senderId: "000001", photoURL: "", displayName: "nathan")
    let steven = UserSender(senderId: "000001", photoURL: "", displayName: "steven")
    let wu = UserSender(senderId: "000001", photoURL: "", displayName: "wu")

    lazy var senders = [nathan, steven, wu]
    
    lazy var contactsToShare = [
        MessageContactItem(name: "System", initials: "S"),
        MessageContactItem(name: "Nathan Tannar", initials: "NT", emails: ["test@test.com"]),
        MessageContactItem(name: "Steven Deutsch", initials: "SD", phoneNumbers: ["+1-202-555-0114", "+1-202-555-0145"]),
        MessageContactItem(name: "Wu Zhong", initials: "WZ", phoneNumbers: ["202-555-0158"]),
        MessageContactItem(name: "+40 123 123", initials: "#", phoneNumbers: ["+40 123 123"]),
        MessageContactItem(name: "test@test.com", initials: "#", emails: ["test@test.com"])
    ]

    var currentSender: UserSender {
        return steven
    }

    var now = Date()
    
    let messageImages: [UIImage] = [#imageLiteral(resourceName: "manaualDistanceControl_ic"), #imageLiteral(resourceName: "email_ic")]
    let messageImageURLs: [URL] = [URL(string: "https://placekitten.com/g/200/300")!,
                                   URL(string: "https://placekitten.com/g/300/300")!,
                                   URL(string: "https://placekitten.com/g/300/400")!,
                                   URL(string: "https://placekitten.com/g/400/400")!]

    let emojis = [
        "👍",
        "😂😂😂",
        "👋👋👋",
        "😱😱😱",
        "😃😃😃",
        "❤️"
    ]
    
    let attributes = ["Font1", "Font2", "Font3", "Font4", "Color", "Combo"]
    
    let locations: [CLLocation] = [
        CLLocation(latitude: 37.3118, longitude: -122.0312),
        CLLocation(latitude: 33.6318, longitude: -100.0386),
        CLLocation(latitude: 29.3358, longitude: -108.8311),
        CLLocation(latitude: 39.3218, longitude: -127.4312),
        CLLocation(latitude: 35.3218, longitude: -127.4314),
        CLLocation(latitude: 39.3218, longitude: -113.3317)
    ]

//    let sounds: [URL] = [Bundle.main.url(forResource: "sound1", withExtension: "m4a")!,
//                         Bundle.main.url(forResource: "sound2", withExtension: "m4a")!
//    ]

    let linkItem: (() -> MessageLinkItem) = {
        MessageLinkItem(
            text: "https://github.com/MessageKit",
            attributedText: nil,
            url: URL(string: "https://github.com/MessageKit")!,
            title: "MessageKit",
            teaser: "A community-driven replacement for JSQMessagesViewController - MessageKit",
            thumbnailImage: UIImage(named: "mkorglogo")!
        )
    }

    func attributedString(with text: String) -> NSAttributedString {
        let nsString = NSString(string: text)
        var mutableAttributedString = NSMutableAttributedString(string: text)
        let randomAttribute = Int(arc4random_uniform(UInt32(attributes.count)))
        let range = NSRange(location: 0, length: nsString.length)
        
        switch attributes[randomAttribute] {
        case "Font1":
            mutableAttributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.preferredFont(forTextStyle: .body), range: range)
        case "Font2":
            mutableAttributedString.addAttributes([NSAttributedString.Key.font: UIFont.monospacedDigitSystemFont(ofSize: UIFont.systemFontSize, weight: UIFont.Weight.bold)], range: range)
        case "Font3":
            mutableAttributedString.addAttributes([NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)], range: range)
        case "Font4":
            mutableAttributedString.addAttributes([NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: UIFont.systemFontSize)], range: range)
        case "Color":
            mutableAttributedString.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.red], range: range)
        case "Combo":
            let msg9String = "Use .attributedText() to add bold, italic, colored text and more..."
            let msg9Text = NSString(string: msg9String)
            let msg9AttributedText = NSMutableAttributedString(string: String(msg9Text))
            
            msg9AttributedText.addAttribute(NSAttributedString.Key.font, value: UIFont.preferredFont(forTextStyle: .body), range: NSRange(location: 0, length: msg9Text.length))
            msg9AttributedText.addAttributes([NSAttributedString.Key.font: UIFont.monospacedDigitSystemFont(ofSize: UIFont.systemFontSize, weight: UIFont.Weight.bold)], range: msg9Text.range(of: ".attributedText()"))
            msg9AttributedText.addAttributes([NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)], range: msg9Text.range(of: "bold"))
            msg9AttributedText.addAttributes([NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: UIFont.systemFontSize)], range: msg9Text.range(of: "italic"))
            msg9AttributedText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.red], range: msg9Text.range(of: "colored"))
            mutableAttributedString = msg9AttributedText
        default:
            fatalError("Unrecognized attribute for mock message")
        }
        
        return NSAttributedString(attributedString: mutableAttributedString)
    }

    func dateAddingRandomTime() -> Date {
        let randomNumber = Int(arc4random_uniform(UInt32(10)))
        if randomNumber % 2 == 0 {
            let date = Calendar.current.date(byAdding: .hour, value: randomNumber, to: now)!
            now = date
            return date
        } else {
            let randomMinute = Int(arc4random_uniform(UInt32(59)))
            let date = Calendar.current.date(byAdding: .minute, value: randomMinute, to: now)!
            now = date
            return date
        }
    }

    func getAvatarFor(sender: SenderType,imag:UIImageView) -> Avatar {
        let firstName = sender.displayName.components(separatedBy: " ").first
        let lastName = sender.displayName.components(separatedBy: " ").first
        let initials = "\(firstName?.first ?? "A")\(lastName?.first ?? "A")"
        //        let imag = UIImageView()
        //        imag.sd_setImage(with: URL(string: imgStr), placeholderImage: UIImage(named: "placeholder"))
        
        switch sender.senderId {
        case "000001":
            return Avatar(image: #imageLiteral(resourceName: "placeholder"), initials: initials)
        case "000000":
            return Avatar(image: nil, initials: "SS")
        default:
            return Avatar(image: imag.image, initials: initials)
        }
    }

}
