import os
import shutil
import re
from pathlib import Path
from vunit import VUnit

regexp = r'(\_[0-9a-z]+)$'

def pre_config(output_path):
    cwd = Path(output_path).parent / '..' / 'modelsim'
    basename = os.path.basename(output_path).split('.')[-1]
    mem_name = '_'.join(basename.split('_')[:-1]) + '.hex'
    if not os.path.isdir(cwd):
        os.mkdir(cwd)
    shutil.copy('src/testpt/' + mem_name, cwd)
    return True

SRC_PATH = Path(__file__).parent / 'modules' / '*' / 'src'
TB_PATH = Path(__file__).parent / 'src'

VU = VUnit.from_argv(compile_builtins=False)
VU.add_verilog_builtins()

lib = VU.add_library('lib')
lib.add_source_file('fmrv32im_core.sv')
lib.add_source_files(SRC_PATH / '*.v')

tb_lib = VU.add_library('tb_lib')
tb_lib.add_source_file(TB_PATH / 'tb_fmrv32im_core.sv')
tb_lib.add_source_file(TB_PATH / 'tb_axi_slave_model.v')
tb_lib.add_source_file(TB_PATH / 'tb_axil_slave_model.v')
# tb_lib.add_source_files(TB_PATH / '*.v')

test_benchs = tb_lib.get_test_benches(pattern='*', allow_empty=False)

for tb in test_benchs:
    test_bench = tb_lib.test_bench(tb.name)
    test_bench.set_pre_config(pre_config)

VU.main()
