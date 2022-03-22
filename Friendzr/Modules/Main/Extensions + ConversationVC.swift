//
//  Extensions + ConversationVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 01/12/2021.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import MapKit
import AVFoundation
import MobileCoreServices
import AVKit
import FirebaseAuth
import Firebase
import FirebaseDatabase
import FirebaseFirestore



// MARK: - MessagesDataSource
extension ConversationVC: MessagesDataSource {
    
    func currentSender() -> SenderType {
        return senderUser
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
    }
    
//    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//
//        guard let messagesDataSource = messagesCollectionView.messagesDataSource else {
//            fatalError("Ouch. nil data source for messages")
//        }
//         
//        // Very important to check this when overriding `cellForItemAt`
//        // Super method will handle returning the typing indicator cell
//        guard !isSectionReservedForTypingIndicator(indexPath.section) else {
//            return super.collectionView(collectionView, cellForItemAt: indexPath)
//        }
//
//        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
//        if case .custom = message.kind {
//            let cell = messagesCollectionView.dequeueReusableCell(CustomCell.self, for: indexPath)
//            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
//            return cell
//        }
//        return super.collectionView(collectionView, cellForItemAt: indexPath)
//    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section % 3 == 0 {
            return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        }
        return nil
    }
    
    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return NSAttributedString(string: "Read".localizedString, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let model = messageList[indexPath.section]
        
        let name = (isFromCurrentSender(message: message) ? senderUser.displayName : model.user.displayName)
        
        let colorlbl = isFromCurrentSender(message: message) ? UIColor.clear : UIColor.darkGray
        
        if !isPreviousMessageSameSender(at: indexPath) {
            return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font:
                                                                    UIFont.init(name: "Montserrat-Medium", size: 12) ?? UIFont.preferredFont(forTextStyle: .caption2),
                                                                 NSAttributedString.Key.foregroundColor:colorlbl])
        }
        return nil
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let model = messageList[indexPath.section]
        let colorlbl = isFromCurrentSender(message: message) ? UIColor.white : UIColor.gray

        if model.messageType == 4 {
            return nil
        }
        else {
            if !isNextMessageSameSender(at: indexPath) && isFromCurrentSender(message: message) {
            return NSAttributedString(string: model.dateandtime, attributes: [NSAttributedString.Key.font:
                                                                                UIFont(name: "Montserrat-Medium", size: 12) ?? UIFont.preferredFont(forTextStyle: .caption2),
                                                                              NSAttributedString.Key.foregroundColor:colorlbl])
            }else {
                return NSAttributedString(string: model.dateandtime, attributes: [NSAttributedString.Key.font:
                                                                                    UIFont(name: "Montserrat-Medium", size: 12) ?? UIFont.preferredFont(forTextStyle: .caption2),
                                                                                  NSAttributedString.Key.foregroundColor:colorlbl])
            }
        }
    }
    
    func textCell(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UICollectionViewCell? {
        return nil
    }
}

