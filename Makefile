CC = clang
AS = clang
LD = /opt/homebrew/opt/lld/bin/ld.lld
QEMU = qemu-system-x86_64

ASFLAGS = -target i386-elf -c
CFLAGS = -target i386-elf -ffreestanding -fno-pie -fno-stack-protector -O2 -Wall -c
LDFLAGS = -m elf_i386 --oformat binary --image-base=0x7c00 -Ttext 0x7c00

os.img: boot.bin kernel.bin
	cat boot.bin kernel.bin > os.img
	truncate -s 5120 os.img

kernel.bin: kernel_entry.o kernel.o
	$(LD) -m elf_i386 --oformat binary --image-base=0x1000 -Ttext 0x1000 $^ -o $@

kernel.o: kernel.c
	$(CC) $(CFLAGS) $< -o $@

kernel_entry.o: kernel_entry.s
	$(AS) $(ASFLAGS) $< -o $@


boot.bin: boot.o
	$(LD) $(LDFLAGS) $< -o $@

boot.o: boot.s
	$(AS) $(ASFLAGS) $< -o $@

run: os.img
	$(QEMU) -drive format=raw,file=$<

run-debug: os.img
	$(QEMU) -drive format=raw,file=$< -d int,cpu_reset -no-reboot

clean:
	rm -f boot.o boot.bin kernel.o kernel_entry.o kernel.bin os.img

.PHONY: clean run run-debug
