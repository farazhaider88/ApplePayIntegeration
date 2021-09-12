//
//  ViewController.swift
//  ApplePayIntegeration
//
//  Created by Faraz Haider on 08/09/2021.
//

import UIKit
import PassKit

class ViewController: UIViewController {
    
    struct Product {
        var name: String
        var price: Double
    }
    
    let productData = [
        Product(name: "Milk", price: 40.00),
        Product(name: "Floor", price: 69.99),
        Product(name: "Rice", price: 90.00),
        Product(name: "Fruits", price: 29.99),
        Product(name: "Vegetables", price: 19.00)
    ]
    
    @IBOutlet weak var productPickerView: UIPickerView!
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBAction func buyProductTapped(_ sender: UIButton) {
        
        let selectedIndex = productPickerView.selectedRow(inComponent: 0)
        let shoe = productData[selectedIndex]
        let paymentItem = PKPaymentSummaryItem.init(label: shoe.name, amount: NSDecimalNumber(value: shoe.price))
      
        ApplePayManager.shared.delegate = self
        ApplePayManager.shared.paymentItem = paymentItem
        ApplePayManager.shared.setupApplePayManager()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        productPickerView.delegate = self
        productPickerView.dataSource = self
        
    }
    
}

extension ViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    // MARK: - Pickerview update
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return productData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return productData[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let priceString = String(format: "%.02f", productData[row].price)
        priceLabel.text = "Price = $\(priceString)"
    }
}


extension ViewController:ApplePayManagerDelegate{
    func applePayDidSucceed() {
        print("Payment did succeed")
    }
}
