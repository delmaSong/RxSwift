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

final class MenuListReactor: Reactor {
    var initialState: State = State(completedDataFetching: false, sectionOfMenu: [])
    private var apiService = APIService()
    
    enum Action {
        case presented
    }
    
    enum Mutation {
        case fetchMenu([SectionOfMenu])
    }
    
    struct State {
        var completedDataFetching: Bool
        var sectionOfMenu: [SectionOfMenu]
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .presented:
            let createObs: ((EndPoints) -> Observable<SectionOfMenu>) = { endPoint -> Observable<SectionOfMenu> in
                let url = EndPoints.BaseURL + endPoint.rawValue
                return self.apiService.fetchWithRxCocoa(url: url)
                    .map({ menus -> SectionOfMenu in
                        return SectionOfMenu(sectionType: endPoint, items: menus)
                    })
            }
            
            return Observable.combineLatest(createObs(.main), createObs(.soup), createObs(.side)) { main, soup, side -> [SectionOfMenu] in
                return [main, soup, side]
            }.map { menus -> Mutation in
                return .fetchMenu(menus)
            }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .fetchMenu(let sectionOfMenu):
            //            var willMutate = newState.sectionOfMenu
            
            newState.completedDataFetching = true
            newState.sectionOfMenu = sectionOfMenu
        }
        return newState
    }
    
    func bindMenuTableViewRxDataSource() -> RxTableViewSectionedReloadDataSource<SectionOfMenu> {
        let dataSource = RxTableViewSectionedReloadDataSource<SectionOfMenu>(
            configureCell: { dataSource, tableView, indexPath, item in
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MenuTableViewCell.self), for: indexPath) as! MenuTableViewCell
                cell.configure(with: item)
                return cell
            })
        
        dataSource.titleForHeaderInSection = { dataSource, index in
            return dataSource.sectionModels[index].sectionType.description
        }
        
        return dataSource
    }
}
