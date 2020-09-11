//
//  ViewController.swift
//  RxSideDish
//
//  Created by Delma Song on 2020/09/07.
//  Copyright © 2020 Delma Song. All rights reserved.
//

import UIKit
import RxSwift

class ViewController: UIViewController {

    @IBOutlet weak var menuTableView: UITableView!
    private var apiService = APIService()
    let bag = DisposeBag()
        
    override func viewDidLoad() {
        super.viewDidLoad()

        apiService.fetchWithRxCocoa(url: EndPoint.main)
        apiService.list.subscribe { print($0) }
        .disposed(by: bag)
    }
}