// MARK: - MessageCellDelegate
extension ConversationVC: MessageCellDelegate {
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        print("Avatar tapped")
        
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
            return
        }
        let model = messageList[indexPath.section]
        
        if model.user.senderId == senderUser.senderId {            
            if let controller = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "MyProfileNC") as? UINavigationController, let vc = controller.viewControllers.first as? MyProfileViewController {
                vc.selectedVC = true
                self.present(controller, animated: true)
            }
        }else {
            if let controller = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "FriendProfileNC") as? UINavigationController, let vc = controller.viewControllers.first as? FriendProfileViewController {
                vc.userID = model.user.senderId
                vc.selectedVC = true
                self.present(controller, animated: true)
            }
        }
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        print("Message tapped")
        
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
            return
        }
        
        let message = messageList[indexPath.section]
        switch message.kind {
        case .attributedText(_):break
        case .location(let locItem):
            let location = locItem.location.coordinate
            //            let locationlng = locItem.location.coordinate.longitude
            if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
                UIApplication.shared.open(URL(string:
                                                "comgooglemaps://?saddr=&daddr=\(location.latitude),\(location.longitude)&directionsmode=driving")!)
                
            } else {
                NSLog("Can't use comgooglemaps://")
            }
            break
        case .contact(_):break
        case .emoji(_):break
        case .linkPreview(_):
            if message.messageType == 4 {
                print("link Preview ")
                if let controller = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "EventDetailsNavC") as? UINavigationController, let vc = controller.viewControllers.first as? EventDetailsViewController {
                    vc.eventId = message.linkPreviewID
                    vc.isEventAdmin = self.isEventAdmin
                    vc.selectedVC = true
                    self.present(controller, animated: true)
                }
            }
        case .photo(_):break
        case .video(_):break
        case .audio(_):break
        case .text(_):break
        default: break
            
        }
    }
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
            return
        }
        
        let message = messageList[indexPath.section]
        
        switch message.kind {
        case .photo(let media):
            if message.messageType == 2 {
                guard let imgURL = media.url else {return}
                guard let popupVC = UIViewController.viewController(withStoryboard: .Main, AndContollerID: "ShowImageVC") as? ShowImageVC else {return}
                popupVC.modalPresentationStyle = .overCurrentContext
                popupVC.modalTransitionStyle = .crossDissolve
                let pVC = popupVC.popoverPresentationController
                pVC?.permittedArrowDirections = .any
                pVC?.delegate = self
                pVC?.sourceRect = CGRect(x: 100, y: 100, width: 1, height: 1)
                popupVC.imgURL = imgURL.description
                present(popupVC, animated: true, completion: nil)
                
            }else if message.messageType == 3 {
                //downlaod file
                print("PDF FILE")
                guard let fileUrl = media.url else {return}
                DispatchQueue.main.async {
                    UIApplication.shared.open(fileUrl)
                }
            }else {
                
            }
        case .video(let media):
            guard let videoURL = media.url else {return}
            let vc = AVPlayerViewController()
            vc.player = AVPlayer(url: videoURL)
            present(vc, animated: true)
            //            break
        default:
            break
        }
    }
    
    
    func pushFile(_ destination: URL) {
        let finalURL = destination.absoluteString
        
        DispatchQueue.main.async {
            if let url = URL(string: finalURL) {
                if #available(iOS 10, *){
                    UIApplication.shared.open(url)
                }else{
                    UIApplication.shared.openURL(url)
                }
                
            }
        }
    }
    
    func didTapCellTopLabel(in cell: MessageCollectionViewCell) {
        print("Top cell label tapped")
    }
    
    func didTapCellBottomLabel(in cell: MessageCollectionViewCell) {
        print("Bottom cell label tapped")
    }
    
    func didTapMessageTopLabel(in cell: MessageCollectionViewCell) {
        print("Top message label tapped")
    }
    
    func didTapMessageBottomLabel(in cell: MessageCollectionViewCell) {
        print("Bottom label tapped")
    }
    
    func didTapPlayButton(in cell: AudioMessageCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell),
              let message = messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView) else {
                  print("Failed to identify message when audio cell receive tap gesture")
                  return
              }
        guard audioController.state != .stopped else {
            // There is no audio sound playing - prepare to start playing for given audio message
            audioController.playSound(for: message, in: cell)
            return
        }
        if audioController.playingMessage?.messageId == message.messageId {
            // tap occur in the current cell that is playing audio sound
            if audioController.state == .playing {
                audioController.pauseSound(for: message, in: cell)
            } else {
                audioController.resumeSound()
            }
        } else {
            // tap occur in a difference cell that the one is currently playing sound. First stop currently playing and start the sound for given message
            audioController.stopAnyOngoingPlaying()
            audioController.playSound(for: message, in: cell)
        }
    }
    
    func didStartAudio(in cell: AudioMessageCell) {
        print("Did start playing audio sound")
    }
    
    func didPauseAudio(in cell: AudioMessageCell) {
        print("Did pause audio sound")
    }
    
    func didStopAudio(in cell: AudioMessageCell) {
        print("Did stop audio sound")
    }
    
    func didTapAccessoryView(in cell: MessageCollectionViewCell) {
        print("Accessory view tapped")
    }
}

