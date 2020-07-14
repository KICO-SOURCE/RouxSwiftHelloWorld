//
//  ViewController.swift
//  RouxSwiftHelloWorld
//
//  Created by H. Cole Wiley on 5/12/20.
//  Copyright © 2020 Scandy. All rights reserved.
//

import GLKit

class ViewController: GLKViewController {
    
    // MARK: Global variables
    var SCAN_MODE_V2 = true
    
    // MARK: Properties
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var flashScanButton: UIButton!
    @IBOutlet weak var stopScanButton: UIButton!
    @IBOutlet weak var startScanButton: UIButton!
    @IBOutlet weak var saveMeshButton: UIButton!
    @IBOutlet weak var startPreviewButton: UIButton!
    @IBOutlet weak var sendMeshButton: UIButton!
    @IBOutlet weak var scanSizeLabel: UILabel!
    @IBOutlet weak var scanSizeSlider: UISlider!
    @IBOutlet weak var v2ModeSwitch: UISwitch!
    @IBOutlet weak var v2ModeLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    var fileURL: URL? = nil
    var socket: GCDAsyncSocket?
    var mData: NSMutableData!
    var imageDict: [String: Any] = [:]
    var test7str: String!
    var test7data: Data!
    var dataLength: UInt = 0
    var totalDataLength: UInt = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the ScandyCoreLicense.txt
        let status = ScandyCore.setLicense()
        print("license status: ", status)
        
        // call our function to start ScandyCore
        self.turnOnScanner()
    }
}

// MARK: Action Methods -
extension ViewController {
    
    @IBAction func settingButtonPressed(_ sender: Any) {
        print("settings button pressed")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let alertController = storyboard.instantiateViewController(withIdentifier: "AlertController") as! AlertController
        alertController.providesPresentationContextTransitionStyle = true
        alertController.definesPresentationContext = true
        alertController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        alertController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func flashScanningPressed(_ sender: Any) {
        print("start scanning pressed")
        self.startScanning(isFlashScan: true)
    }
    
    @IBAction func startScanningPressed(_ sender: Any) {
        print("start scanning pressed")
        self.startScanning(isFlashScan: false)
    }
    
    @IBAction func scanSizeChanged(_ sender: Any) {
        self.setResolution()
    }
    
    @IBAction func sendMeshButtonPressed(_ sender: UIButton) {
        
        
    }
    
    @IBAction func toggleV2(_ sender: Any) {
        self.SCAN_MODE_V2 = self.v2ModeSwitch.isOn
        ScandyCore.uninitializeScanner()
        ScandyCore.toggleV2Scanning(self.v2ModeSwitch.isOn)
        let scanner_type: ScandyCoreScannerType = ScandyCoreScannerType(rawValue: 5)
        ScandyCore.initializeScanner(scanner_type)
        ScandyCore.startPreview()
    }
    
    @IBAction func stopScanningPressed(_ sender: UIButton) {
        print("stop scanning pressed")
        self.stopScanning()
        ScandyCore.generateMesh()
    }
    
    @IBAction func saveMeshPressed(_ sender: Any) {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let id = formatter.string(from: date)
        // NOTE: You can change this to: obj, ply, or stl
        let filetype = "stl"
        let filename = "rouxiosexample_\(id).\(filetype)"
        let documentspath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let documentsURL = URL(fileURLWithPath: documentspath)
        let fileURL = documentsURL.appendingPathComponent(filename)
        let filepath = fileURL.path
        print("saving file to \(filepath)")
        self.fileURL = fileURL.absoluteURL
        print("URL \(String(describing: self.fileURL))")
        ScandyCore.saveMesh(filepath)
        self.saveMeshButton.isHidden = true
        self.sendMeshButton.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            self.sendData()
        }
    }
    
    @IBAction func startPreviewPressed(_ sender: Any) {
        print("start preview pressed")
        self.turnOnScanner()
    }
}

// MARK: Custom Methods -
extension ViewController {
    
    func requestCamera() -> Bool {
        if ScandyCore.hasCameraPermission() {
            print("user has granted permission to camera!")
            return true
        } else {
            print("user has denied permission to camera")
        }
        return false
    }
    
    func turnOnScanner() {
        self.renderPreviewScreen()
        
        if requestCamera() {
            //Default to scan mode v2
            ScandyCore.toggleV2Scanning(self.SCAN_MODE_V2)
            ScandyCore.initializeScanner()
            ScandyCore.startPreview()
            self.setResolution()
        }
    }
    
