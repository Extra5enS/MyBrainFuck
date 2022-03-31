PYTHON=python3
PYPY=pypy
SOURCE=source
CODE=brainfuck
PYPY_SOURCE_REPO=https://foss.heptapod.net/pypy/pypy
TRANSLETOR_PATH=pypy/rpython/translator/goal
RPYTHON=pypy/rpython/bin/rpython
APT=apt

python_only:
	$(PYTHON) $(SOURCE)/python_only.py $(CODE)/first_brainfuck.b

insatll_pypy_rpython:
	hg clone $(PYPY_SOURCE_REPO) pypy

simple_pypy:
	mkdir -p build
	$(PYPY) $(RPYTHON) --opt=2 $(SOURCE)/simple_pypy.py
	mv -f simple_pypy-c build 	

jit_pypy:
	mkdir -p build
	$(PYPY) $(RPYTHON) --opt=jit $(SOURCE)/jit_pypy.py
	mv -f jit_pypy-c build 	

opt_jit_pyp:	
	mkdir -p build
	$(PYPY) $(RPYTHON) --opt=jit $(SOURCE)/opt_jit_pypy.py
	mv -f opt_jit_pypy-c build 	
