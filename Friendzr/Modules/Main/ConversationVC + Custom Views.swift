//
//  ConversationVC + Custom Views.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 16/03/2022.
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
import ListPlaceholder
import SwiftUI


//MARK: - Navigation Buttons
extension ConversationVC {
    func initOptionsInChatUserButton() {
        let imageName = "menu_H_ic"
        let button = UIButton.init(type: .custom)
        let image = UIImage.init(named: imageName)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.setImage(image, for: .normal)
        image?.withTintColor(UIColor.blue)
        button.addTarget(self, action:  #selector(handleUserOptionsBtn), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    func initOptionsInChatEventButton() {
        let imageName = "menu_H_ic"
        let button = UIButton.init(type: .custom)
        let image = UIImage.init(named: imageName)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.setImage(image, for: .normal)
        image?.withTintColor(UIColor.blue)
        button.addTarget(self, action:  #selector(handleEventOptionsBtn), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    @objc func handleUserOptionsBtn() {
        let actionSheet  = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Unfriend".localizedString, style: .default, handler: { action in
            self.unFriendAccount()
        }))
        actionSheet.addAction(UIAlertAction(title: "Block".localizedString, style: .default, handler: { action in
            self.blockFriendAccount()
        }))
        actionSheet.addAction(UIAlertAction(title: "Report".localizedString, style: .default, handler: { action in
            if self.isEvent == true {
                if let controller = UIViewController.viewController(withStoryboard: .Main, AndContollerID: "ReportNC") as? UINavigationController, let vc = controller.viewControllers.first as? ReportVC {
                    vc.id = self.eventChatID
                    vc.chatimg = self.titleChatImage
                    vc.chatname = self.titleChatName
                    vc.reportType = 2
                    vc.selectedVC = "Present"
                    self.present(controller, animated: true)
                }
            }else {
                if self.isChatGroup == true {
                    if let controller = UIViewController.viewController(withStoryboard: .Main, AndContollerID: "ReportNC") as? UINavigationController, let vc = controller.viewControllers.first as? ReportVC {
                        vc.id = self.groupId
                        vc.chatimg = self.titleChatImage
                        vc.chatname = self.titleChatName
                        vc.reportType = 1
                        vc.selectedVC = "Present"
                        self.present(controller, animated: true)
                    }
                }else {
                    if let controller = UIViewController.viewController(withStoryboard: .Main, AndContollerID: "ReportNC") as? UINavigationController, let vc = controller.viewControllers.first as? ReportVC {
                        vc.id = self.chatuserID
                        vc.chatimg = self.titleChatImage
                        vc.chatname = self.titleChatName
                        vc.reportType = 3
                        vc.selectedVC = "Present"
                        self.present(controller, animated: true)
                    }
                }
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel".localizedString, style: .cancel, handler: {  _ in
        }))
        
        present(actionSheet, animated: true, completion: nil)
        
    }
    
