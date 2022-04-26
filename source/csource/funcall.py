import rpython.rtyper
from rpython.rtyper.lltypesystem import rffi, lltype
from rpython.rlib import rdynload
import sys
from rpython.rtyper.lltypesystem.lltype import FuncType, Ptr
import os
from os.path import exists

lib_path = './source/csource/hlib.so'
#print('Is lib exists?', exists(lib_path))

ll_libname = rffi.str2charp(lib_path)

dll = rdynload.dlopen(ll_libname, rdynload._dlopen_default_mode())
	
lltype.free(ll_libname, flavor='raw')

initptr = rdynload.dlsym(dll, 'hello')

# Ptr and FuncType are from rpython.rtyper.lltypesystem.lltype
func_void_void = Ptr(FuncType([], lltype.Void))
helloFunc = rffi.cast(func_void_void, initptr)
print(initptr)
print(helloFunc)
helloFunc()

#initptr
