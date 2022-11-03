//
//  MessagesManager.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 18/05/2022.
//

import Foundation
import UIKit

class LinkPreviewEvent {
    var eventID:String
    var eventTypeLink:String = ""
    var isJoinEvent:Int = 0
    var messsageLinkTitle:String = ""
    var messsageLinkCategory:String = ""
    var messsageLinkImageURL:String = ""
    var messsageLinkAttendeesJoined:String = ""
    var messsageLinkAttendeesTotalnumbert:String = ""
    var messsageLinkEventDate:String = ""
    var linkPreviewID:String = ""
    
    init(eventID:String,eventTypeLink:String,isJoinEvent:Int,messsageLinkTitle:String,messsageLinkCategory:String,messsageLinkImageURL:String,messsageLinkAttendeesJoined:String,messsageLinkAttendeesTotalnumbert:String,messsageLinkEventDate:String,linkPreviewID:String) {
        self.eventID = eventID
        self.eventTypeLink = eventTypeLink
        self.isJoinEvent = isJoinEvent
        self.messsageLinkTitle = messsageLinkTitle
        self.messsageLinkCategory = messsageLinkCategory
        self.messsageLinkImageURL = messsageLinkImageURL
        self.messsageLinkAttendeesJoined = messsageLinkAttendeesJoined
        self.messsageLinkAttendeesTotalnumbert = messsageLinkAttendeesTotalnumbert
        self.messsageLinkEventDate = messsageLinkEventDate
        self.linkPreviewID = linkPreviewID
    }
}

class MessageText {
    var text:String = ""
    
    init(text: String) {
        self.text = text
    }
}

class MessageImage {
    var image:String = ""
    var imageView:UIImage = UIImage()
    
    init(image:String) {
        self.image = image
    }
    
    init(imageView:UIImage) {
        self.imageView = imageView
    }
}

class MessageFile {
    var file:String = ""
    var fileView:UIImage = UIImage()
    
    init(file:String) {
        self.file = file
    }
    
    init(fileView:UIImage) {
        self.fileView = fileView
    }
}

class SenderMessage {
    var senderId:String = ""
    var photoURL:String = ""
    var displayName:String = ""
    var isWhitelabel:Bool = false
    
    init(senderId:String,photoURL:String,displayName:String,isWhitelabel:Bool) {
        self.senderId = senderId
        self.photoURL = photoURL
        self.displayName = displayName
        self.isWhitelabel = isWhitelabel
    }
}

class ChatMessage {
    var messageId:String = ""
    var sender:SenderMessage
    var messageType:Int = 0
    var messageText:MessageText
    var messageImage:MessageImage
    var messageFile:MessageFile
    var messageLink:LinkPreviewEvent
//    var senderType:String = ""
    var date:Date = Date()
    var messageDate:String = ""
    var messageTime:String = ""
    
    init(sender:SenderMessage,messageId:String,messageType:Int,messageText:MessageText,messageImage:MessageImage,messageFile:MessageFile,messageLink:LinkPreviewEvent,date:Date,messageDate:String,messageTime:String) {
        self.sender = sender
        self.messageId = messageId
        self.messageType = messageType
        self.messageText = messageText
        self.messageImage = messageImage
        self.messageFile = messageFile
        self.messageLink = messageLink
        self.date = date
        self.messageDate = messageDate
        self.messageTime = messageTime
    }
}


//MARK: - singletone Notification Message
class NotificationMessage {
    static var action:String = ""
    static var actionCode:String = ""
    static var messageType:Int = 0
    
    static var messageText:String = ""
    static var messsageImageURL:String = ""
    
    static var messsageLinkTitle:String = ""
    static var messsageLinkCategory:String = ""
    static var messsageLinkImageURL:String = ""
    static var messsageLinkAttendeesJoined:String = ""
    static var messsageLinkAttendeesTotalnumbert:String = ""
    static var messsageLinkEventDate:String = ""
    static var linkPreviewID:String = ""

    static var messageId:String = ""
    static var date:Date = Date()
    static var messageDate:String = ""
    static var messageTime:String = ""
    static var eventTypeLink:String = ""
    static var isJoinEvent:Int = 0
    static var senderId:String = ""
    static var photoURL:String = ""
    static var displayName:String = ""
    static var isWhitelabel:Bool = false
}