    @objc func handleEventOptionsBtn() {
        let actionSheet  = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Details".localizedString, style: .default, handler: { action in
            if self.isEvent == true {
                if self.eventType == "External" {
                    if let controller = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "ExternalEventDetailsNC") as? UINavigationController, let vc = controller.viewControllers.first as? ExternalEventDetailsVC {
                        vc.eventId = self.eventChatID
                        vc.isEventAdmin = self.isEventAdmin
                        vc.selectedVC = true
                        self.present(controller, animated: true)
                    }
                }else {
                    if let controller = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "EventDetailsNavC") as? UINavigationController, let vc = controller.viewControllers.first as? EventDetailsViewController {
                        vc.eventId = self.eventChatID
                        vc.isEventAdmin = self.isEventAdmin
                        vc.selectedVC = true
                        self.present(controller, animated: true)
                    }
                }
            }else {
                if let controller = UIViewController.viewController(withStoryboard: .Main, AndContollerID: "GroupDetailsNC") as? UINavigationController, let vc = controller.viewControllers.first as? GroupDetailsVC {
                    vc.groupId = self.groupId
                    vc.isGroupAdmin = self.isChatGroupAdmin
                    vc.selectedVC = true
                    self.present(controller, animated: true)
                }
                
            }
        }))
        if self.isEvent {
            if !self.isEventAdmin {
                actionSheet.addAction(UIAlertAction(title: "Report".localizedString, style: .default, handler: { action in
                    if self.isEvent == true {
                        if let controller = UIViewController.viewController(withStoryboard: .Main, AndContollerID: "ReportNC") as? UINavigationController, let vc = controller.viewControllers.first as? ReportVC {
                            vc.id = self.eventChatID
                            vc.chatimg = self.titleChatImage
                            vc.chatname = self.titleChatName
                            vc.reportType = 2
                            vc.selectedVC = "Present"
                            self.present(controller, animated: true)
                        }
                    }else {
                        if self.isChatGroup == true {
                            if let controller = UIViewController.viewController(withStoryboard: .Main, AndContollerID: "ReportNC") as? UINavigationController, let vc = controller.viewControllers.first as? ReportVC {
                                vc.id = self.groupId
                                vc.chatimg = self.titleChatImage
                                vc.chatname = self.titleChatName
                                vc.reportType = 1
                                vc.selectedVC = "Present"
                                self.present(controller, animated: true)
                            }
                        }else {
                            if let controller = UIViewController.viewController(withStoryboard: .Main, AndContollerID: "ReportNC") as? UINavigationController, let vc = controller.viewControllers.first as? ReportVC {
                                vc.id = self.chatuserID
                                vc.chatimg = self.titleChatImage
                                vc.chatname = self.titleChatName
                                vc.reportType = 3
                                vc.selectedVC = "Present"
                                self.present(controller, animated: true)
                            }
                        }
                    }
                }))
            }
        }else {
            if !self.isChatGroupAdmin {
                actionSheet.addAction(UIAlertAction(title: "Report".localizedString, style: .default, handler: { action in
                    if self.isEvent == true {
                        if let controller = UIViewController.viewController(withStoryboard: .Main, AndContollerID: "ReportNC") as? UINavigationController, let vc = controller.viewControllers.first as? ReportVC {
                            vc.id = self.eventChatID
                            vc.chatimg = self.titleChatImage
                            vc.chatname = self.titleChatName
                            vc.reportType = 2
                            vc.selectedVC = "Present"
                            self.present(controller, animated: true)
                        }
                    }else {
                        if self.isChatGroup == true {
                            if let controller = UIViewController.viewController(withStoryboard: .Main, AndContollerID: "ReportNC") as? UINavigationController, let vc = controller.viewControllers.first as? ReportVC {
                                vc.id = self.groupId
                                vc.chatimg = self.titleChatImage
                                vc.chatname = self.titleChatName
                                vc.reportType = 1
                                vc.selectedVC = "Present"
                                self.present(controller, animated: true)
                            }
                        }else {
                            if let controller = UIViewController.viewController(withStoryboard: .Main, AndContollerID: "ReportNC") as? UINavigationController, let vc = controller.viewControllers.first as? ReportVC {
                                vc.id = self.chatuserID
                                vc.chatimg = self.titleChatImage
                                vc.chatname = self.titleChatName
                                vc.reportType = 3
                                vc.selectedVC = "Present"
                                self.present(controller, animated: true)
                            }
                        }
                    }
                }))
            }
        }
        
        actionSheet.addAction(UIAlertAction(title: "Cancel".localizedString, style: .cancel, handler: {  _ in
        }))
        present(actionSheet, animated: true, completion: nil)
        
    }
    
    func leaveEvent() {
        alertView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        alertView?.titleLbl.text = "Confirm?".localizedString
        alertView?.detailsLbl.text = "Are you sure you want to leave this event chat?".localizedString
        
        let actionDate = formatterDate.string(from: Date())
        let actionTime = formatterTime.string(from: Date())
        
        alertView?.HandleConfirmBtn = {
            self.viewmodel.LeaveChat(ByID: self.eventChatID, ActionDate: actionDate, Actiontime: actionTime) { error, data in
                self.hideLoading()
                if let error = error {
                    DispatchQueue.main.async {
                        self.view.makeToast(error)
                    }
                    return
                }
                
                guard let _ = data else {
                    return
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    Router().toHome()
                }
            }
            
            UIView.animate(withDuration: 0.3, animations: {
                self.alertView?.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                self.alertView?.alpha = 0
            }) { (success: Bool) in
                self.alertView?.removeFromSuperview()
                self.alertView?.alpha = 1
                self.alertView?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            }
        }
        
        self.view.addSubview((alertView)!)
        
    }
    
    func unFriendAccount() {
        alertView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        alertView?.titleLbl.text = "Confirm?".localizedString
        alertView?.detailsLbl.text = "Are you sure you want to unfriend this account?".localizedString
        
        let actionDate = formatterUnfriendDate.string(from: Date())
        let actionTime = formatterTime.string(from: Date())
        
        alertView?.HandleConfirmBtn = {
            self.requestFriendVM.requestFriendStatus(withID: self.chatuserID, AndKey: 5,requestdate: "\(actionDate) \(actionTime)") { error, message in
                self.hideLoading()
                if let error = error {
                    DispatchQueue.main.async {
                        self.view.makeToast(error)
                    }
                    return
                }
                
                guard let message = message else {return}
                print(message)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    Router().toHome()
                }
            }
            
            UIView.animate(withDuration: 0.3, animations: {
                self.alertView?.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                self.alertView?.alpha = 0
            }) { (success: Bool) in
                self.alertView?.removeFromSuperview()
                self.alertView?.alpha = 1
                self.alertView?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            }
        }
        
        self.view.addSubview((alertView)!)
    }
    
    func blockFriendAccount() {
        alertView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        let actionDate = formatterUnfriendDate.string(from: Date())
        let actionTime = formatterTime.string(from: Date())
        
        alertView?.titleLbl.text = "Confirm?".localizedString
        alertView?.detailsLbl.text = "Are you sure you want to block this account?".localizedString
        
        alertView?.HandleConfirmBtn = {
            self.requestFriendVM.requestFriendStatus(withID: self.chatuserID, AndKey: 3,requestdate: "\(actionDate) \(actionTime)") { error, message in
                self.hideLoading()
                if let error = error {
                    DispatchQueue.main.async {
                        self.view.makeToast(error)
                    }
                    return
                }
                
                guard let _ = message else {return}
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    Router().toHome()
                }
            }
            // handling code
            UIView.animate(withDuration: 0.3, animations: {
                self.alertView?.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                self.alertView?.alpha = 0
            }) { (success: Bool) in
                self.alertView?.removeFromSuperview()
                self.alertView?.alpha = 1
                self.alertView?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            }
        }
        
        self.view.addSubview((alertView)!)
    }
}

