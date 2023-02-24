//
//  MainTableViewController.swift
//  MyCityApp
//
//  Created by Мустафа Натур on 23.02.2023.
//

import UIKit
import RealmSwift
import Cosmos

class MainTableViewController: UIViewController {
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var places: Results<Place>!
    private var filteredPlaces:Results<Place>!
    private var isAsceding = true
    private var searchBarIsEmpty:Bool {
        guard let text = searchController.searchBar.text else {return false}
        return text.isEmpty
    }
    private var showFiltered:Bool {
        return !searchBarIsEmpty && searchController.isActive
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var reversedSortingButton: UIBarButtonItem!
    @IBOutlet weak var segemntedControll: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        places = realm.objects(Place.self)
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Places"
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
    }
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEdit" {
            if let vc = segue.destination as? NewPlaceTableViewController {
                let place:Place
                if showFiltered {
                    place = filteredPlaces[tableView.indexPathForSelectedRow!.row]
                } else {
                    place = places[tableView.indexPathForSelectedRow!.row]
                }
                vc.editPlace = place
            }
        }
    }
    
    @IBAction func sortSelection(_ sender: UISegmentedControl) {
        sort()
        tableView.reloadData()
    }
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        if let vc = segue.source as? NewPlaceTableViewController {
            vc.savePlace()
        }
        tableView.reloadData()
    }
    
    @IBAction func reverseSorting(_ sender: UIBarButtonItem) {
        isAsceding.toggle()
        reversedSortingButton.image =  isAsceding ? UIImage(named: "ZA") : UIImage(named: "AZ")
        sort()
        tableView.reloadData()
    }
    
    func sort() {
        if (segemntedControll.selectedSegmentIndex == 0) {
            places = places.sorted(byKeyPath: "date", ascending: isAsceding)
        } else {
            places = places.sorted(byKeyPath: "name", ascending: isAsceding)
        }
    }
    
}

extension MainTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Table view data source
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         if showFiltered {
             return filteredPlaces.count
         }
        return places.isEmpty ? 0:places.count
    }

     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        
         if showFiltered {
             cell.setUp(place: filteredPlaces[indexPath.row])
         } else {
             cell.setUp(place: places[indexPath.row])
         }
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

extension MainTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        filteredPlaces = places.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", searchText, searchText)
        tableView.reloadData()
    }
    
    
}
