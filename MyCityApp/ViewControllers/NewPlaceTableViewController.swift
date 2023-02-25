//
//  NewPlaceTableViewController.swift
//  MyCityApp
//
//  Created by Мустафа Натур on 23.02.2023.
//

import UIKit
import Cosmos

class NewPlaceTableViewController: UITableViewController {
    
    var imageChanged = false
    var newRating = 0.0
    var currentPlace:Place?
    

    @IBOutlet weak var mainImageView: UIView!
    @IBOutlet weak var imageOfPlace: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var ratingControl: CosmosView!
    @IBOutlet weak var showMapButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageOfPlace.layer.cornerRadius = 15
        saveButton.isEnabled = false
        nameTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        changeViewForEdit()
        
        ratingControl.didTouchCosmos = {rating in self.newRating = rating}
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //guard segue.identifier == "showPlace" else {return}
        
        if let mapVc = segue.destination as? MapViewController {
            mapVc.delegateMap = self
            mapVc.place.name = nameTextField.text!
            mapVc.place.type = typeTextField.text!
            mapVc.place.location = locationTextField.text
            mapVc.place.imageData = imageOfPlace.image?.pngData()
            mapVc.incomeSegueIdentier = segue.identifier!
        }
    }
    
    @IBAction func cancleButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    

    
    func savePlace() {
        let image = imageChanged ? imageOfPlace.image:UIImage(named: "defaultImage")
        let imageData = image?.pngData()
        let newPlace = Place()
        
        newPlace.name = nameTextField.text!
        newPlace.location = locationTextField.text
        newPlace.type = typeTextField.text
        newPlace.imageData = imageData
        newPlace.rating = newRating
        
        if currentPlace != nil {
            try! realm.write {
                currentPlace?.name = newPlace.name
                currentPlace?.location = newPlace.location
                currentPlace?.type = newPlace.type
                currentPlace?.imageData = newPlace.imageData
                currentPlace?.rating = newPlace.rating
            }
        } else {
            StorageManager.saveObject(newPlace)
        }
    }
    
    func changeViewForEdit() {
        if let place = currentPlace {
            setupNavigationController()
            nameTextField.text = place.name
            locationTextField.text = place.location
            typeTextField.text = place.type
            imageOfPlace.image = UIImage(data: place.imageData!)
            ratingControl.rating = place.rating
            imageOfPlace.contentMode = .scaleAspectFill
            imageOfPlace.clipsToBounds = true
            mainImageView.backgroundColor = .systemBackground
            imageChanged = true
            saveButton.isEnabled = true
            title = place.name
        }
    }
    
    func setupNavigationController() {
        navigationItem.leftBarButtonItem = nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row == 0) {
            
            let cameraIcon = UIImage(systemName: "camera")
            let photoIcon = UIImage(systemName: "photo")
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let photo = UIAlertAction(title: "Choose from gallery", style: .default) {
                _ in self.chooseImagePicker(source: .photoLibrary)
            }
            photo.setValue(photoIcon, forKey: "image")
            photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let camera = UIAlertAction(title: "Make photo", style: .default) {
                _ in self.chooseImagePicker(source: .camera)
            }
            camera.setValue(cameraIcon, forKey: "image")
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            actionSheet.addAction(camera)
            actionSheet.addAction(photo)
            actionSheet.addAction(cancel)
            
            present(actionSheet, animated: true)

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

extension NewPlaceTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func chooseImagePicker(source: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(source) else { return }
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = source
        
        present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageOfPlace.image = info[.editedImage] as? UIImage
        imageOfPlace.contentMode = .scaleAspectFill
        imageOfPlace.clipsToBounds = true
        mainImageView.backgroundColor = .systemBackground
        imageChanged = true
        
        dismiss(animated: true)
    }
    
    @objc private func textFieldChanged() {
        if (nameTextField.text?.isEmpty == false) {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
}

extension NewPlaceTableViewController: MapViewControllerDelegate {
    func getAdress(_ address: String?) {
        locationTextField.text = address
    }
    
    
}