//MARK: - setup bottom views
extension ConversationVC {
    //handle Long Press
    @objc private func handleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let touchPoint = sender.location(in: self.messagesCollectionView)
            if let indexPath = self.messagesCollectionView.indexPathForItem(at: touchPoint) {
                // your code here, get the row for the indexPath or do whatever you want
                presentActionSheetForLongPress(indexPath: indexPath.section)
            }
        }
    }
    
    //setup buttons for chat
    func configureInputBarItems() {
        messageInputBar.setRightStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.sendButton.imageView?.backgroundColor = UIColor(white: 0.85, alpha: 1)
        messageInputBar.sendButton.contentEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        messageInputBar.sendButton.image = #imageLiteral(resourceName: "send_ic")
        messageInputBar.sendButton.imageView?.contentMode = .scaleAspectFit
        messageInputBar.sendButton.title = nil
        messageInputBar.sendButton.imageView?.layer.cornerRadius = 16
        
        
        let charCountButton = InputBarButtonItem()
            .configure {
                $0.title = "0/160"
                $0.contentHorizontalAlignment = .right
                $0.setTitleColor(UIColor(white: 0.6, alpha: 1), for: .normal)
                $0.titleLabel?.font = UIFont.systemFont(ofSize: 10, weight: .bold)
                $0.setSize(CGSize(width: 50, height: 25), animated: false)
            }
            .onTextViewDidChange { (item, textView) in
                item.title = "\(textView.text.count)/160"
                let isOverLimit = textView.text.count > 160
                item.inputBarAccessoryView?.shouldManageSendButtonEnabledState = !isOverLimit // Disable automated management when over limit
                if isOverLimit {
                    item.inputBarAccessoryView?.sendButton.isEnabled = false
                }
                let color = isOverLimit ? .red : UIColor(white: 0.6, alpha: 1)
                item.setTitleColor(color, for: .normal)
            }
        
        
        let bottomItems = [.flexibleSpace, charCountButton]
        
        configureInputBarPadding()
        
        messageInputBar.setStackViewItems(bottomItems, forStack: .bottom, animated: false)
        
        // This just adds some more flare
        messageInputBar.sendButton
            .onEnabled { item in
                UIView.animate(withDuration: 0.3, animations: {
                    item.imageView?.backgroundColor = .FriendzrColors.primary
                })
            }.onDisabled { item in
                UIView.animate(withDuration: 0.3, animations: {
                    item.imageView?.backgroundColor = UIColor(white: 0.85, alpha: 1)
                })
            }
    }
    
    func setupLeftInputButton(tapMessage:Bool,Recorder:String) {
        messageInputBar.inputTextView.delegate = self
        messageInputBar.inputTextView.setBorder(color: UIColor.FriendzrColors.primary?.cgColor, width: 1)
        messageInputBar.inputTextView.cornerRadiusView(radius: 8)
        
        let button = InputBarSendButton()
        button.setSize(CGSize(width: 36, height: 36), animated: false)
        button.setImage(UIImage(named: "attach_ic"), for: .normal)
        button.onTouchUpInside { [weak self] _ in
            self?.presentInputActionSheet()
        }
        
        let button2 = InputBarSendButton()
        button2.setSize(CGSize(width: 35, height: 35), animated: false)
        button2.setImage(UIImage(systemName: Recorder), for: .normal)
        button2.backgroundColor = UIColor.FriendzrColors.primary!
        button2.tintColor = .white
        button2.cornerRadiusView(radius: 17.5)
        button2.setBorder(color: UIColor.white.cgColor, width: 3)
        button2.onTouchUpInside { [weak self] _ in
            self?.recordMessageAction(sender:Recorder)
        }
        
        if tapMessage {
            messageInputBar.setLeftStackViewWidthConstant(to: 0, animated: false)
        }else {
            messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        }
        
        messageInputBar.leftStackView.spacing = 5
        messageInputBar.padding.bottom = 8
        messageInputBar.middleContentViewPadding.left = 8
        messageInputBar.padding.left = 5
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
        messageInputBar.inputTextView.font = UIFont(name: "Montserrat-Medium", size: 12)
        
        NotificationCenter.default.post(name: UIResponder.keyboardWillChangeFrameNotification, object: nil, userInfo: nil)
        NotificationCenter.default.post(name: UITextView.textDidBeginEditingNotification, object: nil, userInfo: nil)
    }
    
    func setupDownView(textLbl:String) {
        messageInputBar.isHidden = true
        
        let downView:UIView = UIView()
        downView.backgroundColor = .white.withAlphaComponent(0.85)
        downView.setBorder()
        
        view.addSubview(downView)
        let label = UILabel()
        downView.addSubview(label)
        
        label.textColor = .black
        label.font = UIFont(name: "Montserrat-Medium", size: 12)
        label.textAlignment = .center
        label.numberOfLines = 3
        label.text = textLbl
        
        label.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            label.bottomAnchor.constraint(equalTo: downView.bottomAnchor, constant: -30),
            label.topAnchor.constraint(equalTo: downView.topAnchor, constant: 10),
            label.leftAnchor.constraint(equalTo: downView.leftAnchor, constant: 20),
            label.rightAnchor.constraint(equalTo: downView.rightAnchor, constant: -20)
        ]
        
        downView.addConstraints(constraints)
        
        downView.translatesAutoresizingMaskIntoConstraints = false
        let bottomConstraint = downView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        let verticalConstraint = downView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        let widthConstraint = downView.widthAnchor.constraint(equalToConstant: view.bounds.width)
        let heightConstraint = downView.heightAnchor.constraint(equalToConstant: 100)
        view.addConstraints([bottomConstraint, verticalConstraint, widthConstraint, heightConstraint])
    }
    
    private func recordMessageAction(sender:String) {
        print("Record Message")
        
        if (sender == "play"){
            soundRecorder.record()
            setupLeftInputButton(tapMessage: false, Recorder: "pause")
            //            playButton.isEnabled = false
        }
        else {
            soundRecorder.stop()
            setupLeftInputButton(tapMessage: false, Recorder: "play")
            insertMessage(UserMessage(audioURL: getFileURL(), user: senderUser, messageId: "1", date: Date(), dateandtime: "", messageType: 6,linkPreviewID: "",isJoinEvent: 0,eventType: ""))
            self.messagesCollectionView.reloadData()
        }
    }
    
    private func presentActionSheetForLongPress(indexPath:Int) {
        let actionAlert  = UIAlertController(title: "", message: "Choose the action you want to do?".localizedString, preferredStyle: .actionSheet)
        
        actionAlert.addAction(UIAlertAction(title: "Delete".localizedString, style: .default, handler: { action in
            print("\(indexPath)")
            self.messageList.remove(at: indexPath)
            self.messagesCollectionView.reloadData()
        }))
        actionAlert.addAction(UIAlertAction(title: "Hide".localizedString, style: .default, handler: { action in
        }))
        actionAlert.addAction(UIAlertAction(title: "Copy".localizedString, style: .default, handler: { action in
            let message = self.messageList[indexPath]
            switch message.kind {
            case .contact(let contact):
                UIPasteboard.general.string = contact.phoneNumbers[0]
                self.view.makeToast("Copied".localizedString)
                break
            case .emoji((let text)):
                UIPasteboard.general.string = text
                self.view.makeToast("Copied".localizedString)
                break
            case .text(let text):
                UIPasteboard.general.string = text
                self.view.makeToast("Copied".localizedString)
                break
            default: break
            }
        }))
        actionAlert.addAction(UIAlertAction(title: "Replay".localizedString, style: .default, handler: { action in
        }))
        actionAlert.addAction(UIAlertAction(title: "Cancel".localizedString, style: .cancel, handler: {  _ in
        }))
        //            actionAlert.view.tintColor = UIColor.FriendzrColors.primary
        present(actionAlert, animated: true, completion: nil)
    }
    
    private func presentInputActionSheet() {
        let actionSheet  = UIAlertController(title: "Attach Media".localizedString, message: "What would you like attach?".localizedString, preferredStyle: .actionSheet)
        
        let cameraBtn = UIAlertAction(title: "Camera", style: .default) {_ in
            self.openCamera()
        }
        let libraryBtn = UIAlertAction(title: "Photo Library", style: .default) {_ in
            self.openLibrary()
        }
        let fileBtn = UIAlertAction(title: "File", style: .default) {_ in
            self.openFileLibrary()
        }
        
        let cancelBtn = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        cameraBtn.setValue(UIColor.FriendzrColors.primary, forKey: "titleTextColor")
        libraryBtn.setValue(UIColor.FriendzrColors.primary, forKey: "titleTextColor")
        fileBtn.setValue(UIColor.FriendzrColors.primary, forKey: "titleTextColor")
        cancelBtn.setValue(UIColor.red, forKey: "titleTextColor")
        
        actionSheet.addAction(cameraBtn)
        actionSheet.addAction(libraryBtn)
        actionSheet.addAction(fileBtn)
        actionSheet.addAction(cancelBtn)
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    func presentVideoInputActionSheet() {
        let settingsActionSheet: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle:UIAlertController.Style.actionSheet)
        
        settingsActionSheet.addAction(UIAlertAction(title:"Camera".localizedString, style:UIAlertAction.Style.default, handler:{ action in
            self.openVideoCamera()
        }))
        settingsActionSheet.addAction(UIAlertAction(title:"Library".localizedString, style:UIAlertAction.Style.default, handler:{ action in
            self.openVideoLibrary()
        }))
        settingsActionSheet.addAction(UIAlertAction(title:"Cancel".localizedString, style:UIAlertAction.Style.cancel, handler:nil))
        
        present(settingsActionSheet, animated:true, completion:nil)
        
    }
    
}
//MARK: - updateTitleView
extension ConversationVC {
    func updateTitleView(image: String, subtitle: String?,titleId:String,isEvent:Bool) {
        
        let imageUser = UIImageView(frame: CGRect(x: 0, y: 2, width: 30, height: 30))
        imageUser.backgroundColor = UIColor.clear
        imageUser.image = UIImage(named: image)
        imageUser.contentMode = .scaleAspectFill
        imageUser.cornerRadiusForHeight()
        imageUser.sd_setImage(with: URL(string: image), placeholderImage: UIImage(named: "placeHolderApp"))
        
        let subtitleLabel = UILabel(frame: CGRect(x: 0, y: 34, width: 0, height: 0))
        subtitleLabel.textColor = UIColor.setColor(lightColor: UIColor.black, darkColor: UIColor.white)
        subtitleLabel.font = UIFont.init(name: "Montserrat-Medium", size: 8)
        subtitleLabel.text = subtitle
        subtitleLabel.textAlignment = .center
        subtitleLabel.adjustsFontSizeToFitWidth = true
        subtitleLabel.sizeToFit()
        
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: max(imageUser.frame.size.width, subtitleLabel.frame.size.width), height: 45))
        titleView.addSubview(imageUser)
        if subtitle != nil {
            titleView.addSubview(subtitleLabel)
        } else {
            imageUser.frame = titleView.frame
        }
        let widthDiff = subtitleLabel.frame.size.width - imageUser.frame.size.width
        if widthDiff < 0 {
            let newX = widthDiff / 2
            subtitleLabel.frame.origin.x = abs(newX)
        } else {
            let newX = widthDiff / 2
            imageUser.frame.origin.x = newX
        }
        
        let btn = UIButton(frame: titleView.frame)
        if isEvent == true {
            btn.addTarget(self, action: #selector(goToEventDetailsVC), for: .touchUpInside)
        }
        else {
            if isChatGroup {
                if self.leaveGroup == 0 {
                    btn.addTarget(self, action: #selector(goToGroupVC), for: .touchUpInside)
                }
            }else {
                btn.addTarget(self, action: #selector(goToUserProfileVC), for: .touchUpInside)
            }
        }
        
        titleView.addSubview(btn)
        
        navigationItem.titleView = titleView
    }
    
    @objc func goToGroupVC() {
        if let controller = UIViewController.viewController(withStoryboard: .Main, AndContollerID: "GroupDetailsNC") as? UINavigationController, let vc = controller.viewControllers.first as? GroupDetailsVC {
            vc.groupId = self.groupId
            vc.isGroupAdmin = self.isChatGroupAdmin
            vc.selectedVC = true
            self.present(controller, animated: true)
        }
    }
    
    @objc func goToUserProfileVC() {
        if let controller = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "FriendProfileNC") as? UINavigationController, let vc = controller.viewControllers.first as? FriendProfileViewController {
            vc.userID = self.chatuserID
            vc.selectedVC = true
            self.present(controller, animated: true)
        }
    }
    
    @objc func goToEventDetailsVC() {
        if self.eventType == "External" {
            if let controller = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "ExternalEventDetailsNC") as? UINavigationController, let vc = controller.viewControllers.first as? ExternalEventDetailsVC {
                vc.eventId = self.eventChatID
                vc.isEventAdmin = self.isEventAdmin
                vc.selectedVC = true
                self.present(controller, animated: true)
            }
        }else {
            if let controller = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "EventDetailsNavC") as? UINavigationController, let vc = controller.viewControllers.first as? EventDetailsViewController {
                vc.eventId = self.eventChatID
                vc.isEventAdmin = self.isEventAdmin
                vc.selectedVC = true
                self.present(controller, animated: true)
            }
        }
    }
}

