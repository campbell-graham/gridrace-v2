//
//  summaryViewController.swift
//  GridRace
//
//  Created by Christian on 3/7/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

class SummaryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    let mainTextLabel = UILabel()
    let mainValueLabel = UILabel()
    let bonusTextLabel = UILabel()
    let bonusValueLabel = UILabel()
    let timeTextLabel = UILabel()
    let timeValueLabel = UILabel()
    let pointsTextLabel = UILabel()
    let pointsValueLabel = UILabel()

    let pageControl = UIPageControl()
    let objectCount = 10
    var isCorrect = true

    lazy var collectionView: UICollectionView = {

        let screenWidth = view.frame.size.width
        let screenHeight = view.frame.size.height
        let cellSpacing = screenWidth * 0.3

        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: (cellSpacing / 2), bottom: 10, right: (cellSpacing / 2))
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = cellSpacing;
        layout.minimumLineSpacing = cellSpacing
        layout.itemSize = CGSize(width: screenWidth * 0.7, height: screenHeight * 0.5)

        let collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = AppColors.backgroundColor

        setUpLayout()

        mainTextLabel.text = "Main Objectives: "
        mainValueLabel.text = "2/20"
        bonusTextLabel.text = "Bonus Objectives: "
        bonusValueLabel.text = "2/20"
        timeTextLabel.text = "Time: "
        timeValueLabel.text = "1 hr 5 mins"
        pointsTextLabel.text = "Points: "
        pointsValueLabel.text = "40/150"

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = AppColors.backgroundColor
        collectionView.register(ObjectiveCollectionViewCell.self, forCellWithReuseIdentifier: "objectiveCell")

        pageControl.numberOfPages = objectCount
        pageControl.currentPage = 0
    }

    func setUpLayout() {

        for view in [mainTextLabel, mainValueLabel, bonusTextLabel, bonusValueLabel, timeTextLabel,
                     timeValueLabel, pointsTextLabel, pointsValueLabel] {

            view.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(view)
            view.textColor = AppColors.textPrimaryColor
        }

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)

        pageControl.translatesAutoresizingMaskIntoConstraints = false
        collectionView.addSubview(pageControl)

        let views: [String: Any] = [
            "mainTextLabel" : mainTextLabel,
            "mainValueLabel" : mainValueLabel,
            "bonusTextLabel" : bonusTextLabel,
            "bonusValueLabel" : bonusValueLabel,
            "timeTextLabel" : timeTextLabel,
            "timeValueLabel" : timeValueLabel,
            "pointsTextLabel" : pointsTextLabel,
            "pointsValueLabel" : pointsValueLabel
        ]

        var constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-100-[mainTextLabel]-[bonusTextLabel]-[timeTextLabel]-[pointsTextLabel]", options: [.alignAllLeading], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:[mainValueLabel]-[bonusValueLabel]-[timeValueLabel]-[pointsValueLabel]", options: [.alignAllLeading], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-50-[mainTextLabel]-32-[mainValueLabel]", options: [.alignAllTop, .alignAllBottom], metrics: nil, views: views)


        constraints += [
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: (view.frame.height * 0.6) ),

            pageControl.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageControl.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8),
            pageControl.heightAnchor.constraint(equalToConstant: 8 )
        ]

        NSLayoutConstraint.activate(constraints)
    }

    //MARK:- collectionView delegate methods

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return objectCount
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // do someting

        isCorrect = !isCorrect
        collectionView.reloadItems(at: [indexPath])

    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "objectiveCell", for: indexPath) as! ObjectiveCollectionViewCell

        cell.nameLabel.text = "Objective Name"

        var desc = "Desc Desc Desc Desc Desc Desc Desc Desc Desc Desc Desc Desc Desc Desc Desc Desc Desc Desc "
        desc += "Desc Desc Desc Desc Desc Desc Desc Desc Desc Desc Desc Desc Desc Desc Desc Desc Desc Desc "
        cell.descLabel.text = desc

        cell.responseImageView.image = #imageLiteral(resourceName: "testImage").resized(withBounds:  CGSize(width: 200, height: 200))

        if isCorrect {

            cell.crossImageView.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            cell.checkMarkImageView.tintColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
        } else{

            cell.crossImageView.tintColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
            cell.checkMarkImageView.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }

        return cell
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        pageControl.currentPage = Int(self.collectionView.contentOffset.x / self.collectionView.frame.size.width)
    }

}
