//
//  PostViewController.swift
//  BeReal
//
//  Created by Auden Huang on 2/15/23.
//

import UIKit
import PhotosUI
import ParseSwift
import CoreLocation
class PostViewController: UIViewController {
    private var pickedImage: UIImage?
    @IBOutlet weak var captionTextField: UITextField!
    @IBOutlet weak var previewImageView: UIImageView!
    
    @IBOutlet weak var locLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        captionTextField.borderStyle = .roundedRect
        captionTextField.placeholder = "Caption"
        captionTextField.autocapitalizationType = .none
        captionTextField.textAlignment = .left
        
        // Do any additional setup after loading the view.
    }
    @IBAction func tapSelect(_ sender: Any) {
        // If authorized, show photo picker, otherwise request authorization.
        // If authorization denied, show alert with option to go to settings to update authorization.
        if PHPhotoLibrary.authorizationStatus(for: .readWrite) != .authorized {
            // Request photo library access
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
                switch status {
                case .authorized:
                    // The user authorized access to their photo library
                    // show picker (on main thread)
                    DispatchQueue.main.async {
                        self?.presentImagePicker()
                    }
                default:
                    // show settings alert (on main thread)
                    DispatchQueue.main.async {
                        // Helper method to show settings alert
                        self?.presentGoToSettingsAlert()
                    }
                }
            }
        } else {
            // Show photo picker
            presentImagePicker()
        }

    }
    private func presentImagePicker() {
        // Create a configuration object
        var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())

        // Set the filter to only show images as options (i.e. no videos, etc.).
        config.filter = .images

        // Request the original file format. Fastest method as it avoids transcoding.
        config.preferredAssetRepresentationMode = .current

        // Only allow 1 image to be selected at a time.
        config.selectionLimit = 1

        // Instantiate a picker, passing in the configuration.
        let picker = PHPickerViewController(configuration: config)

        // Set the picker delegate so we can receive whatever image the user picks.
        picker.delegate = self

        // Present the picker.
        present(picker, animated: true)

    }
    @IBAction func onTapCamera(_ sender: Any) {
        let locM = CLLocationManager()
        if CLLocationManager.locationServicesEnabled(){
            locM.delegate = self
            locM.desiredAccuracy = kCLLocationAccuracyBest
            locM.requestWhenInUseAuthorization()
        }
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera){
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = false
            imagePicker.delegate = self
            present(imagePicker, animated: true)
        }
    }
    @IBAction func onTapShare(_ sender: Any) {
        
        // Dismiss Keyboard
        view.endEditing(true)

        // TODO: Pt 1 - Create and save Post
        // Unwrap optional pickedImage
        guard let image = pickedImage,
              // Create and compress image data (jpeg) from UIImage
              let imageData = image.jpegData(compressionQuality: 0.1) else {
            return
        }

        // Create a Parse File by providing a name and passing in the image data
        let imageFile = ParseFile(name: "image.jpg", data: imageData)

        // Create Post object
        var post = Post()

        // Set properties
        post.imageFile = imageFile
        post.caption = captionTextField.text
        post.location = locLabel.text
        // Set the user as the current user
        post.user = User.current

        // Save object in background (async)
        post.save { [weak self] result in

            // Switch to the main thread for any UI updates
            DispatchQueue.main.async {
                switch result {
                case .success(let post):
                    print("✅ Post Saved! \(post)")
                    // Get the current user
                    if var currentUser = User.current {

                        // Update the `lastPostedDate` property on the user with the current date.
                        currentUser.lastPostedDate = Date()

                        // Save updates to the user (async)
                        currentUser.save { [weak self] result in
                            switch result {
                            case .success(let user):
                                print("✅ User Saved! \(user)")

                                // Switch to the main thread for any UI updates
                                DispatchQueue.main.async {
                                    // Return to previous view controller
                                    self?.navigationController?.popViewController(animated: true)
                                }

                            case .failure(let error):
                                self?.showAlert(description: error.localizedDescription)
                            }
                        }
                    }

                case .failure(let error):
                    self?.showAlert(description: error.localizedDescription)
                }
            }
        }
    }

    @IBAction func onTapView(_ sender: Any) {
        view.endEditing(true)
    }
    

}
// Helper methods to present various alerts
extension PostViewController {
    func presentGoToSettingsAlert() {
        let alertController = UIAlertController (
            title: "Photo Access Required",
            message: "In order to post a photo to complete a task, we need access to your photo library. You can allow access in Settings",
            preferredStyle: .alert)

        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }

            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        }

        alertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }
    
    private func showAlert(description: String? = nil) {
        let alertController = UIAlertController(title: "Oops...", message: "\(description ?? "Please try again...")", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
}
// TODO: Pt 1 - Add PHPickerViewController delegate and handle picked image.
extension PostViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult])
    {

        // Dismiss the picker
        picker.dismiss(animated: true)
        var address = ""
        // Get the selected image asset (we can grab the 1st item in the array since we only allowed a selection limit of 1)
        let result = results.first

        // Get image location
        // PHAsset contains metadata about an image or video (ex. location, size, etc.)
        guard let assetId = result?.assetIdentifier,
              let location = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil).firstObject?.location else {
            return
        }
        location.lookUpCurrentLocation(){(result) in
            print("result: \(result!)")
            if result!.thoroughfare != nil{
                address = "\(result!.thoroughfare!)"
            }
            if result!.name != nil{address = "\(result!.name!)"
            }
            if result!.locality != nil{
                address = "\(address), \(result!.locality!)"
            }
            if result!.country != nil{
                address = "\(address), \(result!.country!)"
            }
            self.locLabel.text  = address
            
          }


        // Make sure we have a non-nil item provider
        guard let provider = results.first?.itemProvider,
           // Make sure the provider can load a UIImage
           provider.canLoadObject(ofClass: UIImage.self) else { return }

        // Load a UIImage from the provider
        provider.loadObject(ofClass: UIImage.self) { [weak self] object, error in

           // Make sure we can cast the returned object to a UIImage
           guard let image = object as? UIImage else {

              // ❌ Unable to cast to UIImage
              self?.showAlert()
              return
           }

           // Check for and handle any errors
           if let error = error {
               self?.showAlert()
               print(error)
              return
           } else {

              // UI updates (like setting image on image view) should be done on main thread
              DispatchQueue.main.async {

                 // Set image on preview image view
                 self?.previewImageView.image = image

                 // Set image to use when saving post
                 self?.pickedImage = image
              }
           }
        }
    }
    

}
extension CLLocation {
    
