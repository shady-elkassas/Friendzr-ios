//
//  UIImageExtension.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 07/09/2021.
//

import Foundation
import UIKit

extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpeg(_ jpegQuality: JPEGQuality) -> Data? {
        return jpegData(compressionQuality: jpegQuality.rawValue)
    }
    
    func convertImageToBase64String() -> String {
        let imageData:Data = self.jpeg(.lowest)! as Data
        let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
        print(strBase64)
        return strBase64
    }
    
    func convertBase64StringToImage(imageBase64String:String) -> UIImage {
        let imgData = Data(base64Encoded: imageBase64String)!
        let image = UIImage(data: imgData)
        return image!
    }
}
