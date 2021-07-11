//
//  Exception.swift
//  15MayPractice
//
//  Created by Sunil Prasai on 5/17/21.
//

import Foundation

class Exception: Error {
    final let message: String
    
    init(message: String) {
        self.message = message
    }
}
