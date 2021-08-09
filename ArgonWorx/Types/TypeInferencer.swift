//
//  TypeInferencer.swift
//  TypeInferencer
//
//  Created by Vincent Coetzee on 9/8/21.
//

import Foundation
//
//public enum InferencingError:Error
//    {
//    case unboundVariable(String)
//    }
//    
//public indirect enum InferencedType
//    {
//    case undefined
//    case named(Class)
//    case variable(Label)
//    case function(InferencedType,InferencedType)
//    case type(Int)
//    }
//    
//public class TypeInferencer
//    {
//    public struct Context
//        {
//        private var nextVariable:Int = 0
//        private var environment:[Label:InferencedType] = [:]
//        
//        public func newContext() -> Context
//            {
//            let newContext = self
//            return(newContext)
//            }
//            
//        public mutating func setType(_ type:InferencedType,atKey:Label)
//            {
//            self.environment[atKey] = type
//            }
//            
//
//        }
//        
//    public struct Substitution
//        {
//        public var mapping:[String:InferencedType] = [:]
//        }
//        
//    private let scope:NamingContext
//    private var substitutions:[Label:InferencedType] = [:]
//    private var nextVariable:Int = 0
//    private var context = Context()
//    
//    public init(scope:NamingContext)
//        {
//        self.scope = scope
//        }
//        
//    private func newTypeVariable() -> InferencedType
//        {
//        let next = self.nextVariable
//        self.nextVariable += 1
//        return(.type(next))
//        }
//            
//    public func infer(node:ParseNode) throws -> (InferencedType,Substitution)
//        {
//        return(try self.infer(node.type))
//        }
//        
//    public func infer(_ type:Type) throws -> (InferencedType,Substitution)
//        {
//        if type is ClassType
//            {
//            let theType = type as! ClassType
//            return(.named(theType.clazz),Substitution())
//            }
//        else if type is SlotType
//            {
//            let theType = (type as! SlotType).slot
//            if let theSlotType = self.scope.lookup(label: theType.label)
//                {
//                return(.variable(theType.label),Substitution())
//                }
//            else
//                {
//                throw(InferencingError.unboundVariable(theType.label))
//                }
//            }
////        else if type is FunctionType
////            {
////            let function = type as! FunctionType
////            let curried = function.curriedFunction
////            let newType = self.newTypeVariable()
////            var newContext = self.context.newContext()
////            for element in curried
////                {
////                newContext.setType(.named(element.parameter.type.typeClass), atKey: element.parameter.label)
////                }
////            let (bodyType,substitution) = self.infer(function.body)
////            }
//        return(.undefined,Substitution())
//        }
//        
//    private func applySubstitutionToType(substitution:Substitution,type:InferencedType) -> InferencedType
//        {
//        switch(type)
//            {
//            case .named:
//                return(type)
//            case .variable(let name):
//                if let substitution = substitution.mapping[name]
//                    {
//                    return(substitution)
//                    }
//                else
//                    {
//                    return(type)
//                    }
//            case .function(let from,let to):
//                return(.function(self.applySubstitutionToType(substitution: substitution, type: from),self.applySubstitutionToType(substitution: substitution, type: to)))
//            default:
//                return(.undefined)
//            }
//        }
//        
//    private func addToContext(context: Context,name:Label,type:InferencedType) -> Context
//        {
//        var newContext = context.newContext()
//        newContext.setType(type,atKey: name)
//        return(newContext)
//        }
//        
//
//    }
