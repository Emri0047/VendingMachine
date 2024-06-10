// `timescale 1ms/10ps
module tbE;

task testVending ()


endtask



initial begin
    $dumpfile("sim.vcd");
    $dumpvars(0, tbE);

#200;    
$finish;
end

endmodule