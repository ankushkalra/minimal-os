.code16
.globl _start

_start:
  cli                   # 1. Disable hardware interrupts
  xorw %ax, %ax         # 2. Zero out %ax
  movw %ax, %ds         # 3. Clear Data Segment (%ds = 0x0000)
  movw %ax, %es         # 4. Clear Extra Segment (%es = 0x0000)
  movw %ax, %ss         # 5. Clear Stack Segment (%ss = 0x0000)
  movw $0x7c00, %sp     # 6. Set Stack Pointer just below bootloader

  # Enable Fast A20 Gate
  inb  $0x92, %al         # Read System Control Port A
  orb  $0x02, %al         # Set bit 1 (enable A20)
  andb $0xfe, %al         # Clear bit 0 (safety mask so we don't trigger CPU reset)
  outb %al, $0x92         # Write back to System Control Port A

  lgdtl gdt_descriptor   # 7. Load Global Descriptor Table register

  movl %cr0, %eax       # 8. Read Control Register 0
  orl  $0x1, %eax       # 9. Set bit 0 (Protection Enable / PE bit)
  movl %eax, %cr0       # 10. Write back to CR0 (CPU is now in 32-bit mode)

  ljmpl $0x08, $pm_entry # 11. Far jump to flush pipeline and load %cs

# --------------------------------------------------------------------------
# Global Descriptor Table (GDT)
# --------------------------------------------------------------------------

gdt_start:

gdt_null:
  .quad 0x0000000000000000

gdt_code:
  .word 0xffff
  .word 0x0000
  .byte 0x00
  .byte 0b10011010
  .byte 0b11001111
  .byte 0x00

gdt_data:
  .word 0xffff
  .word 0x0000
  .byte 0x00
  .byte 0b10010010
  .byte 0b11001111
  .byte 0x00

gdt_end:

gdt_descriptor:
  .word gdt_end - gdt_start - 1
  .long gdt_start

# --------------------------------------------------------------------------
# 32-Bit Protected Mode Entry Point
# --------------------------------------------------------------------------
.code32
pm_entry:
  movw $0x10, %ax
  movw %ax, %ds
  movw %ax, %es
  movw %ax, %fs
  movw %ax, %gs
  movw %ax, %ss
  movl $0x90000, %esp

  movl $0xb8000, %edi
  movw $0x1f50, (%edi)
  movw $0x1f4d, 2(%edi)

pm_halt:
  hlt
  jmp pm_halt

# --------------------------------------------------------------------------
# Boot Sector Padding & Magic Signature
# --------------------------------------------------------------------------
.fill 510 - (. - _start), 1, 0
.word 0xaa55