    func setResolution() {
        if SCAN_MODE_V2 {
            let minRes = 0.0005 // == 0.5 mm
            let maxRes = 0.006 // == 4 mm
            let range = maxRes - minRes;
            // normalize the scan size based on default slider value range [0, 1]
            //Make sure we are passing a Double to setVoxelSize
            let voxelRes: Double = (range * Double(scanSizeSlider.value)) + minRes
            ScandyCore.setVoxelSize(voxelRes)
            self.scanSizeLabel.text =  String(format: "Resolution: %.1f mm", voxelRes*1000)
        } else {
            // the minimum size of scan volume's dimensions in meters
            let minSize = 0.2
            // the maximum size of scan volume's dimensions in meters
            let maxSize = 5.0
            let range = maxSize - minSize
            //Make sure we are passing a Double to setScanSize
            let scan_size: Double = (range * Double(scanSizeSlider.value)) + minSize
            ScandyCore.setScanSize(scan_size)
            self.scanSizeLabel.text = String(format: "Scan Size: %.3f m", scan_size)
        }
    }
    
    func startScanning(isFlashScan: Bool) {
        self.renderScanningScreen(isFlashScan: isFlashScan)
        ScandyCore.startScanning()
        
        if isFlashScan {
            DispatchQueue.main.asyncAfter(deadline: .now()+1.5) {
                self.stopScanningPressed(self.stopScanButton)
            }
        }
    }
    
    func stopScanning() {
        self.renderMeshScreen()
        ScandyCore.stopScanning()
    }
    
    func renderPreviewScreen() {
        self.flashScanButton.isHidden = false
        self.scanSizeLabel.isHidden = false
        self.scanSizeSlider.isHidden = false
        self.v2ModeSwitch.isHidden = false
        self.v2ModeLabel.isHidden = false
        self.startScanButton.isHidden = false
        self.stopScanButton.isHidden = true
        self.startPreviewButton.isHidden = true
        self.sendMeshButton.isHidden = true
        self.saveMeshButton.isHidden = true
    }
    
    func renderScanningScreen(isFlashScan: Bool) {
        // Render our buttons
        self.stopScanButton.isHidden = isFlashScan
        self.flashScanButton.isHidden = true
        self.startScanButton.isHidden = true
        self.scanSizeLabel.isHidden = true
        self.scanSizeSlider.isHidden = true
        self.v2ModeSwitch.isHidden = true
        self.v2ModeLabel.isHidden = true
    }
    
    func renderMeshScreen() {
        
        self.startPreviewButton.isHidden = false
        self.saveMeshButton.isHidden = false
        self.scanSizeLabel.isHidden = true
        self.scanSizeSlider.isHidden = true
        self.startScanButton.isHidden = true
        self.stopScanButton.isHidden = true
        self.v2ModeSwitch.isHidden = true
        self.v2ModeLabel.isHidden = true
    }
    
    func sendData() {
        
        let ipInfo = PrefsManager.getIPInformation()
        self.socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
        do {
            try self.socket?.connect(toHost: ipInfo.ipAddress, onPort: UInt16(ipInfo.port)!)
            print("connect success")
            
            DispatchQueue.main.asyncAfter(deadline: .now()+3.0) {
                if let fileURL = self.fileURL {
                    do {
                        let data = try Data(contentsOf: fileURL)
                        self.totalDataLength = UInt(data.count)
                        print(self.totalDataLength)
                        self.progressView.isHidden = false
                        self.socket?.write(data, withTimeout: -1, tag: 0)
                        self.socket?.disconnectAfterWriting()
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

// MARK:- GCDAsyncSocketDelegate -
extension ViewController: GCDAsyncSocketDelegate {
    
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        print("conect to " + host)
        self.socket?.readData(withTimeout: -1, tag: 0)
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        if err == nil {
            let alertController = UIAlertController(title: "RouxSwift", message:
                "Data sent successfully", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                self.progressView.isHidden = true
            }))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        let msg = String(data: data as Data, encoding: String.Encoding.utf8)
        print(msg!)
        self.socket?.readData(withTimeout: -1, tag: 0)
    }
    
    func socket(_ sock: GCDAsyncSocket, didWritePartialDataOfLength partialLength: UInt, tag: Int) {
        
        self.dataLength += partialLength
        DispatchQueue.main.async {
            if self.progressView.progress != 1.0 {
                self.progressView.progress = Float(Double(self.dataLength)/Double(self.totalDataLength))
            }
        }
    }
}
