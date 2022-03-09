//
//  MessageItem.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 23/08/2021.
//

import Foundation
import UIKit
import CoreLocation
import MessageKit
import AVFoundation
import MapKit
import SDWebImage

private struct CoordinateItem: LocationItem {

    var location: CLLocation
    var size: CGSize

    init(location: CLLocation) {
        self.location = location
        self.size = CGSize(width: 240, height: 240)
    }
}

private struct ImageMediaItem: MediaItem {

    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize

    init(image: UIImage) {
        self.image = image
        self.size = CGSize(width: 240, height: 240)
        self.placeholderImage = UIImage()
    }

    init(imageURL: URL) {
        self.url = imageURL
        self.size = CGSize(width: 240, height: 240)
        self.placeholderImage = UIImage(named: "placeholder") ?? UIImage()
    }
}

private struct VideoMediaItem: MediaItem {

    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize

    init(image: UIImage) {
        self.image = image
        self.size = CGSize(width: 240, height: 240)
        self.placeholderImage = UIImage()
    }
    
    init(videoURL: URL) {
        self.url = videoURL
        self.size = CGSize(width: 240, height: 240)
        self.placeholderImage = UIImage(named: "video_message_placeholder")!
    }
}

private struct MessageAudioItem: AudioItem {

    var url: URL
    var size: CGSize
    var duration: Float

    init(url: URL) {
        self.url = url
        self.size = CGSize(width: 160, height: 35)
        // compute duration
        let audioAsset = AVURLAsset(url: url)
        self.duration = Float(CMTimeGetSeconds(audioAsset.duration))
    }
}

struct MessageContactItem: ContactItem {
    
    var displayName: String
    var initials: String
    var phoneNumbers: [String]
    var emails: [String]
    
    init(name: String, initials: String, phoneNumbers: [String] = [], emails: [String] = []) {
        self.displayName = name
        self.initials = initials
        self.phoneNumbers = phoneNumbers
        self.emails = emails
    }
    
}

struct MessageLinkItem: LinkItem {
    let text: String?
    let attributedText: NSAttributedString?
    let url: URL
    let title: String?
    let teaser: String
    let thumbnailImage: UIImage
    var people: String?
    var date: String?
    
    init(title:String,teaser:String,thumbnailImage:UIImage,people:String,date:String) {
        self.text = ""
        self.attributedText = NSAttributedString(string: "")
        self.url = URL(string: "bit.ly/3sbXHy5")!
        
        self.title = title
        self.teaser = teaser
        self.people = people
        self.date = date
        self.thumbnailImage = thumbnailImage
    }
}

internal struct UserMessage: MessageType {

    var messageId: String
    var sender: SenderType {
        return user
    }
    var sentDate: Date = Date()
    var kind: MessageKind
    var messageType:Int
    var dateandtime:String = ""
    
    var linkPreviewID:String = ""
    var isJoinEvent:Int = 0
    
    var user: UserSender

    private init(kind: MessageKind, user: UserSender, messageId: String, date: Date,dateandtime:String,messageType:Int,linkPreviewID:String,isJoinEvent:Int) {
        self.kind = kind
        self.user = user
        self.messageId = messageId
        self.sentDate = date
        self.dateandtime = dateandtime
        self.messageType = messageType
        self.isJoinEvent = isJoinEvent
        self.linkPreviewID = linkPreviewID
    }
    
    init(custom: Any?, user: UserSender, messageId: String, date: Date,dateandtime:String,messageType:Int,linkPreviewID:String,isJoinEvent:Int) {
        self.init(kind: .custom(custom), user: user, messageId: messageId, date: date,dateandtime:dateandtime, messageType: messageType,linkPreviewID: linkPreviewID,isJoinEvent: isJoinEvent)
    }
    
    init(text: String, user: UserSender, messageId: String, date: Date,dateandtime:String,messageType:Int,linkPreviewID:String,isJoinEvent:Int) {
        self.init(kind: .text(text), user: user, messageId: messageId,date:date,dateandtime:dateandtime, messageType: messageType,linkPreviewID: linkPreviewID,isJoinEvent: isJoinEvent)
    }

