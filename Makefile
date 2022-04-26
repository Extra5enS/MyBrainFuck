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
	mkdir -p tmp/with_jit
	$(PYPY) $(RPYTHON) -s --opt=jit $(SOURCE)/opt_jit_pypy.py

__without_jit_pypy: export PYPY_USESSION_DIR=$(PWD)/tmp/without_jit
__without_jit_pypy:
	mkdir -p tmp/without_jit
	$(PYPY) $(RPYTHON) -s $(SOURCE)/opt_jit_pypy.py
	
jit_test: __with_jit_pypy __without_jit_pypy

diff:
	diff tmp/with_jit/usession-unknown-0/ tmp/without_jit/usession-unknown-0/

rpython-help:
	$(PYPY) $(RPYTHON) --help

clean_jit_test:
	rm -rdf tmp/*

play_log: export PYPYLOG=jit-backend-dump:l.log
play_log: 
	cd build && ./log_jit_pypy-c ../brainfuck/mandel.b

viewcode: export PYTHONPATH=$(PWD)/pypy
viewcode: play_log
	pypy ./pypy/rpython/jit/backend/tool/viewcode.py ./build/l.log

clean_viewcode:
	rm -f log build/log

funcall: export PYTHONPATH=$(PWD)/pypy
funcall: export LIBPATH=$(PWD)/source/csource/hlib.so	
funcall:
	pypy ./source/csource/funcall.py

viewcode_withfun: export PYTHONPATH=$(PWD)/pypy
viewcode_withfun: play_hellofun
	pypy ./pypy/rpython/jit/backend/tool/viewcode.py ./build/l.log	

play_hellofun: fun_jit_pypy
	cd build && ./fun_jit_withfun-c ../brainfuck/hello.b

fun_jit_pypy: export PYPYLOG=jit-backend-dump:l.log
fun_jit_pypy:
	mkdir -p build
	$(PYPY) $(RPYTHON) --opt=jit $(SOURCE)/fun_jit_pypy.py
	mv -f log_jit_pypy-c build
		

