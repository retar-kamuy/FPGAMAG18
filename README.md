# FPGAMAG18
FPGA Magazine No.18 - RISC-V

ctags --language-force=verilog --tag-relative --extra=f --excmd=number -R .

## 注意
[src/testpt](src/testpt)内のテストパターンは"0x008"番地へ0x001が書かれるとPASSではなく、0x539が書かれるとPASS。それ以外の値が書き込まれるとFAIL。

原因は"0x03c"番地の命令上位12bitが“0539“であるため。
