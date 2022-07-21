APP ?= test.elf
APP_SOURCES ?= test.c

CROSS_COMPILE ?= arm-none-eabi-

.PHONY: $(APP)

CROSS_CC ?= $(CROSS_COMPILE)gcc
CROSS_SIZE ?= $(CROSS_COMPILE)size
CROSS_OBJDUMP ?= $(CROSS_COMPILE)objdump

ARCH ?= r5

ifeq ($(ARCH),r5)
	CFLAGS += -mcpu=cortex-r5
	RPROC ?= 18
endif

ifeq ($(ARCH),m4f)
	CFLAGS += -mcpu=cortex-m4
	RPROC ?= 0
endif

all: $(APP)

clean:
	rm -f $(APP)

$(APP): $(APP_SOURCES) gcc-$(ARCH).ld
	$(CROSS_CC) $(CFLAGS) -Og --specs=nosys.specs --specs=nano.specs -T gcc-$(ARCH).ld -o $(APP) $(APP_SOURCES)
	$(CROSS_SIZE) $(APP)
	$(CROSS_OBJDUMP) -xd $(APP) > $(APP).lst

loadup:
	sudo cp $(APP) /lib/firmware/
	echo stop | sudo tee /sys/class/remoteproc/remoteproc$(RPROC)/state
	echo $(APP) | sudo tee /sys/class/remoteproc/remoteproc$(RPROC)/firmware
	echo start | sudo tee /sys/class/remoteproc/remoteproc$(RPROC)/state
	sudo cat /sys/kernel/debug/remoteproc/remoteproc$(RPROC)/trace0
