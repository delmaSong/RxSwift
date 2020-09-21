//
//  MenuDetailViewController.swift
//  RxSideDish
//
//  Created by Delma Song on 2020/09/18.
//  Copyright © 2020 Delma Song. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import Kingfisher

final class MenuDetailViewController: UIViewController, ReactorKit.StoryboardView {
    typealias Reactor = MenuDetailReactor
    var disposeBag: DisposeBag = DisposeBag()
    
    @IBOutlet weak var thumbnailScrollView: UIScrollView!
    @IBOutlet weak var thumbnailStackView: UIStackView!
    @IBOutlet weak var thumbnailPlaceholder: UIImageView!
    @IBOutlet weak var detailStackView: UIStackView!
    @IBOutlet weak var pointLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var deliveryFeeLabel: UILabel!
    @IBOutlet weak var deliveryInfoLabel: UILabel!
    @IBOutlet weak var originalPriceLabel: UILabel!
    @IBOutlet weak var discountedPriceLabel: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    
    private var menuID: String?
    private var type: EndPoints?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reactor = MenuDetailReactor()
        configureUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    var totlaPages: Int = 0
    
    func bind(reactor: MenuDetailReactor) {
        reactor.action.onNext(.presented(type, menuID))
        reactor.state.map { $0.menuDetail }
            .observeOn(MainScheduler.instance)
            .bind(onNext: { self.configure($0) })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.menuInfo }
            .observeOn(MainScheduler.instance)
            .bind(onNext: { self.configure($0) })
            .disposed(by: disposeBag)

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
    
    private func add(url: String, at stackView: UIStackView) {
        let placeholderImageView = UIImageView()
        placeholderImageView.translatesAutoresizingMaskIntoConstraints = false
        placeholderImageView.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        stackView.addArrangedSubview(placeholderImageView)
        placeholderImageView.kf.setImage(with: URL(string: url)!)
    }
}

//MARK: - Configurations

extension MenuDetailViewController {
    
    private func configure(_ menu: Menu?) {
        titleLabel.text = menu?.title
    }
    
    private func configure(_ menuDetail: MenuDetail?) {
        descriptionLabel.text = menuDetail?.menuDescription
        deliveryFeeLabel.text = menuDetail?.deliveryFee
        pointLabel.text = menuDetail?.point
        deliveryInfoLabel.text = menuDetail?.deliveryInfo
        if menuDetail?.prices.count == 1 {
            discountedPriceLabel.text = menuDetail?.prices[0]
        } else {
            originalPriceLabel.text = menuDetail?.prices[0]
            discountedPriceLabel.text = menuDetail?.prices[1]
        }
        menuDetail?.thumbImages.forEach({
            add(url: $0, at: (thumbnailStackView)!)
        })
        if let count = menuDetail?.thumbImages.count {
            configurePageControl(count)
        }
    }
    
    private func configurePageControl(_ pageCount: Int) {
        pageControl.numberOfPages = pageCount
        pageControl.currentPage = 0
        thumbnailScrollView.rx.contentOffset.map { point -> Int in
            return Int(point.x / self.thumbnailScrollView.frame.maxX)
        }.subscribe {
            self.pageControl.currentPage = $0
        }.disposed(by: disposeBag)
    }
    
    private func configureUI() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        thumbnailPlaceholder.removeFromSuperview()
    }
}
