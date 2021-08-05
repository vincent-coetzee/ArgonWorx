//
//  Function.swift
//  ArgonWx
//
//  Created by Vincent Coetzee on 3/7/21.
//

import Foundation
import FFI
import Interpreter

public class Function:Symbol
    {
    internal var cName: String
    internal var parameters: Parameters
    public var returnType: Type = VoidClass.voidClass.type
    public var library:DynamicLibrary = .emptyLibrary
    
    override init(label:Label)
        {
        self.cName = ""
        self.parameters = Parameters()
        super.init(label: label)
        }
        
    public func call(withArguments: Words) -> Word?
        {
        let argTypes:UnsafeMutablePointer<ffi_type>? = UnsafeMutablePointer<ffi_type>.allocate(capacity: self.parameters.count)
        var argPointer = argTypes
        for type in self.parameters.map({$0.type.ffiType})
            {
            argPointer?.pointee = type
            argPointer = argPointer! + 1
            }
        var interface = ffi_cif()
        let output = (self.returnType.isVoidType ? UnsafeMutablePointer<ffi_type>.allocate(capacity: 1).assigned(ffi_type_void) : UnsafeMutablePointer<ffi_type>.allocate(capacity: 1).assigned(ffi_type_uint64))
        let argTypePointer:UnsafeMutablePointer<UnsafeMutablePointer<ffi_type>?> = UnsafeMutablePointer<UnsafeMutablePointer<ffi_type>?>.allocate(capacity: 1)
        argTypePointer.pointee = argTypes
        ffi_prep_cif(&interface,FFI_DEFAULT_ABI,UInt32(self.parameters.count),output,argTypePointer)
        let argumentPointers = UnsafeMutablePointer<UnsafeMutableRawPointer?>.allocate(capacity: withArguments.count)
        var index = 0
        for argument in withArguments
            {
            let pointer = UnsafeMutablePointer<Word>.allocate(capacity: 1).assigned(argument)
            argumentPointers[index] = UnsafeMutableRawPointer(pointer)
            index += 1
            }
        if let address = self.library.findSymbol(self.cName)
            {
            ffi_call(&interface,MutateSymbol(address.address!),nil,argumentPointers)
            }
        return(0)
        }
    }

extension UnsafeMutablePointer
    {
    public func assigned(_ value:Pointee) -> UnsafeMutablePointer<Pointee>
        {
        self.pointee = value
        return(self)
        }
    }
