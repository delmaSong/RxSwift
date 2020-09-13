//
//  MenuTableViewDataSource.swift
//  RxSideDish
//
//  Created by Delma Song on 2020/09/12.
//  Copyright © 2020 Delma Song. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class MenuTableViewDataSource: NSObject, UITableViewDataSource, RxTableViewDataSourceType {
    typealias Element = [Menu]
    var menuObservable = BehaviorSubject<[Menu]>(value: [])

    func tableView(_ tableView: UITableView, observedEvent: Event<[Menu]>) {
       // TODO : - MenuTableViewDataSource에서 RxTableViewDataSourceType 필수메소드 구현필요
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTableViewCell") as! MenuTableViewCell
        return cell
    }
}