    init(attributedText: NSAttributedString, user: UserSender, messageId: String, date: Date,dateandtime:String,messageType:Int,linkPreviewID:String,isJoinEvent:Int) {
        self.init(kind: .attributedText(attributedText), user: user, messageId: messageId, date: date,dateandtime:dateandtime, messageType: messageType,linkPreviewID: linkPreviewID,isJoinEvent: isJoinEvent)
    }

    init(image: UIImage, user: UserSender, messageId: String, date: Date,dateandtime:String,messageType:Int,linkPreviewID:String,isJoinEvent:Int) {
        let mediaItem = ImageMediaItem(image: image)
        self.init(kind: .photo(mediaItem), user: user, messageId: messageId, date: date,dateandtime:dateandtime, messageType: messageType,linkPreviewID: linkPreviewID,isJoinEvent: isJoinEvent)
    }

    init(imageURL: URL, user: UserSender, messageId: String, date: Date,dateandtime:String,messageType:Int,linkPreviewID:String,isJoinEvent:Int) {
        let mediaItem = ImageMediaItem(imageURL: imageURL)
        self.init(kind: .photo(mediaItem), user: user, messageId: messageId, date: date,dateandtime:dateandtime, messageType: messageType,linkPreviewID: linkPreviewID,isJoinEvent: isJoinEvent)
    }

    init(videoURL: URL, user: UserSender, messageId: String, date: Date,dateandtime:String,messageType:Int,linkPreviewID:String,isJoinEvent:Int) {
        let mediaItem = VideoMediaItem(videoURL: videoURL)
        self.init(kind: .video(mediaItem), user: user, messageId: messageId, date: date,dateandtime:dateandtime, messageType: messageType,linkPreviewID: linkPreviewID,isJoinEvent: isJoinEvent)
    }
    
    init(location: CLLocation, user: UserSender, messageId: String, date: Date,dateandtime:String,messageType:Int,linkPreviewID:String,isJoinEvent:Int) {
        let locationItem = CoordinateItem(location: location)
        self.init(kind: .location(locationItem), user: user, messageId: messageId, date: date,dateandtime:dateandtime, messageType: messageType,linkPreviewID: linkPreviewID,isJoinEvent: isJoinEvent)
    }

    init(emoji: String, user: UserSender, messageId: String, date: Date,dateandtime:String,messageType:Int,linkPreviewID:String,isJoinEvent:Int) {
        self.init(kind: .emoji(emoji), user: user, messageId: messageId, date: date,dateandtime:dateandtime, messageType: messageType,linkPreviewID: linkPreviewID,isJoinEvent: isJoinEvent)
    }

    init(audioURL: URL, user: UserSender, messageId: String, date: Date,dateandtime:String,messageType:Int,linkPreviewID:String,isJoinEvent:Int) {
        let audioItem = MessageAudioItem(url: audioURL)
        self.init(kind: .audio(audioItem), user: user, messageId: messageId, date: date,dateandtime:dateandtime, messageType: messageType,linkPreviewID: linkPreviewID,isJoinEvent: isJoinEvent)
    }

    init(contact: MessageContactItem, user: UserSender, messageId: String, date: Date,dateandtime:String,messageType:Int,linkPreviewID:String,isJoinEvent:Int) {
        self.init(kind: .contact(contact), user: user, messageId: messageId, date: date,dateandtime:dateandtime, messageType: messageType,linkPreviewID: linkPreviewID,isJoinEvent: isJoinEvent)
    }

    init(linkItem: LinkItem, user: UserSender, messageId: String, date: Date,dateandtime:String,messageType:Int,linkPreviewID:String,isJoinEvent:Int) {
        
        self.init(kind: .linkPreview(linkItem), user: user, messageId: messageId, date: date,dateandtime:dateandtime, messageType: messageType,linkPreviewID: linkPreviewID,isJoinEvent: isJoinEvent)
    }
}
