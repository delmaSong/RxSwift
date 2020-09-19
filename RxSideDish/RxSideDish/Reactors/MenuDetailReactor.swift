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

    enum Action {
        case presented
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
        case .presented:
            //TODO: - 서버로 요청
            break
        case .orderButtonDidTapped:
            //TODO: - alert 띄워주기
            break
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
