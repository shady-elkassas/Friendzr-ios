//
//  StoreKitManager.swift
//  Friendzr
//
//  Created by Shady Elkassas on 05/04/2023.
//

import Foundation
import StoreKit

extension AppDelegate {
    func initSKPayment() {
        SKPaymentQueue.default().add(StoreKitManager.sharedInstance)
    }
}

class StoreKitManager: NSObject {
    
    static let sharedInstance = StoreKitManager()
    
    var proId1 = "com.FriendzSocialMediaLimited.monthly"
    var proId2 = "com.FriendzSocialMediaLimited.sixmonth"
    var proId3 = "com.FriendzSocialMediaLimited.year"

    var products: [SKProduct]?
    var purchasedSubscriptions:[SKProduct]?
    
    func getProducts() {
        let request = SKProductsRequest(productIdentifiers: [proId1,proId2,proId3])
        request.delegate = self
        request.start()
    }
    
    func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func purchase(productParam : SKProduct) -> Bool {
        guard let products = products, products.count > 0 else {
            return false
        }
        
        let payment = SKPayment(product: productParam)
        SKPaymentQueue.default().add(payment)
        return true
    }
}

extension StoreKitManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("recevied products")
        products = response.products
        print("products == \(response.products.description)")
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("error")
    }
    
    func requestDidFinish(_ request: SKRequest) {
        print("the request is finished")
    }
}

extension StoreKitManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            if transaction.error != nil {
                print("error: \(transaction.error?.localizedDescription)")
            }
            switch transaction.transactionState {
            case .purchasing:
                print("handle purchasing state")
                break;
            case .purchased:
                print("handle purchased state")
//                if let subscription = products?.first(where: {$0.productIdentifier == transaction.payment.productIdentifier}) {
////                    purchasedSubscriptions.append(subscription)
//                    purchasedSubscriptions?.append(subscription)
//                }
//
//                print("purchasedSubscriptions \(String(describing: purchasedSubscriptions?.count))")
                break
            case .restored:
                print("handle restored state")
                break
            case .failed:
                print("handle failed state")
                break
            case .deferred:
                print("handle deferred state")
                break
            @unknown default:
                print("Fatal Error");
            }
        }
    }
}
