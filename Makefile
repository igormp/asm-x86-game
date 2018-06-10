bootdisk=disk.img
blocksize=512
disksize=100

boot1=src/boot1

# bootloader 2nd stage params
boot2=src/boot2
boot2pos= 1
boot2size= 1

# kernel params
kernel=src/kernel
kernelpos= 3
kernelsize= 6

ASMFLAGS=-f bin
file = $(bootdisk)

all: clean mydisk boot1 write_boot1 boot2 write_boot2 kernel write_kernel hexdump launchqemu

mydisk: 
	dd if=/dev/zero of=$(bootdisk) bs=$(blocksize) count=$(disksize) status=noxfer

boot1: 
	nasm $(ASMFLAGS) $(boot1).asm -o $(boot1).bin 

boot2:
	nasm $(ASMFLAGS) $(boot2).asm -o $(boot2).bin

kernel:
	nasm $(ASMFLAGS) $(kernel).asm -o $(kernel).bin

write_boot1:
	dd if=$(boot1).bin of=$(bootdisk) bs=$(blocksize) count=1 conv=notrunc status=noxfer

write_boot2:
	dd if=$(boot2).bin of=$(bootdisk) bs=$(blocksize) seek=$(boot2pos) count=$(boot2size) conv=notrunc status=noxfer

write_kernel:
	dd if=$(kernel).bin of=$(bootdisk) bs=$(blocksize) seek=$(kernelpos) count=$(kernelsize) conv=notrunc

hexdump:
	hexdump $(file)

disasm:
	ndisasm $(boot1).asm

launchqemu:
	qemu-system-x86_64 -fda $(bootdisk)
	
clean:
	rm -f *.bin $(bootdisk) *~
