import os
import shutil
from pathlib import Path
from vunit import VUnit

def pre_config(output_path):
    cwd = Path(output_path).parent / '..' / 'modelsim'
    basename = os.path.basename(output_path).split('.')[-1]
    mem_name = '_'.join(basename.split('_')[:-1]) + '.hex'
    if not os.path.isdir(cwd):
        os.mkdir(cwd)
    shutil.copy('env/tests/' + mem_name, cwd)
    return True

def post_check(output_path):
    cwd = Path(output_path).parent / '..' / 'modelsim'
    shutil.move(cwd / 'wave.vcd', Path(output_path))
    return True

SRC_PATH = Path(__file__).parent / 'src' / '*' / 'src'
TB_PATH = Path(__file__).parent / 'env'

VU = VUnit.from_argv(compile_builtins=False)
VU.add_verilog_builtins()

lib = VU.add_library('lib')
lib.add_source_file(Path('src') / 'fmrv32im_core.sv')
lib.add_source_files(SRC_PATH / '*.v')
lib.add_source_files(SRC_PATH / '*.sv')

tb_lib = VU.add_library('tb_lib')
tb_lib.add_source_file(TB_PATH / 'vcdplus.v')
tb_lib.add_source_file(TB_PATH / 'tb.sv')
tb_lib.add_source_file(TB_PATH / 'tb_axi_slave_model.v')
tb_lib.add_source_file(TB_PATH / 'tb_axil_slave_model.v')
# tb_lib.add_source_files(TB_PATH / '*.v')

VU.set_sim_option('modelsim.vsim_flags', ['tb_lib.vcdplus'], overwrite=False)

test_benchs = tb_lib.get_test_benches(pattern='*', allow_empty=False)

for tb in test_benchs:
    test_bench = tb_lib.test_bench(tb.name)
    test_bench.set_pre_config(pre_config)
    test_bench.set_post_check(post_check)

VU.main()
