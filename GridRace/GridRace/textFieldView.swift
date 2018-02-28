//
//  textFieldView.swift
//  GridRace
//
//  Created by Christian on 2/28/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

class textFieldView: UIView {

    let textField = UITextField()

    override init(frame: CGRect) {
        super.init(frame: frame)

        textField.textAlignment = .center
        textField.backgroundColor = AppColors.cellColor
        textField.textColor = AppColors.textPrimaryColor
        textField.attributedPlaceholder = NSAttributedString(string: "enter the answer", attributes: [NSAttributedStringKey.foregroundColor: AppColors.greenHighlightColor ])
        textField.font = UIFont.boldSystemFont(ofSize: 16)

        textField.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(textField)

        NSLayoutConstraint.activate([
            textField.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            textField.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            textField.heightAnchor.constraint(equalToConstant: 44)
        ])

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
