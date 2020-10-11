//
//  Service.swift
//  RobotController
//
//  Created by Jenna Luchak on 2018-07-06.
//  Copyright © 2018 Jenna Luchak. All rights reserved.
//

import Foundation
import CoreBluetooth


/* Services UUID */
let Service_BLE_UUID = CBUUID(string: "713D0000-503E-4C75-BA94-3148F18D941E") //
/* Characteristic UUID's */
let Characteristic_write_UUID = CBUUID(string: "713D0003-503E-4C75-BA94-3148F18D941E") // write without response
let Characteristic_notify_UUID = CBUUID(string: "713D0002-503E-4C75-BA94-3148F18D941E") // notify

let BLEServiceChangedStatusNotification = "BLEServiceChangedStatusNotification"

class Service: NSObject, CBPeripheralDelegate
{

    var peripheral: CBPeripheral?
    var TXCharacteristic: CBCharacteristic?
    

    init(initWithPeripheral peripheral: CBPeripheral)
    {
        super.init()
        
        self.peripheral = peripheral
        self.peripheral?.delegate = self
    }
    
    deinit
    {
        self.reset()
    }
    
    func startDiscoveringServices()
    {
        self.peripheral?.discoverServices([Service_BLE_UUID])
    }
    
    func reset()
    {
        if peripheral != nil
        {
            peripheral = nil
        }
        
        // Deallocating therefore send notification
        self.sendServiceNotificationWithIsBluetoothConnected(false)
    }
    
    // Mark: - CBPeripheralDelegate
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?)
    {
        let uuidsForBTService: [CBUUID] = [Characteristic_write_UUID]
        
        if (peripheral != self.peripheral)
        {
            // Wrong Peripheral
            return
        }
        
        if (error != nil)
        {
            return
        }
        
        if ((peripheral.services == nil) || (peripheral.services!.count == 0))
        {
            // No Services
            return
        }
        
        for service in peripheral.services!
        {
            if service.uuid == Service_BLE_UUID
            {
                peripheral.discoverCharacteristics(uuidsForBTService, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if (peripheral != self.peripheral)
        {
            // Wrong Peripheral
            print("wrong peripheral")
            return
        }
        
        if (error != nil) {
            print("Errors")
            return
        }
        
        if let characteristics = service.characteristics
        {
            for characteristic in characteristics
            {
                if characteristic.uuid == Characteristic_write_UUID
                {
                    self.TXCharacteristic = (characteristic)
                    peripheral.setNotifyValue(true, for: characteristic)
                    
                    // Send notification that Bluetooth is connected and all required characteristics are discovered
                    self.sendServiceNotificationWithIsBluetoothConnected(true)
                }
            }
        }
    }
    
    func sendServiceNotificationWithIsBluetoothConnected(_ isBluetoothConnected: Bool)
    {
        let connectionDetails = ["isConnected": isBluetoothConnected]
        NotificationCenter.default.post(name: Notification.Name(rawValue: BLEServiceChangedStatusNotification), object: self, userInfo: connectionDetails)
    }
    
    
    /* Write to the Services Characteristic */
    func writeSpeed(_ speed: Int)
    {
        // See if characteristic has been discovered before writing to it
        if let TXCharacteristic = self.TXCharacteristic
        {
            let s = speed
            
            if (s > 0) // Forward
            {
                let testing = "F>"
                let data = testing.data(using: .utf8)
                self.peripheral?.writeValue(data!, for: TXCharacteristic, type: CBCharacteristicWriteType.withoutResponse)
                print("Data Sent")
                print(testing)
            }
            else if (s < 0) // Backward
            {
                let testing = "B>"
                let data = testing.data(using: .utf8)
                self.peripheral?.writeValue(data!, for: TXCharacteristic, type: CBCharacteristicWriteType.withoutResponse)
                print("Data Sent")
                print(testing)
            }
            else
            {
                let testing = "S>"
                let data = testing.data(using: .utf8)
                self.peripheral?.writeValue(data!, for: TXCharacteristic, type: CBCharacteristicWriteType.withoutResponse)
                print("Data Sent")
                print(testing)
            }
        }
        else
        {
            print("Not connected")
        }
    }
    
    func writeDirection(xCord: Int, yCord: Int)
    {
        // See if characteristic has been discovered before writing to it
        if let TXCharacteristic = self.TXCharacteristic
        {
            let x = xCord
            let y = yCord
            
            if (x > 0 || x == 0)
            {
                let stringXP = "R\(x)>"
                let dataXP = stringXP.data(using: .utf8)
                self.peripheral?.writeValue(dataXP!, for: TXCharacteristic, type: CBCharacteristicWriteType.withoutResponse)
            }
            else
            {
                let stringXN = "L\(x)>"
                let dataXN = stringXN.data(using: .utf8)
                self.peripheral?.writeValue(dataXN!, for: TXCharacteristic, type: CBCharacteristicWriteType.withoutResponse)
            }
            
            if (y > 0 || y == 0)
            {
                let stringYP = "U\(y)>"
                let dataYP = stringYP.data(using: .utf8)
                self.peripheral?.writeValue(dataYP!, for: TXCharacteristic, type: CBCharacteristicWriteType.withoutResponse)
            }
            else
            {
                let stringYN = "D\(y)>"
                let dataYN = stringYN.data(using: .utf8)
                self.peripheral?.writeValue(dataYN!, for: TXCharacteristic, type: CBCharacteristicWriteType.withoutResponse)
            }
                
            print("Data Sent")
            print(xCord)
            print(yCord)
        }
        else
        {
            print("Not connected")
        }
    }


    
}
