//
//  LoginViewController.swift
//  BeReal
//
//  Created by Auden Huang on 2/15/23.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    override func viewDidLoad() {
        usernameField.borderStyle = .roundedRect
        usernameField.placeholder = "Username"
        usernameField.autocapitalizationType = .none
        usernameField.textAlignment = .left
        passwordField.borderStyle = .roundedRect
        passwordField.placeholder = "Password"
        passwordField.autocapitalizationType = .none
        passwordField.textAlignment = .left
        passwordField.isSecureTextEntry = true
        super.viewDidLoad()
    }
    

    @IBAction func tapLogin(_ sender: Any) {
        guard let username = usernameField.text,
              let password = passwordField.text,
              !username.isEmpty,
              !password.isEmpty else {

            showMissingFieldsAlert()
            return
    }
    // TODO: Pt 1 - Log in the parse user
        // Log in the parse user
        User.login(username: username, password: password) { [weak self] result in

            switch result {
            case .success(let user):
                print("✅ Successfully logged in as user: \(user)")

                // Post a notification that the user has successfully logged in.
                NotificationCenter.default.post(name: Notification.Name("login"), object: nil)

            case .failure(let error):
                self?.showAlert(description: error.localizedDescription)
            }
        }

    }

    private func showAlert(description: String?) {
        let alertController = UIAlertController(title: "Unable to Log in", message: description ?? "Unknown error", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }

    private func showMissingFieldsAlert() {
        let alertController = UIAlertController(title: "Opps...", message: "We need all fields filled out in order to log you in.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
}


