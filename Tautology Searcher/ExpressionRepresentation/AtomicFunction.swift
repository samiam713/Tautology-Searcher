//
//  AtomicFunction.swift
//  Tautology Searcher
//
//  Created by Samuel Donovan on 9/20/20.
//

import Foundation

enum AtomicFunction: String, Hashable, RawRepresentable {
    // LOGIC
    case or
    case and
    case equals
    case not
    
    // ARITHMETIC
    // case plus
    // case minus
    // case multiply
    // case negate
    // case greaterThan
    // case lessThan
    
    // CONTROL FLOW
    // case if
    // case for
    // case repeat
    
    // CALCULUS
    // case
}

extension AtomicFunction {
    func toString() -> String {rawValue}
    
    func numArgs() -> Int {
        // you were thinking about implementing this as an array of values where numArgMap[self.rawValue] == self.numArgs()
        switch self {
        case .or:
            return 2
        case .equals:
            return 2
        case .and:
            return 2
        case .not:
            return 1
        }
    }
    
    func evaluate(args: [Bool]) -> Bool? {
        guard args.count == numArgs() else {return nil}
        
        switch self {
        case .and:
            let lhs = args[0]
            let rhs = args[1]
            return lhs&&rhs
        case .or:
            let lhs = args[0]
            let rhs = args[1]
            return lhs||rhs
        case .equals:
            let lhs = args[0]
            let rhs = args[1]
            return lhs==rhs
        case .not:
            let unary = args[0]
            return !unary
        }
    }
}
