//
//  Tautologies.swift
//  Tautology Searcher
//
//  Created by Samuel Donovan on 9/21/20.
//

import Foundation

let tautologiesList = compressedData.map {CompositeFunction(args: $0.getArgRange(), expression: $0)}

func equals(_ lhs: Expression, _ rhs: Expression) -> Expression {.compound(id: .equals, args: [lhs,rhs])}
func not(_ unary: Expression) -> Expression {.compound(id: .not, args: [unary])}
func or(_ lhs: Expression, _ rhs: Expression) -> Expression {.compound(id: .or, args: [lhs,rhs])}
func and(_ lhs: Expression, _ rhs: Expression) -> Expression {.compound(id: .and, args: [lhs,rhs])}

let p = Expression.wildcard(id: 0)
let q = Expression.wildcard(id: 1)
let r = Expression.wildcard(id: 2)

let t = Expression.bool(true)
let f = Expression.bool(false)

let compressedData: [Expression] = [
    or(not(p),p), // 1
    not(and(p,not(p))), // 2
    equals(p,or(p,p)), // 4a
    equals(p, and(q, q)), // 4b
    equals(not(not(p)),p), // 5
    equals(or(p,q),or(q,p)), // 6a
    equals(and(p,q),and(q,p)), // 6b
    equals(equals(p, q), equals(q, p)), // 6c
    equals(or(p, or(q, r)), or(or(p, q), r)), // 7a
    equals(and(p, and(q, r)), and(and(p, q), r)), // 7b
    equals(and(p, or(q, r)), or(and(p, q), and(p, r))), // 8a
    equals(or(p, and(q, r)), and(or(p, q), or(p, r))), // 8b
    equals(or(p, f), p), // 9a
    not(and(p, f)), // 9b
    and(t,t),
    or(p,t), // 9c
    not(or(f, f)),
    equals(and(p, t), p), // 9d
    equals(not(and(p, q)), or(not(p), not(q))), // 10a
    equals(not(or(p, q)), and(not(p), not(q))), // 10b
    equals(t,t),
    equals(f,f),
    not(equals(t,f)),
    equals(equals(p, q), or(and(p, q), and(not(p), not(q)))), //11b
    equals(equals(p, q), equals(not(p),not(q))), //11c
]
