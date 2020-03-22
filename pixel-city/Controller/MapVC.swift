//
//  ViewController.swift
//  pixel-city
//
//  Created by Sebastian Horatiu on 07/09/2019.
//  Copyright © 2019 Sebastian Horatiu. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Alamofire
import AlamofireImage

class MapVC: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pullUpViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pullUpView: UIView!
    
    var locationManger = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus()
    let regionRadiusMeters: Double = 1000
    let screenSize = UIScreen.main.bounds

    
    var spinner = UIActivityIndicatorView(style: .whiteLarge)
    var progressLbl: UILabel?
    
    var collectionView: UICollectionView?
    
    var imageUrlArray = [String]()
    var imageArray = [UIImage]()

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManger.delegate = self
        configureLocationServices()
        addDoubleTap()
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: "photoCell")
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
        
        registerForPreviewing(with: self, sourceView: collectionView!)
        
        pullUpView.addSubview(collectionView!)
    }
    
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        mapView.addGestureRecognizer(doubleTap)
//        spinner.stopAnimating()
    }
    
    func addSwipe() {
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(animateViewDown))
        swipeDown.direction = .down
        pullUpView.addGestureRecognizer(swipeDown)
    }
    
    func addSpinner() {
        spinner.color = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        spinner.center = CGPoint(x: screenSize.width / 2, y: pullUpView.frame.height / 2)
        spinner.startAnimating()
        collectionView?.addSubview(spinner)
    }
    
    func removeSpinner() {
        if spinner.isAnimating {
            spinner.stopAnimating()
            spinner.removeFromSuperview()
        }
    }
    
    func addProgressLbl() {
        progressLbl = UILabel()
        progressLbl?.frame = CGRect(x: (screenSize.width / 2) - 120, y: pullUpView.bounds.height / 2 + spinner.bounds.height / 2, width: 240, height: 40)
        progressLbl?.font = UIFont(name: "Avenir Next", size: 18)
        progressLbl?.textColor = #colorLiteral(red: 0.5019607843, green: 0.5019607843, blue: 0.5019607843, alpha: 1)
        progressLbl?.textAlignment = .center
        collectionView?.addSubview(progressLbl!)
    }
    
    func removeProgressLbl () {
        if progressLbl != nil {
            progressLbl?.removeFromSuperview()
        }
    }
    
    func animateViewUp() {
        pullUpViewHeightConstraint.constant = 0.45 * screenSize.height
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func animateViewDown() {
        cancelAllSessions()
        pullUpViewHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        spinner.stopAnimating()
    }

    @IBAction func CenterMapBtnWasPressed(_ sender: Any) {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            centerMapOnUserLocation()
        }
    }
    

}

