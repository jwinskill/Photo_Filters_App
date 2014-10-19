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
    var parentImageSize: CGSize?
    
    
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
    }

        self.stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(buffer : CMSampleBuffer!, error : NSError!) -> Void in
            var data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
            var image = UIImage(data: data)
            var croppedImage = self.squareImageWithImage(image, scaledToSize: self.parentImageSize!)
            self.capturePreviewImageView.image = croppedImage
            self.confirmButtonConstraint.constant = 8
            UIView.animateWithDuration(0.4, animations: { () -> Void in
                self.view.layoutIfNeeded()
            })
            
            //println(image.size)
        })
    }
    
    func squareImageWithImage(image: UIImage, scaledToSize: CGSize) -> UIImage {
        var ratio: CGFloat!
        var delta: CGFloat!
        var offset: CGPoint!
        
        var size = CGSizeMake(scaledToSize.width, scaledToSize.width)
        
        if image.size.width > image.size.height {
            ratio = scaledToSize.width / image.size.width
            delta = ratio * image.size.width - ratio * image.size.height
            offset = CGPointMake(delta / 2, 0)
        } else {
            ratio = scaledToSize.width / image.size.height
            delta = ratio * image.size.height - ratio * image.size.width
            offset = CGPointMake(0, delta / 2)
        }
        
        var clipRect: CGRect = CGRectMake(-offset.x, -offset.y, (ratio * image.size.width) + delta, (ratio * image.size.height) + delta)
        
        if UIScreen.mainScreen().respondsToSelector("scale") {
            UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
        } else {
            UIGraphicsBeginImageContext(size)
        }
        UIRectClip(clipRect)
        image.drawInRect(clipRect)
        var newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
}

