//
//  LibraryModule.swift
//  LibraryModule
//
//  Created by Vincent Coetzee on 5/8/21.
//

import Foundation

public class LibraryModule: Module
    {
    private var path: String?
    
    init(label:Label,path:String)
        {
        self.path = path
        super.init(label: label)
        }
    }
