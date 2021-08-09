//
//  VariableType.swift
//  VariableType
//
//  Created by Vincent Coetzee on 9/8/21.
//

import Foundation

public class SlotType: Type
    {
    let slot: Slot
    
    init(slot:Slot)
        {
        self.slot = slot
        super.init(label: slot.label)
        }
    }
