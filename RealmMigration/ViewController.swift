//
//  ViewController.swift
//  RealmMigration
//
//  Created by ShengHua Wu on 19/03/2017.
//  Copyright © 2017 ShengHuaWu. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        seedData()
    }
}

// MARK: - Data
extension ViewController {
    func seedData() {
        do {
            let people: Results<Person> = try DataStore.findAll()
            debugPrint(people)
            
            if people.count <= 0 {
                try DataStore.seedPeople()
            }
        } catch let error {
            debugPrint(error.localizedDescription)
        }
    }
}