// MARK: - MessageLabelDelegate
extension ConversationVC: MessageLabelDelegate {
    func didSelectAddress(_ addressComponents: [String: String]) {
        print("Address Selected: \(addressComponents)")
    }
    
    func didSelectDate(_ date: Date) {
        print("Date Selected: \(date)")
    }
    
    func didSelectPhoneNumber(_ phoneNumber: String) {
        print("Phone Number Selected: \(phoneNumber)")
        if let url = URL(string: "tel://\(phoneNumber)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        
    }
    
    func didSelectURL(_ url: URL) {
        print("URL Selected: \(url)")
        if let url = URL(string: "\(url)") {
            UIApplication.shared.open(url)
        }
    }
    
    func didSelectTransitInformation(_ transitInformation: [String: String]) {
        print("TransitInformation Selected: \(transitInformation)")
    }
    
    func didSelectHashtag(_ hashtag: String) {
        print("Hashtag selected: \(hashtag)")
    }
    
    func didSelectMention(_ mention: String) {
        print("Mention selected: \(mention)")
    }
    
    func didSelectCustom(_ pattern: String, match: String?) {
        print("Custom data detector patter selected: \(pattern)")
    }
}

// MARK: - MessageInputBarDelegate
extension ConversationVC: InputBarAccessoryViewDelegate ,UITextViewDelegate {
    @objc func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        //        processInputBar(setupLeftInputButton(tapMessage: false, Recorder: "play"))
        //1==>message 2==>images 3==>file
        
        let messageDate = formatterDate.string(from: Date())
        let messageTime = formatterTime.string(from: Date())
        let url:URL? = URL(string: "https://www.apple.com/eg/")
        
        self.insertMessage(UserMessage(text: text, user: self.senderUser, messageId: "1", date: Date(), dateandtime: messageDateTimeNow(date: messageDate, time: messageTime), messageType: 1,linkPreviewID: "",isJoinEvent: 0))
        
        DispatchQueue.main.async {
            inputBar.inputTextView.text = ""
        }
        
        if isEvent {
            viewmodel.SendMessage(withEventId: eventChatID, AndMessageType: 1, AndMessage: text, messagesdate: messageDate, messagestime: messageTime, attachedImg: false, AndAttachImage: UIImage(), fileUrl: url!,eventShareid: "") { error, data in
                
                if let error = error {
                    DispatchQueue.main.async {
                        self.view.makeToast(error)
                    }
                    return
                }
                
                guard let _ = data else {
                    return
                }
                
                DispatchQueue.main.async {
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
                }
            }
        }
        else {
            if isChatGroup {
                viewmodel.SendMessage(withGroupId: groupId, AndMessageType: 1, AndMessage: text, messagesdate: messageDate, messagestime: messageTime, attachedImg: false, AndAttachImage: UIImage(), fileUrl: url!,eventShareid: "") { error, data in
                    if let error = error {
                        DispatchQueue.main.async {
                            self.view.makeToast(error)
                        }
                        return
                    }
                    
                    guard data != nil else {
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.messagesCollectionView.reloadData()
                        self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
                    }
                }
            }else {
                viewmodel.SendMessage(withUserId: chatuserID, AndMessage: text, AndMessageType: 1, messagesdate: messageDate, messagestime: messageTime, attachedImg: false, AndAttachImage: UIImage(),fileUrl: url!,eventShareid: "") { error, data in
                    if let error = error {
                        DispatchQueue.main.async {
                            self.view.makeToast(error)
                        }
                        return
                    }
                    
                    guard data != nil else {
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.messagesCollectionView.reloadData()
                        self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
                    }
                }
            }

        }
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        if text == "" {
            setupLeftInputButton(tapMessage: false, Recorder: "play")
        }else {
            setupLeftInputButton(tapMessage: true, Recorder: "play")
        }
        
