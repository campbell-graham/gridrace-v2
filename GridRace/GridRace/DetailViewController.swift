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
    private let descLabel = UITextView()
    private let starImageView = UIImageView()
    private let pointLabel = UILabel()
    private let answerView: UIView

    init(objective: ObjectiveStruct) {

        self.objective = objective

        switch  objective.objectiveType {
        case 0: // imageview
            answerView = UIImageView()
        case 1: // textField
            answerView = textFieldView()
        case 2: // pin view
            answerView = UIView()
        default:
            answerView = UIView()

        }

        super.init(nibName: nil, bundle: nil)
    }

    init() {

        self.objective = ObjectiveStruct(name: "Office", desc: "Take photo at office and and then there was a little boy that Take photo at office and and then there was a little boy Take photo at office and and then there was a little boy Take photo at office and and then there was a little boy Take photo at office and and then there was a little boy oto at office and and then there was a little boy Take photo at office and and then there was a little boy Take photo at office and and then there was a little boy Take photo at office and and then there was a little boy", objectiveType: 1,
            hintImage: #imageLiteral(resourceName: "eye"), hintText: "its in plain sight, or is it?", pointsCount: 10, hintViewed: false, pointDeductionValue: 2)

        switch  objective.objectiveType {
        case 0: // imageview
            answerView = UIImageView()
        case 1: // textField
            answerView = textFieldView()
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
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancelHandler) )
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Get Clue", style: .done, target: self, action: #selector(clueButtonHandler) )
        title = objective.name

        initialiseViews()
        setUpLayout()
    }

    private func initialiseViews() {

        //Colors
        view.backgroundColor = AppColors.backgroundColor
        descLabel.textColor = AppColors.textPrimaryColor
        pointLabel.textColor = AppColors.greenHighlightColor

        updateViewsData()

        // misc stuff
        descLabel.backgroundColor = AppColors.backgroundColor
        descLabel.font = UIFont.systemFont(ofSize: 16)

        starImageView.contentMode = .scaleAspectFit
        starImageView.tintColor = AppColors.greenHighlightColor

        pointLabel.font = UIFont.boldSystemFont(ofSize: 16)

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
            if let answerView = answerView as? textFieldView {
                
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
        starImageView.image = #imageLiteral(resourceName: "circle")
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

            descLabel.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 16),
            descLabel.leadingAnchor.constraint(equalTo: starImageView.trailingAnchor, constant: 16),
            descLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            descLabel.heightAnchor.constraint(equalToConstant: 160),

            starImageView.topAnchor.constraint(equalTo: descLabel.topAnchor),
            starImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            starImageView.heightAnchor.constraint(equalToConstant: 64),
            starImageView.widthAnchor.constraint(equalToConstant: 64),

            pointLabel.centerXAnchor.constraint(equalTo: starImageView.centerXAnchor),
            pointLabel.centerYAnchor.constraint(equalTo: starImageView.centerYAnchor),


        ])

        switch answerView {
        case is UIImageView:
            constraints += [
                answerView.topAnchor.constraint(greaterThanOrEqualTo: starImageView.bottomAnchor, constant: 16),
                answerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                answerView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
                answerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            answerView.heightAnchor.constraint(equalTo: answerView.widthAnchor)]
        case is textFieldView:
            constraints += [
                answerView.topAnchor.constraint(equalTo: starImageView.bottomAnchor),
                answerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                answerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                answerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)]
        default:
            break
        }

        NSLayoutConstraint.activate(constraints)
    }

    @objc private func cancelHandler() {

        navigationController?.popViewController(animated: true)
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

    //set textView to be scrolled to top
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        descLabel.setContentOffset(CGPoint.zero, animated: false)
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
