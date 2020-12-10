//
//  ContentView.swift
//  Tautology Searcher
//
//  Created by Samuel Donovan on 9/20/20.
//

import SwiftUI

struct TautologySearcherView: View {
    
    let tautologySearcher: TautologySearcher
    
    @State var inputTautology = "or(not(not($0)),not($0))"
    let minExpressionSize = 4
    @State var offset = 0
    @State var outputExpressions: [String] = []
    @State var searching: Bool = false
    
    init(tautologySearcher: TautologySearcher) {
        self.tautologySearcher = tautologySearcher
        self.outputExpressions = ["Start Searching!"]
    }
    
    var body: some View {
        VStack {
            TextField("Input Expression", text: $inputTautology)
                .frame(width: 700, height: 50, alignment: .leading)
            HStack {
                Button("Example 1") {
                    inputTautology = "equals(not(not($0)),not($0))"
                }
                Button("Example 2") {
                    inputTautology = "equals(or(not($0),$0),not($0))"
                }
                Button("Example 3") {
                    inputTautology = "or(and(not($0),$0),or($0,$1))"
                }
                Button("Example 3") {
                    inputTautology = "not(or(or(not($0),$1),and($0,$1)))"
                }
            }
            Picker("Maximum Number of Nodes in Expression", selection: $offset) {
                ForEach(0..<10, content: {
                    Text(String(minExpressionSize+$0))
                })
            }
            .frame(width: 700, alignment: .leading)
            if searching {
                LoadingAnimation()
            } else {
                Button("Search for equivalent expressions") {
                  
                    searching = true
                    DispatchQueue.global().async {
                  
                        let outputExpressions = tautologySearcher.searchStringExpression(input: inputTautology, maxExpressionSize: minExpressionSize+offset)
                        DispatchQueue.main.async {
                            self.outputExpressions = outputExpressions
                            searching = false
                        }
                    }
                }
            }
            Divider()
            List(outputExpressions, id: \.self, rowContent: {x in
                HStack {
                Spacer()
                Text(x)
                Spacer()
            }})
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        TautologySearcherView(tautologySearcher: TautologySearcher(tautologies: tautologiesList))
    }
}
