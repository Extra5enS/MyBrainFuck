import sys
import py
import os
from os.path import exists

import rpython.rtyper
from rpython.rlib.objectmodel import specialize
from rpython.rlib import rdynload
from rpython.rtyper.lltypesystem import rffi, lltype
from rpython.rtyper.lltypesystem.lltype import FuncType, Ptr

@specialize.ll()
def return_caller(func):
    source = py.code.Source("""
    def cpy_call_external(funcptr):
        # NB. it is essential that no exception checking occurs here!
        res = funcptr()
        return res
    """)
    miniglobals = {'__name__': __name__}

    exec(source.compile()) in miniglobals
    call_external_function = miniglobals['cpy_call_external']
    call_external_function._dont_inline_ = True
    call_external_function._annspecialcase_ = 'specialize:ll'
    call_external_function._gctransformer_hint_close_stack_ = True

    def func_exec():
        return call_external_function(func)

    return func_exec

ll_libname = rffi.str2charp('./source/csource/hlib.so')
dll = rdynload.dlopen(ll_libname, rdynload._dlopen_default_mode())
lltype.free(ll_libname, flavor='raw')
initptr = rdynload.dlsym(dll, 'hello')
# Ptr and FuncType are from rpython.rtyper.lltypesystem.lltype
helloFunc = rffi.cast(Ptr(FuncType([], lltype.Void)), initptr)

func_caller = return_caller(helloFunc)

try:
    from rpython.rlib.jit import JitDriver, purefunction
except ImportError:
    class JitDriver(object):
        def __init__(self,**kw): pass
        def jit_merge_point(self,**kw): pass
        def can_enter_jit(self,**kw): pass

def get_location(pc, program, bracket_map):
    return "%s|%s|%s" % (
            program[:pc], program[pc], program[pc+1:]
            )

jitdriver = JitDriver(greens=['pc', 'program', 'bracket_map'], reds=['tape'],
        get_printable_location=get_location)

@purefunction
def get_matching_bracket(bracket_map, pc):
    return bracket_map[pc]

def mainloop(program, bracket_map):
    pc = 0
    tape = Tape()
    while pc < len(program):
        jitdriver.jit_merge_point(pc=pc, 
				tape=tape, program=program,
        		bracket_map=bracket_map,)

        code = program[pc]

        if code == ">":
            tape.advance()

        elif code == "<":
            tape.devance()

        elif code == "+":
            tape.inc()

        elif code == "-":
            tape.dec()
        
        elif code == ".":
            os.write(1, chr(tape.get()))
        
        elif code == ",":
            tape.set(ord(os.read(0, 1)[0]))

        elif code == "[" and tape.get() == 0:
            pc = get_matching_bracket(bracket_map, pc)
            
        elif code == "]" and tape.get() != 0:
            pc = get_matching_bracket(bracket_map, pc)

        elif code == "h":
			tape.hello()	

        pc += 1

class Tape(object):
    def __init__(self):
        self.thetape = [0]
        self.position = 0

    def get(self):
        return self.thetape[self.position]
    def set(self, val):
        self.thetape[self.position] = val
    def inc(self):
        self.thetape[self.position] += 1
    def dec(self):
        self.thetape[self.position] -= 1
    def advance(self):
        self.position += 1
    	if len(self.thetape) <= self.position:
            self.thetape.append(0)
    def devance(self):
        self.position -= 1

    def hello(self):
		#print('Is lib exists?', exists(lib_path))
        func_caller()

def parse(program):
    parsed = []
    bracket_map = {}
    leftstack = []

    pc = 0
    for char in program:
        if char in ('[', ']', '<', '>', '+', '-', ',', '.', 'h'):
            parsed.append(char)

            if char == '[':
                leftstack.append(pc)
            elif char == ']':
                left = leftstack.pop()
                right = pc
                bracket_map[left] = right
                bracket_map[right] = left
            pc += 1
    
    return "".join(parsed), bracket_map

def run(fp):
    program_contents = ""
    while True:
        read = os.read(fp, 4096)
        if len(read) == 0:
            break
        program_contents += read
    os.close(fp)
    program, bm = parse(program_contents)
    mainloop(program, bm)

def entry_point(argv):
    try:
        filename = argv[1]
    except IndexError:
        print("You must supply a filename")
        return 1
    
    run(os.open(filename, os.O_RDONLY, 0777))
    return 0

def jitpolicy(driver):
    from rpython.jit.codewriter.policy import JitPolicy
    return JitPolicy()

def target(*args):
    return entry_point, None
    
if __name__ == "__main__":
    entry_point(sys.argv)
