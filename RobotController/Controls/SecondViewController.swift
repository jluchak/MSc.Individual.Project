//
//  SecondViewController.swift
//  RobotController
//
//  Created by Jenna Luchak on 2018-07-07.
//  Copyright © 2018 Jenna Luchak. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreGraphics


class SecondViewController: UIViewController
{
    // Define outlets
    @IBOutlet weak var speedValue: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var radiusLabel: UILabel!
    @IBOutlet weak var radiusValue: UILabel!
    @IBOutlet weak var angleLabel: UILabel!
    @IBOutlet weak var angleValue: UILabel!
    
    // Initialize variables
    var lastSpeed: Int = 0
    var lastXCord: Int = 101
    var lastYCord: Int = 101

    ///////////////////////////////////////////////////////
    // Begin Slider Functions
    ///////////////////////////////////////////////////////
    // Setup Slider
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Rotate slider to vertical position
        let superView = self.slider.superview
        slider.removeFromSuperview()
        slider.removeConstraints(self.view.constraints)
        slider.translatesAutoresizingMaskIntoConstraints = true
        slider.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 3 / 2)) // 270deg
        
        // Define slider properties
        slider.frame = CGRect(x: 0.0, y: 0.0, width: 50.0, height: 310.0)
        superView?.addSubview(self.slider)
        slider.autoresizingMask = [UIView.AutoresizingMask.flexibleLeftMargin, UIView.AutoresizingMask.flexibleRightMargin]
        slider.center = CGPoint(x: 109, y:190)
        slider.minimumValue = -6;
        slider.maximumValue = 6;
        
        // Set thumb image on slider
        slider.setThumbImage(UIImage(named: "SliderHandle"), for: UIControl.State())

        // Reset slider after no touch is observed
        slider.addTarget(self, action: #selector(sliderDidEndSliding), for: [.touchUpInside, .touchUpOutside])
    }
    
    // Something to do when touch is observed
    @IBAction func valueSliderChanged(_ sender: UISlider)
    {
        if Int(sender.value) > 0
        {
            speedValue.text = "FORWARD"
            speedValue.textColor = .green
        }
        else // Int(send.value) < 0
        {
            speedValue.text = "REVERSE"
            speedValue.textColor = .green
        }
        self.sendSpeed(Int(sender.value))
    }

    // Something to do when NO touch is observed
    @objc func sliderDidEndSliding()
    {
        speedValue.text = "STOPPED"
        speedValue.textColor = .red
        slider.value = 0;
        self.sendSpeed(Int(slider.value))
        print("end sliding") // Check to see if working
    }

    // Send data to BLE Shield write function (if service exists and is connected)
    func sendSpeed(_ speed: Int)
    {
        if ((speed == lastSpeed) && (speed == 0))
        {
            return // Do NOT send data
        }
            
        else if ((speed < Int(slider.minimumValue)) || (speed > Int(slider.maximumValue)))
        {
            return // Do NOT send data
        }
        
        if let bleService = btDiscoverySharedInstance.bleService
        {
            bleService.writeSpeed(speed) // Send data
            lastSpeed = speed; // Update
        }
        print("Slider sent") // Check to see if working
    }
    ///////////////////////////////////////////////////////
    // End Slider Functions
    ///////////////////////////////////////////////////////
    
    ///////////////////////////////////////////////////////
    // Begin Joystick Functions
    ///////////////////////////////////////////////////////
    // Set up joystick
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        // Define joystick structure and size
        let size = CGSize(width: 150.0, height: 150.0)
        let joystickFrame = CGRect(origin: CGPoint(x: (425), y: (143)), size: size)
        
        // Something to do when Joystick moves
        let joystick = JoyStick(frame: joystickFrame)
        joystick.monitor =
            {
                angle, displacement, stopTouch in
                let angleRound = Double(round(angle))
                let displacementRound = Double(round(displacement*100)/100)
                
                let xCord = Int(round(displacementRound * sin(angleRound * Double.pi / 180)*100))
                let yCord = Int(round(displacementRound * cos(angleRound * Double.pi / 180)*100))

                if stopTouch == 1
                {
                    self.sendDirection(Int(xCord), yCord: Int(yCord))
                }
                
                let angleDisplay = angleRound
                let displacementDisplay = displacementRound * 100
                self.angleValue.text = "\(angleDisplay)"
                self.radiusValue.text = "\(displacementDisplay)"
            }

        view.addSubview(joystick)
        joystick.alpha = 1.0
        joystick.baseAlpha = 0.5 // let the background bleed thru the base
        joystick.handleTintColor = UIColor.lightGray // Colorize the handle
    }
    
    // Send data to BLE Shield write function (if service exists and is connected)
    func sendDirection(_ xCord: Int, yCord: Int)
    {
        // Validate value
        if xCord == lastXCord || yCord == lastYCord
        {
            return // Do NOT send data
        }
            
        else if ((xCord < -100 || (xCord > 100)) || ((yCord < -100) || (yCord > 100)))
        {
            return // Do NOT send data
        }

        if let bleService = btDiscoverySharedInstance.bleService
        {
            bleService.writeDirection(xCord: Int(xCord), yCord: Int(yCord)) // Send data
            lastXCord = xCord // Update
            lastYCord = yCord // Update
        }
        print("Joystick sent") // Check to see if working
    }
    ///////////////////////////////////////////////////////
    // End Joystick Functions
    ///////////////////////////////////////////////////////

    // Teardown Function
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
    }
    
    // Dispose of any resources that can be recreated
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Put resources here.
    }
}
///////////////////////////////////////////////////////
// End of Second View Controller
///////////////////////////////////////////////////////
