//
//  ServicesViewController.swift
//  CCBluetooth
//
//  Created by Kevin Tallevi on 7/6/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import CCBluetooth
import CoreBluetooth

class ServicesViewController: UITableViewController, BluetoothServiceProtocol {
    var peripheral:CBPeripheral!
    let cellIdentifier = "CharacteristicCellIdentifier"
    var servicesAndCharacteristics : [String: [CBCharacteristic]] = [:]
    var characteristic:CBCharacteristic!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ServicesViewController#viewDidLoad")
        Bluetooth.sharedInstance().bluetoothServiceDelegate = self
        self.refreshPeripherals()
        Bluetooth.sharedInstance().discoverAllServices(self.peripheral)
    }

    override func viewWillAppear(_ animated: Bool) {
        print("ServicesViewController#viewWillAppear \(self.peripheral)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cvc =  segue.destination as! CharacteristicViewController
        cvc.peripheral = self.peripheral
        cvc.characteristic = self.characteristic
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return servicesAndCharacteristics.count
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 75
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let title = Array(servicesAndCharacteristics.keys)[section]
        var uuidString: String = "UUID: "
        uuidString.append(title)
        
        return uuidString
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let values = Array(self.servicesAndCharacteristics.values)
        
        return values[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath as IndexPath) as UITableViewCell
        
        let characteristics = Array(servicesAndCharacteristics.values)[indexPath.section]
        let characteristic = characteristics[indexPath.row]
        
        var labelText = ""
        
        if (characteristic.properties.rawValue & CBCharacteristicProperties.read.rawValue > 0)
        {
            labelText.append("Read ");
        }
        if (characteristic.properties.rawValue & CBCharacteristicProperties.write.rawValue > 0)
        {
            labelText.append("Write ");
        }
        if (characteristic.properties.rawValue & CBCharacteristicProperties.notify.rawValue > 0)
        {
            labelText.append("Notify ");
        }
        if (characteristic.properties.rawValue & CBCharacteristicProperties.indicate.rawValue > 0)
        {
            labelText.append("Indicate ");
        }
        
        cell.detailTextLabel!.text = labelText
        cell.textLabel!.text = characteristic.uuid.description
        
        return cell
    }

    //MARK: table delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("didSelectRowAtIndexPath")
        
        tableView.deselectRow(at: indexPath, animated: true)
        let characteristics = Array(servicesAndCharacteristics.values)[indexPath.section]
        let characteristic = characteristics[indexPath.row]
        self.characteristic = characteristic
        print(self.characteristic)
        
        performSegue(withIdentifier: "segueToCharacteristic", sender: self)
    }
    
    // MARK peripheralDelegate methods
    func didDiscoverService(_ service:CBService) {
        print("ServicesViewController#didDiscoverService - \(service)")
    }
    
    //@objc(didDiscoverServiceWithCharacteristics:) func didDiscoverServiceWithCharacteristics(_ service:CBService) {
    func didDiscoverServiceWithCharacteristics(_ service:CBService) {
        print("didDiscoverServiceWithCharacteristics - \(service.uuid.uuidString)")
        servicesAndCharacteristics[service.uuid.uuidString] = service.characteristics
        
        self.refreshPeripherals()
    }
    
    func refreshPeripherals() {
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
    func bluetoothError(_ error:Error?) {
        print("error: \(error)")
    }
}
