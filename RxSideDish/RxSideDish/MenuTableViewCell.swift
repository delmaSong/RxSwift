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
        badgePlaceholder.isHidden = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        menuImage.image = nil
        title.text = nil
        menuDescription.text = nil
        discountedPrice.text = nil
        originalPrice.text = nil
        badgeStack.subviews.forEach {
            $0.removeFromSuperview()
        }
    }
    
    func configure(with menu: Menu) {
        title.text = menu.title
        menuDescription.text = menu.menuDescription
        discountedPrice.text = menu.discountedPrice
        originalPrice.attributedText = NSAttributedString(string: "\(String(describing: menu.originalPrice ?? ""))",
            attributes: [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue])
        menu.badge?.forEach({ feat in
            configureBadge(feat)
        })
    }
    
    func configure(_ handler: @escaping (UIImageView) -> Void) {
        handler(menuImage)
        configureUI()
    }
    
    private func configureUI() {
        menuImage.layer.cornerRadius = menuImage.frame.width / 2
        menuImage.layer.masksToBounds = true
    }
    
    private func configureBadge(_ text: String) {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.backgroundColor = UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 0.5)
        label.translatesAutoresizingMaskIntoConstraints = false
        badgeStack.addArrangedSubview(label)
    }
}