    func lookUpCurrentLocation(completionHandler: @escaping (CLPlacemark?)
                    -> Void ) {
        
        let geocoder = CLGeocoder()
            
        // Look up the location and pass it to the completion handler
        geocoder.reverseGeocodeLocation(self,
                    completionHandler: { (placemarks, error) in
            if error == nil {
                let firstLocation = placemarks?[0]
                completionHandler(firstLocation)
            }
            else {
             // An error occurred during geocoding.
                completionHandler(nil)
            }
        })
    }
}
extension PostViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate, CLLocationManagerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    func locationManager(_ manager:CLLocationManager, didUpdayeLocations locations:[CLLocation]){
        guard let location = locations.last else{
            return
        }
        print("Location: \(location)")
    }


    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let locM = CLLocationManager()
        locM.startUpdatingLocation()

        picker.dismiss(animated: true, completion:nil)
        var address = ""
       
        guard let location = locM.location else { return}
        print(location)
        location.lookUpCurrentLocation(){(result) in
            print("result: \(result!)")
            if result!.thoroughfare != nil{
                address = "\(result!.thoroughfare!)"
            }
            if result!.name != nil{address = "\(result!.name!)"
            }
            if result!.locality != nil{
                address = "\(address), \(result!.locality!)"
            }
            if result!.country != nil{
                address = "\(address), \(result!.country!)"
            }
            self.locLabel.text  = address
            
          }
        print(address)
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else
        {
            return
        }
        print("get image")
        // hide picker when done w/it.
        DispatchQueue.main.async {

           // Set image on preview image view
            self.previewImageView.image = image

           // Set image to use when saving post
            self.pickedImage = image
        }
       
    }

}
