//
//  ViewController.swift
//  CCBluetooth
//
//  Created by Kevin Tallevi on 07/05/2016.
//  Copyright (c) 2016 Kevin Tallevi. All rights reserved.
//

import UIKit
import CCBluetooth
import CoreBluetooth

class PeripheralSelectionViewController: UITableViewController, BluetoothProtocol, BluetoothPeripheralProtocol {
    let cellIdentifier = "PeripheralCellIdentifier"
    var serviceUUIDString:String = "1808"
    var autoEnableNotifications:Bool = false
    var peripherals: Array<CBPeripheral> = Array<CBPeripheral>()
    var peripheral : CBPeripheral!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("PeripheralSelectionViewController#viewDidLoad")
        Bluetooth.sharedInstance().bluetoothDelegate = self
        Bluetooth.sharedInstance().bluetoothPeripheralDelegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        self.refreshPeripherals()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("PeripheralSelectionViewController#prepareForSegue")
        let svc =  segue.destination as! ServicesViewController
        svc.peripheral = self.peripheral
    }
    
    //MARK CentralManagerProtocol methods
    func bluetoothIsAvailable() {
        Bluetooth.sharedInstance().startScanning(false)
    }
    
    func bluetoothIsUnavailable() {
        Bluetooth.sharedInstance().stopScanning()
    }
    
    func didConnectPeripheral(_ cbPeripheral:CBPeripheral) {
        print("PeripheralSelectionViewController#didConnectPeripheral \(cbPeripheral)")
        print("PeripheralSelectionViewController#didConnectPeripheral \(cbPeripheral.name)")
        
        self.peripheral = cbPeripheral
        self.performSegue(withIdentifier: "segueToServices", sender: self)
    }
    
    func didDiscoverPeripheral(_ cbPeripheral:CBPeripheral) {
        print("PeripheralSelectionViewController#didDiscoverPeripheral")
        peripherals.append(cbPeripheral)
        print("device name: \(cbPeripheral.name)")
        print("peripherals: \(self.peripherals)")
        
        self.refreshPeripherals()

    }
    
    // MARK: Table data source methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath as IndexPath) as UITableViewCell
        
        let peripheral = Array(self.peripherals)[indexPath.row]
        cell.textLabel!.text = peripheral.name
        
        return cell
    }
    
    //MARK: table delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("didSelectRowAtIndexPath")
        tableView.deselectRow(at: indexPath, animated: true)
        
        Bluetooth.sharedInstance().stopScanning()
        self.didSelectPeripheral(Array(self.peripherals)[indexPath.row])
    }
    
    func didSelectPeripheral(_ peripheral:CBPeripheral) {
        print("ViewController#didSelectPeripheral \(peripheral.name)")
        Bluetooth.sharedInstance().connectPeripheral(peripheral)
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

