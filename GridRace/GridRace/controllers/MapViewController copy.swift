//
//  DetailViewController.swift
//  GridRace
//
//  Created by Christian on 2/26/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate {

    var objectives = [Objective]()
    private let mapView = MKMapView()

    //user location
    private let locationManager = CLLocationManager()
    private var userLocation: CLLocation?
    private var updatingLocation = false
    private var lastLocationError: Error?

    private let detailViewController: DetailViewController
    private lazy var collapsableDetailsView: UIView = {

        let view = detailViewController.view
        return view ?? UIView()
    }()

    var delegate: ObjectiveTableViewControllerDelegate? {
        didSet {
            detailViewController.delegate = self.delegate
        }
    }
    private var isCollapsed = false
    private var collapsableDetailsAnimator: UIViewPropertyAnimator?

    init(objective: Objective) {

        self.objectives.append(objective)
        self.detailViewController = DetailViewController(objective: objective)
        super.init(nibName: nil, bundle: nil)

        addChildViewController(detailViewController)
        detailViewController.didMove(toParentViewController: self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func viewDidLoad() {

        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = false
        title = objectives[0].name

        setUpLayout()

        //set up animation panGestureRecognizer
        let collapseGestureRecogniser = UIPanGestureRecognizer(target: self, action: #selector(collapseAnimationHandler))
        detailViewController.panView.addGestureRecognizer(collapseGestureRecogniser)

        // show user, and zoom to objective location
        mapView.showsUserLocation = true
        showLocations()
    }

    private func setUpLayout() {

        for view in [ mapView, collapsableDetailsView] {
            view.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(view)
        }

        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            collapsableDetailsView.heightAnchor.constraint(equalToConstant: view.frame.height * 0.6),
            collapsableDetailsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collapsableDetailsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collapsableDetailsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }

    @objc func getLocation() {
        //ask permission for user location  (also had to add "NSLocationWhenInUseUsageDescription" to Info.plist file)
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        // if permission denied show popup alert
        if authStatus == .denied || authStatus == .restricted {
            showLocationServicesDeniedAlert()
            return
        }
        //start/stop searching for user location
        if updatingLocation {
            stopLocationManager()
        } else {
            userLocation = nil
            lastLocationError = nil
            startLocationManager()
        }
    }

    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            updatingLocation = true
        }
    }

    func stopLocationManager() {
        if updatingLocation {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
        }
    }

    func showLocations() {

        // set region to userLocation to begin with
        var region = MKCoordinateRegionMakeWithDistance( mapView.userLocation.coordinate, 1000, 1000)

        // if there only one location, set region to that location
        if objectives.count == 1 {

            if let objCord = objectives[0].coordinate {
                region = MKCoordinateRegionMakeWithDistance( objCord, 1000, 1000)
            }
        } else { // if there are many location set region to fit them all

            var topLeft = CLLocationCoordinate2D(latitude: -90,  longitude: 180)
            var bottomRight = CLLocationCoordinate2D(latitude: 90, longitude: -180)

            for objective in objectives {
                if let objCord = objective.coordinate {
                    topLeft.latitude = max(topLeft.latitude,  objCord.latitude)
                    topLeft.longitude = min(topLeft.longitude,  objCord.longitude)
                    bottomRight.latitude = min(bottomRight.latitude, objCord.latitude)
                    bottomRight.longitude = max(bottomRight.longitude, objCord.longitude)
                }
            }

            let center = CLLocationCoordinate2D(
                latitude: topLeft.latitude - (topLeft.latitude - bottomRight.latitude) / 2,
                longitude: topLeft.longitude - (topLeft.longitude - bottomRight.longitude) / 2)
            let extraSpace = 1.1
            let span = MKCoordinateSpan( latitudeDelta: abs(topLeft.latitude - bottomRight.latitude) * extraSpace,
                                         longitudeDelta: abs(topLeft.longitude - bottomRight.longitude) * extraSpace)
            region = MKCoordinateRegion(center: center, span: span)
            region = mapView.regionThatFits(region)

        }

        mapView.setRegion(region, animated: true)
    }

    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError \(error)")
        if (error as NSError).code == CLError.locationUnknown.rawValue {
            return
        }
        lastLocationError = error
        stopLocationManager()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        print("didUpdateLocations \(newLocation)")
        // only update location if its been at least 5 seconds from last update
        guard newLocation.timestamp.timeIntervalSinceNow > -5 else { return }
        // filter out invalid location updates
        guard newLocation.horizontalAccuracy > 0 else { return }


        var distance = CLLocationDistance(Double.greatestFiniteMagnitude)
        if let location = userLocation {
            distance = newLocation.distance(from: location)
        }

        // only update if current location hasnt been retrieved or the new update is more accurate
        if userLocation == nil || userLocation!.horizontalAccuracy > newLocation.horizontalAccuracy {
            lastLocationError = nil
            userLocation = newLocation
            zoomTo(location: userLocation!)
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                print("*** We're done!")
                stopLocationManager()
            }
        }
        else if distance < 1 {
            let timeInterval = newLocation.timestamp.timeIntervalSince(userLocation!.timestamp)
            if timeInterval > 10 {
                print("*** Force done!")
                stopLocationManager()
            }
        }
    }

    func zoomTo(location: CLLocation) {
        let region = MKCoordinateRegionMakeWithDistance( location.coordinate, 1000, 1000)
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
    }

    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(
            title: "Location Services Disabled",
            message: "Please enable location services for this app in Settings.",
            preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        present(alert, animated: true, completion: nil)
        alert.addAction(okAction)
    }
}