        NotificationCenter.default.post(name: UIResponder.keyboardWillChangeFrameNotification, object: nil, userInfo: nil)
        NotificationCenter.default.post(name: UITextView.textDidBeginEditingNotification, object: nil, userInfo: nil)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        print("SSSSSS")
        setupNavigationbar()
        
        NotificationCenter.default.post(name: UIResponder.keyboardWillChangeFrameNotification, object: nil, userInfo: nil)
        NotificationCenter.default.post(name: UITextView.textDidBeginEditingNotification, object: nil, userInfo: nil)
    }
    
    func processInputBar(_ inputBar: InputBarAccessoryView) {
        // Here we can parse for which substrings were autocompleted
        let attributedText = inputBar.inputTextView.attributedText!
        let range = NSRange(location: 0, length: attributedText.length)
        attributedText.enumerateAttribute(.autocompleted, in: range, options: []) { (_, range, _) in
            
            let substring = attributedText.attributedSubstring(from: range)
            let context = substring.attribute(.autocompletedContext, at: 0, effectiveRange: nil)
            print("Autocompleted: `", substring, "` with context: ", context ?? [])
        }
        
        //        let components = inputBar.inputTextView.components
        inputBar.inputTextView.text = String()
        inputBar.invalidatePlugins()
        // Send button activity animation
        inputBar.sendButton.startAnimating()
        inputBar.inputTextView.placeholder = "Sending...".localizedString
        // Resign first responder for iPad split view
        inputBar.inputTextView.resignFirstResponder()
        DispatchQueue.global(qos: .default).async {
            // fake send request task
            sleep(1)
            DispatchQueue.main.async { [weak self] in
                inputBar.sendButton.stopAnimating()
                inputBar.inputTextView.placeholder = "Aa".localizedString
                self?.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
            }
        }
    }
}

// MARK: - MessagesDisplayDelegate
extension ConversationVC: MessagesDisplayDelegate {
    
    // MARK: - Text Messages
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        switch message.kind {
        case .linkPreview(_):
            return UIColor.white
        default:
            break
        }
        
