.code16
.globl _start
_start:
  hlt
  jmp _start
.fill 510 - (. - _start), 1, 0
.word 0xaa55
