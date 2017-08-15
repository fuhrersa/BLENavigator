//
//  PeripheralTableViewController.swift
//  BLENavigator
//
//  Created by Samuel Fuhrer on 8/14/17.
//  Copyright © 2017 Samuel Fuhrer. All rights reserved.
//

import UIKit
import CoreBluetooth


class PeripheralsTableViewController: UITableViewController, CBCentralManagerDelegate {

    
    //MARK: Poperties
    var peripherals = [CBPeripheral]()
    var manager: CBCentralManager? = nil
    
    func add(peripheral: CBPeripheral) {
        let indexPath = IndexPath(row: peripherals.count, section: 0)
        peripherals.append(peripheral)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    func remove(peripheral: CBPeripheral) {
        if let index = peripherals.index(of: peripheral) {
            let indexPath = IndexPath(row: index, section: 0)
            peripherals.remove(at: index)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }


    
    // MARK: CBCentralManagerDelegate methods
    
  

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        //tbd
    }
    
    
    func scanBLEDevices() {
        print("** start scanning")
        peripherals.removeAll()
        tableView.reloadData()

        manager!.scanForPeripherals(withServices: nil, options:nil)
        DispatchQueue.main.asyncAfter(deadline: .now()+5.0, execute: {
            if (self.manager!.isScanning) {
                self.manager!.stopScan()
                self.refreshControl!.endRefreshing()
                self.tableView.reloadData()
                print("** stop scanning")
            }
        })
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch(central.state) {
        case CBManagerState.poweredOn:
            print("** didUpdateState: poweredOn")
            scanBLEDevices()
        case CBManagerState.poweredOff:
            print("** didUpdateState: poweredOff")
        case CBManagerState.resetting:
            print("** didUpdateState: resetting")
        case CBManagerState.unauthorized:
            print("** didUpdateState: unauthorized")
        case CBManagerState.unsupported:
            print("** didUpdateState: unsupported")
        default:
            print("** didUpdateState: unknown")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard (!peripherals.contains(peripheral)) else { return }
     
        print("** didDiscover: " + (peripheral.name ?? "unknown device") + ", RSSI = " + RSSI.description)
        
        add(peripheral: peripheral)
        
    }

    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("** didDisconnect: " + (peripheral.name ?? "unknown device"))
    }
    
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("** didConnect: " + (peripheral.name ?? "unknown device"))
        peripheral.discoverServices(nil)
    }
    
    
    //MARK: Private methods
   

    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager = CBCentralManager(delegate: self, queue: nil)
    }

  
  
    @IBAction func refreh(_ sender: UIRefreshControl) {
        scanBLEDevices()

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
        cell.nameLabel.text = peripheral.name ?? "unknown"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ServicesSegue", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ServicesSegue") {
            if let indexPath = tableView.indexPathForSelectedRow {
                let peripheral = peripherals[indexPath.row]
                let destinationViewController = segue.destination as! ServicesTableViewController
                destinationViewController.peripheral = peripheral
                destinationViewController.manager = manager
                peripheral.delegate = destinationViewController
                self.manager!.connect(peripheral, options: nil)
            }
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return truei ndexPath.row
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
    
 

}
