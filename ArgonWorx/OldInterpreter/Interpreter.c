//
//  Interpreter.c
//  Interpreter
//
//  Created by Vincent Coetzee on 27/7/21.
//

#include "Interpreter.h"

void* allocate(Context input)
    {
    return((void*)input.thisWord);
    }
