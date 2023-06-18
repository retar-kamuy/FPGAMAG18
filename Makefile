# Variables: Defaults
#
PIP = .venv\Scripts\pip
PYTHON = .venv\Scripts\python

# Variables: Verilog
#
BUILD_DIR = build
DUT = tb_top

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

.PHONY : test_verilator
test_verilator:
	cmake -B $(BUILD_DIR) -DVERILATOR_ARGS=--trace -GNinja .
	ninja -C $(BUILD_DIR)
	mv $(BUILD_DIR)/V$(DUT) V$(DUT)
	./V$(DUT)

.PHONY : test_verilator_vcd
test_verilator_vcd:
	cmake -B $(BUILD_DIR) -DVERILATOR_ARGS=--trace -GNinja .
	ninja -C $(BUILD_DIR)
	mv $(BUILD_DIR)/V$(DUT) V$(DUT)
	./V$(DUT) +trace

.PHONY : clean
clean:
	rm -rf vunit_out

.PHONY : distclean
distclean: clean
	rm -rf build
