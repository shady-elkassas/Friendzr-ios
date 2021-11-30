//
//  structAPI.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 17/11/2021.
//

import Foundation

struct structAPI {

    
    
    //https://www.instagram.com/accounts/login/?force_authentication=1&enable_fb_login=1&platform_app_id=1893892080735726&next=/oauth/authorize/%3Fredirect_uri%3Dhttps%3A//developers.facebook.com/instagram/token_generator/oauth/%26client_id%3D1893892080735726%26response_type%3Dcode%26scope%3Duser_profile%2Cuser_media%26state%3D%257B%2522app_id%2522%3A%25221893892080735726%2522%2C%2522user_id%2522%3A%252217841403355698833%2522%2C%2522nonce%2522%3A%2522CCjEh86jurBVyly2%2522%257D
    
    static let INSTAGRAM_AUTHURL = "https://api.instagram.com/oauth/authorize/"
    static let INSTAGRAM_CLIENT_ID = "284152480286634"
    static let INSTAGRAM_CLIENTSERCRET = "0654705463c20d184ad33dad0b706164"
    static let INSTAGRAM_REDIRECT_URI = "https://instagram.com/"
    static let INSTAGRAM_ACCESS_TOKEN = "https://api.instagram.com/"
    static let INSTAGRAM_SCOPE = "follower_list+public_content" /* add whatever scope you need https://www.instagram.com/developer/authorization/ */

}

public struct InstagramError: Error {

    // MARK: - Properties

    let kind: ErrorKind
    let message: String

    /// Retrieve the localized description for this error.
    public var localizedDescription: String {
        return "[\(kind.description)] - \(message)"
    }

    // MARK: - Types

    enum ErrorKind: CustomStringConvertible {
        case invalidRequest

        var description: String {
            switch self {
            case .invalidRequest:
                return "invalidRequest"
            }
        }
    }

}
