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

class ViewController: UIViewController {
    
    @IBOutlet weak var menuTableView: UITableView!
    
    private var menuDataSource: MenuTableViewDataSource!
    private var apiService = APIService()
    
    private var menuObservable: Observable<[Menu]>!
    
    let bag = DisposeBag()
    lazy var sectionsSubject = BehaviorSubject<[SectionOfMenu]>(value: sections)
    var sections: [SectionOfMenu] = [SectionOfMenu(header: "메인메뉴", items: [])]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuObservable = apiService.fetchWithRxCocoa(url: EndPoint.main)
            .asObservable()
            
        
        //        fetchMenuCellType()
        //        fetchMenuDataSource()
        fetchMenuRxDataSource()
        bindMenuTableViewRxDataSource()
        
    }
    
    private func fetchMenuCellType() {
        _ = apiService.fetchWithRxCocoa(url: EndPoint.main)
            .observeOn(MainScheduler.instance)
            .bind(to: menuTableView.rx.items(cellIdentifier:  "MenuTableViewCell", cellType: MenuTableViewCell.self)) { index, model, cell in
                cell.title.text = model.title
                cell.menuDescription.text = model.menuDescription
                cell.originalPrice.text = model.originalPrice
                cell.discountedPrice.text = model.discountedPrice
        }.disposed(by: bag)
    }
    
    private func fetchMenuDataSource() {
        menuDataSource = MenuTableViewDataSource()
        _ = apiService.fetchWithRxCocoa(url: EndPoint.main)
            .observeOn(MainScheduler.instance)
            .bind(to: menuTableView.rx.items(dataSource: menuDataSource))
        // TODO : - MenuTableViewDataSource에서 RxTableViewDataSourceType 필수메소드 구현필요
    }
    
    private func fetchMenuRxDataSource() {
        menuObservable.subscribe { nextEvent in
            let menus = nextEvent.element
            menus?.forEach({ (menu) in
                self.sections[0].items.append(menu)
            })
        }.disposed(by: bag)
    }
    
    private func bindMenuTableViewRxDataSource() {
        let dataSource = RxTableViewSectionedReloadDataSource<SectionOfMenu>(
            configureCell: { dataSource, tableView, indexPath, item in
                let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTableViewCell", for: indexPath) as! MenuTableViewCell
                cell.title.text = item.title
                cell.menuDescription.text = item.menuDescription
                cell.originalPrice.text = item.originalPrice
                cell.discountedPrice.text = item.discountedPrice
                return cell
        })
        
        dataSource.titleForHeaderInSection = { dataSource, index in
            return dataSource.sectionModels[index].header
        }
        
        Observable.just(sections)
            .bind(to: menuTableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
    }
}
