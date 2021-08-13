//
//  ParseExpression.swift
//  ArgonCompiler
//
//  Created by Vincent Coetzee on 5/3/21.
//

import Foundation

public class Expression: NSObject
    {
    public func operation(_ symbol:Token.Symbol,_ rhs:Expression) -> Expression
        {
        return(BinaryExpression(self,symbol,rhs))
        }
        
    public func unary(_ symbol:Token.Symbol) -> Expression
        {
        return(UnaryExpression(symbol, self))
        }
        
    public func index(_ index:Expression) -> Expression
        {
        return(ArrayAccessExpression(array:self,index:index))
        }
        
    public func assign(_ index:Expression) -> Expression
        {
        return(AssignmentExpression(self,index))
        }
        
    public func slot(_ index:Expression) -> Expression
        {
        return(SlotExpression(self,slot: index))
        }
        
    public func emitCode(into instance: InstructionBuffer,using: CodeGenerator) throws
        {
        }
        
    public func realize(_ compiler:Compiler)
        {
        }
        
    public var declaration: Location
        {
        return(self.locations.declaration)
        }
        
    public var resultType: TypeResult
        {
        .undefined
        }
    
    public var place: Instruction.Operand
        {
        return(self._place)
        }
    
    public var locations = SourceLocations()
    public var _place: Instruction.Operand = .none
    
    public func addDeclaration(_ location:Location)
        {
        self.locations.append(.declaration(location))
        }
        
    public func addReference(_ location:Location)
        {
        self.locations.append(.reference(location))
        }
        
    public func allocateAddresses(using allocator:AddressAllocator)
        {
        }
        
    public func realize(using: Realizer)
        {
        }
        
    public func analyzeSemantics(using analyzer: SemanticAnalyzer)
        {
        }
        
    public func dump(depth: Int)
        {
        let padding = String(repeating: "\t", count: depth)
        print("\(padding)EXPRESSION()")
        }
        
    public func lookupSlot(selector: String) -> Slot?
        {
        return(nil)
        }
    }
    

public typealias Expressions = Array<Expression>