extension MapVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
        pinAnnotation.pinTintColor = #colorLiteral(red: 0.9647058824, green: 0.6509803922, blue: 0.137254902, alpha: 1)
        return pinAnnotation
    }
    
    func centerMapOnUserLocation() {
        guard let currentLocationCoordinate = locationManger.location?.coordinate else { return }
        centerMap(arround: currentLocationCoordinate)
    }
    
    @objc func dropPin(sender: UITapGestureRecognizer) {
        removePin()
        removeProgressLbl()
        cancelAllSessions()
        
        imageUrlArray = []
        imageArray = []
        collectionView?.reloadData()
        
        let touchPoint = sender.location(in: mapView)
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        print("screenSize=\(screenSize), touchPoint=\(touchPoint), touchCoordinate=\(touchCoordinate)")
        
        //This is just for my benefit; I'll probably remove it later
        displayTouchCoordinate(touchPoint, touchCoordinate)
        
        let annotation = DroppablePin(coordinate: touchCoordinate, identifier: "droppablePin")
        mapView.addAnnotation(annotation)
        
        print("flickUrl: \(flickrUrl(forApiKey: API_KEY, withAnnotation: annotation, andNumberOfPhotos: 10))")
        
        centerMap(arround: touchCoordinate)
        
        animateViewUp()
        addSpinner()
        addProgressLbl()
        addSwipe()
        
        retireveUrls(forAnnontation: annotation) { (finished) in
            print (self.imageUrlArray)
            
            if finished {
                self.retrieveImages { (finished) in
                    if finished {
                        self.removeSpinner()
                        self.removeProgressLbl()
                        self.collectionView?.reloadData()
                    }
                }
            }
            
        }
    }
    
    func removePin() {
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
    }
    
    fileprivate func displayTouchCoordinate(_ touchPoint: CGPoint, _ touchCoordinate: CLLocationCoordinate2D) {
        let droppedPinAlertController = UIAlertController(title: "Dropped pin", message: "A pin was dropped at: \r- screen coordinates: \(touchPoint); \r- map coordinates: \(touchCoordinate);", preferredStyle: .alert)
        droppedPinAlertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(droppedPinAlertController, animated: true, completion: nil)
    }
    
    fileprivate func centerMap(arround coordinate: CLLocationCoordinate2D) {
        /*
        This function was not in the lesson
        I've created it because the same code was being used twice
        */
        let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRadiusMeters, longitudinalMeters: regionRadiusMeters)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func retireveUrls(forAnnontation annotation: DroppablePin, handler: @escaping (_ status: Bool) -> ()) {
        imageUrlArray = []
        
        Alamofire.request(flickrUrl(forApiKey: API_KEY, withAnnotation: annotation, andNumberOfPhotos: NUMBER_OF_PHOTOS)).responseJSON { (response) in
            print("response: \(response)")
           
            guard let json = response.result.value as? Dictionary<String, AnyObject> else { return }
            print ("response.result.value as Dictionary<String, AnyObject>: \(json)")
            
            guard let photosDict = json ["photos"] as? Dictionary<String, AnyObject> else { return }
            print("photos: \(photosDict)")
            
            guard let photoDictArray = photosDict["photo"] as? Array<Dictionary<String, AnyObject>> else {
                print("Something went wrong while getting photoDictArray[]")
                return
            }
            print ("photoDictArray: \(photoDictArray)")
            
            for photo in photoDictArray {
//                URL structure is slightly diffferent than in the tutorial,
//                maybe it just changed since the the lesson was recorded
//                Basically the URL is like this
//                https://farm{farm-id}.staticflickr.com/{server-id}/{id}_{secret}_{size}.jpg
//                where the _{size} is optional
//                More details here:
//                https://www.flickr.com/services/api/misc.urls.html
                
                print("photo=\(photo)")
                
                //JSONDecoder version with Swift 4
                //I'm leaving this here for my reference, as a different way of doin this
//                do {
//                    let flickPhoto2 = try JSONDecoder().decode(FlickPhoto.self, from: photo as! Data)
//                    print("farm safely unwrapped =\(flickPhoto2.farm)")
//
//                } catch let jsonErr {
//                    print(jsonErr)
//                }
                
                let postUrl = "https://farm\(photo["farm"]!).staticflickr.com/\(photo["server"]!)/\(photo["id"]!)_\(photo["secret"]!)_c.jpg"
                print("postUrl=\(postUrl)")
                self.imageUrlArray.append(postUrl)
            }
            handler(true)
        }
    }
    
    func retrieveImages(handler: @escaping (_ status: Bool) -> ()) {
        imageArray = []
        
        for url in imageUrlArray {
            Alamofire.request(url).responseImage { (response) in
                guard let image = response.result.value else { return }
                self.imageArray.append(image)
                
                self.progressLbl?.text = "\(self.imageArray.count)/\(NUMBER_OF_PHOTOS) images downloaded"
                
                if self.imageArray.count == self.imageUrlArray.count {
                    handler(true)
                }
            }
        }
    }
    
    func cancelAllSessions() {
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (uRLSessionDataTask, uRLSessionUploadTask, uRLSessionDownloadTask) in
            uRLSessionDataTask.forEach { $0.cancel() }
            uRLSessionDownloadTask.forEach { $0.cancel()}
            print("\n************\n\n          All session should be cancelled now\n\n************")
        }
    }
    
}

extension MapVC: CLLocationManagerDelegate {
    func configureLocationServices() {
        if authorizationStatus == .notDetermined {
            locationManger.requestAlwaysAuthorization()
        } else {
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        centerMapOnUserLocation()
    }
}

extension MapVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCell {
            cell.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
            let imageFromIndexPath = imageArray[indexPath.row]
            let imageView = UIImageView(image: imageFromIndexPath)
            imageView.contentMode = .scaleAspectFill
//            imageView.clipsToBounds = true
            cell.addSubview(imageView)
//            cell.contentMode = .scaleAspectFit
            return cell
        } else {
            return PhotoCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "PopVC") as? PopVC else { return }
        popVC.initData(forImage: imageArray[indexPath.row])
        present(popVC, animated: true, completion: nil)
    }
    
    
}

extension MapVC: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard
            let indexPath = collectionView?.indexPathForItem(at: location),
            let cell = collectionView?.cellForItem(at: indexPath),
            let popVC = storyboard?.instantiateViewController(withIdentifier: "PopVC") as? PopVC
        else {
            return nil
        }
        
        previewingContext.sourceRect = cell.contentView.frame
        
        popVC.initData(forImage: imageArray[indexPath.row])
        
        return popVC
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
    
    
}
