//
//  DetailViewController.swift
//  GridRace
//
//  Created by Christian on 2/26/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    var objective: Objective
    private let mapView = MKMapView()

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

        self.objective = objective
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
        title = objective.name

        setUpLayout()



        let collapseGestureRecogniser = UIPanGestureRecognizer(target: self, action: #selector(collapseAnimationHandler))
        detailViewController.panView.addGestureRecognizer(collapseGestureRecogniser)
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

    @objc private func collapseAnimationHandler(recognizer: UIPanGestureRecognizer) {
        var translation = recognizer.translation(in: view.superview)

        if recognizer.state == .began {

            onPanBegin()
        }
        if recognizer.state == .ended {
            let velocity = recognizer.velocity(in: view)
            panningEndedWithTranslation(recognizer: recognizer, translation: translation, velocity: velocity)
        }
        else {
            translation = recognizer.translation(in: view.superview)
            panningChangedWithTranslation(translation: translation)
        }


    }

    // when user starts panning set the end position of the collapsableView
    private func onPanBegin() {

        if let animator = collapsableDetailsAnimator, animator.isRunning {
            return
        }

        var targetFrame: CGRect

        if !isCollapsed {
            let newY = view.bounds.height - self.tabBarController!.tabBar.bounds.height - detailViewController.panView.bounds.height - detailViewController.pointBorderImageView.bounds.height - 32
            let oldFrame = collapsableDetailsView.frame
            targetFrame = CGRect(x: oldFrame.minX, y: newY, width: oldFrame.size.width, height: oldFrame.size.height)
        } else {
            let oldFrame = collapsableDetailsView.frame
            let newY = UIApplication.shared.statusBarFrame.height + self.navigationController!.navigationBar.bounds.height + mapView.bounds.height - collapsableDetailsView.bounds.height + 1
            targetFrame = CGRect(x: oldFrame.minX, y: newY, width: oldFrame.width, height: oldFrame.height)
        }

        collapsableDetailsAnimator = UIViewPropertyAnimator(duration: 0.6, curve: .easeIn,
                                                            animations: {
                                                                self.collapsableDetailsView.frame = targetFrame
        })

    }

    // whilst the user is panning translate their finger position the progress of the panning animaition of collapsableView
    private func panningChangedWithTranslation(translation: CGPoint) {

        if let animator = self.collapsableDetailsAnimator, animator.isRunning {

            return
        }

        let translatedY = collapsableDetailsView.frame.origin.y + translation.y

        var progress: CGFloat
        if self.isCollapsed {
            progress = 1 - (translatedY / collapsableDetailsView.frame.origin.y);
        } else {
            progress = (translatedY / collapsableDetailsView.frame.origin.y) - 1;
        }

        progress = max(0.001, min(0.999, progress))

        collapsableDetailsAnimator?.fractionComplete = progress
    }


    // when the user stops panning, decide where the collapsible view should bounce back to
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
