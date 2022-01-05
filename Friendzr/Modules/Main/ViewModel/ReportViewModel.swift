//
//  ReportViewModel.swift
//  Friendzr
//
//  Created by Shady Elkassas on 04/01/2022.
//

import Foundation
import ObjectMapper
import MobileCoreServices
import Alamofire

class ReportViewModel {
    
    var model : DynamicType<Problems> = DynamicType<Problems>()
    
    // Fields that bind to our view's
    var isSuccess : Bool = false
    var error:DynamicType<String> = DynamicType()
    
    func getAllProblems() {
        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "ReportReason/getAllReportReasons"
        let headers = RequestComponent.headerComponent([.authorization,.type])
        
        RequestManager().request(fromUrl: url, byMethod: "GET", withParameters: nil, andHeaders: headers) { (data,error) in
            
            guard let userResponse = Mapper<ReportProblemsModel>().map(JSON: data!) else {
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
                    self.model.value = toAdd
                }
            }
        }
    }
    
    func sendReport(withID id:String,isEvent:Bool,message:String,reportReasonID:String,completion: @escaping (_ error: String?, _ data: String?) -> ()) {
        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "Report/sendReport"
        let headers = RequestComponent.headerComponent([.authorization,.type])
        let parameters:[String : Any] = ["ID": id,"IsEvent":isEvent,"Message":message,"ReportReasonID":reportReasonID]
        
        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: parameters, andHeaders: headers) { (data,error) in
            
            guard let userResponse = Mapper<SendReportResponse>().map(JSON: data!) else {
                self.error.value = error!
                completion(self.error.value, nil)
                return
            }
            if let error = error {
                print ("Error while fetching data \(error)")
                self.error.value = error
                completion(self.error.value, nil)
            }
            else {
                // When set the listener (if any) will be notified
                if let toAdd = userResponse.message {
                    completion(nil,toAdd)
                }
            }
        }
    }
}
