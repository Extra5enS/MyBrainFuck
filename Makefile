PYTHON=python3
PYPY=pypy
SOURCE=source
CODE=brainfuck
TRANSLETOR_STORE_LINK=https://foss.heptapod.net/pypy/pypy
TRANSLETOR_PATH=pypy/rpython/translator/goal


python_only:
	$(PYTHON) $(SOURCE)/python_only.py $(CODE)/first_brainfuck.b

install_transletor:
	hg clone $(TRANSLETOR_STORE_LINK)

simple_pypy:
	$(PYPY) $(TRANSLETOR_PATH)/translate.py $(SOURCE)/simple_pypy.py
	
