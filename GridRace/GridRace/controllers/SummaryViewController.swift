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
        let cellSpacing = screenWidth * 0.1

        //custom flow layout used to set custome pagination offset
        let layout: UICollectionViewFlowLayout = customFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: (cellSpacing * 2), bottom: 10, right: (cellSpacing * 2) )
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = cellSpacing
        layout.minimumLineSpacing = cellSpacing
        layout.itemSize = CGSize(width: screenWidth * 0.6, height: screenHeight * 0.5)


        let collectionView = UICollectionView(frame: CGRect(x: screenWidth * 0.2, y: screenWidth * 0.4, width: screenWidth * 0.6, height: screenWidth * 0.6),
                                              collectionViewLayout: layout)
        //        collectionView.isPagingEnabled = true
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.clipsToBounds = false

        return collectionView
    }()

    // all places and bonus objectives minus 'last'/ 'password' objective
    var allObjectives: [Objective] {
        var objs = AppResources.ObjectiveData.sharedPlaces.objectives + AppResources.ObjectiveData.sharedBonus.objectives
        objs.remove(at: AppResources.ObjectiveData.sharedPlaces.objectives.count - 1)

        return objs
    }
    var allData = AppResources.ObjectiveData.sharedPlaces.data + AppResources.ObjectiveData.sharedBonus.data

    var placesObjectives: [Objective] {
        return AppResources.ObjectiveData.sharedPlaces.objectives
    }

    var bonusObjectives: [Objective] {
        return AppResources.ObjectiveData.sharedBonus.objectives
    }

    var completedObjectives: Int {

        var result = 0
        for data in allData {
            if data.completed == true {
                result += 1
            }
        }
        return result
    }

    var completedPlacesObjectives: Int {

        var result = 0
        for data in AppResources.ObjectiveData.sharedPlaces.data {
            if data.completed == true {
                result += 1
            }
        }
        return result
    }

    var completedBonusObjectives: Int {

        var result = 0
        for data in AppResources.ObjectiveData.sharedBonus.data {
            if data.completed == true {
                result += 1
            }
        }
        return result
    }

    var userPoints: Int {

        var result = 0
        for objective in allObjectives {
            let dataForObject = allData.first(where: {$0.objectiveID == objective.id})
            if (dataForObject?.completed)! {
                result += dataForObject?.adjustedPoints != nil ? (dataForObject?.adjustedPoints)! : objective.points
            }
        }

        return result
    }

    var totalPoints: Int {

        var result = 0
        for obj in allObjectives{

            result += obj.points
        }
        return result
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = AppColors.backgroundColor

        setUpLayout()

        updateLabels()

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = AppColors.backgroundColor
        collectionView.register(ObjectiveCollectionViewCell.self, forCellWithReuseIdentifier: "objectiveCell")

        pageControl.numberOfPages = objectCount
        pageControl.currentPage = 0
    }

    func updateLabels() {

        mainTextLabel.text = "Main Objectives: "
        mainValueLabel.text = "\(completedPlacesObjectives)/\(placesObjectives .count)"
        bonusTextLabel.text = "Bonus Objectives: "
        bonusValueLabel.text = "\(completedBonusObjectives)/\(bonusObjectives.count)"
        timeTextLabel.text = "Time: "
        timeValueLabel.text = "\(AppResources.timeToDisplay)"
        pointsTextLabel.text = "Points: "
        pointsValueLabel.text = "\(userPoints)/\(totalPoints)"
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

        let totalCount = allObjectives.count
        pageControl.numberOfPages = totalCount
        return totalCount
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let data = allData.first(where: {$0.objectiveID == allObjectives[indexPath.row].id})
        data!.correct = !(data!.correct)

        updateLabels()
        collectionView.reloadData()

    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "objectiveCell", for: indexPath) as! ObjectiveCollectionViewCell

        let objective = allObjectives[indexPath.row]
        let userData = allData.first(where: {$0.objectiveID == objective.id})

        cell.nameLabel.text = objective.name
        cell.descLabel.text = objective.desc

        if objective.objectiveType == .photo {

            cell.responseImageView.isHidden = false
            cell.responseTextView.isHidden = true

            if let path =  userData?.imageResponseURL?.path {

                cell.responseImageView.image = UIImage(contentsOfFile: path)?.resized(withBounds: CGSize(width: 200, height: 200))
            } else {

                cell.responseImageView.image = #imageLiteral(resourceName: "nothing")
                cell.responseImageView.tintColor = AppColors.cellColor
            }
            cell.responseImageView.contentMode = .scaleAspectFit
        }

        if objective.objectiveType == .text {

            cell.responseTextView.isHidden = false
            cell.responseImageView.isHidden = true

            cell.responseTextView.text = userData?.textResponse != nil ? userData?.textResponse : "No Response Given"
        }

        if userData!.completed {

            cell.crossImageView.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            cell.checkMarkImageView.tintColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
        } else{

            cell.crossImageView.tintColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
            cell.checkMarkImageView.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }

        return cell
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        //bryans attempt to make cells increase in size when they are in the middle of screen, didnt work

//        collectionView.visibleCells.forEach { cell in
//
//            let attributes = collectionView.layoutAttributesForItem(at: collectionView.indexPath(for: cell)!)
//            guard let center = attributes?.center.x else { return }
//            let collectionViewCenter = collectionView.frame.size.width / 2
//            let difference = abs(center - collectionViewCenter)
//            let multiplierReduction = difference * 2 / 100.0
//
//            cell.layer.contentsScale = 1.2 - min(multiplierReduction, 2);
//        }

        pageControl.currentPage = Int(self.collectionView.contentOffset.x / self.collectionView.frame.size.width)
    }


    

//    UIView.animate(withDuration: 0.2, animations: {
//    self.collectionView.setContentOffset(CGPoint(x: self.collectionView.contentOffset.x + self.collectionView.frame.width, y: 0), animated: true)
//    self.view.layoutIfNeeded()
//    })

}
