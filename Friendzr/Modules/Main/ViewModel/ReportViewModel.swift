//
//  ReportViewModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 04/01/2022.
//

import Foundation
import ObjectMapper
import MobileCoreServices
import Alamofire


class ReportViewModel {
    
    var model : DynamicType<Problems> = DynamicType<Problems>()
    
    let reportReasonIDViewModel = ReportReasonIDViewModel()

    
    func validateSendReportCredentials() -> Bool{
        
        isSuccess =  reportReasonIDViewModel.validateCredentials()
        
        error.value = "\(reportReasonIDViewModel.errorValue ?? "")"
        
        return isSuccess
    }
    
    // Fields that bind to our view's
    var isSuccess : Bool = false
    var error:DynamicType<String> = DynamicType()
    
    func getAllProblems() {
        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "ReportReason/getAllReportReasons"
        let headers = RequestComponent.headerComponent([.authorization,.type,.lang])

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
    
    //1 group 2 event 3 user
    func sendReport(withID id:String,reportType:Int,message:String,reportReasonID:String,completion: @escaping (_ error: String?, _ data: String?) -> ()) {
        CancelRequest.currentTask = false
        
        reportReasonIDViewModel.data = reportReasonID
        guard validateSendReportCredentials() else {
            completion(error.value, nil)
            return
        }
        
        
        let url = URLs.baseURLFirst + "Report/sendReport"
        let headers = RequestComponent.headerComponent([.authorization,.type,.lang])
        let parameters:[String : Any] = ["ID": id,"ReportType":reportType,"Message":message,"ReportReasonID":reportReasonID]
        
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



class ReportReasonIDViewModel : ValidationViewModel{
    var errorValue: String?
    var errorMessage: String = "Please select a reason for reporting".localizedString
    var data: String = ""
    
    func validateCredentials() -> Bool {
        
        guard validateLength(text: data, size: (Defaults.eventTitle_MinLength,Defaults.eventTitle_MaxLength)) else {
            errorValue = errorMessage
            return false
        }
        
        errorValue = ""
        return true
    }
    
    func validateLength(text : String, size : (min : Int, max : Int)) -> Bool{
        return (size.min...size.max).contains(text.count)
    }
}
