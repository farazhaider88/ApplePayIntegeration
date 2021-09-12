//
//  ApplePayManager.swift
//  ApplePayIntegeration
//
//  Created by Faraz Haider on 12/09/2021.
//

import UIKit
import PassKit

 protocol ApplePayManagerDelegate: AnyObject {
    func applePayDidSucceed()
}


@objc final class ApplePayManager: NSObject{
    weak var delegate: ApplePayManagerDelegate?
    var paymentItem = PKPaymentSummaryItem.init(label: "productName", amount: NSDecimalNumber(value: 100))
    static let shared: ApplePayManager = {
        let instance = ApplePayManager()
        return instance
    }()
    private override init() {}
   
    @objc var jsonPayload : String?
    
    func setupApplePayManager() {
        let paymentNetworks = [PKPaymentNetwork.amex, .discover, .masterCard, .visa]
        
        if PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: paymentNetworks) {
            let request = PKPaymentRequest()
                request.currencyCode = "AED"
                   request.countryCode = "AE"
                request.merchantIdentifier = "merchant.me.ApplePayIntegeration"
                request.merchantCapabilities = PKMerchantCapability.capability3DS
                request.supportedNetworks = paymentNetworks
                request.paymentSummaryItems = [paymentItem]
            
            
            guard let paymentVC = PKPaymentAuthorizationViewController(paymentRequest: request) else {
              displayDefaultAlert(title: "Error", message: "Unable to present Apple Pay authorization.")
              return
          }
              paymentVC.delegate = self
            UIViewController().findLastPresentedViewController()?.present(paymentVC, animated: true, completion: nil)
            
        } else {
            displayDefaultAlert(title: "Error", message: "Unable to make Apple Pay transaction.")
        }
    }
    
    
    func displayDefaultAlert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
       let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        UIViewController().findLastPresentedViewController()?.present(alert, animated: true, completion: nil)
    }
}



extension ApplePayManager: PKPaymentAuthorizationViewControllerDelegate {
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        UIViewController().findLastPresentedViewController()?.dismiss()
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        self.jsonPayload = NSString(data: payment.token.paymentData, encoding: String.Encoding.utf8.rawValue) as String?
        self.delegate?.applePayDidSucceed()
        UIViewController().findLastPresentedViewController()?.dismiss()
      
    }
}


