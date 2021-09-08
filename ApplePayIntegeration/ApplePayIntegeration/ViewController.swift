//
//  ViewController.swift
//  ApplePayIntegeration
//
//  Created by Faraz Haider on 08/09/2021.
//

import UIKit
import PassKit

class ViewController: UIViewController {
    
    // Data Setup
    
    struct Shoe {
        var name: String
        var price: Double
    }
    
    let shoeData = [
        Shoe(name: "Nike Air Force 1 High LV8", price: 110.00),
        Shoe(name: "adidas Ultra Boost Clima", price: 139.99),
        Shoe(name: "Jordan Retro 10", price: 190.00),
        Shoe(name: "adidas Originals Prophere", price: 49.99),
        Shoe(name: "New Balance 574 Classic", price: 90.00)
    ]
    
    // Storyboard outlets
    
    @IBOutlet weak var shoePickerView: UIPickerView!
    @IBOutlet weak var priceLabel: UILabel!
    
    
    func displayDefaultAlert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
       let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func buyShoeTapped(_ sender: UIButton) {
        
        // Open Apple Pay purchase
        
        let selectedIndex = shoePickerView.selectedRow(inComponent: 0)
           let shoe = shoeData[selectedIndex]
           let paymentItem = PKPaymentSummaryItem.init(label: shoe.name, amount: NSDecimalNumber(value: shoe.price))
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
              self.present(paymentVC, animated: true, completion: nil)
            
        } else {
            displayDefaultAlert(title: "Error", message: "Unable to make Apple Pay transaction.")
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shoePickerView.delegate = self
        shoePickerView.dataSource = self
        
    }
    
}

extension ViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    // MARK: - Pickerview update
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return shoeData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return shoeData[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let priceString = String(format: "%.02f", shoeData[row].price)
        priceLabel.text = "Price = $\(priceString)"
    }
}



extension ViewController: PKPaymentAuthorizationViewControllerDelegate {
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {

//        let encryptedPaymentData = payment.token.paymentData
//            let paymentMethod = payment.token.paymentMethod
//            let txId = payment.token.transactionIdentifier
//            print("paymentMethod = \(paymentMethod)")
//            print("txId = \(txId)")
//        let decryptedPaymentData:NSString! = NSString(data: encryptedPaymentData, encoding: String.Encoding.utf8.rawValue)
//            print("decryptedPaymentData = \(decryptedPaymentData)")
      
        
        let paymentDataDictionary: [AnyHashable: Any]? = try? JSONSerialization.jsonObject(with: payment.token.paymentData, options: .mutableContainers) as! [AnyHashable : Any]
        var paymentType: String = "debit"

        var paymentMethodDictionary: [AnyHashable: Any] = ["network": "", "type": paymentType, "displayName": ""]

        let cryptogramDictionary: [AnyHashable: Any] = ["paymentData": paymentDataDictionary ?? "", "transactionIdentifier": payment.token.transactionIdentifier, "paymentMethod": paymentMethodDictionary]
        let cardCryptogramPacketDictionary: [AnyHashable: Any] = cryptogramDictionary
        let cardCryptogramPacketData: Data? = try? JSONSerialization.data(withJSONObject: cardCryptogramPacketDictionary, options: [])

        // in cardCryptogramPacketString we now have all necessary data which demand most of bank gateways to process the payment

        let cardCryptogramPacketString = String(describing: cardCryptogramPacketData)
        
        
        dismiss(animated: true, completion: nil)
        displayDefaultAlert(title: "Success!", message: "The Apple Pay transaction was complete.")
    }
}
