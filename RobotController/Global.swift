//
//  Global.swift
//  RobotController
//
//  Created by Jenna Luchak on 2018-07-06.
//  Copyright © 2018 Jenna Luchak. All rights reserved.
//

import Foundation
import CoreBluetooth

class Main{
    var positionCharacteristic: CBCharacteristic?
    init(positionCharacteristic: CBCharacteristic?){
        self.positionCharacteristic = positionCharacteristic
    }
}
var positionCharacteristic = Main(positionCharacteristic: CBCharacteristic?)

