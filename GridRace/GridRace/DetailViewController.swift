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
    var pointsCount: Int

}

class DetailViewController: UIViewController {

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
        self.objective = Objective(name: "office", desc: "take photo at office", hintImage: #imageLiteral(resourceName: "camera"), pointsCount: 10)

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = AppColors.backgroundColor
        navigationController?.navigationBar.prefersLargeTitles = true
        title = objective.name
        edgesForExtendedLayout = []

        mapImageView.image = #imageLiteral(resourceName: "map")
        mapImageView.contentMode = .scaleAspectFit
        descLabel.text = objective.desc
        pointLabel.text = "\(objective.pointsCount)"
        userPhotoImageView.image = #imageLiteral(resourceName: "camera")
        userPhotoImageView.contentMode = .scaleAspectFit
        getClueButton.setTitle("Get Clue", for: .normal)
        lowerNavBarView.backgroundColor = AppColors.greenHighlightColor
        timerLabel.text = "1:00"
        timerLabel.textColor = AppColors.textSecondaryColor
        timerLabel.textAlignment = .center
        totalPointsLabel.text = "0"
        totalPointsLabel.textColor = AppColors.textSecondaryColor
        totalPointsLabel.textAlignment = .center


        setUpLayout()

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
            userPhotoImageView.widthAnchor.constraint(equalToConstant: 150),

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
  

}
