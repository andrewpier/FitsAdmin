//
//  Camera ViewController.swift
//  Fits
//
//  Created by Sophia Gebert on 1/20/16.
//  Copyright © 2016 Urban Fish Studio. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class CameraViewController: UIViewController {
        
    let captureSession = AVCaptureSession()
    var previewLayer : AVCaptureVideoPreviewLayer?
    let stillImageOutput = AVCaptureStillImageOutput()
    var cameFromUploadView = false
    // If we find a device we'll store it here for later use
    var captureDevice : AVCaptureDevice?
    
    
    @IBOutlet weak var shutterButton: UIButton!
    @IBOutlet weak var flashButtom: UIButton!
    @IBOutlet weak var cameraFlipButton: UIButton!
    @IBOutlet weak var cameraImage: UIImageView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var viewLabel: UILabel!
    
    @IBOutlet weak var HeaderView: UIView!
    var frontCameraOn = false
    var backCameraOn = true
    var flash = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Loading: " + String(cameFromUploadView))
        
        if(backCameraOn){
             cameraFlipButton.setImage(UIImage(named: "SwitchMainCamera.png"), forState: .Normal)
        }
        else{
            cameraFlipButton.setImage(UIImage(named: "SwitchFaceCamera.png"), forState: .Normal)
        }
        // Do any additional setup after loading the view, typically from a nib.
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        
        let devices = AVCaptureDevice.devices()
        
        // Loop through all the capture devices on this phone
        for device in devices {
            // Make sure this particular device supports video
            if (device.hasMediaType(AVMediaTypeVideo)) {
                // Finally check the position and confirm we've got the back camera
                if(device.position == AVCaptureDevicePosition.Back) {
                    captureDevice = device as? AVCaptureDevice
                    if captureDevice != nil {
                        print("Capture device found")
                        
                        
                        /////////////////////////////////////////////////////////
                        
                        
                        beginSession() //Causes error when you try to load Camera
                        
                        // Error says Unexpectedly found nil while unwrapping an Optional Value
                        /////////////////////////////////////////////////////////
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        // When we leave the view we stop the session so the image is frozen. Need to restart so the user can take a picture
        captureSession.startRunning()
    }
    
    
    
    func configureDevice() {
        if let device = captureDevice {
            do{
               try device.lockForConfiguration()
                
            }catch let error as NSError{
                print(error.code)
            }
          
            device.unlockForConfiguration()
        }
    }
    
    func beginSession() {
        configureDevice()
        
        do{
            try captureSession.addInput(AVCaptureDeviceInput(device: captureDevice))
        }catch let error as NSError{
            print(error.code)
        }
        
        stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        if(captureSession.canAddOutput(stillImageOutput)){
            captureSession.addOutput(stillImageOutput)
        }
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        previewLayer?.frame = self.view.layer.frame
        self.view.layer.addSublayer(previewLayer!)
        captureSession.startRunning()
        
        //add to camera view
        //self.view.bringSubviewToFront(exitBackground)
        self.view.bringSubviewToFront(closeButton)
        self.view.bringSubviewToFront(viewLabel)
        self.view.bringSubviewToFront(shutterButton)
        self.view.bringSubviewToFront(HeaderView)
        self.view.bringSubviewToFront(cameraFlipButton)
        self.view.bringSubviewToFront(flashButtom)
    }
    
    @IBAction func xButtonTapped(sender: UIButton) {
        //iTry to iterte and find the tab bar controller...
        if (cameFromUploadView) {
            let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
            let vc : UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("UploadView") as UIViewController
            self.presentViewController(vc, animated: true, completion: nil)
        }else{
            print("Changing Tab")
            self.tabBarController?.tabBar.hidden = false
            self.tabBarController?.selectedIndex = 0
        }
    }
    
    @IBAction func flipCamera(sender: UIButton) {
       captureSession.stopRunning()
       captureSession.removeInput(captureSession.inputs[0] as! AVCaptureInput)
       
        //the back camera is currently showing so flip to front camera
        let devices = AVCaptureDevice.devices()
        if(backCameraOn){
            
            // Loop through all the capture devices on this phone
            for device in devices {
                // Make sure this particular device supports video
                if (device.hasMediaType(AVMediaTypeVideo)) {
                    // Finally check the position and confirm we've got the back camera
                    if(device.position == AVCaptureDevicePosition.Front) {
                        captureDevice = device as? AVCaptureDevice
                        if captureDevice != nil {
                            print("Front Capture device found")
                            
                            backCameraOn = false
                            frontCameraOn = true
                            cameraFlipButton.setImage(UIImage(named: "SwitchFaceCamera.png"), forState: .Normal)
                            beginSession()
                        }
                    }
                }
            }
        }
        else{
            // Loop through all the capture devices on this phone
            for device in devices {
                // Make sure this particular device supports video
                if (device.hasMediaType(AVMediaTypeVideo)) {
                    // Finally check the position and confirm we've got the back camera
                    if(device.position == AVCaptureDevicePosition.Back) {
                        captureDevice = device as? AVCaptureDevice
                        if captureDevice != nil {
                            print("Back Capture device found")
                            backCameraOn = true
                            frontCameraOn = false
                            cameraFlipButton.setImage(UIImage(named: "SwitchMainCamera.png"), forState: .Normal)
                            
                            beginSession()
                        }
                    }
                }
            }
        }
        
    }
    
    @IBAction func toggleFlash(sender: UIButton) {
        if((captureDevice?.hasFlash) == true){
            do{
                try captureDevice?.lockForConfiguration()
                if(captureDevice?.flashActive == true){
                    captureDevice?.flashMode = .On
                    flashButtom.setImage(UIImage(named: "FlashButton"), forState: .Normal)
                }else{
                    captureDevice?.flashMode = .Off
                    flashButtom.setImage(UIImage(named: "FlashButtonOff"), forState: .Normal)
                }
                captureDevice?.unlockForConfiguration()
            }catch {
                print("Flash could not be used")
            }
        }else{
            print("Flash is not available")
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender:AnyObject?) {
        if( segue.identifier != "CloseCamera"){
            if let videoConnection = stillImageOutput.connectionWithMediaType(AVMediaTypeVideo){
                stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {
                    (sampleBuffer, error) in
                    var imageData : NSData!
                    if (sampleBuffer != nil){
                        imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    } else {
                        //Make uhh ohh image to display here
                        imageData = UIImage().makeImageWithColorAndSize(SELECTEDBACKGROUNDCOLOR, accentColor: ACCENTCOLOR, size: CGSizeMake(400,400)).lowestQualityJPEGNSData
                    }
                    let dataProvider = CGDataProviderCreateWithCFData(imageData)
                    let cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, CGColorRenderingIntent.RenderingIntentDefault)
                    let image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Right)
                    
                    let imageView = UIImageView(image: image)
                    imageView.frame = CGRect(x:0, y:0, width:self.view.frame.width, height:self.view.frame.height)
                    
                    //Show the captured image
                    // self.view.addSubview(imageView)
                    self.cameraImage.image = imageView.image;
                    
                })
                self.captureSession.stopRunning()
            }
            
            let destViewController = segue.destinationViewController as! RetakeViewController
            
            destViewController.imageTaken = self.cameraImage.image
        }
    }
    
    @IBAction func PressToGoBack(sender: AnyObject) {
        //let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        //let vc : UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("Tab Bar Controller") as UIViewController
        //self.presentViewController(vc, animated: true, completion: nil)
        self.performSegueWithIdentifier("CloseCamera", sender: nil)
        
    }
    
    @IBOutlet weak var xPressToGoBack: UIButton!
    
    func exit(segue: UIStoryboardSegue){
        cameraImage.image = nil
        if(segue.identifier != "RetakeView"){
            self.captureSession.startRunning()
        }
    }
}