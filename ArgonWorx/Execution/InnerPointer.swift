//
//  InnerPointer.swift
//  ArgonWorx
//
//  Created by Vincent Coetzee on 24/7/21.
//

import Foundation

public class InnerPointer
    {
    var classPointer:InnerClassPointer?
    let address:Word
    var wordPointer:WordPointer?

    init(address:Word)
        {
        self.classPointer = nil
        self.address = address
        self.wordPointer = WordPointer(address:address)
        }
        
    public func word(atOffset:Int) -> Word
        {
        return(self.wordPointer?[atOffset/8] ?? 0)
        }
        
    public func setWord(_ word:Word,atOffset:Int)
        {
        self.wordPointer?[atOffset/8] = word
        }
        
    public func slotValue(atName:String) -> Word
        {
        let slot = classPointer!.slot(atName:atName)
        return(self.wordPointer?[slot.offset] ?? 0)
        }
        
    public func setSlotValue(_ value:Word,atName:String)
        {
        let slot = classPointer!.slot(atName:atName)
        self.wordPointer?[slot.offset] = value
        }
    }
