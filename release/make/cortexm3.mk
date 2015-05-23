#common compilers
AS  = $(IAR_DIR)/arm/bin/iasmarm.exe
CC  = $(IAR_DIR)/arm/bin/iccarm.exe
LD  = $(IAR_DIR)/arm/bin/ilinkarm.exe
AR  = ar
RM  = rm

#common flags
asflags-y += -s+ -M\<\> -w+ -r --cpu Cortex-M3 --fpu None
cflags-y += --no_cse --no_unroll --no_inline --no_code_motion
cflags-y += --no_tbaa --no_clustering --no_scheduling 
cflags-y += --cpu=Cortex-M3 -e --fpu=None --endian=little
cflags-y += --dlib_config $(IAR_DIR)/arm/INC/c/DLib_Config_Normal.h

ifeq ($(DEBUG),TRUE)
cflags-y += --debug -On
else
cflags-y += --debug -Oh 
endif

ldflags-y += --config $(link-script)
ldflags-y += --semihosting --entry __iar_program_start --vfe

inc-y += -I $(IAR_DIR)/arm/CMSIS/Include

dir-y += $(src-dir)

VPATH += $(dir-y)
inc-y += $(foreach x,$(dir-y),$(addprefix -I,$(x)))	
	
obj-y += $(patsubst %.c,$(obj-dir)/%.o,$(foreach x,$(dir-y),$(notdir $(wildcard $(addprefix $(x)/*,.c)))))		
obj-y += $(patsubst %.S,$(obj-dir)/%.o,$(foreach x,$(dir-y),$(notdir $(wildcard $(addprefix $(x)/*,.S)))))	
obj-y += $(patsubst %.s,$(obj-dir)/%.o,$(foreach x,$(dir-y),$(notdir $(wildcard $(addprefix $(x)/*,.s)))))	

#common rules	

$(obj-dir)/%.o:%.s
	@echo
	@echo "  >> AS $(notdir $<)"
	@$(AS) $(asflags-y) $(def-y) -o $@ $<
	
$(obj-dir)/%.o:%.c
	@echo
	@echo "  >> CC $(notdir $<)"
	@$(CC) $(cflags-y) $(inc-y) $(def-y) -o $@ $<	
	
.PHONY:all clean

$(obj-dir):
	@mkdir -p $(obj-dir)
	
$(exe-dir):
	@mkdir -p $(exe-dir)	

include $(wildcard $(obj-dir)/*.d)

exe:$(obj-dir) $(exe-dir) $(obj-y)
	@echo "  >> LD $(target-y).OUT"
	@$(LD) $(obj-y) $(ldflags-y) -o $(exe-dir)/$(target-y).out 
	@echo ">>>>>>>>>>>>>>>>>  BUILD $(exe-dir)/$(target-y)  DONE   <<<<<<<<<<<<<<<<<<<<<<"	
	
dll:$(obj-dir) $(exe-dir) $(obj-y)
	@echo "  >> LD $(target-y).DLL"
	@$(CC) -shared $(obj-y) $(ldflags-y) -o $(exe-dir)/$(target-y).dll 
	@echo ">>>>>>>>>>>>>>>>>  BUILD $(exe-dir)/$(target-y)  DONE   <<<<<<<<<<<<<<<<<<<<<<"

lib:$(obj-dir) $(exe-dir) $(obj-y)
	@echo "  >> LD $(target-y).LIB"
	@$(AR) -r $(exe-dir)/lib$(target-y).a $(obj-y)  
	@echo ">>>>>>>>>>>>>>>>>  BUILD $(exe-dir)/$(target-y)  DONE   <<<<<<<<<<<<<<<<<<<<<<"		

clean-obj:
	@rm -fv $(obj-dir)/*
	@rm -fv $(exe-dir)/*
	
clean-obj-src:clean-obj
	@rm -fv $(src-dir)/*
