//
//  PeripheralTableViewController.swift
//  BLENavigator
//
//  Created by Samuel Fuhrer on 8/14/17.
//  Copyright © 2017 Samuel Fuhrer. All rights reserved.
//

import UIKit
import CoreBluetooth


class PeripheralsTableViewController: UITableViewController, CBCentralManagerDelegate, CBPeripheralDelegate {

    
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

    //MARK: Poperties
    var peripherals = [Peripheral]()

    
    func add(peripheral: Peripheral) {
        let newIndexPath = IndexPath(row: peripherals.count, section: 0)

        peripherals.append(peripheral)
        tableView.insertRows(at: [newIndexPath], with: .automatic)
    }
    
    //MARK: Private methods
    private func loadPeripherals() {
        //peripherals += [Peripheral(name: "peri1"), Peripheral(name: "peri3"),Peripheral(name: "peri3")]
        peripherals.append(Peripheral(name: "peri1"))
        peripherals.append(Peripheral(name: "peri2"))
        peripherals.append(Peripheral(name: "peri3"))

        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager = CBCentralManager(delegate: self, queue: nil)
        loadPeripherals()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
       return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return peripherals.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "PeripheralsTableViewCell"

        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? PeripheralsTableViewCell  else {
            fatalError("The dequeued cell is not an instance of PeripheralsTableViewCell.")
        }
        
        let peripheral = peripherals[indexPath.row]
        cell.nameLabel.text = peripheral.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ServicesSegue", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
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
        peripheral.delegate = self
        peripheral.readRSSI()
        
        peripheral.discoverServices(nil)
        peripheral.discoverServices([CBUUID(string: "00001234-B38D-4985-720E-0F993A68EE41"), CBUUID(string: "00002234-B38D-4985-720E-0F993A68EE41"), CBUUID(string: "180F")])
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        add(peripheral: Peripheral(name: peripheral.name ?? "Unknown"))
        
        // print("DidDiscover: " + peripheral.name!)
        
        if (peripheral.name == "Smart Humigadget") {
            print("Humi gadget discovered")
            self.peripheral = peripheral
            manager!.connect(peripheral, options: nil)
            if (manager!.isScanning) {
                manager!.stopScan()
                print("** stop scanning")
            }
        }
    }


}
