//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Larissa Metz on 4/3/17.
//  Copyright © 2017 Larissa Metz - Thoughtworks. All rights reserved.
//

import Foundation


struct CalculatorBrain {
    
    private var accumulator: Double?
    
    private var descriptionBuilder = " "
    
    private var isPartialResult = false
    
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double, (String) -> String)
        case binaryOperation((Double,Double) -> Double, (String, String) -> String)
        case equals
    }
    
    private var operations: Dictionary<String,Operation> = [
        "π" : Operation.constant(Double.pi),
        "e" : Operation.constant(M_E),
        "√" : Operation.unaryOperation(sqrt, {"√(" + $0 + ")"}),
        "%" : Operation.unaryOperation({$0 / 100}, {$0 + "%"}),
        "sin" : Operation.unaryOperation(sin, {"sin(" + $0 + ")"}),
        "cos" : Operation.unaryOperation(cos, {"cos(" + $0 + ")"}),
        "±" : Operation.unaryOperation({ -$0 }, {"±" + $0}),
        "×" : Operation.binaryOperation({ $0 * $1 }, {$0 + " × " + $1}),
        "÷" : Operation.binaryOperation({ $0 / $1 }, {$0 + " ÷ " + $1}),
        "+" : Operation.binaryOperation({ $0 + $1 }, {$0 + " + " + $1}),
        "−" : Operation.binaryOperation({ $0 - $1 }, {$0 + " − " + $1}),
        "=" : Operation.equals
        ]
    
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                accumulator = value
                descriptionBuilder = symbol
            case .unaryOperation(let function, let descriptionFunc):
                if accumulator != nil {
                    accumulator = function(accumulator!)
                    descriptionBuilder = descriptionFunc(descriptionBuilder)
                }
            case .binaryOperation(let function, let descriptionFunc):
                if accumulator != nil {
                    pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!, descriptionFunction: descriptionFunc, descriptionOperand: descriptionBuilder)
                    accumulator = nil

                }
            case .equals:
                performPendingBinaryOperation()
            }
      
        }
    }
    
    private mutating func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && accumulator != nil {
            accumulator = pendingBinaryOperation!.perform(with: accumulator!)
            descriptionBuilder = pendingBinaryOperation!.makeDescription(with: descriptionBuilder)
            pendingBinaryOperation = nil
        }
    }
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    private struct PendingBinaryOperation {
        let function: (Double,Double) -> Double
        let firstOperand: Double
        let descriptionFunction: (String, String) -> String
        let descriptionOperand: String
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
        
        func makeDescription(with secondDescOperand: String) -> String {
            return descriptionFunction(descriptionOperand, secondDescOperand)
        }
    }
    
    mutating func setOperand(_ operand: Double) {
        accumulator = operand
        descriptionBuilder = String(operand)
    }
    
    var result: Double? {
        get {
            return accumulator
        }
    }
    
    var description: String {
        return descriptionBuilder
    }
    
    mutating func clear() {
        accumulator = 0
        pendingBinaryOperation = nil
        descriptionBuilder = " "
        isPartialResult = false
    }
}
