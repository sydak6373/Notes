//
//  inputCell.swift
//  Notes
//
//  Created by JoyDev on 14.11.2023.
//

import UIKit
import SnapKit

class InputCell: UITableViewCell {
    var textField: UITextField!
    var identifier: String!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.textField = UITextField(frame: CGRect.zero)
        self.contentView.addSubview(self.textField)

        self.textField.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8))
        }

        self.textField.clearButtonMode = .whileEditing
        self.textField.borderStyle = .roundedRect
        self.textField.font = UIFont.systemFont(ofSize: 14)
        
        self.selectionStyle = .none
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

