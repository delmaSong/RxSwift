//
//  MenuDetailReactor.swift
//  RxSideDish
//
//  Created by Delma Song on 2020/09/19.
//  Copyright © 2020 Delma Song. All rights reserved.
//

import Foundation
import RxSwift
import ReactorKit

final class MenuDetailReactor: Reactor {
    var initialState: State = State(isOrdered: false, menuDetail: nil)
    private var useCase = UseCase()
    
    enum Action {
        case presented(String?)
        case orderButtonDidTapped
    }
    
    enum Mutation {
        case fetchDetail(MenuDetail)
        case order(Bool)
    }
    
    struct State {
        var isOrdered: Bool
        var menuDetail: MenuDetail?
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .presented(let menuID):
            return useCase.fetchMenuDetail(ID: menuID ?? "")
                .map { menuDetail -> Mutation in
                return .fetchDetail(menuDetail!)
                }
        case .orderButtonDidTapped:
            return Observable.just(.order(true))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .fetchDetail(let detailMenu):
            newState.menuDetail = detailMenu
        case .order(let isOrdered):
            newState.isOrdered = isOrdered
        }
        return newState
    }
}
