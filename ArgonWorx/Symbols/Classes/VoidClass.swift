//
//  VoidClass.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation
import FFI

public class VoidClass:SystemClass
    {
    public static let voidClass = VoidClass(label:"Void")
    
    public override var ffiType: ffi_type
        {
        return(ffi_type_void)
        }
        
    public override var isVoidType: Bool
        {
        return(true)
        }
        
    public override func printLayout()
        {
        }
    }
