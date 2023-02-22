//
//  Extension + EditProfileVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 09/02/2023.
//

import UIKit


extension EditMyProfileVC {
    func setupMyProfileTags() {

        tagsListView.removeAllTags()
        tagsid.removeAll()
        tagsNames.removeAll()
        for itm in profileModel?.listoftagsmodel ?? [] {
            tagsListView.addTag(tagId: itm.tagID, title: "#\(itm.tagname)")
            tagsid.append(itm.tagID)
            tagsNames.append(itm.tagname)
        }
        
        if tagsListView.rows == 0 {
            tagsViewHeight.constant = 45
            selectTagsLbl.isHidden = false
            selectTagsLbl.textColor = .lightGray
        }else {
            tagsViewHeight.constant = CGFloat(tagsListView.rows * 25) + 25
            selectTagsLbl.isHidden = true
            
            print("tagsViewHeight.constant >> \(tagsViewHeight.constant)")
        }
        
        tagsListView.textFont = UIFont(name: "Montserrat-Bold", size: 10)!
        if tagsListView.rows == 0 {
            tagsTopSpaceLayout.constant = 5
            tagsBottomSpaceLayout.constant = 5
        }else if tagsListView.rows == 1 {
            tagsTopSpaceLayout.constant = 25
            tagsBottomSpaceLayout.constant = 5
        }else if tagsListView.rows == 2 {
            tagsTopSpaceLayout.constant = 16
            tagsBottomSpaceLayout.constant = 5
        }else if tagsListView.rows == 3 {
            tagsTopSpaceLayout.constant = 10
            tagsBottomSpaceLayout.constant = 5
        }else if tagsListView.rows == 4 {
            tagsTopSpaceLayout.constant = 10
            tagsBottomSpaceLayout.constant = 17
        }
    }
    
    func setupMyIamListProfile() {
        bestDescribesListView.removeAllTags()
        iamid.removeAll()
        iamNames.removeAll()
        for itm in profileModel?.iamList ?? [] {
            if itm.tagname.contains("#") == false {
                bestDescribesListView.addTag(tagId: itm.tagID, title: "#\(itm.tagname)")
                iamid.append(itm.tagID)
                iamNames.append(itm.tagname)
            }else {
                print("iamList.tagname.contains(#)")
            }
        }
        
        if bestDescribesListView.rows == 0 {
            bestDescribesViewHeight.constant = 45
            selectbestDescribesLbl.isHidden = false
            selectbestDescribesLbl.textColor = .lightGray
        }else {
            bestDescribesViewHeight.constant = CGFloat(bestDescribesListView.rows * 25) + 25
            selectbestDescribesLbl.isHidden = true
            
            print("bestViewHeight.constant >> \(bestDescribesViewHeight.constant)")
        }
        
        bestDescribesListView.textFont = UIFont(name: "Montserrat-SemiBold", size: 10)!
        
        if bestDescribesListView.rows == 0 {
            bestDescribessTopSpaceLayout.constant = 5
            bestDescribesBottomSpaceLayout.constant = 5
        }else if bestDescribesListView.rows == 1 {
            bestDescribessTopSpaceLayout.constant = 25
            bestDescribesBottomSpaceLayout.constant = 5
        }else if bestDescribesListView.rows == 2 {
            bestDescribessTopSpaceLayout.constant = 16
            bestDescribesBottomSpaceLayout.constant = 5
        }else if bestDescribesListView.rows == 3 {
            bestDescribessTopSpaceLayout.constant = 10
            bestDescribesBottomSpaceLayout.constant = 5
        }else if bestDescribesListView.rows == 4 {
            bestDescribessTopSpaceLayout.constant = 10
            bestDescribesBottomSpaceLayout.constant = 17
        }
    }
    
