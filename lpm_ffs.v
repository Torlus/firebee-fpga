module lpm_ff0(
	clock,
	data,
	enable,
	q
);
input clock;
input [31:0] data;
input enable;
output [31:0] q;

reg [31:0] r_q = 32'd0;

assign q = r_q;

always @(posedge clock) begin
	if (enable) begin
		r_q <= data;
	end
end
endmodule

////////////////////////////////////////////////////////////////////////////////

module lpm_ff1(
	clock,
	data,
	q
);
input clock;
input [31:0] data;
output [31:0] q;

reg [31:0] r_q = 32'd0;

assign q = r_q;

always @(posedge clock) begin
	r_q <= data;
end
endmodule

////////////////////////////////////////////////////////////////////////////////

module lpm_ff2(
	clock,
	data,
	q
);
input clock;
input [127:0] data;
output [127:0] q;

reg [127:0] r_q = 128'd0;

assign q = r_q;

always @(posedge clock) begin
	r_q <= data;
end
endmodule

////////////////////////////////////////////////////////////////////////////////

module lpm_ff3(
	clock,
	data,
	q
);
input clock;
input [23:0] data;
output [23:0] q;

reg [23:0] r_q = 24'd0;

assign q = r_q;

always @(posedge clock) begin
	r_q <= data;
end
endmodule

////////////////////////////////////////////////////////////////////////////////

module lpm_ff4(
	clock,
	data,
	q
);
input clock;
input [15:0] data;
output [15:0] q;

reg [15:0] r_q = 16'd0;

assign q = r_q;

always @(posedge clock) begin
	r_q <= data;
end
endmodule

////////////////////////////////////////////////////////////////////////////////

module lpm_ff5(
	clock,
	data,
	q
);
input clock;
input [7:0] data;
output [7:0] q;

reg [7:0] r_q = 8'd0;

assign q = r_q;

always @(posedge clock) begin
	r_q <= data;
end
endmodule

////////////////////////////////////////////////////////////////////////////////

module lpm_ff6(
	clock,
	data,
	enable,
	q
);
input clock;
input [127:0] data;
input enable;
output [127:0] q;

reg [127:0] r_q = 128'd0;

assign q = r_q;

always @(posedge clock) begin
	if (enable) begin
		r_q <= data;
	end
end
endmodule
