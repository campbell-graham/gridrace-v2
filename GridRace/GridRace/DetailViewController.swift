//
//  DetailViewController.swift
//  GridRace
//
//  Created by Christian on 2/26/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MapKit

struct ObjectiveStruct {
    var name: String
    var desc: String
    var objectiveType: Int // 0: take picture, 1: enter word, 2: enter pin
    var hintImage: UIImage
    var hintText: String
    var pointsCount: Int
    var hintViewed: Bool
    var pointDeductionValue: Int
}

class DetailViewController: UIViewController {

    var objective: ObjectiveStruct

    private let mapView = MKMapView()
    private let descLabel = UILabel()
    private let starImageView = UIImageView()
    private let pointLabel = UILabel()
    private let answerView: UIView

    init(objective: ObjectiveStruct) {

        self.objective = objective

        switch  objective.objectiveType {
        case 0: // imageview
            answerView = UIImageView()
        case 1: // textField
            answerView = UITextField()
        case 2: // pin view
            answerView = UIView()
        default:
            answerView = UIView()

        }

        super.init(nibName: nil, bundle: nil)
    }

    init() {

        self.objective = ObjectiveStruct(name: "office", desc: "Take photo at office and then there was a little boy that", objectiveType: 0,
            hintImage: #imageLiteral(resourceName: "eye"), hintText: "its in plain sight, or is it?", pointsCount: 10, hintViewed: false, pointDeductionValue: 2)

        switch  objective.objectiveType {
        case 0: // imageview
            answerView = UIImageView()
        case 1: // textField
            answerView = UITextField()
        case 2: // pin view
            answerView = UIView()
        default:
            answerView = UIView()

        }

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func viewDidLoad() {

        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Get Clue", style: .done, target: self, action: #selector(clueButtonHandler) )
        title = objective.name

        initialiseViews()
        setUpLayout()
    }

    private func initialiseViews() {

        //Colors
        view.backgroundColor = AppColors.backgroundColor
        descLabel.textColor = AppColors.textPrimaryColor
        pointLabel.textColor = AppColors.textSecondaryColor

        // misc stuff
        descLabel.lineBreakMode = .byWordWrapping
        descLabel.numberOfLines = 0

        starImageView.contentMode = .scaleAspectFit
        starImageView.tintColor = AppColors.starPointsColor

        pointLabel.font = UIFont.boldSystemFont(ofSize: 16)

        updateViewsData()

        switch answerView {
        case is UIImageView:
            if let answerView = answerView as? UIImageView {
                let tapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(selectPhoto))
                answerView.addGestureRecognizer(tapGestureRecogniser)
                answerView.isUserInteractionEnabled = true
                answerView.tintColor = AppColors.greenHighlightColor
//                answerView.contentMode = .scaleAspectFit
                answerView.image = #imageLiteral(resourceName: "camera")
            }
        case is UITextField:
            if let answerView = answerView as? UITextField {
            }
        case is UIView:
            if let answerView = answerView as? UIView {
            }
        default:
            break
        }
    }

    private func updateViewsData() {

        descLabel.text = objective.desc
        starImageView.image = #imageLiteral(resourceName: "star")
        pointLabel.text = "\(objective.pointsCount)"
    }

    private func setUpLayout() {

        for view in [ mapView, descLabel, starImageView, answerView] {
            view.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(view)
        }

        pointLabel.translatesAutoresizingMaskIntoConstraints = false
        starImageView.addSubview(pointLabel)

        var constraints = ([
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.25),

            starImageView.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 16),
            starImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            starImageView.heightAnchor.constraint(equalToConstant: 64),
            starImageView.widthAnchor.constraint(equalToConstant: 64),

            pointLabel.centerXAnchor.constraint(equalTo: starImageView.centerXAnchor),
            pointLabel.centerYAnchor.constraint(equalTo: starImageView.centerYAnchor),

            descLabel.centerYAnchor.constraint(equalTo: starImageView.centerYAnchor),
            descLabel.leadingAnchor.constraint(equalTo: starImageView.trailingAnchor, constant: 16),
            descLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            answerView.topAnchor.constraint(greaterThanOrEqualTo: starImageView.bottomAnchor, constant: 16),
            answerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            answerView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
        ])

        if answerView is UIImageView {
            constraints += [
                answerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            answerView.heightAnchor.constraint(equalTo: answerView.widthAnchor)]
        }

        NSLayoutConstraint.activate(constraints)
    }

    @objc private func clueButtonHandler() {

        if !objective.hintViewed {
            presentPointLossAlert()
        } else {
            presentClueViewController()
        }

    }

    @objc private func presentPointLossAlert() {

        let alert = UIAlertController(title: "Warning:", message: "The amount of points gained for this objective will be reduced by \(objective.pointDeductionValue)", preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        let continueAction = UIAlertAction(title: "Continue", style: .default, handler: { _ in
            self.objective.pointsCount -= self.objective.pointDeductionValue
            self.objective.hintViewed = true
            self.updateViewsData()
            self.presentClueViewController() })
        alert.addAction(continueAction)

        present(alert, animated: true, completion: nil)
    }

    private func presentClueViewController() {
        let clueViewController = ClueViewController(objective: objective)
        clueViewController.modalTransitionStyle = .crossDissolve
        clueViewController.modalPresentationStyle = .overCurrentContext
        present(clueViewController, animated: true, completion: nil)
    }

}

extension DetailViewController:
UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @objc private func selectPhoto() {

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            takePhotoWithCamera()
        } else {
            choosePhotoFromLibrary()
        }
    }

    private func takePhotoWithCamera() {

        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }

    private func choosePhotoFromLibrary() {

        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }



    // MARK:- Image Picker Delegates
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        let retrivedImage = info[UIImagePickerControllerEditedImage] as? UIImage
        if let answerView = answerView as? UIImageView {
            answerView.contentMode = .scaleAspectFit
            answerView.image = retrivedImage?.resized(withBounds:  CGSize(width: 200, height: 200))
        }
        dismiss(animated: true, completion: nil)

        playHudAnimation()
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {

        dismiss(animated: true, completion: nil)
    }

    private func playHudAnimation() {

        let hudView = HudView.hud(inView: navigationController!.view, animated: true)
            hudView.text = "Complete!"

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0,
        execute: {
            hudView.hide()
            //self.navigationController?.popViewController(animated: true)
        })
    }

}
