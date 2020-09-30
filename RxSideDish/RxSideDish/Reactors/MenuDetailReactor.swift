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
    var initialState: State = State(isOrdered: false, menuDetail: nil, menuInfo: nil)
    private let useCase = UseCaseProvider.getUseCase()
    private var type: EndPoints?
    private var menuID: String
    
    init(type: Int, menuID: String) {
        self.menuID = menuID
        switch type {
        case 0: self.type = .main
        case 1: self.type = .soup
        case 2: self.type = .side
        default: break
        }
    }
    
    enum Action {
        case presented
        case orderButtonDidTapped
    }
    
    enum Mutation {
        case fetchDetail((MenuDetail?, Menu?))
        case order(Bool)
    }
    
    struct State {
        var isOrdered: Bool
        var menuDetail: MenuDetail?
        var menuInfo: Menu?
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .presented:
            let menuDetailObservable = useCase.fetchMenuDetail(ID: menuID)
            let menuInfoObservable = useCase.fetchMenu(type: type ?? EndPoints.main, ID: menuID)
            return Observable.combineLatest(menuDetailObservable, menuInfoObservable)
                .map { (menuDetail, menuInfo) -> Mutation in
                    return .fetchDetail((menuDetail, menuInfo))
                }
        case .orderButtonDidTapped:
            return Observable.just(.order(true))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .fetchDetail((detailMenu, menuInfo)):
            newState.menuDetail = detailMenu
            newState.menuInfo = menuInfo
        case .order(let isOrdered):
            newState.isOrdered = isOrdered
        }
        return newState
    }
}
