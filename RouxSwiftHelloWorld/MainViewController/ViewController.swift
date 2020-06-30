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
    @IBOutlet weak var stopScanButton: UIButton!
    @IBOutlet weak var startScanButton: UIButton!
    @IBOutlet weak var saveMeshButton: UIButton!
    @IBOutlet weak var startPreviewButton: UIButton!
    @IBOutlet weak var sendMeshButton: UIButton!
    @IBOutlet weak var scanSizeLabel: UILabel!
    @IBOutlet weak var scanSizeSlider: UISlider!
    @IBOutlet weak var v2ModeSwitch: UISwitch!
    @IBOutlet weak var v2ModeLabel: UILabel!
    
    var fileURL: URL? = nil
    
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
    
    @IBAction func startScanningPressed(_ sender: Any) {
        print("start scanning pressed")
        self.startScanning()
    }
    
    @IBAction func scanSizeChanged(_ sender: Any) {
        self.setResolution()
    }
    
    @IBAction func sendMeshButtonPressed(_ sender: UIButton) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let alertController = storyboard.instantiateViewController(withIdentifier: "AlertController") as! AlertController
        alertController.fileURL = self.fileURL
        alertController.providesPresentationContextTransitionStyle = true
        alertController.definesPresentationContext = true
        alertController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        alertController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func toggleV2(_ sender: Any) {
        self.SCAN_MODE_V2 = self.v2ModeSwitch.isOn
        ScandyCore.uninitializeScanner()
        ScandyCore.toggleV2Scanning(self.v2ModeSwitch.isOn)
        let scanner_type: ScandyCoreScannerType = ScandyCoreScannerType(rawValue: 5)
        ScandyCore.initializeScanner(scanner_type)
        ScandyCore.startPreview()
    }
    
    @IBAction func stopScanningPressed(_ sender: Any) {
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
        let filetype = "ply"
        let filename = "rouxiosexample_\(id).\(filetype)"
        let documentspath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let documentsURL = URL(fileURLWithPath: documentspath)
        let fileURL = documentsURL.appendingPathComponent(filename)
        let filepath = fileURL.path
        print("saving file to \(filepath)")
        self.fileURL = fileURL.absoluteURL
        print("URL \(String(describing: self.fileURL))")
        let alertController = UIAlertController(title: "Mesh Saved", message:
            "file saved to \(filepath)", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
        ScandyCore.saveMesh(filepath)
        self.present(alertController, animated: true, completion: {
            self.saveMeshButton.isHidden = true
            self.sendMeshButton.isHidden = false
        })
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
    
    func startScanning() {
        self.renderScanningScreen()
        ScandyCore.startScanning()
    }
    
    func stopScanning() {
        self.renderMeshScreen()
        ScandyCore.stopScanning()
    }
    
    func renderPreviewScreen() {
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
    
    func renderScanningScreen() {
        // Render our buttons
        self.stopScanButton.isHidden = false
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
}
