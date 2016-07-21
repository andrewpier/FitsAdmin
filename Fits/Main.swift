//
//  Main.swift
//  Fits
//
//  Created by Andrew Pier on 4/11/16.
//  Copyright © 2016 Urban Fish Studio. All rights reserved.
//

import Foundation

class Main {
    var name:String
    var voteOnce: Bool = false
    init(name:String) {
        self.name = name
    }
}
var mainInstance = Main(name:"My Global Class")