//MARK:- animation extension
extension MapViewController {

    @objc private func collapseAnimationHandler(recognizer: UIPanGestureRecognizer) {

        // translation is a numeric value that represents how much pixels the user has moved from start of panning
        let translation = recognizer.translation(in: view)

        var totalYMovement: CGFloat = 0.0 // the value between the animated views highest possible point and lowest possible point

        if recognizer.state == .began {

            // on start of user panning, set destination frame of the animated viewController
            totalYMovement = onPanBegin()
        }

        if recognizer.state == .ended {

            let velocity = recognizer.velocity(in: view)
            // whilst the user is panning translate their finger position the progress of the panning animaition of collapsableView
            panningEndedWithTranslation(recognizer: recognizer, translation: translation, velocity: velocity)

        }

        else {
            // when the user stops panning, decide where the collapsible view should bounce back to
            panningChangedWithTranslation(translation: translation, totalYMovement: totalYMovement)
        }
    }

    private func onPanBegin() -> CGFloat {

        if let animator = collapsableDetailsAnimator, animator.isRunning {
            return CGFloat(0.0)
        }

        var targetFrame: CGRect
        let oldFrame = collapsableDetailsView.frame
        var totalYMovement: CGFloat = 0.0

        if !isCollapsed {

            let newY = view.bounds.height - self.tabBarController!.tabBar.bounds.height - detailViewController.panView.bounds.height - detailViewController.pointBorderImageView.bounds.height - 32

            targetFrame = CGRect(x: oldFrame.minX, y: newY, width: oldFrame.size.width, height: oldFrame.size.height)

            totalYMovement = targetFrame.origin.y - oldFrame.origin.y
        } else {

            let newY = UIApplication.shared.statusBarFrame.height + navigationController!.navigationBar.bounds.height + mapView.bounds.height - collapsableDetailsView.bounds.height + 1
            targetFrame = CGRect(x: oldFrame.minX, y: newY, width: oldFrame.width, height: oldFrame.height)

            totalYMovement =  oldFrame.origin.y - targetFrame.origin.y
        }

        collapsableDetailsAnimator = UIViewPropertyAnimator(duration: 0.6, curve: .easeIn,
        animations: {
            self.collapsableDetailsView.frame = targetFrame
        })

        return totalYMovement
    }


    private func panningChangedWithTranslation(translation: CGPoint, totalYMovement: CGFloat) {

        if let animator = self.collapsableDetailsAnimator, animator.isRunning {
            return
        }

        print("Translation", translation)

        var progress: CGFloat
        if self.isCollapsed {
            progress = -(translation.y / totalYMovement)
        } else {
            progress = (translation.y / totalYMovement)
        }

        progress = max(0.001, min(0.999, progress)) // ensure progress is a percentage (greather than 0, less than 1)

        collapsableDetailsAnimator?.fractionComplete = progress
    }



    private func panningEndedWithTranslation(recognizer: UIPanGestureRecognizer, translation: CGPoint, velocity: CGPoint) {

        recognizer.isEnabled = false

        let screenHeight = UIScreen.main.bounds.height

        if isCollapsed {
            if (translation.y <= -screenHeight / 3 || velocity.y <= -100)
            {
                self.collapsableDetailsAnimator!.isReversed = false

                self.collapsableDetailsAnimator!.addCompletion({ final in

                    self.isCollapsed = false
                    recognizer.isEnabled = true
                })
            } else {
                self.collapsableDetailsAnimator!.isReversed = true

                self.collapsableDetailsAnimator!.addCompletion({ final in
                    self.isCollapsed = true
                    recognizer.isEnabled = true
                })
            }
        } else {

            if (translation.y >= screenHeight / 3 || velocity.y >= 100) {

                self.collapsableDetailsAnimator!.isReversed = false

                self.collapsableDetailsAnimator!.addCompletion({ final in
                    self.isCollapsed = true
                    recognizer.isEnabled = true
                })
            } else {
                self.collapsableDetailsAnimator!.isReversed = true

                self.collapsableDetailsAnimator!.addCompletion({ final in

                    self.isCollapsed = false
                    recognizer.isEnabled = true
                })
            }
        }

        let velocityVector = CGVector(dx: velocity.x / 100, dy: velocity.y / 100)
        let springParameters = UISpringTimingParameters.init(dampingRatio: 0.8, initialVelocity: velocityVector)

        collapsableDetailsAnimator?.continueAnimation(withTimingParameters: springParameters, durationFactor: 1.0)
    }

}

