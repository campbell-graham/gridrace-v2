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

    let objectCount = 10
    var isCorrect = true

    lazy var collectionView: UICollectionView = {
        
        let collectionView = UICollectionView(frame: view.frame, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.isPagingEnabled = true
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.indicatorStyle = .white

        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Summary"
        
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

        
        var constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[mainTextLabel]-[bonusTextLabel]-[timeTextLabel]-[pointsTextLabel]", options: [.alignAllLeading], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:[mainValueLabel]-[bonusValueLabel]-[timeValueLabel]-[pointsValueLabel]", options: [.alignAllLeading], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-50-[mainTextLabel]-32-[mainValueLabel]", options: [.alignAllTop, .alignAllBottom], metrics: nil, views: views)


        constraints += [
            
            mainTextLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
           
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            collectionView.topAnchor.constraint(equalTo: pointsTextLabel.bottomAnchor, constant: 4),

        ]

        NSLayoutConstraint.activate(constraints)
    }
    
    override func viewDidLayoutSubviews() {
        let collectionViewWidth = collectionView.frame.width
        let cellSpacing = collectionViewWidth * 0.2
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: (cellSpacing / 2), bottom: 0, right: (cellSpacing / 2))
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = cellSpacing;
        layout.minimumLineSpacing = cellSpacing
        layout.itemSize = CGSize(width: collectionViewWidth * 0.8, height: collectionView.frame.height * 0.9)
        
        collectionView.collectionViewLayout = layout
    }
    
    override func viewDidAppear(_ animated: Bool) {
        var _ = Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: {_ in
            self.collectionView.flashScrollIndicators()
       })
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

}