        return isFromCurrentSender(message: message) ? UIColor.white : UIColor.darkText
    }
    
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {
        switch detector {
        case .hashtag, .mention, .url : return [.foregroundColor: UIColor.yellow]
        default: return MessageLabel.defaultAttributes
        }
    }
    
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url, .address, .phoneNumber, .date, .transitInformation, .mention, .hashtag]
    }
    
    // MARK: - All Messages
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        switch message.kind {
        case .contact(_):
            return isFromCurrentSender(message: message) ? UIColor.FriendzrColors.primary! : UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        case .emoji((_)):
            return isFromCurrentSender(message: message) ? UIColor.FriendzrColors.primary! : UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        case .text(_):
            return isFromCurrentSender(message: message) ? UIColor.FriendzrColors.primary! : UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        case .photo(_):
            return isFromCurrentSender(message: message) ? UIColor.clear : UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        case .audio(_):
            return isFromCurrentSender(message: message) ? UIColor.FriendzrColors.primary! : UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        case .location(_):
            return isFromCurrentSender(message: message) ? UIColor.FriendzrColors.primary! : UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        case .video(_):
            return isFromCurrentSender(message: message) ? UIColor.clear : UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        case .linkPreview(_):
            return isFromCurrentSender(message: message) ? UIColor.FriendzrColors.primary! : UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        case .attributedText(_):
            return isFromCurrentSender(message: message) ? UIColor.FriendzrColors.primary! : UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        default:
            return isFromCurrentSender(message: message) ? UIColor.FriendzrColors.primary! : UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        }
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        var corners: UIRectCorner = []
        
        if isFromCurrentSender(message: message) {
            corners.formUnion(.topLeft)
            corners.formUnion(.bottomLeft)
            if !isPreviousMessageSameSender(at: indexPath) {
                corners.formUnion(.topRight)
            }
            if !isNextMessageSameSender(at: indexPath) {
                corners.formUnion(.bottomRight)
            }
        } else {
            corners.formUnion(.topRight)
            corners.formUnion(.bottomRight)
            if !isPreviousMessageSameSender(at: indexPath) {
                corners.formUnion(.topLeft)
            }
            
            if !isNextMessageSameSender(at: indexPath) {
                corners.formUnion(.bottomLeft)
            }
        }
        
        return .custom { view in
            let radius: CGFloat = 16
            let path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            view.layer.mask = mask
        }
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        let model = messageList[indexPath.section]
        
        let avatar1 = SimpleDataModel.shared.getAvatarFor(sender: message.sender, imag: model.user.photoURL)
        let avatar2 = SimpleDataModel.shared.getAvatarFor(sender: message.sender, imag: model.user.photoURL) // receive img
        avatarView.isHidden = isNextMessageSameSender(at: indexPath)
        avatarView.set(avatar: isFromCurrentSender(message: message) ? avatar1 : avatar2)
    }
    
    func configureAccessoryView(_ accessoryView: UIView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        // Cells are reused, so only add a button here once. For real use you would need to
        // ensure any subviews are removed if not needed
        accessoryView.subviews.forEach { $0.removeFromSuperview() }
        accessoryView.backgroundColor = .clear

        let shouldShow = Int.random(in: 0...10) == 0
        guard shouldShow else { return }

        let button = UIButton(type: .infoLight)
        button.tintColor = UIColor.FriendzrColors.primary!
        accessoryView.addSubview(button)
        button.frame = accessoryView.bounds
        button.isUserInteractionEnabled = false // respond to accessoryView tap through `MessageCellDelegate`
        accessoryView.layer.cornerRadius = accessoryView.frame.height / 2
        accessoryView.backgroundColor = UIColor.FriendzrColors.primary!.withAlphaComponent(0.3)
    }
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        if case MessageKind.photo(let media) = message.kind, let imageURL = media.url {
            imageView.sd_setImage(with: imageURL, placeholderImage: UIImage(named: "image_message_placeholder"))
        } else {
            imageView.image = self.sendingImageView
        }
    }
    
    // MARK: - Location Messages
    func annotationViewForLocation(message: MessageType, at indexPath: IndexPath, in messageCollectionView: MessagesCollectionView) -> MKAnnotationView? {
        let annotationView = MKAnnotationView(annotation: nil, reuseIdentifier: nil)
        let pinImage = #imageLiteral(resourceName: "ic_map_marker")
        annotationView.image = pinImage
        annotationView.centerOffset = CGPoint(x: 0, y: -pinImage.size.height / 2)
        return annotationView
    }
    
    func animationBlockForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> ((UIImageView) -> Void)? {
        return { view in
            view.layer.transform = CATransform3DMakeScale(2, 2, 2)
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: [], animations: {
                view.layer.transform = CATransform3DIdentity
            }, completion: nil)
        }
    }
    
    func snapshotOptionsForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> LocationMessageSnapshotOptions {
        
        return LocationMessageSnapshotOptions(showsBuildings: true, showsPointsOfInterest: true, span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
    }
    
    // MARK: - Audio Messages
    func audioTintColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : UIColor(red: 15/255, green: 135/255, blue: 255/255, alpha: 1.0)
    }
    
    func configureAudioCell(_ cell: AudioMessageCell, message: MessageType) {
        audioController.configureAudioCell(cell, message: message) // this is needed especially when the cell is reconfigure while is playing sound
    }
}

