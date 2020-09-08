//
//  MenuTableViewCell.swift
//  RxSideDish
//
//  Created by Delma Song on 2020/09/08.
//  Copyright © 2020 Delma Song. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell {

    @IBOutlet weak var menuImage: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var menuDescription: UILabel!
    @IBOutlet weak var originalPrice: UILabel!
    @IBOutlet weak var discountedPrice: UILabel!
    @IBOutlet weak var badgeStack: UIStackView!
    @IBOutlet weak var badgePlaceholder: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private func configure() {
        configureUI()
    }
    
    private func configureUI() {
        addCancelLine(originalPrice)
        menuImage.layer.cornerRadius = menuImage.frame.width / 2
        menuImage.layer.masksToBounds = true
    }
    
    private func addCancelLine(_ label: UILabel) {
        guard let text = label.text else { return }
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(.strikethroughStyle, value: 1, range: NSRange(text)!)
    }
    
    private func configureBadge(_ text: String) {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        badgeStack.addArrangedSubview(label)
    }
}
