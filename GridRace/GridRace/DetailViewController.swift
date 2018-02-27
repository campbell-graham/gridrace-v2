//
//  DetailViewController.swift
//  GridRace
//
//  Created by Christian on 2/26/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

struct Objective {
    var name: String
    var desc: String
    var hintImage: UIImage
    var hintText: String
    var pointsCount: Int

}

class DetailViewController: UIViewController, UIGestureRecognizerDelegate {

    var objective: Objective

    let mapImageView = UIImageView()
    let descLabel = UILabel()
    let pointLabel = UILabel()
    let userPhotoImageView = UIImageView()
    let getClueButton = UIButton()
    let lowerNavBarView = UIView()
    let timerLabel = UILabel()
    let totalPointsLabel = UILabel()

    init(objective: Objective) {
        self.objective = objective

        super.init(nibName: nil, bundle: nil)
    }

    init() {
        self.objective = Objective(name: "office", desc: "take photo at office and then there was a little boy that",
                                   hintImage: #imageLiteral(resourceName: "eye"), hintText: "its in plain sight, or is it?", pointsCount: 10)

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true
        title = objective.name
        edgesForExtendedLayout = []

        initialiseViews()
        setUpLayout()
    }

    func initialiseViews() {

        //Colors
        view.backgroundColor = AppColors.backgroundColor
        descLabel.textColor = AppColors.textPrimaryColor
        pointLabel.textColor = AppColors.textPrimaryColor
        getClueButton.setTitleColor(AppColors.greenHighlightColor, for: .normal)
        getClueButton.backgroundColor = AppColors.cellColor
        timerLabel.textColor = AppColors.textSecondaryColor
        totalPointsLabel.textColor = AppColors.textSecondaryColor
        lowerNavBarView.backgroundColor = AppColors.greenHighlightColor

        // misc stuff
        descLabel.lineBreakMode = .byWordWrapping
        descLabel.numberOfLines = 0
        timerLabel.textAlignment = .center
        totalPointsLabel.textAlignment = .center

        let tapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(selectPhoto))
        tapGestureRecogniser.delegate = self
        userPhotoImageView.addGestureRecognizer(tapGestureRecogniser)
        userPhotoImageView.isUserInteractionEnabled = true

        userPhotoImageView.contentMode = .scaleAspectFit
        userPhotoImageView.layer.borderColor = AppColors.textPrimaryColor.cgColor
        userPhotoImageView.layer.borderWidth = 5
        mapImageView.contentMode = .scaleAspectFit

        getClueButton.contentEdgeInsets = .init(top: 20, left: 30, bottom: 20, right: 30)
        getClueButton.layer.cornerRadius = 10
        getClueButton.layer.masksToBounds = false
        getClueButton.addTarget(self, action: #selector(presentClueViewController), for: .touchUpInside)

        updateViewsData()
    }

    func updateViewsData() {

        mapImageView.image = #imageLiteral(resourceName: "map")
        descLabel.text = objective.desc
        pointLabel.text = "\(objective.pointsCount)"
        userPhotoImageView.image = #imageLiteral(resourceName: "camera")
        getClueButton.setTitle("Get Clue", for: .normal)
        timerLabel.text = "1:00"
        totalPointsLabel.text = "0"
    }

    func setUpLayout() {

        for v in [ mapImageView, descLabel, pointLabel, userPhotoImageView,
        getClueButton, lowerNavBarView, timerLabel, totalPointsLabel] {
            v.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(v)
        }

        NSLayoutConstraint.activate([
            mapImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            mapImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapImageView.topAnchor.constraint(equalTo: view.topAnchor),
            mapImageView.heightAnchor.constraint(equalToConstant: 200),

            descLabel.topAnchor.constraint(equalTo: mapImageView.bottomAnchor, constant: 5),
            descLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            descLabel.trailingAnchor.constraint(equalTo: pointLabel.leadingAnchor),

            pointLabel.topAnchor.constraint(equalTo: descLabel.topAnchor),
            pointLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            userPhotoImageView.topAnchor.constraint(equalTo: descLabel.bottomAnchor, constant: 10),
            userPhotoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            userPhotoImageView.heightAnchor.constraint(equalToConstant: 200),
            userPhotoImageView.widthAnchor.constraint(equalToConstant: 200),

            getClueButton.topAnchor.constraint(equalTo: userPhotoImageView.bottomAnchor, constant: 20),
            getClueButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            lowerNavBarView.topAnchor.constraint(greaterThanOrEqualTo: getClueButton.bottomAnchor, constant: 10),
            lowerNavBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            lowerNavBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            lowerNavBarView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            lowerNavBarView.heightAnchor.constraint(equalToConstant: 30),

            timerLabel.centerYAnchor.constraint(equalTo: lowerNavBarView.centerYAnchor),
            timerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            timerLabel.trailingAnchor.constraint(lessThanOrEqualTo: totalPointsLabel.trailingAnchor),

            totalPointsLabel.centerYAnchor.constraint(equalTo: timerLabel.centerYAnchor),
            totalPointsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor)

            ])
    }

    @objc func presentClueViewController() {

        objective.pointsCount -= 2

        let clueViewController = ClueViewController(objective: objective)
        clueViewController.modalTransitionStyle = .crossDissolve
        clueViewController.modalPresentationStyle = .overCurrentContext
        present(clueViewController, animated: true, completion: nil)
    }

    @objc func dismissClueViewController() {

        dismiss(animated: true, completion: nil)
    }

}

extension DetailViewController:
UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @objc func selectPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            showPhotoMenu()
        } else {
            choosePhotoFromLibrary()
        }
    }

    func showPhotoMenu() {

        let alert: UIAlertController

        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad ){
            alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        } else {
            alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        }
        let actCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(actCancel)
        let actPhoto = UIAlertAction(title: "Take Photo", style: .default, handler: { _ in
            self.takePhotoWithCamera() })
        alert.addAction(actPhoto)
        let actLibrary = UIAlertAction(title: "Choose From Library", style: .default, handler: { _ in
            self.choosePhotoFromLibrary() })
        alert.addAction(actLibrary)

        present(alert, animated: true, completion: nil)

    }

    func takePhotoWithCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }

    func choosePhotoFromLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }



    // MARK:- Image Picker Delegates
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        userPhotoImageView.image = info[UIImagePickerControllerEditedImage] as? UIImage
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

}
