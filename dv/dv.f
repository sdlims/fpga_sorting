dv/tb.sv
dv/icebreak_runner.sv

--timing
-j 0
-Wall
-Wno-fatal
--assert
--trace-fst
--trace-structs
--main-top-name "-"

// Run with +verilator+rand+reset+2
--x-assign unique
--x-initial unique

-Werror-IMPLICIT
-Werror-USERERROR
-Werror-LATCH