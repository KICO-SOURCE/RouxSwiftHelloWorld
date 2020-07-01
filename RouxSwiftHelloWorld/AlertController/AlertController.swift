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
    @IBOutlet weak var sendButton: UIButton!
    
    var socket: GCDAsyncSocket?
    var mData: NSMutableData!
    var imageDict: [String: Any] = [:]
    var test7str: String!
    var test7data: Data!

    var fileURL: URL? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        self.ipTextField.delegate = self
        self.portTextField.delegate = self
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
        self.socket?.disconnect()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK:- Custom Methods -
extension AlertController {
    
    func convertDictionaryToString(dict: [String: Any]) -> String {
        var result:String = ""
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions.init(rawValue: 0))
            
            if let JSONString = String(data: jsonData, encoding: String.Encoding.utf8) {
                result = JSONString
            }
        } catch {
            result = ""
        }
        return result
    }
    
    func sendData(data: Data, type: String) {
        
        let size = data.count
        var headDict: [String: Any] = [:]
        headDict["size"] = size
        headDict["type"] = type
        let jsonStr = convertDictionaryToString(dict: headDict as [String: AnyObject])
        if let lengthData = jsonStr.data(using: String.Encoding.utf8) {
            
//            mData = NSMutableData.init(data: lengthData)
            mData = NSMutableData()
            mData.append(GCDAsyncSocket.crlfData())
            mData.append(data)
            
            print("mData.length \(mData.length)")
            print("Data.length \(data.count)")
            socket?.write(mData as Data, withTimeout: -1, tag: 0)
        }
    }

    func convertStringToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: [JSONSerialization.ReadingOptions.init(rawValue: 0)]) as? [String: Any]
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }
}

// MARK:- Action Methods -
extension AlertController {
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {

        self.socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
        do {
            try self.socket?.connect(toHost: self.ipTextField.text!, onPort: UInt16(self.portTextField.text!)!)
            print("connect success")
            
            DispatchQueue.main.asyncAfter(deadline: .now()+3.0) {
                if let fileURL = self.fileURL {
                    do {
                        let data = try Data(contentsOf: fileURL)
                        let data_Base64str = data.base64EncodedString()
                        self.imageDict["stl"] = data_Base64str
                        self.test7str = self.convertDictionaryToString(dict: self.imageDict as [String: Any])
                        self.test7data = self.test7str.data(using: String.Encoding.utf8)
                        self.sendData(data: self.test7data, type: "stl")
                    } catch {
                        print("No Data Found")
                    }
                }
            }
        } catch _ {
            print("connect fail")
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

// MARK:- GCDAsyncSocketDelegate -
extension AlertController: GCDAsyncSocketDelegate {
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        print("conect to " + host)
        self.socket?.readData(withTimeout: -1, tag: 0)
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        let msg = String(data: data as Data, encoding: String.Encoding.utf8)
        print(msg!)
        self.socket?.readData(withTimeout: -1, tag: 0)
    }
}
