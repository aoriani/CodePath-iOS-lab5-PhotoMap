//
//  PhotoMapViewController.swift
//  Photo Map
//
//  Created by Nicholas Aiwazian on 10/15/15.
//  Copyright © 2015 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit

class PhotoMapViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,LocationsViewControllerDelegate, MKMapViewDelegate {
    
    var cameraImage: UIImage?

    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //one degree of latitude is approximately 111 kilometers (69 miles) at all times.
        let sfRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake(37.783333, -122.416667),
            MKCoordinateSpanMake(0.1, 0.1))
        mapView.setRegion(sfRegion, animated: false)
        mapView.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapCamera(sender: AnyObject) {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            vc.sourceType = .Camera
        } else {
            vc.sourceType = .PhotoLibrary
        }
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "fullImageSegue" {
            let vc = segue.destinationViewController as! FullImageViewController
        } else {
            let vc = segue.destinationViewController as! LocationsViewController
            vc.delegate = self
        }
        
        
    }
    
    func locationsPickerLocation(controller: LocationsViewController, latitude: NSNumber, longitude: NSNumber) {
        
        let nvc = self.navigationController?.popToViewController(self, animated: true)
        
        let annotation = PhotoAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: latitude.doubleValue, longitude: longitude.doubleValue)
        //annotation.title = "Picture"
        annotation.photo = cameraImage
        
        
        mapView.addAnnotation(annotation)
        
    } 

    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        cameraImage = info[UIImagePickerControllerEditedImage] as! UIImage
        
        
        //
        dismissViewControllerAnimated(true, completion: {
            self.performSegueWithIdentifier("tagSegue", sender: self)
        })
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "myAnnotationView"
        var annotatioView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)

        var resizeRenderImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
        resizeRenderImageView.layer.borderColor = UIColor.whiteColor().CGColor
        resizeRenderImageView.layer.borderWidth = 3.0
        resizeRenderImageView.contentMode = UIViewContentMode.ScaleAspectFill
        resizeRenderImageView.image = (annotation as? PhotoAnnotation)?.photo
        
        
        UIGraphicsBeginImageContext(resizeRenderImageView.frame.size)
        resizeRenderImageView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        var thumbnail = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if (annotatioView == nil) {
            annotatioView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            annotatioView!.canShowCallout = true
            annotatioView!.leftCalloutAccessoryView =  resizeRenderImageView //UIImageView(frame: CGRect(x:0, y:0, width:  50, height: 50))
            annotatioView!.rightCalloutAccessoryView = UIButtonType.DetailDisclosure
            
        }
        
        let imageView = annotatioView?.leftCalloutAccessoryView as! UIImageView
        imageView.image = thumbnail // UIImage(named: "camera")
        return annotatioView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        performSegueWithIdentifier("fullImageSegue", sender: self)
    }
    

}
