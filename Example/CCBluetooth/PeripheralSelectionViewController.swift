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
    var serviceUUIDString:String = "181F"  //1808
    var autoEnableNotifications:Bool = false
    var discoveredPeripherals: Array<CBPeripheral> = Array<CBPeripheral>()
    var previouslyConnectedPeripherals: Array<CBPeripheral> = Array<CBPeripheral>()
    var peripheral : CBPeripheral!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("PeripheralSelectionViewController#viewDidLoad")
        
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl?.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        
        Bluetooth.sharedInstance().bluetoothDelegate = self
        Bluetooth.sharedInstance().bluetoothPeripheralDelegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        self.refreshPeripherals()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func onRefresh() {
        Bluetooth.sharedInstance().stopScanning()
        Bluetooth.sharedInstance().startScanning(false)
        
        refreshControl?.endRefreshing()
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
        print("PeripheralSelectionViewController#didConnectPeripheral \(String(describing: cbPeripheral.name))")
        
        self.peripheral = cbPeripheral
        self.addPreviouslyConnectedPeripheral(cbPeripheral)
        self.discoveredPeripherals.removeAll()

        self.performSegue(withIdentifier: "segueToServices", sender: self)
    }
    
    public func didDisconnectPeripheral(_ cbPeripheral: CBPeripheral) {
        print("PeripheralSelectionViewController#didDisconnectPeripheral \(cbPeripheral)")
    }
    
    func didDiscoverPeripheral(_ cbPeripheral:CBPeripheral) {
        print("PeripheralSelectionViewController#didDiscoverPeripheral")
        discoveredPeripherals.append(cbPeripheral)
        print("device name: \(String(describing: cbPeripheral.name))")
        print("peripherals: \(self.discoveredPeripherals)")
        
        self.refreshPeripherals()
    }
    
    func addPreviouslyConnectedPeripheral(_ cbPeripheral:CBPeripheral) {
        var peripheralAlreadyExists: Bool = false
        
        for aPeripheral in self.previouslyConnectedPeripherals {
            if (aPeripheral.identifier.uuidString == cbPeripheral.identifier.uuidString) {
                peripheralAlreadyExists = true
            }
        }
        
        if (!peripheralAlreadyExists) {
            self.previouslyConnectedPeripherals.append(cbPeripheral)
        }
    }
    
    // MARK: Table data source methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {
            return "Discovered Peripherals"
        } else {
            return "Previously Connected Peripherals"
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return discoveredPeripherals.count
        } else {
            return previouslyConnectedPeripherals.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath as IndexPath) as UITableViewCell
        
        if (indexPath.section == 0) {
            let peripheral = Array(self.discoveredPeripherals)[indexPath.row]
            cell.textLabel!.text = peripheral.name
            cell.detailTextLabel!.text = peripheral.identifier.uuidString
        } else {
            let peripheral = Array(self.previouslyConnectedPeripherals)[indexPath.row]
            cell.textLabel!.text = peripheral.name
            cell.detailTextLabel!.text = peripheral.identifier.uuidString
        }
        
        return cell
    }
    
    //MARK: table delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("didSelectRowAtIndexPath")
        tableView.deselectRow(at: indexPath, animated: true)
        Bluetooth.sharedInstance().stopScanning()
        
        if (indexPath.section == 0) {
            self.didSelectDiscoveredPeripheral(Array(self.discoveredPeripherals)[indexPath.row])
        } else {
            self.didSelectPreviouslyConnectedPeripheral(Array(self.previouslyConnectedPeripherals)[indexPath.row])
        }
    }
    
    func didSelectDiscoveredPeripheral(_ peripheral:CBPeripheral) {
        print("ViewController#didSelectDiscoveredPeripheral \(String(describing: peripheral.name))")
        Bluetooth.sharedInstance().connectPeripheral(peripheral)
    }
    
    func didSelectPreviouslyConnectedPeripheral(_ peripheral:CBPeripheral) {
        print("ViewController#didSelectPreviouslyConnectedPeripheral \(String(describing: peripheral.name))")
        Bluetooth.sharedInstance().reconnectPeripheral(peripheral.identifier.uuidString)
    }
    
    func refreshPeripherals() {
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
    func bluetoothError(_ error:Error?) {
        print("error: \(String(describing: error))")
    }
}

