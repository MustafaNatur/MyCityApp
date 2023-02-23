//
//  NewPlaceTableViewController.swift
//  MyCityApp
//
//  Created by Мустафа Натур on 23.02.2023.
//

import UIKit

class NewPlaceTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row == 0) {
            
        } else {
            view.endEditing(true)
        }
    }
    
    

}

// MARK: Text field delegate

extension NewPlaceTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
