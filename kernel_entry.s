.code32
.globl _kernel_entry
.extern kernel_main

_kernel_entry:
    call kernel_main
halt_loop:
    hlt
    jmp halt_loop

