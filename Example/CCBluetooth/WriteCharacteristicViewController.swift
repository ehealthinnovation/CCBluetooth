//
//  WriteCharacteristicViewController.swift
//  CCBluetooth
//
//  Created by Kevin Tallevi on 7/8/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import CCBluetooth
import CCToolbox
import CoreBluetooth

class WriteCharacteristicViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var writeField: UITextField!
    var peripheral:CBPeripheral!
    var characteristic:CBCharacteristic!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("WriteCharacteristicViewController#viewDidLoad")
        //CentralManager.sharedInstance().writeCharacteristicDelegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.writeField.becomeFirstResponder()
        self.writeField.returnKeyType = .done
        self.writeField.delegate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.writeField.resignFirstResponder()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.writeField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let str = self.writeField.text!
        let data = str.dataFromHexadecimalString()
        Bluetooth.sharedInstance().writeCharacteristic(self.characteristic, data: data! as Data)
        return true
    }
    
    func didWriteValueForCharacteristic(_ cbPeripheral: CBPeripheral, didWriteValueFor descriptor:CBDescriptor, error: NSError?) {
        print("didWriteValueForCharacteristic \(descriptor.characteristic.value)")
    }
}
