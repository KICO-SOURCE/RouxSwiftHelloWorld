//
//  AlertController.swift
//  RouxSwiftHelloWorld
//
//  Created by Jayesh Mardiya on 28/06/20.
//  Copyright © 2020 Scandy. All rights reserved.
//

import UIKit

class AlertController: UIViewController {

    @IBOutlet weak var ipTextField: UITextField!
    @IBOutlet weak var portTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        self.ipTextField.delegate = self
        self.portTextField.delegate = self
        
        let ipInfo = PrefsManager.getIPInformation()
        self.ipTextField.text = ipInfo.ipAddress
        self.portTextField.text = ipInfo.port
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.ipTextField.resignFirstResponder()
        self.portTextField.resignFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK:- Action Methods -
extension AlertController {
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {

        if let ipAddress = self.ipTextField.text, let port = self.portTextField.text {
            let ipInfo = IPModel(ipAddress: ipAddress, port: port)
            PrefsManager.setIPInformation(model: ipInfo)
            let alertController = UIAlertController(title: "RouxSwift", message:
                "Saved settings successfully", preferredStyle: .alert)
            self.present(alertController, animated: true) {
                self.dismiss(animated: true, completion: nil)
            }
        } else {
            let alertController = UIAlertController(title: "RouxSwift", message:
                "Please enter IP address and Port number", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

// MARK:- UITextFieldDelegate -
extension AlertController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.ipTextField.resignFirstResponder()
        self.portTextField.resignFirstResponder()
        return true
    }
}
