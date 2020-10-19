//
//  ImageManager.swift
//  mMotiv8
//
//  Created by UF on 26/12/18.
//  Copyright © 2018 UF. All rights reserved.
//
import UIKit
import AVFoundation

protocol ImageManagerDelegate : AnyObject{
    
    func didNotAllowCamera()
}

class ImageManager:NSObject, AVCapturePhotoCaptureDelegate{
    
    weak var delegate : ImageManagerDelegate!

    func performInBackground(block: @escaping (() -> Void)) {
        sessionQueue.async() { () -> Void in
            block()
        }
    }
    
    private var sessionQueue = DispatchQueue.global(qos: .background)
    
    private var session:AVCaptureSession!
    private var stillCameraOutput:AVCapturePhotoOutput!

    private var imageID : String!

    override init(){
        
        super.init()
        
        setImageID()
        initializeSession()
    }

    //MARK: PublicMethods
    func setImageID(imageID : String){
        
        self.imageID = imageID
    }
    
    func captureImage(){
        captureStillImage()
    }
    
    func deinitialize(){
    
        session.stopRunning()
        clearDirectory()
    }
    
    //MARK: AVCapturePhotoCaptureDelegate
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {

        if let imageData = photo.fileDataRepresentation() {
            if let image = UIImage(data: imageData){
                
                DispatchQueue.main.async {
                    self.saveImage(image: image)
                }
            }
        }
    }
    
    //MARK: PrivateMethods
    private func setImageID(){
    
        let dateString = DateFormatter.imageDateFormat().string(from: Date())
        
        imageID = dateString
    }
    
    private func initializeSession(){
        
        session = AVCaptureSession()
        session.sessionPreset = AVCaptureSession.Preset.photo

        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)

        switch authorizationStatus {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted:Bool) -> Void in
                if granted {
                    self.setupCamera()
                }
                else {
                    
                    DispatchQueue.main.async {
                        
                        if self.delegate != nil {
                            
                            self.delegate.didNotAllowCamera()
                        }
                    }
                }
            })
        case .authorized:
            setupCamera()
        case .denied, .restricted:
            
            DispatchQueue.main.async {
                
                if self.delegate != nil {
                    
                    self.delegate.didNotAllowCamera()
                }
            }
        }
    }

    private func setupCamera(){
        
        performInBackground {
            
            let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                                                    mediaType: AVMediaType.video,
                                                                    position: .front)
            if let device = discoverySession.devices.first{
                
                let input: AVCaptureDeviceInput
                do {
                    input = try AVCaptureDeviceInput(device: device)
                } catch {
                    return
                }
                
                self.stillCameraOutput = AVCapturePhotoOutput()
                
                self.session.addInput(input)
                self.session.addOutput(self.stillCameraOutput)
                
                self.session.startRunning()
            }
        }
    }
    
    private func captureStillImage(){
    
        performInBackground{
            
            let connection = self.stillCameraOutput.connection(with: AVMediaType.video)
            
            connection?.videoOrientation = AVCaptureVideoOrientation(rawValue: UIDevice.current.orientation.rawValue)!
            
            let photoSettings = AVCapturePhotoSettings()
            photoSettings.livePhotoVideoCodecType = .jpeg
            
            self.stillCameraOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }
    
    //MARK: Image Processing
    
    private func mergeImage(firstImage : UIImage, secondImage : UIImage) -> UIImage?{
        
        let height = firstImage.size.height
        let width = firstImage.size.width + secondImage.size.width
        
        let padding = ImageManagerConstants().padding

        let size = CGSize(width: width + 3 * padding, height: height + 2 * padding)

        UIGraphicsBeginImageContext(size)
        
        if let context = UIGraphicsGetCurrentContext(){
            context.setFillColor(UIColor.black.cgColor)
            context.fill(CGRect(origin: .zero, size: size))
        }

        firstImage.draw(in: CGRect(x: padding, y: padding, width: firstImage.size.width, height: height))
        secondImage.draw(in: CGRect(x: 2 * padding + firstImage.size.width, y: padding, width: secondImage.size.width, height: height))
        
        let mergedImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        return mergedImage
    }
    
    //MARK: File Read/Write Methods
    class func returnDirectoryPath() -> URL!{
        
        let fileManager = FileManager.default
        
        if let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first{
            
            let directory = documentsDirectory.appendingPathComponent("Pictures")
            
            if(!fileManager.fileExists(atPath: directory.path)){
                
                do{
                    try fileManager.createDirectory(atPath: directory.path, withIntermediateDirectories: false, attributes: nil)
                    print("Created directory")
                }
                catch{
                    return nil
                }
            }
            return directory
        }
        return nil
    }
    
    class func getImageData(imageID : String) -> Data!{
        
        if let documentsDirectory = returnDirectoryPath(){
            
            let fileURL = documentsDirectory.appendingPathComponent(imageID)
            
            if let image = UIImage(contentsOfFile: fileURL.path){
                
                let data = image.jpegData(compressionQuality: 1.0)
                return data
            }
        }
        
        return nil
    }
    
    func clearDirectory(){
    
        let fileManager = FileManager.default
        if let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first{
            
            let directory = documentsDirectory.appendingPathComponent("Pictures")
            
            if(fileManager.fileExists(atPath: directory.path)){
            
                do{
                    try fileManager.removeItem(atPath: directory.path)
                    print("Deleted Directory")
                }
                catch{
                    
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    private func saveImage(image: UIImage){
        
        let fileManager = FileManager.default
        
        if let documentsDirectory = ImageManager.returnDirectoryPath(){
            
            let fileURL = documentsDirectory.appendingPathComponent(imageID)
            let path = fileURL.path
            
            if fileManager.fileExists(atPath: path){
                
                if let firstImage = UIImage(contentsOfFile: path){
                    
                    if let mergedImage = mergeImage(firstImage: firstImage, secondImage: image){
                        
                        writeImage(image: mergedImage, fileURL: fileURL)
                    }
                }
            }
            else
            {
                writeImage(image: image, fileURL: fileURL)
            }
            
        }
    }
    
    private func writeImage(image : UIImage, fileURL : URL){
        
        if let data = image.jpegData(compressionQuality: ImageManagerConstants().compression){
            do {// writes the image data to disk
                try data.write(to: fileURL)
                print("file saved")
            } catch {
                print("error saving file:", error)
            }
        }
    }
    
   
}