    func setupMyPrefertoListProfile() {
        preferToListView.removeAllTags()
        preferToNames.removeAll()
        preferToid.removeAll()
        for itm in profileModel?.prefertoList ?? [] {
            if itm.tagname.contains("#") == false {
                preferToListView.addTag(tagId: itm.tagID, title: "#\(itm.tagname)")
                preferToid.append(itm.tagID)
                preferToNames.append(itm.tagname)
            }else {
                print("prefertoList.tagname.contains(#)")
            }
        }
        
        if preferToListView.rows == 0 {
            preferToViewHeight.constant = 45
            selectPreferToLbl.isHidden = false
            selectPreferToLbl.textColor = .lightGray
        }else {
            preferToViewHeight.constant = CGFloat(preferToListView.rows * 25) + 25
            selectPreferToLbl.isHidden = true
            
            print("bestViewHeight.constant >> \(preferToViewHeight.constant)")
        }
        
        preferToListView.textFont = UIFont(name: "Montserrat-Bold", size: 10)!
        
        if preferToListView.rows == 0 {
            preferToTopSpaceLayout.constant = 5
            preferToBottomSpaceLayout.constant = 5
        }else if preferToListView.rows == 1 {
            preferToTopSpaceLayout.constant = 25
            preferToBottomSpaceLayout.constant = 5
        }else if preferToListView.rows == 2 {
            preferToTopSpaceLayout.constant = 16
            preferToBottomSpaceLayout.constant = 5
        }else if preferToListView.rows == 3 {
            preferToTopSpaceLayout.constant = 10
            preferToBottomSpaceLayout.constant = 5
        }else if preferToListView.rows == 4 {
            preferToTopSpaceLayout.constant = 10
            preferToBottomSpaceLayout.constant = 17
        }
    }
    
    func setupMyGinderProfile() {
    if profileModel?.gender == "male" {
        maleImg.image = UIImage(named: "select_ic")
        femaleImg.image = UIImage(named: "unSelect_ic")
        otherImg.image = UIImage(named: "unSelect_ic")
        otherGenderView.isHidden = true
        otherGenderTxt.text = ""
        
        genderString = "male"
    }
    else if profileModel?.gender == "female" {
        femaleImg.image = UIImage(named: "select_ic")
        maleImg.image = UIImage(named: "unSelect_ic")
        otherImg.image = UIImage(named: "unSelect_ic")
        otherGenderView.isHidden = true
        otherGenderTxt.text = ""
        
        genderString = "female"
    }
    else {
        otherImg.image = UIImage(named: "select_ic")
        maleImg.image = UIImage(named: "unSelect_ic")
        femaleImg.image = UIImage(named: "unSelect_ic")
        otherGenderView.isHidden = false
        otherGenderTxt.text = profileModel?.otherGenderName
        
        genderString = "other"
    }
}
    
    func setupMyAdditionalImagesBtn() {
        if Defaults.imageIsVerified == true {
            self.additionalPhotoBtnView.isHidden = false
        }else {
            self.additionalPhotoBtnView.isHidden = true
        }
        
        self.profileImages.removeAll()
        for item in profileModel?.userImages ?? [] {
            profileImages.append(convertToImage(imagURL: item))
        }
    }
    
