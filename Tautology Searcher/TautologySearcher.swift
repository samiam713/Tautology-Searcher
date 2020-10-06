//
//  TautologySearcher.swift
//  Tautology Searcher
//
//  Created by Samuel Donovan on 9/20/20.
//

import Foundation

class TautologySearcher {
    var equivalenceFinders = [(Expression) -> Expression?]()
    var truthGenerators = [(Expression) -> Expression?]()
    
    var importedTruths = Set<CompositeFunction>()
    
    init<T:Sequence>(tautologies: T) where T.Element == CompositeFunction {
        for tautology in tautologies {
            importTruth(tautology: tautology)
        }
    }
    
    func importTruth(tautology: CompositeFunction) {
        // the idea is that because this is imported expression is true for any possible arguments, you can create functions that generate more true things
        
        let (inserted,_) = importedTruths.insert(tautology)
        if !inserted {return}
        
        // if the testMe matches a tautology form, it equals true
        equivalenceFinders.append({(testMe) in
            var matcher: [Expression?]? = [Expression?].init(repeating: nil, count: tautology.args)
            tautology.expression.matchWildcards(onto: testMe, into: &matcher)
            return matcher == nil ? nil : .bool(true)
        })
        
        switch tautology.expression {
        case .compound(id: let functionIdentifier, args: let args):
            switch functionIdentifier {
            case .or:
                
                func generateTruth(notThis: Expression, meansThis: Expression) {
                    var checker = [Bool].init(repeating: false, count: tautology.args)
                    notThis.checkForContainment(into: &checker)
                    
                    guard checker.allSatisfy({$0}) else {return}
                    
                    self.truthGenerators.append({(testMe) in
                        var matcher: [Expression?]? = [Expression?].init(repeating: nil, count: tautology.args)
                        Expression.compound(id: .not, args: [notThis]).matchWildcards(onto: testMe, into: &matcher)
                        if let successfulMatcher = matcher {
                            return meansThis.replaceWildcards(using: successfulMatcher.map({$0!}))
                        } else {
                            return nil
                        }
                    })
                    
                }
                
                guard args.count == 2 else {fatalError()}
                let (lhs, rhs) = (args[0], args[1])
                
                generateTruth(notThis: lhs, meansThis: rhs)
                generateTruth(notThis: rhs, meansThis: lhs)
                
            case .equals:
                
                func addEquivalence(this: Expression, that: Expression) {
                    var checker = [Bool].init(repeating: false, count: tautology.args)
                    
                    this.checkForContainment(into: &checker)
                    
                    guard checker.allSatisfy({$0}) else {return}
                    
                    
                    
                    self.equivalenceFinders.append({(testMe) in
                        var matcher: [Expression?]? = [Expression?].init(repeating: nil, count: tautology.args)
                        this.matchWildcards(onto: testMe, into: &matcher)
                        
                        
                        if let successfulMatcher = matcher {
                            return that.replaceWildcards(using: successfulMatcher.map({$0!}))
                        } else {
                            return nil
                        }
                    })
                    
                }
                
                guard args.count == 2 else {fatalError()}
                let (lhs, rhs) = (args[0], args[1])
                
                addEquivalence(this: lhs, that: rhs)
                addEquivalence(this: rhs, that: lhs)
            default:
                return
            }
        default:
            return
        }
    }
    
    private var neighborCache = [Expression:Set<Expression>]()
    
    private func findAllNeighboringEquivalences(of: Expression) -> Set<Expression> {
        if let alreadyComputed = neighborCache[of] {return alreadyComputed}
        
        var neighbors: Set<Expression> = [of]
        
        switch of {
        case .compound(id: let functionIdentifier, args: let args):
            
            let argNeighbors = args.map({findAllNeighboringEquivalences(of: $0)})
            var permutationBuilder: [[Expression]] = [[]]
            
            for argNeighborSet in argNeighbors {
                var newPermutationBuilder = [[Expression]]()
                for argNeighbor in argNeighborSet {
                    for prevPerm in permutationBuilder {
                        var newPerm: [Expression] = prevPerm
                        newPerm.append(argNeighbor)
                        newPermutationBuilder.append(newPerm)
                    }
                }
                permutationBuilder = newPermutationBuilder
            }
            
            for argPermutation in permutationBuilder {
                neighbors.insert(.compound(id: functionIdentifier, args: argPermutation))
            }
            
        default:
            break
        }
        
        for equivalenceFinder in equivalenceFinders {
            if let equivalence = equivalenceFinder(of) {
                neighbors.insert(equivalence)
            }
        }
        
        if let functionSimplify = of.evaluateIfEvaluatable() {
            neighbors.insert(functionSimplify)
        }
        
        neighborCache[of] = neighbors
        
        return neighbors
    }
    
    func findSortedEquivalentExpressions(expression: Expression, maxNodes: Int) -> [Expression] {
    
        var beenSearched = Set<Expression>() // remember node limit
        var toBeSearched: Set<Expression> = [expression] // remember node limit
        
        var howManyLoops = 1
        while let searchMe = toBeSearched.first {
            let neighbors = findAllNeighboringEquivalences(of: searchMe).filter({$0.getNodeCount() <= maxNodes})
            
            for neighbor in neighbors {
                if !beenSearched.contains(neighbor) {
                    toBeSearched.insert(neighbor)
                }
            }
            
            toBeSearched.remove(searchMe)
            beenSearched.insert(searchMe)
            
            if howManyLoops == 100 {
                beenSearched.formUnion(toBeSearched)
                break
            } else {
                howManyLoops += 1
            }
        }
        
        return beenSearched.sorted(by: {$0.getNodeCount() <= $1.getNodeCount()})
    }
    
    func searchStringExpression(input: String, maxExpressionSize: Int) -> [String] {
        guard let inputExpression = Expression(fromString: input) else {return ["COULDN'T PARSE!"]}
        let equivalences = findSortedEquivalentExpressions(expression: inputExpression, maxNodes: maxExpressionSize)
        return equivalences.map({$0.toString()})
    }
}
