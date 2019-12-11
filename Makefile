#
# Usage:
# make        # Compile all binary
# make clean  # Remove ALL binaries and object files from the directory
# make flash  # Write compiled file to the Flash memory
# make list   # Generate extended listing file
# make size   # Display the sizes of sections inside binary file
#

SHELL = /bin/sh
#
# A common settings for all projects in this folder
#

TARGET    = DEMO
MCU       = atmega328p
MCU_DUDE  = m328p
F_CPU     = 16000000
USBPORT   = /dev/ttyUSB0

## AVR 8-bit toolchain
# https://www.microchip.com/mplab/avr-support/avr-and-arm-toolchains-c-compilers
PREFIX = /usr#/opt/avr8-gnu-toolchain-linux_x86_64
#PREFIX=/home/martin/Downloads/avr8-gnu-toolchain-linux_x86_64


##
## You should not have to change anything below here
##

# Define variables used as names of programs in built-in rules
export LC_ALL=C
BINDIR  = $(PREFIX)/bin
CC      = $(BINDIR)/avr-gcc -fdiagnostics-color=always
AS      = $(BINDIR)/avr-gcc -fdiagnostics-color=always -x assembler-with-cpp
OBJDUMP = $(BINDIR)/avr-objdump
OBJCOPY = $(BINDIR)/avr-objcopy
SIZE    = $(BINDIR)/avr-size
AVRDUDE = avrdude
RM      = rm -f
RMFILES = *.o *.hex *.map *.elf *.lss

# Extra flags to give to the C compiler
# https://gcc.gnu.org/onlinedocs/gcc/Warning-Options.html
CFLAGS  = -std=c99 -Wall -Wextra -Werror -g -Os -mmcu=$(MCU) -DF_CPU=$(F_CPU)UL -I. -I$(LIBRARY_DIR)/inc -Iinc
# Extra flags to give to the assembler
ASFLAGS  = -mmcu=$(MCU) -Wall -I$(LIBRARY_DIR)/inc -Iinc
# Extra flags to give to compilers when they are supposed to invoke the linker
LDFLAGS = -mmcu=$(MCU) -Wl,-Map=$(TARGET).map -Wl,--cref

# We define all the targets that are not files
.PHONY = all list size flash clean

LIBRARY_DIR = lib

# The result of wildcard is a space-separated list of the names of
# existing files that match the pattern.
SRCS := main.c
# Add or comment libraries you are using in the project
SRCS += $(LIBRARY_DIR)/src/nokialcd.c
SRCS += $(LIBRARY_DIR)/src/uart.c
SRCS += $(LIBRARY_DIR)/src/fft.c
#SRCS += $(LIBRARY_DIR)/src/twi.c
#SRCS += $(LIBRARY_DIR)/src/gpio.c
SRCS += $(LIBRARY_DIR)/src/timer.c
#SRCS += $(LIBRARY_DIR)/src/segment.c
#ASSRC := $(wildcard src/*.S)



##
## You should not have to change anything below here
##

# This is called as substitution reference. In this case, if SRCS has
# values 'foo.c bar.c', OBJS variable will have 'foo.o bar.o'.
OBJS := $(SRCS:%.c=%.o)
OBJS += $(ASSRC:%.S=%.o)
# One of the functions for filenames. For example $(notdir src/foo.c hacks)
# produces the result 'foo.c hacks'.
# https://www.gnu.org/software/make/manual/html_node/File-Name-Functions.html
OBJS := $(notdir $(OBJS))

## Default rule executed
# target : prerequisites
#	recipe
all : $(TARGET).hex

## Generic compilation rule
# $@...The file name of the target of the rule
# $<...The name of the first prerequisite
# $^...The names of all the prerequisites, with spaces between them
# https://www.gnu.org/software/make/manual/html_node/Automatic-Variables.html#Automatic-Variables
# '%' is a pattern for matching file names
%.o : %.c
	@echo "Compiling \t$< --> $@"
	@$(CC) -c $(CFLAGS) $< -o $@

## Rule for object files from libraries
%.o : $(LIBRARY_DIR)/src/%.c
	@echo "Compiling \t$< --> $@"
	@$(CC) -c $(CFLAGS) $< -o $@

## Rule for object files from assembler
%.o : %.S
	@echo "Assembling \t$< --> $@"
	@$(AS) -c $(ASFLAGS) $< -o $@

## Rule for making the actual target
$(TARGET).elf : $(OBJS)
	@echo "Linking \t$^ --> $@"
	@$(CC) $(OBJS) $(LDFLAGS) -o $@

## Rule for Intel Hex file
$(TARGET).hex : $(TARGET).elf
	@echo "Generating Intel Hex \t$< --> $@"
	@$(OBJCOPY) -j .text -j .data -O ihex $< $@

## Rule for extended listing file
list : $(TARGET).lss
$(TARGET).lss : $(TARGET).elf
	@echo "Generating listing file\t$< --> $@"
	@$(OBJDUMP) -h -S $< > $@

## Rule for printing the actual program size
# Displays the sizes of sections inside binary file
size : $(TARGET).elf
	@$(SIZE) --format=avr --mcu=$(MCU) --radix=16 $<


flashusbasp : $(TARGET).hex
	@echo "Flashing program memory\t$<"
	@$(AVRDUDE) -p $(MCU_DUDE) -c usbasp -U flash:w:$(TARGET).hex:i

## Rule for program flashing
# https://www.nongnu.org/avrdude/user-manual/avrdude_4.html
flash : $(TARGET).hex
	@echo "Flashing program memory\t$<"
	@$(AVRDUDE) -p $(MCU_DUDE) -c arduino -D -V -u -q -U flash:w:$(TARGET).hex:i -P $(USBPORT)

## Clean rule
clean :
	@echo "Cleaning project files \t$(RMFILES)"
	@$(RM) $(RMFILES)
