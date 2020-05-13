//
//  ViewController.swift
//  RouxSwiftHelloWorld
//
//  Created by H. Cole Wiley on 5/12/20.
//  Copyright © 2020 Scandy. All rights reserved.
//

import GLKit

class ViewController: GLKViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Set the ScandyCoreLicense.txt
    let status = ScandyCore.setLicense()
    print("license status: ", status)
    
    // call our function to start ScandyCore
    turnOnScanner()
  }
  
  func requestCamera() -> Bool {
    if ( ScandyCore.hasCameraPermission() )
    {
      print("user has granted permission to camera!")
      return true
    } else {
      print("user has denied permission to camera")
    }
    return false
  }

  
  func turnOnScanner() {
    if( requestCamera() ) {
      /*
       This is a little ugly, we could make this ScandyCoreScannerType into
       a better Swift class, but it works for now.
       */
      let scanner_type: ScandyCoreScannerType = ScandyCoreScannerType(rawValue: 5);
      ScandyCore.initializeScanner(scanner_type)
      ScandyCore.startPreview()
      // Set the voxel size to some custom thing
      let mm = 1.5
      ScandyCore.setVoxelSize(mm * 1e-3)
    }
  }


}

