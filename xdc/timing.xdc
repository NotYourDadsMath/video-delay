set_false_path \
    -from [get_pins {the_pattern_selector/pattern_reg[*]/C}] \
    -to [get_pins {the_dvi_driver/pattern_sync_reg[0][*]/D}]

set_false_path \
    -from [get_pins the_dvi_driver/tick_reg/C] \
    -to [get_pins {the_timer/the_send_synchronizer/signal_sync_reg[0]/D}]

set_false_path \
    -from [get_pins the_timer/enable_reg/C] \
    -to [get_pins {the_dvi_driver/the_enable_synchronizer/signal_sync_reg[0]/D}]
