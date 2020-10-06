//
//  Expression.swift
//  Tautology Searcher
//
//  Created by Samuel Donovan on 9/20/20.
//

import Foundation

indirect enum Expression: Hashable {
    case compound(id: AtomicFunction, args: [Expression]) // in Swift: "id(arg0,...,argN)
    case wildcard(id: Int) // in Swift: "$id"
    case bool(Bool)
}

extension Expression {
    func asBool() -> Bool? {
        switch self {
        case .bool(let bool):
            return bool
        default:
            return nil
        }
    }
    
    func toString() -> String {
        switch self {
        case .compound(id: let id, args: let args):
            var builder = id.toString()
            builder += "("
            for arg in args.dropLast() {
                builder += arg.toString()
                builder += ","
            }
            if let last = args.last {
                builder += last.toString()
            }
            builder += ")"
            return builder
        case .wildcard(id: let id):
            return "$"+id.description
        case .bool(let bool):
            return bool.description
        }
    }
    
    func evaluateIfEvaluatable() -> Expression? {
        switch self {
        case .compound(id: let id, args: let args):
            var objectArgs = [Bool]()
            // if !id.isEvaluatable() {return nil}
            for arg in args {
                if let object = arg.asBool() {
                    objectArgs.append(object)
                } else {
                    break
                }
            }
            if objectArgs.count == args.count {
                if let result = id.evaluate(args: objectArgs) {
                    return .bool(result)
                } else {
                    return nil
                }
            } else {
                return nil
            }
        default:
            return nil
        }
    }
    
    // use "this" as a template to match onto "onto"
    // if you can match then into will be nil upon return, if you can't match then into's indices will correspond to what was at "this"'s wildcards in "onto"
    // I just read that to myself and it made no sense, here's an equally bad comment:
    // after executing .or(.wildcard(0),.wildcard(1)).matchWildcards(onto: .or(true,.wildcard(0)), into: [nil]), into == [true,.wildcard(0)]
    
    func matchWildcards(onto: Expression, into: inout [Expression?]?) {
        if into == nil {return}
        switch self {
        case .compound(id: let templateID, args: let templateArgs):
            switch onto {
            case .compound(id: let ontoID, args: let ontoArgs):
                if templateID == ontoID {
                    for i in 0..<templateID.numArgs() {
                        templateArgs[i].matchWildcards(onto: ontoArgs[i], into: &into)
                    }
                } else {
                    into = nil
                }
            default:
                into = nil
            }
            
        case .wildcard(id: let id):
            if let currentMatch = into![id] {
                if currentMatch == onto {
                    return
                } else {
                    into = nil
                }
            } else {
                into![id] = onto
            }
        case .bool(let bool):
            switch onto {
            case .bool(let ontoBool):
                if bool == ontoBool {
                    return
                } else {
                    into = nil
                }
            default:
                into = nil
            }
        }
    }
    
    // if this ExpressionTree contains .wildcard(id), then into[id] == true after return
    func checkForContainment(into: inout [Bool]) {
        switch self {
        case .compound(id: _, args: let args):
            for arg in args {
                arg.checkForContainment(into: &into)
            }
        case .wildcard(id: let id):
            into[id] = true
        case .bool:
            return
        }
    }
    
    func replaceWildcards(using: [Expression]) -> Expression {
        switch self {
        case .compound(id: let id, args: let args):
            return .compound(id: id, args: args.map({$0.replaceWildcards(using: using)}))
        case .wildcard(id: let id):
            return using[id]
        case .bool:
            return self
        }
    }
    
    
    static var cache = [Self:Int]()
    func getNodeCount() -> Int {
        switch self {
        case .compound(id: _, args: let args):
            if let cached = Self.cache[self] {return cached}
            let ans = args.reduce(1, {(result, arg) in
                
                return result + arg.getNodeCount()
            })
            Self.cache[self] = ans
            return ans
        case .wildcard, .bool:
            return 1
        }
    }
    
    private func getArgCount() -> Int {
        switch self {
        case .compound(id: _, args: let expression):
            return expression.reduce(0, {return max($0,$1.getArgCount())})
        case .wildcard(id: let id):
            return id
        case .bool:
            return 0
        }
    }
    
    func getArgRange() -> Int {getArgCount()+1}
}
