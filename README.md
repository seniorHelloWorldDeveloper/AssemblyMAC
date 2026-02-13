To compile and run:

nasm -felf64 get_current_mac.asm -o get_current_mac.o
nasm -felf64 get_interface.asm -o get_interface.o
ld get_interface.o get_current_mac.o -o print_current_mac
./print_current_mac