    func setupDeepLinkInEditProfile() {
        if self.checkoutName == "interests" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if NetworkConected.internetConect {
                    guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "SelectedTagsVC") as? SelectedTagsVC else {return}
                    vc.arrSelectedDataIds = self.tagsid
                    vc.arrSelectedDataNames = self.tagsNames
                    vc.onInterestsCallBackResponse = self.OnInterestsCallBack
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
        else if self.checkoutName == "additionalImages" {
            if Defaults.imageIsVerified == true {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    if NetworkConected.internetConect {
                        guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "AdditionalImagesVC") as? AdditionalImagesVC else {return}
                        vc.onAdditionalPhotosCallBackResponse = self.onAdditionalPhotosCallBack
                        vc.profileImages = self.profileImages
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        }
        
        self.checkoutName = ""
    }
    
    func OnInterestsCallBack(_ data: [String], _ value: [String]) -> () {
        print(data, value)
        
        selectTagsLbl.isHidden = true
        tagsListView.removeAllTags()
        tagsNames.removeAll()
        for item in value {
            tagsListView.addTag(tagId: "", title: "#" + (item).capitalizingFirstLetter())
            tagsNames.append(item)
        }
        
        if tagsListView.rows == 0 {
            tagsViewHeight.constant = 45
            selectTagsLbl.isHidden = false
            selectTagsLbl.textColor = .lightGray
        }else {
            tagsViewHeight.constant = CGFloat(tagsListView.rows * 25) + 25
            selectTagsLbl.isHidden = true
        }
        
        print("tagsViewHeight.constant >> \(tagsViewHeight.constant)")
        
        tagsid.removeAll()
        for itm in data {
            tagsid.append(itm)
        }
        
        if tagsListView.rows == 0 {
            tagsTopSpaceLayout.constant = 5
            tagsBottomSpaceLayout.constant = 5
        }else if tagsListView.rows == 1 {
            tagsTopSpaceLayout.constant = 25
            tagsBottomSpaceLayout.constant = 5
        }else if tagsListView.rows == 2 {
            tagsTopSpaceLayout.constant = 16
            tagsBottomSpaceLayout.constant = 5
        }else if tagsListView.rows == 3 {
            tagsTopSpaceLayout.constant = 10
            tagsBottomSpaceLayout.constant = 5
        }else if tagsListView.rows == 4 {
            tagsTopSpaceLayout.constant = 10
            tagsBottomSpaceLayout.constant = 17
        }else {
            tagsTopSpaceLayout.constant = 8
            tagsBottomSpaceLayout.constant = 20
        }
    }
    
    func OnIamCallBack(_ data: [String], _ value: [String]) -> () {
        print(data, value)
        
        selectbestDescribesLbl.isHidden = true
        bestDescribesListView.removeAllTags()
        iamNames.removeAll()
        for item in value {
            bestDescribesListView.addTag(tagId: "", title: "#" + (item).capitalizingFirstLetter())
            iamNames.append(item)
        }
        
        if bestDescribesListView.rows == 0 {
            bestDescribesViewHeight.constant = 45
            selectbestDescribesLbl.isHidden = false
            selectbestDescribesLbl.textColor = .lightGray
        }else {
            bestDescribesViewHeight.constant = CGFloat(bestDescribesListView.rows * 25) + 25
            selectbestDescribesLbl.isHidden = true
        }
        
        print("bestViewHeight.constant >> \(bestDescribesViewHeight.constant)")
        
        iamid.removeAll()
        for itm in data {
            iamid.append(itm)
        }
        
        if bestDescribesListView.rows == 0 {
            bestDescribessTopSpaceLayout.constant = 5
            bestDescribesBottomSpaceLayout.constant = 5
        }else if bestDescribesListView.rows == 1 {
            bestDescribessTopSpaceLayout.constant = 25
            bestDescribesBottomSpaceLayout.constant = 5
        }else if bestDescribesListView.rows == 2 {
            bestDescribessTopSpaceLayout.constant = 16
            bestDescribesBottomSpaceLayout.constant = 5
        }else if bestDescribesListView.rows == 3 {
            bestDescribessTopSpaceLayout.constant = 10
            bestDescribesBottomSpaceLayout.constant = 5
        }else if bestDescribesListView.rows == 4 {
            bestDescribessTopSpaceLayout.constant = 10
            bestDescribesBottomSpaceLayout.constant = 17
        }else {
            bestDescribessTopSpaceLayout.constant = 8
            bestDescribesBottomSpaceLayout.constant = 20
        }
        
    }
    
    func OnPreferToCallBack(_ data: [String], _ value: [String]) -> () {
        print(data, value)
        
        selectPreferToLbl.isHidden = true
        preferToListView.removeAllTags()
        preferToNames.removeAll()
        for item in value {
            preferToListView.addTag(tagId: "", title: "#" + (item).capitalizingFirstLetter())
            preferToNames.append(item)
        }
        
        if preferToListView.rows == 0 {
            preferToViewHeight.constant = 45
            selectPreferToLbl.isHidden = false
            selectPreferToLbl.textColor = .lightGray
        }else {
            preferToViewHeight.constant = CGFloat(preferToListView.rows * 25) + 25
            selectPreferToLbl.isHidden = true
        }
        
        print("bestViewHeight.constant >> \(bestDescribesViewHeight.constant)")
        
        preferToid.removeAll()
        for itm in data {
            preferToid.append(itm)
        }
        
        if preferToListView.rows == 0 {
            preferToTopSpaceLayout.constant = 5
            preferToBottomSpaceLayout.constant = 5
        }else if preferToListView.rows == 1 {
            preferToTopSpaceLayout.constant = 25
            preferToBottomSpaceLayout.constant = 5
        }else if preferToListView.rows == 2 {
            preferToTopSpaceLayout.constant = 16
            preferToBottomSpaceLayout.constant = 5
        }else if preferToListView.rows == 3 {
            preferToTopSpaceLayout.constant = 10
            preferToBottomSpaceLayout.constant = 5
        }else if preferToListView.rows == 4 {
            preferToTopSpaceLayout.constant = 10
            preferToBottomSpaceLayout.constant = 17
        }else {
            preferToTopSpaceLayout.constant = 8
            preferToBottomSpaceLayout.constant = 20
        }
    }

}
