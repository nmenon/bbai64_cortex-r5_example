APP ?= test.elf
APP_SOURCES ?= test.c

CROSS_COMPILE ?= arm-none-eabi-

.PHONY: $(APP)

ifeq ($(LLVM),)
CROSS_CC ?= $(CROSS_COMPILE)gcc
CROSS_SIZE ?= $(CROSS_COMPILE)size
CROSS_OBJDUMP ?= $(CROSS_COMPILE)objdump
CFLAGS += --specs=nosys.specs --specs=nano.specs
else
CROSS_CC ?= clang
CROSS_SIZE ?= llvm-size
CROSS_OBJDUMP ?= llvm-objdump
CFLAGS += --target=arm-none-eabi
endif

ARCH ?= r5

ifeq ($(ARCH),r5)
	CFLAGS += -mcpu=cortex-r5
endif

all: $(APP)

clean:
	rm -f $(APP)

$(APP): $(APP_SOURCES) gcc.ld
	$(CROSS_CC) $(CFLAGS) -Og  -T gcc.ld -o $(APP) $(APP_SOURCES)
	$(CROSS_SIZE) $(APP)
	$(CROSS_OBJDUMP) -xd $(APP) > $(APP).lst
	# sudo cp $(APP) /lib/firmware/
	# sudo echo stop > /sys/class/remoteproc/remoteproc18/state
	# sudo echo $(APP) > /sys/class/remoteproc/remoteproc18/firmware
	# sudo echo start > /sys/class/remoteproc/remoteproc18/state
	# sudo cat /sys/kernel/debug/remoteproc/remoteproc18/trace0
