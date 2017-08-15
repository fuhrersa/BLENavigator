//
//  CentralManager.swift
//  BLENavigator
//
//  Created by Samuel Fuhrer on 8/15/17.
//  Copyright © 2017 Samuel Fuhrer. All rights reserved.
//

import CoreBluetooth

class CentralManager:  NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    //MARK: Proberties
    var manager: CBCentralManager? = nil
    var humi: Float = 0.0
    var temp: Float = 0.0
    
    let humiUUID = "00001235-B38D-4985-720E-0F993A68EE41"
    let tempUUID = "00002235-B38D-4985-720E-0F993A68EE41"
    let batteryLevelUUID    = "2A19"
    let manufacturerUUID    = "2A29" // UTF 8 string
    let modelNumberUUID     = "2A24" // UTF8 string
    let serialNumberUUID    = "2A25" // UTF8 string
    let firmwareVersionUUID = "2A26" // UTF8 string
    let hardwareVersionUUID = "2A27" // UTF8 string
    let softwareVersionUUID = "2A28" // UTF8 string
    
    
    
    
    
    var humiChar : CBCharacteristic? = nil
    var tempChar : CBCharacteristic? = nil
    
    var peripheral: CBPeripheral? = nil
    
    override init() {
        super.init()
        manager = CBCentralManager(delegate: self, queue: nil)
    }

    
    func scanBLEDevices() {
        print("** start scanning")
        
        manager?.scanForPeripherals(withServices: nil, options:nil)
        DispatchQueue.main.asyncAfter(deadline: .now()+5.0, execute: {
            if (self.manager!.isScanning) {
                self.manager!.stopScan()
                print("** stop scanning")
            }
        })
    }
    
    // MARK: CBPeripheralDelegate methods
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services ?? [] {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        //<#code#>
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("\n")
        print("Characteristics for service " + service.description)
        for characteristic in service.characteristics ?? [] {
            peripheral.readValue(for: characteristic)
            print("  " + characteristic.description)
        }
    }
    
    func dataToString(_ data: Data) -> String? {
        let value: String? = data.withUnsafeBytes({
            (pointer: UnsafePointer<String>) -> String? in
            return pointer.pointee
        })
        return value
    }
    
    func dataToFloat32(_ data: Data) -> Float32? {
        let value: Float32? = data.withUnsafeBytes({
            (pointer: UnsafePointer<Float32>) -> Float32? in
            if MemoryLayout<Float32>.size != data.count { return nil}
            return pointer.pointee
        })
        return value
    }
    
    func dataToUInt8(_ data: Data) -> UInt8? {
        let value: UInt8? = data.withUnsafeBytes({
            (pointer: UnsafePointer<UInt8>) -> UInt8? in
            if MemoryLayout<UInt8>.size != data.count { return nil}
            return pointer.pointee
        })
        return value
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        switch(characteristic.uuid.uuidString) {
        case(humiUUID):
            let value = dataToFloat32(characteristic.value!)
            print("Humi = \(value!) %")
            
        case(tempUUID):
            let value = dataToFloat32(characteristic.value!)
            print("Temp = \(value!) degC")
            
        case (batteryLevelUUID):
            let value = dataToUInt8(characteristic.value!)
            print("Battery level = \(value!) %")
            
        case(manufacturerUUID):
            if let str = String(data: characteristic.value!, encoding: .utf8) {
                print("Manufacturer: " + str)
            }
            
        case(modelNumberUUID):
            if let str = String(data: characteristic.value!, encoding: .utf8) {
                print("Model number: " + str)
            }
            
        case(serialNumberUUID):
            if let str = String(data: characteristic.value!, encoding: .utf8) {
                print("Serial number: " + str)
            }
            
        case(firmwareVersionUUID):
            if let str = String(data: characteristic.value!, encoding: .utf8) {
                print("Firmware revision number: " + str)
            }
            
        case(hardwareVersionUUID):
            if let str = String(data: characteristic.value!, encoding: .utf8) {
                print("Hardware revision number: " + str)
            }
            
        case(softwareVersionUUID):
            if let str = String(data: characteristic.value!, encoding: .utf8) {
                print("Software revision number: " + str)
            }
            
            
        default:
            print(characteristic.uuid.uuidString + ": \(characteristic.value)")
            
        }
    }
    
    // MARK: CBCentralManagerDelegate methods
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print(central.state)
        switch(central.state) {
        case CBManagerState.poweredOn:
            scanBLEDevices()
        default: break
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        print("RSSI:" + RSSI.stringValue)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("** did disconnect")
        
    }
    
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("** did connect")
       // peripheral.delegate = self
        peripheral.readRSSI()
        peripheral.discoverServices(nil)
        //peripheral.discoverServices([CBUUID(string: "00001234-B38D-4985-720E-0F993A68EE41"), CBUUID(string: "00002234-B38D-4985-720E-0F993A68EE41"), CBUUID(string: "180F")])
    }
    
    func stateToString(state: CBPeripheralState) -> String {
        switch (state) {
        case (CBPeripheralState.connected): return "connected"
        case (CBPeripheralState.disconnected): return "disconnected"
        default: return "unknown"
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
       // add(peripheral: Peripheral(name: peripheral.name ?? "Unknown"))
        
        print("Peripheral.name" + peripheral.name!)
        print("RSSI:" + RSSI.description)
        print("Peripheral.state=" + stateToString(state: peripheral.state))
        
        /*
        
        if (peripheral.name == "Smart Humigadget") {
            print("Humi gadget discovered")
            self.peripheral = peripheral
            manager!.connect(peripheral, options: nil)
            if (manager!.isScanning) {
                manager!.stopScan()
                print("** stop scanning")
            }
        }*/
    }

    
}
