//
//  ExpressionFromString.swift
//  Tautology Searcher
//
//  Created by Samuel Donovan on 9/21/20.
//

import Foundation

extension Array {
    func attemptMap<T>(unsafe: (Element) -> T?) -> [T]? {
        var newArray = [T]()
        newArray.reserveCapacity(self.count)
        for index in self.indices {
            guard let newElement = unsafe(self[index]) else {return nil}
            newArray.append(newElement)
        }
        return newArray
    }
}

fileprivate protocol ExpressionNode {
    func toExpression() -> Expression?
}

fileprivate class FunctionNode: ExpressionNode {
    
    let data: String
    let children: [ExpressionNode]
    
    init(data: String, children: [ExpressionNode]) {
        self.data = data
        self.children = children
    }
    
    func toExpression() -> Expression? {
        guard let function = AtomicFunction(rawValue: data), let children = children.attemptMap(unsafe: {$0.toExpression()}) else {return nil}
        return .compound(id: function, args: children)
    }
}

fileprivate class RootNode: ExpressionNode {
    
    let data: String
    
    init(data: String) {
        self.data = data
    }
    
    func toExpression() -> Expression? {
        if let bool = Bool(data) {
            return .bool(bool)
        }
        
        if let first = data.first, first == "$", let int = Int(data.dropFirst()) {
            return .wildcard(id: int)
        }
        
        return nil
    }
}

fileprivate func generateExpressionNode(fromString: String) -> ExpressionNode? {
    
    if !fromString.contains("(") {return RootNode(data: fromString)}
    
    var parenthesisCounter = 0
    var idString = ""
    
    var currentSubExpressionString = ""
    var subExpressionCollection = [String]()
    
    for character in fromString {
        switch character {
        case "(":
            parenthesisCounter+=1
            if parenthesisCounter > 1 {
                currentSubExpressionString.append("(")
            }
        case ")":
            parenthesisCounter-=1
            if parenthesisCounter == 0 {
                subExpressionCollection.append(currentSubExpressionString)
                guard let children = subExpressionCollection.attemptMap(unsafe: {generateExpressionNode(fromString: $0)}) else {return nil}
                return FunctionNode(data: idString, children: children)
            } else {
                currentSubExpressionString.append(")")
            }
        case ",":
            if parenthesisCounter == 1 {
                subExpressionCollection.append(currentSubExpressionString)
                currentSubExpressionString = ""
            } else {
                currentSubExpressionString.append(",")
            }
        default:
            if parenthesisCounter == 0 {
                idString.append(character)
            } else {
                currentSubExpressionString.append(character)
            }
        }
    }
    return nil
}

extension Expression {
    
    init?(fromString: String) {
        guard let expression = generateExpressionNode(fromString: fromString)?.toExpression() else  {return nil}
        self = expression
    }
}
