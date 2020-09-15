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
    
    let bag = DisposeBag()
    private var apiService = APIService()
    private var allMenuSubject = BehaviorRelay<[SectionOfMenu]>(value: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchMenuRxDataSource()
        bindMenuTableViewRxDataSource()
    }
    
    private func fetchMenuRxDataSource() {
        EndPoints.allCases.map { ($0, EndPoints.BaseURL + $0.rawValue) }
            .forEach { type, url in
                _ = apiService.fetchWithRxCocoa(url: url).subscribe { [weak self] event in
                    guard let menu = event.element, var sections = self?.allMenuSubject.value else { return }
                    if let index = sections.firstIndex(where: { $0.sectionType == type}) {
                        sections[index] = SectionOfMenu(sectionType: type, items: menu)
                    } else {
                        sections.append(SectionOfMenu(sectionType: type, items: menu))
                    }
                    self?.allMenuSubject.accept(sections)
                }
        }
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
            return dataSource.sectionModels[index].sectionType.description
        }
        
        allMenuSubject.asObservable()
            .bind(to: menuTableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
    }
}
