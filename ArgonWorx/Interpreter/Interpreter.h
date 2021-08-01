//
//  Interpreter.h
//  Interpreter
//
//  Created by Vincent Coetzee on 27/7/21.
//

#ifndef Interpreter_h
#define Interpreter_h

#include <stdio.h>

typedef unsigned long long CWord;
typedef CWord* CWordPointer;
typedef long SInt;

typedef struct _SlotKey
    {
    char* name;
    CWord offset;
    }
    SlotKey;
    
void InitClassPointerSlotKeys();
CWord WordAtAddressAtOffset(CWord address,CWord offset);
SInt IntegerAtAddressAtOffset(CWord address,CWord offset);
double FloatAtAddressAtOffset(CWord address,CWord offset);
void SetFloatAtAddressAtOffset(double value,CWord address,CWord offset);
void SetIntegerAtAddressAtOffset(long value,CWord address,CWord offset);
void SetWordAtAddressAtOffset(CWord value,CWord address,CWord offset);

#endif /* Interpreter_h */
