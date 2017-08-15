//
//  CharacteristicTableViewController.swift
//  BLENavigator
//
//  Created by Samuel Fuhrer on 8/14/17.
//  Copyright © 2017 Samuel Fuhrer. All rights reserved.
//

import UIKit
import CoreBluetooth

class CharacteristicsTableViewController: UITableViewController, CBPeripheralDelegate {

    //MARK: Properties
    var characteristics = [CBCharacteristic]()
    var service: CBService? = nil
    
    //MARK: Methods
    func add(charactersitic: CBCharacteristic) {
        let indexPath = IndexPath(row: characteristics.count, section: 0)
        characteristics.append(charactersitic)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    func remove(service: CBCharacteristic) {
        if let index = characteristics.index(of: service) {
            let indexPath = IndexPath(row: index, section: 0)
            characteristics.remove(at: index)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("** didDiscoverCharacteristics for: " + service.uuid.description)
        characteristics = service.characteristics ?? []
        tableView.reloadData()
    }

    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return characteristics.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "CharacteristicsTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CharacteristicsTableViewCell  else {
            fatalError("The dequeued cell is not an instance of CharacteristicsTableViewCell.")
        }
        
        let characteristic = characteristics[indexPath.row]
        cell.nameLabel.text = characteristic.uuid.description
        return cell
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

}
