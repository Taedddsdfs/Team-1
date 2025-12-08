#!/bin/bash

# =========================================================
# 1. 关键路径修正：向上跳两层 (../../) 去找 rtl
# =========================================================
RTL_DIR="../../rtl"       
HEX_FILE="f1.hex"         
TB_FILE="tb_top.cpp"      

# 2. 检查一下路径对不对 (调试用)
if [ ! -d "$RTL_DIR" ]; then
    echo "Error: Cannot find RTL directory at $RTL_DIR"
    echo "Current directory is $(pwd)"
    exit 1
fi

# 3. 修改 Instruction Memory 的加载路径
#    这里会把 instruction_memory.sv 里的文件名改成 "f1.hex"
#    注意：这里假设 instruction_memory.sv 确实在 ../../rtl/ 下
echo "Updating instruction memory to load ${HEX_FILE}..."
sed -i "s|.*\$readmemh.*|\$readmemh(\"${HEX_FILE}\", rom_array);|" ${RTL_DIR}/instruction_memory.sv

# 4. 清理旧构建
rm -rf obj_dir
rm -f top.vcd

# 5. 运行 Verilator
#    注意 -I 参数和文件路径都使用了 $RTL_DIR
echo "Verilating..."
verilator -Wall --cc --trace \
    -I${RTL_DIR} \
    ${RTL_DIR}/top.sv \
    --exe ${TB_FILE}

# 6. 编译 C++
echo "Building C++..."
make -j -C obj_dir/ -f Vtop.mk Vtop

# 7. 运行仿真
if [ ! -f "vbuddy.cfg" ]; then
    echo "Warning: vbuddy.cfg not found in current directory!"
fi

echo "Running simulation..."
./obj_dir/Vtop