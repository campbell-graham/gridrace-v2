//
//  DetailViewController.swift
//  GridRace
//
//  Created by Christian on 2/26/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MapKit

class DetailViewController: UIViewController {

    var objective: Objective
    private let mapView = MKMapView()
    private let collapsableDetailsView = UIView()
    private let descLabel = UITextView()
    private let pointBorderImageView = UIImageView()
    private let pointLabel = UILabel()
    private let answerView: UIView
    private let interactImageView = UIImageView()
    private let hintImageView = UIImageView()
    private let pointDeductionValue = 2
    private var isCollapsed = false
    private var collapsableDetailsAnimator: UIViewPropertyAnimator?

    init(objective: Objective) {

        self.objective = objective

        switch  objective.objectiveType {
        case .photo: // imageview
            answerView = UIImageView()
        case .text: // textField
            answerView = ContainerView()
        case .password: // pin view
            answerView = UIView()
        default:
            break

        }

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func viewDidLoad() {

        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = false
        title = objective.name

        initialiseViews()
        setUpLayout()
    }

    private func initialiseViews() {

        //Colors
        collapsableDetailsView.backgroundColor = AppColors.backgroundColor
        descLabel.textColor = AppColors.textPrimaryColor
        pointLabel.textColor = AppColors.greenHighlightColor
        pointBorderImageView.tintColor = AppColors.greenHighlightColor
        interactImageView.tintColor = AppColors.greenHighlightColor
        hintImageView.tintColor = AppColors.greenHighlightColor

        updateViewsData()

        // misc stuff
        descLabel.backgroundColor = AppColors.backgroundColor
        descLabel.font = UIFont.systemFont(ofSize: 16)
        descLabel.isEditable = false

        let collapseGestureRecogniser = UIPanGestureRecognizer(target: self, action: #selector(collapseAnimationHandler))
        pointBorderImageView.addGestureRecognizer(collapseGestureRecogniser)
        pointBorderImageView.isUserInteractionEnabled = true
        pointBorderImageView.contentMode = .scaleAspectFit

        pointLabel.font = UIFont.boldSystemFont(ofSize: 16)

        let interactGestureRecogniser: UITapGestureRecognizer

        switch answerView {
        case is UIImageView :
            interactGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(selectPhoto))
        case is ContainerView :
            interactGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(enterAnswer))
        default:
            interactGestureRecogniser = UITapGestureRecognizer(target: self, action: nil)
        }

        interactImageView.addGestureRecognizer(interactGestureRecogniser)
        interactImageView.isUserInteractionEnabled = true
        interactImageView.contentMode = .scaleAspectFit

        let hintGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(clueButtonHandler))
        hintImageView.addGestureRecognizer(hintGestureRecogniser)
        hintImageView.isUserInteractionEnabled = true
        hintImageView.contentMode = .scaleAspectFit
    }

    private func updateViewsData() {

        descLabel.text = objective.desc
        pointBorderImageView.image = #imageLiteral(resourceName: "circle")
        pointLabel.text = "\(ObjectiveManager.shared.pointValue(for: self.objective))"
        interactImageView.image = answerView is UIImageView ? #imageLiteral(resourceName: "camera") : #imageLiteral(resourceName: "textCursor")
        hintImageView.image = #imageLiteral(resourceName: "hint")
    }

    private func setUpLayout() {

        for view in [ mapView, collapsableDetailsView] {
            view.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(view)
        }

        for view in [descLabel, pointBorderImageView, answerView, interactImageView, hintImageView] {
            view.translatesAutoresizingMaskIntoConstraints = false
            collapsableDetailsView.addSubview(view)
        }

        pointLabel.translatesAutoresizingMaskIntoConstraints = false
        pointBorderImageView.addSubview(pointLabel)

        var constraints = ([
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            collapsableDetailsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: (view.bounds.height) / 4 ),
            collapsableDetailsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collapsableDetailsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collapsableDetailsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            descLabel.topAnchor.constraint(equalTo: collapsableDetailsView.topAnchor, constant: 16),
            descLabel.leadingAnchor.constraint(equalTo: pointBorderImageView.trailingAnchor, constant: 16),
            descLabel.trailingAnchor.constraint(equalTo: collapsableDetailsView.trailingAnchor, constant: -16),
            descLabel.heightAnchor.constraint(equalTo: collapsableDetailsView.heightAnchor, multiplier: 0.2),

            pointBorderImageView.topAnchor.constraint(equalTo: descLabel.topAnchor),
            pointBorderImageView.leadingAnchor.constraint(equalTo: collapsableDetailsView.leadingAnchor, constant: 16),
            pointBorderImageView.heightAnchor.constraint(equalToConstant: 64),
            pointBorderImageView.widthAnchor.constraint(equalToConstant: 64),

            pointLabel.centerXAnchor.constraint(equalTo: pointBorderImageView.centerXAnchor),
            pointLabel.centerYAnchor.constraint(equalTo: pointBorderImageView.centerYAnchor),
        ])

        switch answerView {
        case is UIImageView:
            constraints += [
                answerView.topAnchor.constraint(greaterThanOrEqualTo: descLabel.bottomAnchor, constant: 16),
                answerView.centerXAnchor.constraint(equalTo: collapsableDetailsView.centerXAnchor),
                answerView.bottomAnchor.constraint(lessThanOrEqualTo: interactImageView.bottomAnchor, constant: -16),
                answerView.widthAnchor.constraint(equalTo: collapsableDetailsView.widthAnchor, multiplier: 0.3),
            answerView.heightAnchor.constraint(equalTo: answerView.widthAnchor)]
        case is ContainerView:
            constraints += [
                answerView.topAnchor.constraint(equalTo: descLabel.bottomAnchor),
                answerView.leadingAnchor.constraint(equalTo: collapsableDetailsView.leadingAnchor),
                answerView.trailingAnchor.constraint(equalTo: collapsableDetailsView.trailingAnchor),
                answerView.bottomAnchor.constraint(equalTo: collapsableDetailsView.safeAreaLayoutGuide.bottomAnchor)]
        default:
            break
        }

        constraints += [
            interactImageView.topAnchor.constraint(greaterThanOrEqualTo: answerView.bottomAnchor, constant: 16),
            interactImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -(view.center.x / 2) ),
            interactImageView.bottomAnchor.constraint(lessThanOrEqualTo: collapsableDetailsView.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            interactImageView.widthAnchor.constraint(equalTo: collapsableDetailsView.widthAnchor, multiplier: 0.20),
            interactImageView.heightAnchor.constraint(equalTo: interactImageView.widthAnchor),

            hintImageView.topAnchor.constraint(equalTo: interactImageView.topAnchor),
            hintImageView.centerXAnchor.constraint(equalTo: collapsableDetailsView.centerXAnchor, constant: (view.center.x / 2) ),
            hintImageView.bottomAnchor.constraint(equalTo: interactImageView.bottomAnchor),
            hintImageView.widthAnchor.constraint(equalTo: collapsableDetailsView.widthAnchor, multiplier: 0.20),
            hintImageView.heightAnchor.constraint(equalTo: hintImageView.widthAnchor)
        ]

        NSLayoutConstraint.activate(constraints)
    }

    @objc private func collapseAnimationHandler() {



        let translation = [recognizer translationInView:self.view.superview];

        if (recognizer.state == UIGestureRecognizerStateBegan)
        {
            onPanBegin()
        }
        if (recognizer.state == UIGestureRecognizerStateEnded)
        {
            let velocity = [recognizer velocityInView:self.view];
            panningEndedWithTranslation:(translation: translation, velocity: velocity)
        }
        else
        {
            CGPoint translation = [recognizer translationInView:self.view.superview];
            panningChangedWithTranslation(translation: velocity)
        }
    }

    private func onPanBegin() {

        if self.collapsableDetailsAnimator.isRunning {
            return
        }

        var targetFrame: CGRect

        if !isCollapsed {

            isCollapsed = true

            let newY = self.view.bounds.height - self.tabBarController!.tabBar.bounds.height - self.pointBorderImageView.bounds.height - 32
            let oldFrame = self.collapsableDetailsView.frame
            targetFrame = CGRect(x: oldFrame.minX, y: newY, width: oldFrame.size.width, height: oldFrame.size.height)

        } else {

            let bounds = self.collapsableDetailsView.bounds
            let newY = UIApplication.shared.statusBarFrame.height + self.navigationController!.navigationBar.bounds.height + ((self.view.bounds.height) / 4) + 1
            targetFrame = CGRect(x: bounds.minX, y: newY, width: bounds.width, height: bounds.height)

            isCollapsed = false
        }

        collapsableDetailsAnimator = UIViewPropertyAnimator(duration: 0.6, curve: .easeIn,
                                                            animations: {
                                                                self.collapsableDetailsView.frame = targetFrame
        })

    }

    private func panningChangedWithTranslation(translation: CGPoint)
    {
        if (self.playerViewAnimator.isRunning)
        {
        return;
        }

        CGFloat translatedY = self.view.center.y + translation.y;

        CGFloat progress;
        switch (self.playerState) {
        case PlayerStateThumbnail:
        progress = 1 - (translatedY / self.view.center.y);
        break;
        case PlayerStateFullscreen:
        progress = (translatedY / self.view.center.y) - 1;
        }

        progress = MAX(0.001, MIN(0.999, progress));

        self.playerViewAnimator.fractionComplete = progress;
    }

    private func panningEndedWithTranslation:(translation: CGPoint, velocity: CGPoint)
    {
        self.panGestureRecognizer.enabled = NO;

        CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
        __weak ViewController *weakSelf = self;

        switch (self.playerState) {
        case PlayerStateThumbnail:
            if (translation.y <= -screenHeight / 3 || velocity.y <= -100)
            {
                self.playerViewAnimator.reversed = NO;
                [self.playerViewAnimator addCompletion:^(UIViewAnimatingPosition finalPosition) {
                weakSelf.playerState = PlayerStateFullscreen;
                weakSelf.panGestureRecognizer.enabled = YES;
                }];
                }
                else
                {
                self.playerViewAnimator.reversed = YES;
                [self.playerViewAnimator addCompletion:^(UIViewAnimatingPosition finalPosition) {
                weakSelf.playerState = PlayerStateThumbnail;
                weakSelf.panGestureRecognizer.enabled = YES;
                }];
            }
            break;
        case PlayerStateFullscreen:
            if (translation.y >= screenHeight / 3 || velocity.y >= 100)
            {
                self.playerViewAnimator.reversed = NO;
                [self.playerViewAnimator addCompletion:^(UIViewAnimatingPosition finalPosition) {
                weakSelf.playerState = PlayerStateThumbnail;
                weakSelf.panGestureRecognizer.enabled = YES;
                }];
            }
            else
            {
                self.playerViewAnimator.reversed = YES;
                [self.playerViewAnimator addCompletion:^(UIViewAnimatingPosition finalPosition) {
                weakSelf.playerState = PlayerStateFullscreen;
                weakSelf.panGestureRecognizer.enabled = YES;
                }];
            }
    }

    @objc private func clueButtonHandler() {

        if !objective.hintTaken {
            presentPointLossAlert()
        } else {
            presentClueViewController()
        }

    }

    @objc private func presentPointLossAlert() {

        let alert = UIAlertController(title: "Warning:", message: "The amount of points gained for this objective will be reduced by \(pointDeductionValue)", preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        let continueAction = UIAlertAction(title: "Continue", style: .default, handler: { _ in
            ObjectiveManager.shared.objectivePointMap[self.objective.id] = self.objective.points - self.pointDeductionValue
            //self.objective.hintTaken = true
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

    @objc func enterAnswer() {

        let textFieldViewController = TextFieldViewController(closure: enterAnswerCompletion)
        textFieldViewController.modalTransitionStyle = .crossDissolve
        textFieldViewController.modalPresentationStyle = .overCurrentContext
        present(textFieldViewController, animated: true, completion: nil)
    }

    func enterAnswerCompletion(answer: String) {

        if let answerView = answerView as? ContainerView {
            answerView.textLabel.text = answer
            playHudAnimation()
            ObjectiveManager.shared.completeObjectives.insert(self.objective.id)
        }
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
        ObjectiveManager.shared.completeObjectives.insert(self.objective.id)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {

        dismiss(animated: true, completion: nil)
    }

}
