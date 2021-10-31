//
//  Downloader.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 27/10/2021.
//

import Foundation
import UIKit

class Downloader {
    
    func dowanloadFile (downloadURL: URL, onCompletion:@escaping ()->Void, onError:@escaping ()->Void?){
        // Create destination URL
        let mananger = FileManager.default
        let fileName = randomString(length: 10)
        guard let documentsUrl:URL = mananger.urls(for: .documentDirectory, in: .userDomainMask).first else {return}
        let destinationFileUrl = documentsUrl.appendingPathComponent(fileName + ".pdf")
        
        print("Dest Location: \(destinationFileUrl)")
        //Create URL to the source file you want to download
        
        let fileURL = downloadURL
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let request = URLRequest(url:fileURL)
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Successfully downloaded. Status code: \(statusCode)")
                    print("Path is :",destinationFileUrl)
                    print("Path is Temp :",tempLocalUrl)
                }
                do {
                    try mananger.moveItem(at: tempLocalUrl, to: destinationFileUrl)
                    onCompletion()
                    print("dest :",destinationFileUrl)
                    self.pushFile(destinationFileUrl)
                    return
                } catch (let writeError) {
                    print("Error creating a file \(destinationFileUrl) : \(writeError)")
                }
            } else {
                print("Error took place while downloading a file. Error description: %#", error?.localizedDescription ?? "error");
            }
            if(onError != nil){
                onError()
            }
        }
        task.resume()
    }
    
    func pushFile(_ destination: URL) {
        var finalURL = destination.absoluteString
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
}

func randomString(length: Int) -> String {
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    return String((0..<length).map{ _ in letters.randomElement()! })
}
