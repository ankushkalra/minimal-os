AS = clang
LD = /opt/homebrew/opt/lld/bin/ld.lld
QEMU = qemu-system-x86_64

ASFLAGS = -target i386-elf -c
LDFLAGS = -m elf_i386 --oformat binary --image-base=0x7c00 -Ttext 0x7c00

boot.bin: boot.o
	$(LD) $(LDFLAGS) $< -o $@

boot.o: boot.s
	$(AS) $(ASFLAGS) $< -o $@

run: boot.bin
	$(QEMU) -drive format=raw,file=$<

run-debug: boot.bin
	$(QEMU) -drive format=raw,file=$< -d int,cpu_reset -no-reboot

clean:
	rm -f boot.o boot.bin

.PHONY: clean run run-debug
