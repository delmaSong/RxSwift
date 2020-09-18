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
    }
    
    private func configure() {
        navigationController?.isNavigationBarHidden = true
        menuTableView.rx.itemSelected.subscribe { [weak self] indexPath in
            self?.menuTableView.deselectRow(at: indexPath, animated: true)
        }.disposed(by: disposeBag)
    }
}