extension ConversationVC : UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    //MARK:- Take Picture
    func openCamera(){
        fileUpload = "IMAGE"
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    //MARK:- Open Library
    func openLibrary(){
        fileUpload = "IMAGE"
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false
            imagePicker.mediaTypes = ["public.image"]
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func openVideoLibrary() {
        fileUpload = "VIDEO"
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false
            imagePicker.mediaTypes = ["public.movie"]
            imagePicker.videoQuality = .typeMedium
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func openVideoCamera() {
        fileUpload = "VIDEO"
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = false
            imagePicker.videoQuality = .typeMedium
            imagePicker.mediaTypes = ["public.movie"]
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    //selct file to send in chat
    func openFileLibrary() {
        fileUpload = "File"
        let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypePDF,kUTTypeUTF8PlainText] as [String] , in: .import)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        documentPicker.modalPresentationStyle = .formSheet
        present(documentPicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let messageDate = formatterDate.string(from: Date())
        let messageTime = formatterTime.string(from: Date())
        let url:URL? = URL(string: "https://www.apple.com/eg/")
        
        if let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            print(videoURL)
            picker.dismiss(animated:true, completion: {
                
                self.insertMessage(UserMessage(videoURL: videoURL, user: self.senderUser, messageId: "1", date: Date(), dateandtime: "", messageType: 6,linkPreviewID: "",isJoinEvent: 0))
                self.messagesCollectionView.reloadData()
            })
        }else {
            let image = info[.originalImage] as! UIImage
            
            self.insertMessage(UserMessage(image: image, user: self.senderUser, messageId: "1", date: Date(), dateandtime: messageDateTimeNow(date: messageDate, time: messageTime), messageType: 2,linkPreviewID: "",isJoinEvent: 0))
            self.sendingImageView = image
            
            if isEvent {
                viewmodel.SendMessage(withEventId: eventChatID, AndMessageType: 2, AndMessage: "", messagesdate: messageDate, messagestime: messageTime, attachedImg: true, AndAttachImage: image, fileUrl: url!,eventShareid: "") { error, data in
                    
                    if let error = error {
                        DispatchQueue.main.async {
                            self.view.makeToast(error)
                        }
                        return
                    }
                    
                    guard let _ = data else {
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.messagesCollectionView.reloadData()
                        self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
                    }
                }
            }else {
                if isChatGroup {
                    viewmodel.SendMessage(withGroupId: groupId, AndMessageType: 2, AndMessage: "", messagesdate: messageDate, messagestime: messageTime, attachedImg: true, AndAttachImage: image, fileUrl: url!,eventShareid: "") { error, data in
                        if let error = error {
                            DispatchQueue.main.async {
                                self.view.makeToast(error)
                            }
                            return
                        }
                        
                        guard let _ = data else {
                            return
                        }
                        
                        DispatchQueue.main.async {
                            self.messagesCollectionView.reloadData()
                            self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
                        }
                    }
                }else {
                    viewmodel.SendMessage(withUserId: chatuserID, AndMessage: "", AndMessageType: 2, messagesdate: messageDate, messagestime: messageTime, attachedImg: true, AndAttachImage: image, fileUrl: url!,eventShareid: "") { error, data in
                        
                        if let error = error {
                            DispatchQueue.main.async {
                                self.view.makeToast(error)
                            }
                            return
                        }
                        
                        guard let _ = data else {
                            return
                        }
                        
                        DispatchQueue.main.async {
                            self.messagesCollectionView.reloadData()
                            self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
                        }
                    }
                }
            }
            
            picker.dismiss(animated:true, completion: {
                
            })
        }
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated:true, completion: nil)
    }
}

