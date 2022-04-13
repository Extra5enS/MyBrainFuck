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

install_pypy_rpython:
	git submodule init
	git submodule update

simple_pypy:
	mkdir -p build
	$(PYPY) $(RPYTHON) --opt=2 $(SOURCE)/simple_pypy.py
	mv -f simple_pypy-c build 	

jit_pypy:
	mkdir -p build
	$(PYPY) $(RPYTHON) --opt=jit $(SOURCE)/jit_pypy.py
	mv -f jit_pypy-c build 	

opt_jit_pypy:	
	mkdir -p build
	$(PYPY) $(RPYTHON) --opt=jit $(SOURCE)/opt_jit_pypy.py
	mv -f opt_jit_pypy-c build 	

log_jit_pypy:	
	mkdir -p build
	$(PYPY) $(RPYTHON) --opt=jit $(SOURCE)/log_jit_pypy.py
	mv -f log_jit_pypy-c build

__with_jit_pypy: export PYPY_USESSION_DIR=$(PWD)/tmp/with_jit
__with_jit_pypy:
	$(PYPY) $(RPYTHON) -s --opt=jit $(SOURCE)/opt_jit_pypy.py

__without_jit_pypy: export PYPY_USESSION_DIR=$(PWD)/tmp/without_jit
__without_jit_pypy:
	$(PYPY) $(RPYTHON) -s --opt=jit --no-pyjitpl $(SOURCE)/opt_jit_pypy.py
	
jit_test: __with_jit_pypy __without_jit_pypy


rpython-help:
	$(PYPY) $(RPYTHON) --help
