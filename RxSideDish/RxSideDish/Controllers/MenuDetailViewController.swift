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
    
    private var menuID: String?
    private var type: EndPoints?
    private let mainInstance = MainScheduler.instance
    
    @IBOutlet weak var thumbnailScrollView: UIScrollView!
    @IBOutlet weak var thumbnailStackView: UIStackView!
    @IBOutlet weak var thumbnailPlaceholder: UIImageView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var detailStackView: UIStackView!
    @IBOutlet weak var detailPlaceholder: UIImageView!
    
    @IBOutlet weak var pointLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var deliveryFeeLabel: UILabel!
    @IBOutlet weak var deliveryInfoLabel: UILabel!
    @IBOutlet weak var originalPriceLabel: UILabel!
    @IBOutlet weak var discountedPriceLabel: UILabel!
    @IBOutlet weak var orderButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reactor = MenuDetailReactor()
        configureUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func bind(reactor: MenuDetailReactor) {
        reactor.action.onNext(.presented(type, menuID))
        
        orderButton.rx.tap.bind {
            reactor.action.onNext(.orderButtonDidTapped)
        }.disposed(by: disposeBag)
        
        reactor.state.map { $0.menuDetail }
            .observeOn(mainInstance)
            .bind(onNext: { [weak self] menuDetail in
                self?.configure(menuDetail)
            }).disposed(by: disposeBag)
        
        reactor.state.map { $0.menuInfo }
            .observeOn(mainInstance)
            .bind(onNext: { [weak self] menuInfo in
                self?.configure(menuInfo)
            }).disposed(by: disposeBag)
        
        reactor.state.map { $0.menuDetail?.thumbImages.count ?? 0 }
            .observeOn(mainInstance)
            .bind { [weak self] count in
                self?.pageControl.numberOfPages = count
            }.disposed(by: disposeBag)
        
        reactor.state.filter { $0.isOrdered }
            .bind { [unowned self] _ in
                self.presentOrderAlert()
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
    
    private func add(url: String, of stackView: UIStackView, contentMode: UIView.ContentMode, isThumbnail: Bool) {
        retrieveImage(at: url) {
            let placeholderImageView = UIImageView()
            placeholderImageView.image = $0
            placeholderImageView.contentMode = contentMode
            placeholderImageView.translatesAutoresizingMaskIntoConstraints = false
            placeholderImageView.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
            !isThumbnail ? placeholderImageView.heightAnchor.constraint(equalTo: placeholderImageView.widthAnchor, multiplier: $0.size.height / $0.size.width).isActive = true : nil
            stackView.addArrangedSubview(placeholderImageView)
        }
    }

    private func retrieveImage(at url: String, handler: @escaping (UIImage) -> Void) {
        KingfisherManager.shared.retrieveImage(with: URL(string: url)!) { result in
            switch result {
            case .success(let retrieve):
                handler(retrieve.image)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func presentOrderAlert() {
        let alertController = UIAlertController(title: "주문", message: "주문하시겠습니까?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "예", style: .default) { _ in }
        let cancelAction = UIAlertAction(title: "아니오", style: .cancel) { _ in }
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
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
            add(url: $0, of: thumbnailStackView!, contentMode: .scaleAspectFill, isThumbnail: true)
        })
        
        menuDetail?.detailImages.forEach({
            add(url: $0, of: detailStackView!, contentMode: .scaleAspectFit, isThumbnail: false)
        })
    }
    
    private func configurePageControl() {
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
        detailPlaceholder.removeFromSuperview()
        configurePageControl()
        orderButton.layer.cornerRadius = 16
        orderButton.layer.masksToBounds = true
    }
}