extension ConversationVC: AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    // MARK:- AVRecorder Setup
    
    func setupRecorder() {
        
        //set the settings for recorder
        
        let recordSettings = [AVSampleRateKey : NSNumber(value: Float(44100.0)),
                                AVFormatIDKey : NSNumber(value: Int32(kAudioFormatAppleLossless)),
                        AVNumberOfChannelsKey : NSNumber(value: 2),
                     AVEncoderAudioQualityKey : NSNumber(value: Int32(AVAudioQuality.max.rawValue))];
        
        var error: NSError?
        
        do {
            //  soundRecorder = try AVAudioRecorder(URL: getFileURL(), settings: recordSettings as [NSObject : AnyObject])
            soundRecorder =  try AVAudioRecorder(url: getFileURL() as URL, settings: recordSettings)
        } catch let error1 as NSError {
            error = error1
            soundRecorder = nil
        }
        
        if let err = error {
            print("AVAudioRecorder error: \(err.localizedDescription)")
        } else {
            soundRecorder.delegate = self
            soundRecorder.prepareToRecord()
        }
    }
    
    // MARK:- Prepare AVPlayer
    
    func preparePlayer() {
        var error: NSError?
        
        do {
            soundPlayer = try AVAudioPlayer(contentsOf: getFileURL() as URL)
        } catch let error1 as NSError {
            error = error1
            soundPlayer = nil
        }
        
        if let err = error {
            print("AVAudioPlayer error: \(err.localizedDescription)")
        } else {
            soundPlayer.delegate = self
            soundPlayer.prepareToPlay()
            soundPlayer.volume = 1.0
        }
    }
    
    // MARK:- File URL
    
    func getCacheDirectory() -> String {
        
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory,.userDomainMask, true)
        
        return paths[0]
    }
    
    func getFileURL() -> URL {
        
        let path = getCacheDirectory().appending(fileRecordName)
        
        let filePath = URL(fileURLWithPath: path)
        
        return filePath
    }
    
    // MARK:- AVAudioPlayer delegate methods
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        //        recordButton.isEnabled = true
        //        playButton.setTitle("Play", for: .normal)
        setupLeftInputButton(tapMessage: false, Recorder: "play")
    }
    
    private func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer, error: NSError?) {
        print("Error while playing audio \(error!.localizedDescription)")
    }
    
    // MARK:- AVAudioRecorder delegate methods
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        //        playButton.isEnabled = true
        //        recordButton.setTitle("Record", for: .normal)
        setupLeftInputButton(tapMessage: false, Recorder: "play")
    }
    
    private func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder, error: NSError?) {
        print("Error while recording audio \(error!.localizedDescription)")
    }
    
    // MARK:- didReceiveMemoryWarning
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension ConversationVC: MessagesLayoutDelegate {
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if isFromCurrentSender(message: message) {
            return !isPreviousMessageSameSender(at: indexPath) ? 20 : 0
        } else {
            return !isPreviousMessageSameSender(at: indexPath) ? (20 + outgoingAvatarOverlap) : 0
        }
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return (!isNextMessageSameSender(at: indexPath) && isFromCurrentSender(message: message)) ? 16 : 16
    }
    
    // MARK: - Helpers
//    func isTimeLabelVisible(at indexPath: IndexPath) -> Bool {
//        return indexPath.section % 3 == 0 && !isPreviousMessageSameSender(at: indexPath)
//    }
    
    func isPreviousMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section - 1 >= 0 else { return false }
        return messageList[indexPath.section].user == messageList[indexPath.section - 1].user
    }
    
    func isNextMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section + 1 < messageList.count else { return false }
        return messageList[indexPath.section].user == messageList[indexPath.section + 1].user
    }
    
    func setTypingIndicatorViewHidden(_ isHidden: Bool, performUpdates updates: (() -> Void)? = nil) {
        updateTitleView(title: "Mesaages Room".localizedString, subtitle: isHidden ? "2 Online".localizedString : "Typing...".localizedString)
        setTypingIndicatorViewHidden(isHidden, animated: true, whilePerforming: updates) { [weak self] success in
            if success, self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
            }
        }
    }
}

