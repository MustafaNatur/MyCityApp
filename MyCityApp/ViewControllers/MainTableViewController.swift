//
//  MainTableViewController.swift
//  MyCityApp
//
//  Created by Мустафа Натур on 23.02.2023.
//

import UIKit
import RealmSwift

class MainTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var places: Results<Place>!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Places"
        
        places = realm.objects(Place.self)
    }
 
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        if let vc = segue.source as? NewPlaceTableViewController {
            vc.savePlace()
        }
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEdit" {
            if let vc = segue.destination as? NewPlaceTableViewController {
                vc.editPlace = places[tableView.indexPathForSelectedRow!.row]
            }
        }
    }

    // MARK: - Table view data source
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.isEmpty ? 0:places.count
    }

     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        cell.setUp(place: places[indexPath.row])
        return cell
    }
    
    // MARK: - Table view delegate
    
     func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let place = places[indexPath.row]
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (_, _)in
            StorageManager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        return [deleteAction]
    }

}
