from rpython.rtyper.lltypesystem import rffi
from rpython.rlib import rdynload

import os

ll_libname = rffi.str2charp(os.environ['LIBPATH'])
dll = rdynload.dlopen(ll_libname)#,space.sys.dlopenflags)
print(dll)