extension ConversationVC: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        guard let selectedFileURL = urls.first else {
            return
        }
        
        //        let dir = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let sandboxFileURL = dir.appendingPathComponent(selectedFileURL.lastPathComponent)
        
        do {
            if FileManager.default.fileExists(atPath: sandboxFileURL.path) {
                try FileManager.default.removeItem(at: sandboxFileURL)
            }
            
            try FileManager.default.copyItem(at: selectedFileURL, to: sandboxFileURL)
            
            let messageDate = formatterDate.string(from: Date())
            let messageTime = formatterTime.string(from: Date())

            if isEvent {
                let imgView:UIImageView = UIImageView()
                self.insertMessage(UserMessage(imageURL: selectedFileURL, user: self.senderUser, messageId: "1", date: Date(), dateandtime: messageDateTimeNow(date: messageDate, time: messageTime), messageType: 3,linkPreviewID: "",isJoinEvent: 0))
                
                imgView.sd_setImage(with: selectedFileURL, placeholderImage: UIImage(named: "placeHolderApp"))
                self.sendingImageView  = imgView.image
                
                viewmodel.SendMessage(withEventId: eventChatID, AndMessageType: 3, AndMessage: "", messagesdate: messageDate, messagestime: messageTime, attachedImg: true, AndAttachImage: UIImage(), fileUrl: selectedFileURL,eventShareid: "") { error, data in
                    if let error = error {
                        DispatchQueue.main.async {
                            self.view.makeToast(error)
                        }
                        return
                    }
                    
                    guard let _ = data else {
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.messagesCollectionView.reloadData()
                        self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
                    }
                    
                }
            }else {
                if isChatGroup {
                    let imgView:UIImageView = UIImageView()
                    self.insertMessage(UserMessage(imageURL: selectedFileURL, user: self.senderUser, messageId: "1", date: Date(), dateandtime:messageDateTimeNow(date: messageDate, time: messageTime), messageType: 3,linkPreviewID: "",isJoinEvent: 0))
                    imgView.sd_setImage(with: selectedFileURL, placeholderImage: UIImage(named: "placeHolderApp"))
                    self.sendingImageView  = imgView.image

                    viewmodel.SendMessage(withGroupId: groupId, AndMessageType: 3, AndMessage: "", messagesdate: messageDate, messagestime: messageTime, attachedImg: true, AndAttachImage: UIImage(), fileUrl: selectedFileURL,eventShareid: "") { error, data in
                        
                        if let error = error {
                            DispatchQueue.main.async {
                                self.view.makeToast(error)
                            }
                            return
                        }
                        
                        guard let _ = data else {
                            return
                        }
                        
                        DispatchQueue.main.async {
                            self.messagesCollectionView.reloadData()
                            self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
                        }
                        
                    }
                }else {
                    let imgView:UIImageView = UIImageView()
                    self.insertMessage(UserMessage(imageURL: selectedFileURL, user: self.senderUser, messageId: "1", date: Date(), dateandtime: messageDateTimeNow(date: messageDate, time: messageTime), messageType: 3,linkPreviewID: "",isJoinEvent: 0))
                    imgView.sd_setImage(with: selectedFileURL, placeholderImage: UIImage(named: "placeHolderApp"))
                    self.sendingImageView  = imgView.image
                    
                    viewmodel.SendMessage(withUserId: chatuserID, AndMessage: "", AndMessageType: 3, messagesdate: messageDate, messagestime: messageTime, attachedImg: true, AndAttachImage: UIImage(), fileUrl: selectedFileURL,eventShareid: "") { error, data in
                        
                        if let error = error {
                            DispatchQueue.main.async {
                                self.view.makeToast(error)
                            }
                            return
                        }
                        
                        guard let _ = data else {
                            return
                        }
                        
                        DispatchQueue.main.async {
                            self.messagesCollectionView.reloadData()
                            self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
                        }
                        
                    }
                }

            }
            
        }
        
        catch {
            print("Error: \(error)")
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("close")
        controller.dismiss(animated: true, completion: nil)
    }
}

