//
//  SlotMemberExpression.swift
//  SlotMemberExpression
//
//  Created by Vincent Coetzee on 9/8/21.
//

import Foundation

public class SlotMemberExpression: Expression
    {
    public func instance(_ expression:Expression)
        {
        let instance = expression as! LocalReadExpression
        let name = instance.name
        let object = self.context.lookup(name: name)
        let localSlot = object?.lookup(label:names[0])
        }
        
    let names:Array<String>
    let context:NamingContext
    
    init(_ context:NamingContext,_ names:Array<String>)
        {
        self.names = names
        self.context = context
        }
    }
