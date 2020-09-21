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
    private var type: EndPoints?
    
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
        reactor.action.onNext(.presented(type, menuID))
        reactor.state.map { $0.menuDetail }
            .observeOn(MainScheduler.instance)
            .bind { [weak self] menu in
                self?.descriptionLabel.text = menu?.menuDescription
                self?.deliveryFeeLabel.text = menu?.deliveryFee
                self?.pointLabel.text = menu?.point
                self?.deliveryInfoLabel.text = menu?.deliveryInfo
                if menu?.prices.count == 1 {
                    self?.discountedPriceLabel.text = menu?.prices[0]
                } else {
                    self?.originalPriceLabel.text = menu?.prices[0]
                    self?.discountedPriceLabel.text = menu?.prices[1]
                }
                
            }.disposed(by: disposeBag)
    }
    
    func set(type: Int, menuID: String) {
        self.menuID = menuID
        switch type {
        case 0:
            self.type = .main
        case 1:
            self.type = .soup
        case 2:
            self.type = .side
        default:
            break
        }
    }
}
