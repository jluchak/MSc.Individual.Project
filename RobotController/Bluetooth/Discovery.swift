//
//  Discovery.swift
//  RobotController
//
//  Created by Jenna Luchak on 2018-07-06.
//  Copyright © 2018 Jenna Luchak. All rights reserved.
//

import Foundation
import CoreBluetooth

let btDiscoverySharedInstance = Discovery();

class Discovery: NSObject, CBCentralManagerDelegate
{
    
    var centralManager: CBCentralManager?
    var thePeripheral: CBPeripheral?

    
    override init()
    {
        super.init()
        
        let centralQueue = DispatchQueue(label: "JKL.RobotController", attributes: [])
        centralManager = CBCentralManager(delegate: self, queue: centralQueue)
    
    }

    
    @objc func startScanning()
    {
        if let central = centralManager
        {
            central.scanForPeripherals(withServices: [Service_BLE_UUID], options: nil)
        }
    }
    
    var bleService: Service?
    {
        didSet
        {
            if let service = self.bleService
            {
                service.startDiscoveringServices()
            }
        }
    }
    
    // MARK: - CBCentralManagerDelegate
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber)
    {
        // Be sure to retain the peripheral or it will fail during connection.
        
        // Validate peripheral information
        if ((peripheral.name == nil) || (peripheral.name == "C3649E0C-04CE-7B3B-DABF-BF9548D3E699"))
        {
            return
        }
        
        // If not already connected to a peripheral, then connect to this one
        if ((self.thePeripheral == nil) || (self.thePeripheral?.state == CBPeripheralState.disconnected))
        {
            // Retain the peripheral before trying to connect
            self.thePeripheral = peripheral
            
            // Reset service
            self.bleService = nil
            
            // Connect to peripheral
            central.connect(peripheral, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral)
    {
        
        // Create new service class
        if (peripheral == self.thePeripheral)
        {
            self.bleService = Service(initWithPeripheral: peripheral)
        }
        
        //
        
        // Stop scanning for new devices
        central.stopScan()
        print("Scanning stopped")
        //_ = FirstViewController().scanStopped
        
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?)
    {
        
        // See if it was our peripheral that disconnected
        if (peripheral == self.thePeripheral)
        {
            self.bleService = nil;
            self.thePeripheral = nil;
        }
        
        // Start scanning for new devices
        self.startScanning()
        
    }
    
    
    // MARK: - Private


    func clearDevices()
    {
        self.bleService = nil
        self.thePeripheral = nil
    }
    
        
    func centralManagerDidUpdateState(_ central: CBCentralManager)
    {
        switch (central.state)
        {
            
        case .poweredOff:
            self.clearDevices()
            
        case .unauthorized:
            // Indicate to user that the iOS device does not support BLE.
            break
            
        case .unknown:
            // Wait for another event
            break
            
        case .poweredOn:
            self.startScanning()
            
        case .resetting:
            self.clearDevices()
            
        case .unsupported:
            break
        }
    }
    
    
}

