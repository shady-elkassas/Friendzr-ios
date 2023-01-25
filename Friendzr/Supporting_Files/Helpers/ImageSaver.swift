//
//  ImageSaver.swift
//  Friendzr
//
//  Created by Shady Elkassas on 18/01/2023.
//

import Foundation
import UIKit
import SwiftUI


class ImageSaver: NSObject {
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }

    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        print("Saved")
    }
}
