//
//  CharacteristicViewController.swift
//  CCBluetooth
//
//  Created by Kevin Tallevi on 7/7/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import CCBluetooth
import CoreBluetooth
import CCToolbox

class CharacteristicViewController: UITableViewController, BluetoothCharacteristicProtocol {
    var peripheral:CBPeripheral!
    var characteristic:CBCharacteristic!
    let cellIdentifier = "CharacteristicDetailCellIdentifier"
    var headers = [String]()
    var readValues = [Data]()
    var notificationEnabled = false
    var indicationEnabled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("CharacteristicViewController#viewDidLoad")
        Bluetooth.sharedInstance().bluetoothCharacteristicDelegate = self
        self.setupArrays()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("CharacteristicViewController#viewWillAppear \(self.characteristic)")
        self.refreshPeripherals()
    }
    
    func setupArrays() {
        if (characteristic.properties.rawValue & CBCharacteristicProperties.read.rawValue > 0)
        {
            self.headers.append("Read")
        }
        if (characteristic.properties.rawValue & CBCharacteristicProperties.write.rawValue > 0)
        {
            self.headers.append("Write")
        }
        if (characteristic.properties.rawValue & CBCharacteristicProperties.notify.rawValue > 0)
        {
            self.headers.append("Notification")
        }
        if (characteristic.properties.rawValue & CBCharacteristicProperties.indicate.rawValue > 0)
        {
            self.headers.append("Indication")
        }
        
        print(self.headers)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let wcv =  segue.destination as! WriteCharacteristicViewController
        wcv.peripheral = self.peripheral
        wcv.characteristic = self.characteristic
    }
    
    //MARK
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.headers.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let header = Array(self.headers)[section]
        
        return header
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let header = Array(self.headers)[section]
        
        if (header.range(of: "Read") != nil) {
            return self.readValues.count + 1
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath as IndexPath) as UITableViewCell

        let header = Array(self.headers)[indexPath.section]
        var labelText = ""
        
        switch header {
            case "Read":
                if(indexPath.row == 0) {
                    labelText = "Read Value"
                } else {
                    let data:NSData = Array(self.readValues)[indexPath.row-1] as NSData
                    let hexString = data.toHexString()
                    print("\(hexString)")
                    labelText = hexString
                }
            case "Write":
                labelText = "Write Value"
            case "Notification":
                if (notificationEnabled) {
                    labelText = "Disable Notification"
                } else {
                    labelText = "Enable Notification"
                }
            case "Indication":
                if (indicationEnabled) {
                    labelText = "Disable Indication"
                } else {
                    labelText = "Enable Indication"
            }
            default:
                print("")
        }
        
        cell.textLabel!.text =  labelText
        
        return cell
    }
    
    //MARK: table delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("didSelectRowAtIndexPath")
        
        tableView.deselectRow(at: indexPath, animated: true)
        let header = Array(self.headers)[indexPath.section]
        
        switch header {
            case "Read":
                Bluetooth.sharedInstance().readCharacteristic(self.characteristic)
            case "Write":
                performSegue(withIdentifier: "segueToWriteCharacteristic", sender: self)
            case "Notification":
                print("toggling notification")
                if (notificationEnabled) {
                    self.peripheral.setNotifyValue(false, for: characteristic)
                    notificationEnabled = false
                } else {
                    self.peripheral.setNotifyValue(true, for: characteristic)
                    notificationEnabled = true
                }
            case "Indication":
                print("toggling indication")
                if (indicationEnabled) {
                    self.peripheral.setNotifyValue(false, for: characteristic)
                    indicationEnabled = false
                } else {
                    self.peripheral.setNotifyValue(true, for: characteristic)
                    indicationEnabled = true
                }
            default:
                print("")
        }
    }
    
    func refreshPeripherals() {
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
    // MARK
    func didUpdateNotificationStateFor(_ characteristic:CBCharacteristic) {
        print("CharacteristicViewController#didUpdateNotificationStateFor: \(characteristic)")
        if(characteristic.isNotifying) {
            notificationEnabled = true
        } else {
            notificationEnabled = false
        }
        self.refreshPeripherals()
    }
    
    public func didUpdateValueForCharacteristic(_ cbPeripheral: CBPeripheral, characteristic:CBCharacteristic) {
        print("CharacteristicViewController#didUpdateValueForCharacteristic")
        let data = characteristic.value
        print(data!)
        
        self.readValues.append(characteristic.value!)
        self.refreshPeripherals()
    }
    
    func bluetoothError(_ error:Error?) {
        print("error: \(String(describing: error))")
    }
    
    func didWriteValueForCharacteristic(_ cbPeripheral: CBPeripheral, didWriteValueFor descriptor:CBDescriptor) {
        
    }
}
