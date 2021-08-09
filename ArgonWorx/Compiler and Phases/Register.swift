//
//  Register.swift
//  Register
//
//  Created by Vincent Coetzee on 9/8/21.
//

import Foundation

public class Register:Equatable
    {
    public static func ==(lhs:Register,rhs:Register) -> Bool
        {
        return(lhs.register == rhs.register)
        }
        
    private var isEmpty = true
    internal let register: Instruction.Register
    internal var slots: Slots = []
    
    public var contentsAreDuplicatedElsewhere: Bool
        {
        for slot in self.slots
            {
            if slot.addressDescriptors.valueIsDuplicated
                {
                return(true)
                }
            }
        return(false)
        }
        
    init(register:Instruction.Register)
        {
        self.register = register
        }
    }

public class RegisterFile
    {
    public static let shared = RegisterFile()
    
    private var file: Array<Register>
    private var available: Array<Register>
    private var unavailable: Array<Register>
    
    init()
        {
        self.unavailable = []
        self.file = []
        self.available = []
        for register in Instruction.Register.generalPurposeRegisters
            {
            self.file.append(Register(register: register))
            }
        self.available = file
        }
        
    public func findRegister(for slot:Slot?,instance: MethodInstance) -> Instruction.Register
        {
        if !slot.isNil
            {
            for register in self.file
                {
                if register.slots.contains(slot!)
                    {
                    return(register.register)
                    }
                }
            }
        if !self.available.isEmpty
            {
            let register = self.available[0]
            self.available.remove(at: 0)
            self.unavailable.append(register)
            if slot.isNotNil
                {
                register.slots.append(slot!)
                }
            return(register.register)
            }
        for register in self.unavailable
            {
            if register.contentsAreDuplicatedElsewhere
                {
                if slot.isNotNil
                    {
                    register.slots.append(slot!)
                    }
                return(register.register)
                }
            }
        return(self.spillRegister(self.unavailable.first!,instance: instance))
        }
        
    private func spillRegister(_ register:Register,instance: MethodInstance) -> Instruction.Register
        {
        let address = DataSegment.shared.allocateObject(sizeInBytes: 8)
        for slot in register.slots
            {
            slot.addressDescriptors.append(.address(address))
            }
        instance.append(.store,.register(register.register),.address(address))
        return(register.register)
        }
    }
