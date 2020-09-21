//
//  MenuListReactor.swift
//  RxSideDish
//
//  Created by Delma Song on 2020/09/16.
//  Copyright © 2020 Delma Song. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import ReactorKit
import RxDataSources
import Kingfisher

final class MenuListReactor: Reactor {
    var initialState: State = State(completedDataFetching: false, sectionOfMenu: [], tappedCellID: nil, isCellTapped: false)
    private var useCase = UseCase()
    
    enum Action {
        case presented
        case cellDidTapped(String)
    }
    
    enum Mutation {
        case fetchMenu([SectionOfMenu])
        case presentMenuDetail(String)
    }
    
    struct State {
        var completedDataFetching: Bool
        var sectionOfMenu: [SectionOfMenu]
        var tappedCellID: String?
        var isCellTapped: Bool
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .presented:
            let createObs: ((EndPoints) -> Observable<SectionOfMenu>) = { type -> Observable<SectionOfMenu> in
                return self.useCase.fetchMenuList(type: type)
                    .map({ menus -> SectionOfMenu in
                        return SectionOfMenu(sectionType: type, items: menus)
                    })
            }
            
            return Observable.combineLatest(createObs(.main), createObs(.soup), createObs(.side)) { main, soup, side -> [SectionOfMenu] in
                return [main, soup, side]
            }.map { menus -> Mutation in
                return .fetchMenu(menus)
            }
        case .cellDidTapped(let hash):
            return Observable.just(Mutation.presentMenuDetail(hash))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .fetchMenu(let sectionOfMenu):
            newState.completedDataFetching = true
            newState.sectionOfMenu = sectionOfMenu
        case .presentMenuDetail(let hash):
            newState.tappedCellID = hash
            newState.isCellTapped = true
        }
        return newState
    }
    
    func bindMenuTableViewRxDataSource() -> RxTableViewSectionedReloadDataSource<SectionOfMenu> {
        let dataSource = RxTableViewSectionedReloadDataSource<SectionOfMenu>(
            configureCell: { dataSource, tableView, indexPath, item in
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MenuTableViewCell.self), for: indexPath) as! MenuTableViewCell
                cell.configure(with: item)
                cell.configure {
                    $0.kf.setImage(with: URL(string: item.image))
                }
                return cell
            })
        
        dataSource.titleForHeaderInSection = { dataSource, index in
            return dataSource.sectionModels[index].sectionType.description
        }
        
        return dataSource
    }
}
