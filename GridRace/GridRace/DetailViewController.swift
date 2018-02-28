//
//  DetailViewController.swift
//  GridRace
//
//  Created by Christian on 2/26/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

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

    private let mapImageView = UIImageView()
    private let descLabel = UILabel()
    private let starImageView = UIImageView()
    private let pointLabel = UILabel()
    private let answerView: UIView
    private let getClueButton = UIButton()

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
        title = objective.name

        initialiseViews()
        setUpLayout()
    }

    private func initialiseViews() {

        //Colors
        view.backgroundColor = AppColors.backgroundColor
        descLabel.textColor = AppColors.textPrimaryColor
        pointLabel.textColor = AppColors.textSecondaryColor
        getClueButton.setTitleColor(AppColors.greenHighlightColor, for: .normal)
        getClueButton.backgroundColor = AppColors.cellColor

        // misc stuff
        descLabel.lineBreakMode = .byWordWrapping
        descLabel.numberOfLines = 0

        mapImageView.contentMode = .scaleAspectFit

        starImageView.contentMode = .scaleAspectFit
        starImageView.tintColor = AppColors.starPointsColor

        pointLabel.font = UIFont.boldSystemFont(ofSize: 16)

        getClueButton.contentEdgeInsets = .init(top: 20, left: 30, bottom: 20, right: 30)
        getClueButton.layer.cornerRadius = 10
        getClueButton.layer.masksToBounds = false
        getClueButton.addTarget(self, action: #selector(clueButtonHandler), for: .touchUpInside)

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

        mapImageView.image = #imageLiteral(resourceName: "map")
        descLabel.text = objective.desc
        starImageView.image = #imageLiteral(resourceName: "star")
        pointLabel.text = "\(objective.pointsCount)"
        getClueButton.setTitle("Get Clue", for: .normal)
    }

    private func setUpLayout() {

        for view in [ mapImageView, descLabel, starImageView, answerView,
        getClueButton] {
            view.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(view)
        }

        pointLabel.translatesAutoresizingMaskIntoConstraints = false
        starImageView.addSubview(pointLabel)

        var constraints = ([
            mapImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapImageView.heightAnchor.constraint(equalToConstant: 200),

            starImageView.topAnchor.constraint(equalTo: mapImageView.bottomAnchor, constant: 16),
            starImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            starImageView.heightAnchor.constraint(equalToConstant: 64),
            starImageView.widthAnchor.constraint(equalToConstant: 64),

            pointLabel.centerXAnchor.constraint(equalTo: starImageView.centerXAnchor),
            pointLabel.centerYAnchor.constraint(equalTo: starImageView.centerYAnchor),

            descLabel.topAnchor.constraint(equalTo: starImageView.topAnchor),
            descLabel.leadingAnchor.constraint(equalTo: starImageView.trailingAnchor, constant: 16),
            descLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            answerView.topAnchor.constraint(equalTo: starImageView.bottomAnchor, constant: 16),
            answerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),


            getClueButton.topAnchor.constraint(equalTo: answerView.bottomAnchor, constant: 20),
            getClueButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        if answerView is UIImageView {
            constraints += [ answerView.heightAnchor.constraint(equalToConstant: 180),
                answerView.widthAnchor.constraint(equalToConstant: 180)]
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
            hudView.text = "CheckPoint"

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0,
        execute: {
            hudView.hide()
            //self.navigationController?.popViewController(animated: true)
        })
    }

}
