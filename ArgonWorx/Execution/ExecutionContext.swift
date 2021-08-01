//
//  ExecutionContext.swift
//  ExecutionContext
//
//  Created by Vincent Coetzee on 1/8/21.
//

import Foundation

public class ExecutionContext:ObservableObject
    {
    @Published var registers = Array<Word>(repeating: 0, count: 42)
    @Published var _allRegisters = Instruction.Register.allCases
    
    public func register(atIndex:Instruction.Register) -> Word
        {
        return(self.registers[atIndex.rawValue])
        }
        
    public func setRegister(_ word:Word,atIndex:Instruction.Register) 
        {
        self.registers[atIndex.rawValue] = word
//        var someRegisters = self.registers
//        someRegisters[atIndex.rawValue] = word
//        self.registers = someRegisters
//        self._allRegisters = Instruction.Register.allCases
        }
        
    public var bp:Word
        {
        get
            {
            return(self.registers[Instruction.Register.bp.rawValue])
            }
        set
            {
            self.registers[Instruction.Register.bp.rawValue] = newValue
            }
        }
        
    public var managedSegment: Segment = ManagedSegment.shared

    
    public var registerPairs: Array<(Instruction.Register,Instruction.Register)>
        {
        var registers = Array<(Instruction.Register,Instruction.Register)>()
        
        for index in stride(from: Instruction.Register.code.rawValue,through: Instruction.Register.fr15.rawValue,by: 2)
            {
            registers.append((Instruction.Register(rawValue: index)!,Instruction.Register(rawValue: index)!))
            }
        return(registers)
        }
        
    public func update()
        {
        for index in 0..<registers.count
            {
            self.registers[index] *= 1
            }
        }
        
    public var allRegisters: Array<Instruction.Register>
        {
        return(self._allRegisters)
        }
    }
