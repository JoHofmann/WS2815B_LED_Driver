PROJECT=ws2815b_driver

GHDL_CMD=ghdl
GHDL_FLAGS=#--std=08
STOP_TIME=1000us

SYNTH_DIR=synth
SIM_DIR=sim

FILES = $(PROJECT)_rtl \
	pwmgen_rtl \
	memreadinterface_rtl \
	mem_rtl \
	spi_slave_rtl \
	memwriteinterface_rtl

TB_FILENAME = tb_$(PROJECT)
# TB_FILENAME = tb_memreadinterface
# TB_FILENAME = tb_transmission
# TB_FILENAME = tb_recieving

PCF_FILE = pinmap

ICELINK_DIR=$(shell df | grep iCELink | awk '{print $$6}')
${warning iCELink path: $(ICELINK_DIR)}

build:
	@for f in $(FILES); do \
		$(GHDL_CMD) -a $(GHDL_FLAGS) src/$$f.vhd; \
	done

	yosys -p 'ghdl $(PROJECT); synth_ice40 -json $(SYNTH_DIR)/$(PROJECT).json'
	nextpnr-ice40 --debug --lp1k --package cm36 --json $(SYNTH_DIR)/$(PROJECT).json --pcf $(SYNTH_DIR)/$(PCF_FILE).pcf --asc $(SYNTH_DIR)/$(PROJECT).asc --freq 48
	icepack $(SYNTH_DIR)/$(PROJECT).asc $(SYNTH_DIR)/$(PROJECT).bin

prog_flash:
	@if [ -d '$(ICELINK_DIR)' ]; \
        then \
            cp $(SYNTH_DIR)/$(PROJECT).bin $(ICELINK_DIR); \
        else \
            echo "iCELink not found"; \
            exit 1; \
    fi

.PHONY: sim
sim:
	@mkdir -p $(SIM_DIR)

	@$(GHDL_CMD) -a $(GHDL_FLAGS) src/testbenches/$(TB_FILENAME).vhd
	@for f in $(FILES); do \
		$(GHDL_CMD) -a $(GHDL_FLAGS) src/$$f.vhd; \
	done

	@$(GHDL_CMD) -e $(GHDL_FLAGS) $(TB_FILENAME)
	@$(GHDL_CMD) -r $(GHDL_FLAGS) $(TB_FILENAME) --vcd=$(SIM_DIR)/$(PROJECT).vcd --wave=$(SIM_DIR)/$(PROJECT).ghw --stop-time=$(STOP_TIME)
	
	gtkwave $(SIM_DIR)/wave.ghw

show:
	@for f in $(FILES); do \
		$(GHDL_CMD) -a $(GHDL_FLAGS) src/$$f.vhd; \
	done
	yosys -p 'ghdl $(PROJECT); synth_ice40 -json $(SYNTH_DIR)/$(PROJECT).json; show'	

clean:
	rm $(SYNTH_DIR)/$(PROJECT).asc $(SYNTH_DIR)/$(PROJECT).bin *.cf
