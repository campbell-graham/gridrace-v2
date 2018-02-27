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
    var hintViewed: Bool

}

class DetailViewController: UIViewController, UIGestureRecognizerDelegate {

    var objective: Objective

    let mapImageView = UIImageView()
    let descLabel = UILabel()
    let pointLabel = UILabel()
    let userPhotoImageView = UIImageView()
    let getClueButton = UIButton()
    let pointDeductionValue = 2

    init(objective: Objective) {
        self.objective = objective

        super.init(nibName: nil, bundle: nil)
    }

    init() {
        self.objective = Objective(name: "office", desc: "Take photo at office and then there was a little boy that",
                                   hintImage: #imageLiteral(resourceName: "eye"), hintText: "its in plain sight, or is it?", pointsCount: 10, hintViewed: false)

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

        // misc stuff
        descLabel.lineBreakMode = .byWordWrapping
        descLabel.numberOfLines = 0

        let tapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(selectPhoto))
        tapGestureRecogniser.delegate = self
        userPhotoImageView.addGestureRecognizer(tapGestureRecogniser)
        userPhotoImageView.isUserInteractionEnabled = true
        userPhotoImageView.tintColor = AppColors.greenHighlightColor

        userPhotoImageView.contentMode = .scaleAspectFit
        mapImageView.contentMode = .scaleAspectFit

        getClueButton.contentEdgeInsets = .init(top: 20, left: 30, bottom: 20, right: 30)
        getClueButton.layer.cornerRadius = 10
        getClueButton.layer.masksToBounds = false
        getClueButton.addTarget(self, action: #selector(clueButtonHandler), for: .touchUpInside)

        updateViewsData()
    }

    func updateViewsData() {

        mapImageView.image = #imageLiteral(resourceName: "map")
        descLabel.text = objective.desc
        pointLabel.text = "\(objective.pointsCount)"
        userPhotoImageView.image = #imageLiteral(resourceName: "camera")
        getClueButton.setTitle("Get Clue", for: .normal)
    }

    func setUpLayout() {

        for v in [ mapImageView, descLabel, pointLabel, userPhotoImageView,
        getClueButton] {
            v.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(v)
        }

        NSLayoutConstraint.activate([
            mapImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            mapImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapImageView.topAnchor.constraint(equalTo: view.topAnchor),
            mapImageView.heightAnchor.constraint(equalToConstant: 200),

            descLabel.topAnchor.constraint(equalTo: mapImageView.bottomAnchor, constant: 5),
            descLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            descLabel.trailingAnchor.constraint(equalTo: pointLabel.leadingAnchor),

            pointLabel.topAnchor.constraint(equalTo: descLabel.topAnchor),
            pointLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),

            userPhotoImageView.topAnchor.constraint(equalTo: descLabel.bottomAnchor, constant: 10),
            userPhotoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            userPhotoImageView.heightAnchor.constraint(equalToConstant: 180),
            userPhotoImageView.widthAnchor.constraint(equalToConstant: 180),

            getClueButton.topAnchor.constraint(equalTo: userPhotoImageView.bottomAnchor, constant: 20),
            getClueButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            
            ])
    }

    @objc func clueButtonHandler() {

        if !objective.hintViewed {
            presentPointLossAlert()
        } else {
            presentClueViewController()
        }

    }

    @objc func presentPointLossAlert() {

        let alert = UIAlertController(title: "Warning:", message: "The amount of points gained for this objective will be reduced by \(pointDeductionValue)", preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        let continueAction = UIAlertAction(title: "Continue", style: .default, handler: { _ in
            self.objective.pointsCount -= self.pointDeductionValue
            self.objective.hintViewed = true
            self.updateViewsData()
            self.presentClueViewController() })
        alert.addAction(continueAction)

        present(alert, animated: true, completion: nil)

    }

    func presentClueViewController() {
        let clueViewController = ClueViewController(objective: objective)
        clueViewController.modalTransitionStyle = .crossDissolve
        clueViewController.modalPresentationStyle = .overCurrentContext
        present(clueViewController, animated: true, completion: nil)
    }

}

extension DetailViewController:
UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @objc func selectPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            takePhotoWithCamera()
        } else {
            choosePhotoFromLibrary()
        }
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
        let retrivedImage = info[UIImagePickerControllerEditedImage] as? UIImage
        userPhotoImageView.image = retrivedImage?.resized(withBounds:  CGSize(width: 200, height: 200))
        dismiss(animated: true, completion: nil)

        playHudAnimation()
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    func playHudAnimation() {
        let hudView = HudView.hud(inView: navigationController!.view, animated: true)
            hudView.text = "CheckPoint"

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5,
                                      execute: {
                                        hudView.hide()
                                        self.navigationController?.popViewController(animated: true)
        })
    }

}
