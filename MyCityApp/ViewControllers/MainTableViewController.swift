//
//  MainTableViewController.swift
//  MyCityApp
//
//  Created by Мустафа Натур on 23.02.2023.
//

import UIKit

class MainTableViewController: UITableViewController {


    
    let places = Place.getPlaces()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Places"
    }
    
    @IBAction func cancelAction(_ segue: UIStoryboardSegue) {
        
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        cell.setUp(place: places[indexPath.row])
        return cell
    }
    
    // MARK: - Table view delegate

}
