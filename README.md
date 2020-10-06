# Tautology-Searcher

This is a macOS app that uses brute force (and some minor optimizations to avoid doing some work multiples times) to find equivalent forms of logical expressions.
For example, searching "or($0,not($0))" would yield expressions like "true" and "or(not($0),$0)". 

The name is a little misleading since it can search for expressions equivalent to any logical expression, not just tautologies.

The part I am proud of is that the program works by "learning from" a list of tautologies I feed it in string form at app launch.
The transformations are not hard coded!

From "TautologiesList.swift"

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
