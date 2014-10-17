//
//  AVFoundationCameraViewController.swift
//  CFImageFilterSwift
//
//  Created by Bradley Johnson on 9/22/14.
//  Copyright (c) 2014 Brad Johnson. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMedia
import CoreVideo
import ImageIO
import QuartzCore

class AVFoundationCameraViewController: UIViewController {

    @IBOutlet weak var capturePreviewImageView: UIImageView!
    @IBOutlet weak var photoPreviewView: UIView!
    @IBOutlet weak var confirmButtonConstraint: NSLayoutConstraint!
    
    var delegate: GalleryDelegate?
    var stillImageOutput = AVCaptureStillImageOutput()
    var capturedImage: UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var captureSession = AVCaptureSession()
        var previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        var bounds = photoPreviewView.layer.bounds
        println("bounds height is \(bounds.height) and bounds width is \(bounds.width)")
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        previewLayer.bounds = bounds
        previewLayer.position = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds))
        
        
        self.photoPreviewView.layer.addSublayer(previewLayer)
        
        var device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        var error : NSError?
        var input = AVCaptureDeviceInput.deviceInputWithDevice(device, error: &error) as AVCaptureDeviceInput!
        if input == nil {
            println("bad!")
        }
        captureSession.addInput(input)
        var outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
        self.stillImageOutput.outputSettings = outputSettings
        captureSession.addOutput(self.stillImageOutput)
        captureSession.startRunning()
    }

    @IBAction func confirmButtonPressed(sender: AnyObject) {
        println("button done got pressed")
        self.delegate?.didTapOnPicture(self.capturePreviewImageView.image!)
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func capturePressed(sender: AnyObject) {
        
        var videoConnection : AVCaptureConnection?
        for connection in self.stillImageOutput.connections {
            if let cameraConnection = connection as? AVCaptureConnection {
                for port in cameraConnection.inputPorts {
                    if let videoPort = port as? AVCaptureInputPort {
                        if videoPort.mediaType == AVMediaTypeVideo {
                            videoConnection = cameraConnection
                            break;
                        }
                    }
                }
            }
            if videoConnection != nil {
                break;
            }
            if (videoConnection?.supportsVideoOrientation != nil) {
                videoConnection?.videoOrientation = interfaceOrientationToVideoOrientation(UIDevice.currentDevice().orientation)
            }
        }
        self.stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(buffer : CMSampleBuffer!, error : NSError!) -> Void in
            var data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
            var image = UIImage(data: data)
            self.capturePreviewImageView.image = image
            self.confirmButtonConstraint.constant = 8
            UIView.animateWithDuration(0.4, animations: { () -> Void in
                self.view.layoutIfNeeded()
            })
            
            //println(image.size)
        })
    }

    
//    override func viewWillLayoutSubviews() {
//        self.previewLayer.frame = photoPreviewView.bounds
//        if self.previewLayer.connection.supportsVideoOrientation {
//            self.previewLayer.connection.videoOrientation = interfaceOrientationToVideoOrientation(UIApplication.sharedApplication().statusBarOrientation)
//        }
//    }
//    
    func interfaceOrientationToVideoOrientation(deviceOrientation: UIDeviceOrientation) -> AVCaptureVideoOrientation {
        switch deviceOrientation {
        case UIDeviceOrientation.Portrait:
            return AVCaptureVideoOrientation.Portrait
        case UIDeviceOrientation.LandscapeLeft:
            return AVCaptureVideoOrientation.LandscapeLeft
        case UIDeviceOrientation.LandscapeRight:
            return AVCaptureVideoOrientation.LandscapeRight
        default:
            return AVCaptureVideoOrientation.Portrait
        }
    }
}

