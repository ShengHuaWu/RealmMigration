//
//  Person.swift
//  RealmMigration
//
//  Created by ShengHua Wu on 19/03/2017.
//  Copyright © 2017 ShengHuaWu. All rights reserved.
//

import Foundation
import RealmSwift

final class Person: Object {
    dynamic var firstName = ""
    dynamic var lastName = ""
    dynamic var age = 0
    dynamic var email = ""
}
