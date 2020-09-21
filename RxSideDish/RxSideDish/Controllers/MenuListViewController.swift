//
//  ViewController.swift
//  RxSideDish
//
//  Created by Delma Song on 2020/09/07.
//  Copyright © 2020 Delma Song. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import ReactorKit

class MenuListViewController: UIViewController, ReactorKit.StoryboardView {
    typealias Reactor = MenuListReactor
    
    @IBOutlet weak var menuTableView: UITableView!

    private var typeIndex: Int?
    var disposeBag: DisposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    func bind(reactor: MenuListReactor) {
        reactor.action.onNext(.presented)
        
        let dataSource = reactor.bindMenuTableViewRxDataSource()
        reactor.state.map { $0.sectionOfMenu }
            .bind(to: menuTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        reactor.state.filter { $0.isCellTapped }
            .map { $0.tappedCellID }
            .bind { [weak self] menuID in
                    guard let menuDetailViewController = self?.storyboard?.instantiateViewController(withIdentifier: String(describing: MenuDetailViewController.self)) as? MenuDetailViewController else { return }
                self?.navigationController?.pushViewController(menuDetailViewController, animated: true)
                menuDetailViewController.set(type: self?.typeIndex ?? 0, menuID: menuID ?? "")
            }.disposed(by: disposeBag)
    }
    
    private func configure() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        menuTableView.rx.itemSelected.subscribe { [weak self] item in
            let indexPath = item.element.map { $0 }
            self?.typeIndex = indexPath?.item
        }.disposed(by: disposeBag)
        
        menuTableView.rx.modelSelected(Menu.self).subscribe { [weak self] model in
            let item = model.element.map { $0 }
            self?.reactor?.action.onNext(.cellDidTapped(item?.menuID ?? ""))
        }.disposed(by: disposeBag)
    }
}
