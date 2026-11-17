volatile unsigned short *vga = (volatile unsigned short *)0xB8000;

void kprint(const char *str, unsigned char color) {
  int i = 0;
  while (str[i] != '\0') {
    vga[i] = ((unsigned short)color <<8) | str[i];
    i++;
  }
}

void kernel_main(void) {
  kprint("Hello from 32-bit C Kernel!", 0x1F);

  while(1) {
    __asm__ volatile ("hlt");
  }
}
