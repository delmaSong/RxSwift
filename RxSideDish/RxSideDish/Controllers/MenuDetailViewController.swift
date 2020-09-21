//
//  MenuDetailViewController.swift
//  RxSideDish
//
//  Created by Delma Song on 2020/09/18.
//  Copyright © 2020 Delma Song. All rights reserved.
//

import UIKit
import RxSwift
import ReactorKit

class MenuDetailViewController: UIViewController, ReactorKit.StoryboardView {
    typealias Reactor = MenuDetailReactor
    var disposeBag: DisposeBag = DisposeBag()

    @IBOutlet weak var thumbnailStackView: UIStackView!
    @IBOutlet weak var detailStackView: UIStackView!
    @IBOutlet weak var pointLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var deliveryFeeLabel: UILabel!
    @IBOutlet weak var deliveryInfoLabel: UILabel!
    @IBOutlet weak var originalPriceLabel: UILabel!
    @IBOutlet weak var discountedPriceLabel: UILabel!

    private var menuID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reactor = MenuDetailReactor()
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func bind(reactor: MenuDetailReactor) {
        reactor.action.onNext(.presented(menuID))
    }
    
    func set(menuID: String) {
        self.menuID = menuID
    }
}
