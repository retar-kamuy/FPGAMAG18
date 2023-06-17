# Variables: Defaults
#
PIP = .venv\Scripts\pip
PYTHON = .venv\Scripts\python

# Variables: Verilog
#


# Variables: Lists of objects, source and deps
#


# Rules
#
.DEFAULT_GOAL := test

all: distclean build test

.PHONY : build
build:
	python -m venv .venv
	python -m pip install --upgrade pip
	$(PIP) install -r requirements.txt

.PHONY : test
test:
	$(PYTHON) run.py

.PHONY : clean
clean:
ifeq ("$(wildcard vunit_out)", "vunit_out")
	rd /s /q vunit_out
endif

.PHONY : distclean
distclean: clean
ifeq ("$(wildcard .venv)", ".venv")
	rd /s /q .venv
endif

.PHONY : verilator
verilator:
	mkdir build
	cd build
	cmake -GNinja ..
	ninja
	./Vtb_top
