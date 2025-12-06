#!/bin/bash

# Usage: ./compile.sh <file.s>


output_file="program.hex"


if [[ $# -eq 0 ]]; then
    echo "Usage: ./compile.sh <file.s or file.c>"
    exit 1
fi

input_file=$1
basename=$(basename "$input_file" | sed 's/\.[^.]*$//')
file_extension="${input_file##*.}"


if [ "$file_extension" == "c" ]; then
    riscv64-unknown-elf-gcc -S -g -O0 -fno-builtin -static \
                            -march=rv32i -mabi=ilp32 \
                            -o "${basename}.s" "$input_file" \
                            -Wno-unused-result
    input_file="${basename}.s"
fi


riscv64-unknown-elf-as -march=rv32i -mabi=ilp32 -o "a.out" "${input_file}"


riscv64-unknown-elf-ld -melf32lriscv \
                        -e 0x0 \
                        -Ttext 0x0 \
                        -o "a.out.reloc" "a.out"


riscv64-unknown-elf-objcopy -O verilog --verilog-data-width=4 --gap-fill=0 "a.out.reloc" "${output_file}"


riscv64-unknown-elf-objdump -d "a.out.reloc" > "${basename}.dis"


rm -f a.out a.out.reloc a.bin

echo "Compiled $1 to $output_file"
