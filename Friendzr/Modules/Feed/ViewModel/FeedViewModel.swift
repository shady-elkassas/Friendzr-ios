//
//  FeedViewModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 09/09/2021.
//

import Foundation
import ObjectMapper
import MobileCoreServices
//import Alamofire

class FeedViewModel {
    
    var feeds : DynamicType<UsersList> = DynamicType<UsersList>()

    // Fields that bind to our view's
    var isSuccess : Bool = false
    var error:DynamicType<String> = DynamicType()
    
    var feedsTemp : UsersList = FeedDataModel()

    //MARK:- Get All Users Request
    func getAllUsers(pageNumber:Int) {
        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "FrindRequest/AllUsers"
        let headers = RequestComponent.headerComponent([.authorization,.type])
        let parameters:[String : Any] = ["userlat":Defaults.LocationLat,"userlang":Defaults.LocationLng,"pageNumber": pageNumber,"pageSize":10]

        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: parameters, andHeaders: headers) { (data,error) in
            
            guard let userResponse = Mapper<FeedModel>().map(JSON: data!) else {
                self.error.value = error
                return
            }
            if let error = error {
                print ("Error while fetching data \(error)")
                self.error.value = error
            }
            else {
                // When set the listener (if any) will be notified
                if let toAdd = userResponse.data {
                    if pageNumber > 0 {
                        for itm in toAdd.data ?? [] {
                            if !(self.feedsTemp.data?.contains(where: { $0.userId == itm.userId }) ?? false) {
                                self.feedsTemp.data?.append(itm)
                            }
                        }
                        self.feeds.value = self.feedsTemp
                    } else {
                        self.feeds.value = toAdd
                        self.feedsTemp = toAdd
                    }
                }
            }
        }
    }
    
    //MARK:- filter All Users Request by degree
    func filterFeeds(Bydegree degree:Double,pageNumber:Int) {
        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "FrindRequest/AllUsers"
        let headers = RequestComponent.headerComponent([.authorization,.type])
        let parameters:[String : Any] = ["userlat":Defaults.LocationLat,"userlang":Defaults.LocationLng,"degree":degree,"pageNumber": pageNumber,"pageSize":10]

        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: parameters, andHeaders: headers) { (data,error) in
            
            guard let userResponse = Mapper<FeedModel>().map(JSON: data!) else {
                self.error.value = error
                return
            }
            if let error = error {
                print ("Error while fetching data \(error)")
                self.error.value = error
            }
            else {
                // When set the listener (if any) will be notified
                if let toAdd = userResponse.data {
                    if pageNumber > 1 {
                        for itm in toAdd.data ?? [] {
                            if !(self.feedsTemp.data?.contains(where: { $0.userId == itm.userId }) ?? false) {
                                self.feedsTemp.data?.append(itm)
                            }
                        }
                        self.feeds.value = self.feedsTemp
                    } else {
                        self.feeds.value = toAdd
                        self.feedsTemp = toAdd
                    }
                }
            }
        }
    }
}
