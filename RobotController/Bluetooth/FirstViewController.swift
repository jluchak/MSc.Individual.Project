//
//  FirstViewController.swift
//  RobotController
//
//  Created by Jenna Luchak on 2018-07-06.
//  Copyright © 2018 Jenna Luchak. All rights reserved.
//
// * Help from online tutorial
// URL: https://www.raywenderlich.com/85900/arduino-tutorial-integrating-bluetooth-le-ios-swift
// *

import UIKit
import CoreBluetooth


class FirstViewController: UIViewController
{
    var firstTimePressed = false
    /////
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //self.statusLabel.text = "Scanning for devices..."
        // Start the Bluetooth discovery process
        _ = btDiscoverySharedInstance
        
        // Watch Bluetooth connection
        NotificationCenter.default.addObserver(self, selector: #selector(FirstViewController.connectionChanged(_:)), name: NSNotification.Name(rawValue: BLEServiceChangedStatusNotification), object: nil)

    }
    //////
    // Outlets/actions
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var btOffLabel1: UILabel!
    @IBOutlet weak var overrideButton: UIButton!
    @IBOutlet weak var btOffLabel2: UILabel!
    
    @IBAction func overrideAction(_ sender: Any)
    {
        firstTimePressed = true
    }
    
    deinit
    {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: BLEServiceChangedStatusNotification), object: nil)
    }

    @objc func connectionChanged(_ notification: Notification)
    {
        // Connection status changed. Indicate on GUI.
        let userInfo = (notification as NSNotification).userInfo as! [String: Bool]
        
        DispatchQueue.main.async(execute:
            {
            // Set image based on connection status
            if let isConnected: Bool = userInfo["isConnected"]
            {
                if isConnected
                {
                    //self.imgBluetoothStatus.image = UIImage(named: "Bluetooth_Connected")
                    
                    self.connectButton.isEnabled = true
                    
                    self.statusLabel.text = "Bluetooth Connected"
                    self.statusLabel.textColor = .green
                    
                    self.btOffLabel1.textColor = .clear
                    self.btOffLabel2.textColor = .clear
                    
                } else
                {
                    //self.imgBluetoothStatus.image = UIImage(named: "Bluetooth_Disconnected")
                    
                    self.connectButton.isEnabled = false
                    
                    self.statusLabel.text = "Bluetooth Disconnected"
                    self.btOffLabel1.textColor = .black
                    self.btOffLabel2.textColor = .black
                    self.statusLabel.textColor = .red
                    
                    // Segue back to root view controller
                    if self.firstTimePressed == false
                    {
                        _ = self.navigationController?.popToRootViewController(animated: true)
                    }
                }
            }
        });
    }
}

