//
//  ImageDownloader.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 07/03/2022.
//

import UIKit

public class ImageDownloader {
  public static let shared = ImageDownloader()
  
  private init () { }
  
  public func downloadImage(forURL url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) {
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
      if let error = error {
        completion(.failure(error))
        return
      }
      
      guard let data = data else {
        completion(.failure(DownloadError.emptyData))
        return
      }
      
      guard let image = UIImage(data: data) else {
        completion(.failure(DownloadError.invalidImage))
        return
      }
      
      completion(.success(image))
    }
    
    task.resume()
  }
}

public enum DownloadError: Error {
  case emptyData
  case invalidImage
}