//MARK: -handleLinkPreviewOptionsTapped
extension ConversationVC {
    func handleLinkPreviewOptionsTapped(ById id:String,IsInEvent:Int) {
        
        var joinTitle:String = ""
        if IsInEvent == 0 {
            
        }else {
            if IsInEvent == 1 {
                joinTitle = "Exit"
            }else {
                joinTitle = "Join"
            }
        }
        
        if IsInEvent == 0 {
            let actionSheet  = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: "Details".localizedString, style: .default, handler: { action in
                
                if self.eventType == "External" {
                    if let controller = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "ExternalEventDetailsNC") as? UINavigationController, let vc = controller.viewControllers.first as? ExternalEventDetailsVC {
                        vc.eventId = id
                        vc.isEventAdmin = self.isEventAdmin
                        vc.selectedVC = true
                        self.present(controller, animated: true)
                    }
                }else {
                    if let controller = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "EventDetailsNavC") as? UINavigationController, let vc = controller.viewControllers.first as? EventDetailsViewController {
                        vc.eventId = id
                        vc.isEventAdmin = self.isEventAdmin
                        vc.selectedVC = true
                        self.present(controller, animated: true)
                    }
                }
            }))
            actionSheet.addAction(UIAlertAction(title: "Cancel".localizedString, style: .cancel, handler: {  _ in
            }))
            present(actionSheet, animated: true, completion: nil)
        }
        else {
            let actionSheet  = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: "Details".localizedString, style: .default, handler: { action in
                if self.eventType == "External" {
                    if let controller = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "ExternalEventDetailsNC") as? UINavigationController, let vc = controller.viewControllers.first as? ExternalEventDetailsVC {
                        vc.eventId = id
                        vc.isEventAdmin = self.isEventAdmin
                        vc.selectedVC = true
                        self.present(controller, animated: true)
                    }
                }else {
                    if let controller = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "EventDetailsNavC") as? UINavigationController, let vc = controller.viewControllers.first as? EventDetailsViewController {
                        vc.eventId = id
                        vc.isEventAdmin = self.isEventAdmin
                        vc.selectedVC = true
                        self.present(controller, animated: true)
                    }
                }
            }))
            
            actionSheet.addAction(UIAlertAction(title: joinTitle, style: .default, handler: { action in
            }))
            actionSheet.addAction(UIAlertAction(title: "Cancel".localizedString, style: .cancel, handler: {  _ in
            }))
            present(actionSheet, animated: true, completion: nil)
            
        }
    }
}

//MARK: -setup navigation bar
extension MessagesViewController {
    func setupNavigationbar() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.shadowImage = UIColor.color("#F4F8F3")?.as1ptImage()
        navigationController?.navigationBar.setBackgroundImage(UIColor.white.as1ptImage(), for: .default)
        view.backgroundColor = UIColor.white
    }
}

