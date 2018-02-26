//
//  ObjectiveTableViewCell.swift
//  GridRace
//
//  Created by Campbell Graham on 26/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

class ObjectiveTableViewCell: UITableViewCell {
    
    var titleLabel = UILabel()
    var pointsLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        //cell styling
        backgroundColor = AppColors.cellColor
        let bgView = UIView()
        bgView.backgroundColor = AppColors.greenHighlightColor
        selectedBackgroundView = bgView
        
        //label styling
        titleLabel.textColor = AppColors.textPrimaryColor
        pointsLabel.textColor = AppColors.textPrimaryColor
        
        //add items to cell
        addSubview(titleLabel)
        addSubview(pointsLabel)
        
        //layout constraints
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        pointsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            pointsLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            pointsLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            pointsLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
