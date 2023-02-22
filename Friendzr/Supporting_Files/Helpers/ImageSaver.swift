//
//  ImageSaver.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 18/01/2023.
//

import Foundation
import UIKit
import SwiftUI
import ImageSlideshow

let placeholderString = "https://www.friendzsocialmedia.com/Images/Userprofile/person_default_a353371c-fcc2-43c3-ab55-d02229fba815.png"
let placeholderLocalSource = [BundleImageSource(imageString: "placeHolderApp")]
let userPlaceHolderImage = [BundleImageSource(imageString: "userPlaceHolderImage")]

class ImageSaver: NSObject {
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }

    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        print("Saved")
    }
}
