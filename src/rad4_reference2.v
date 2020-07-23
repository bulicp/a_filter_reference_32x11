/*
  rad4_reference       -> Exact rad-4 multiplier 
                       -> with all partial product2s  

*/
module rad4_reference2(
    input [31:0] x,
    input [10:0] y,
    output [31:0] p
    );

    wire [5:0] sign_factor;
    wire [32:0] PP_5;
    wire [32:0] PP_4;
    wire [32:0] PP_3;
    wire [32:0] PP_2;
    wire [32:0] PP_1;
    wire [32:0] PP_0;
    wire [2:0] tmp1;
    wire [2:0] tmp0;

    assign tmp1 = {y[10],y[10:9]}; 
    assign tmp0 = {y[1:0],1'b0};

// Calculates PP_2 
    rad4_BE2 PP5_gen(
        .x1(tmp1),
        .y(x),
        .sign_factor(sign_factor[5]),
        .PP(PP_5)
        );
// Calculates PP_2 
    rad4_BE2 PP4_gen(
        .x1(y[9:7]),
        .y(x),
        .sign_factor(sign_factor[4]),
        .PP(PP_4)
        );
// Calculates PP_2 
    rad4_BE2 PP3_gen(
        .x1(y[7:5]),
        .y(x),
        .sign_factor(sign_factor[3]),
        .PP(PP_3)
        );
// Calculates PP_2 
    rad4_BE2 PP2_gen(
        .x1(y[5:3]),
        .y(x),
        .sign_factor(sign_factor[2]),
        .PP(PP_2)
        );
// Calculates PP_1
    rad4_BE2 PP1_gen(
        .x1(y[3:1]),
        .y(x),
        .sign_factor(sign_factor[1]),
        .PP(PP_1)
        );

// Calculates PP_1
    rad4_BE2 PP0_gen(
        .x1(tmp0),
        .y(x),
        .sign_factor(sign_factor[0]),
        .PP(PP_0)
        );

// Partial product2 addition 

    PP_add2 Final(
        .sign_factor(sign_factor),
        .PP_5(PP_5),
        .PP_4(PP_4),
        .PP_3(PP_3),
        .PP_2(PP_2),
        .PP_1(PP_1),
        .PP_0(PP_0),
        .p(p)
        );
        
endmodule



module rad4_BE2(
    input [2:0] x1,
    input [31:0] y,
    output sign_factor,
    output [32:0] PP
    );
    
    // encode2 
    wire one, two, sign;
    
    code2 encode2_block(
        .one(one),
        .two(two),
        .sign(sign),
        .y2(x1[2]),
        .y1(x1[1]),
        .y0(x1[0])
        );
        
    // generation of PP
    wire [32:0] tmp1_pp; 
    assign tmp1_pp = {y[31],y}; // This variable is introduced because pp has 33 bits
    
    wire [33:0] out1;
    assign out1[0] = sign;
    
    genvar i;
    generate
        for ( i = 0; i < 33; i = i+1 )
            begin : pp_rad4_first 
            product2 pp_pr(tmp1_pp[i],out1[i],one,two,sign,PP[i],out1[i+1]);
            end
    endgenerate
    
    //sign factor generate
    assign sign_factor = sign;

endmodule

module code2(one,two,sign,y2,y1,y0);  
	input y2,y1,y0;                     
	output one,two,sign;                
	wire [1:0]k;                        
	xor x1(one,y0,y1);                  
	xor x2(k[1],y2,y1);                 
	not n1(k[0],one);                   
	and a1(two,k[0],k[1]);              
	assign sign=y2;                     
endmodule   

module product2(x1,x0,one,two,sign,p,i);
	input x1,x0,sign,one,two;
	output p,i;
	wire [1:0] k;
	xor xo1(i,x1,sign);
	and a1(k[1],i,one);
	and a0(k[0],x0,two);
	or o1(p,k[1],k[0]);
endmodule


module PP_add2(
    input [5:0] sign_factor,
    input [32:0] PP_5,
    input [32:0] PP_4,
    input [32:0] PP_3,
    input [32:0] PP_2,
    input [32:0] PP_1,
    input [32:0] PP_0,
    output [31:0] p
    );
    
    
    // generate negative MSBs
    wire [5:0] E_MSB;
    assign E_MSB[0] = ~ PP_0[32];
    assign E_MSB[1] = ~ PP_1[32];
    assign E_MSB[2] = ~ PP_2[32];
    assign E_MSB[3] = ~ PP_3[32];
    assign E_MSB[4] = ~ PP_4[32];
    assign E_MSB[5] = ~ PP_5[32];


    // First  reduction
    
    // First group
    wire [33:0] sum00_FA;
    wire [33:0] carry00_FA;
  

    wire [33:0] tmp001_FA;
    wire [33:0] tmp002_FA;
    wire [33:0] tmp003_FA;

    assign tmp001_FA = {E_MSB[0],{3{PP_0[32]}},PP_0[32:4],PP_0[2]};
    assign tmp002_FA = {E_MSB[1],PP_1[32],PP_1[32:2],PP_1[0]};
    assign tmp003_FA = {PP_2,sign_factor[1]};

    genvar i001;
    generate
        for (i001 = 0; i001 < 34; i001 = i001 + 1)
            begin : pp_FAd200
            FAd2 pp_FAd2(tmp001_FA[i001],tmp002_FA[i001], tmp003_FA[i001], carry00_FA[i001],sum00_FA[i001]);
            end
    endgenerate


    wire [1:0] sum00_HA;
    wire [1:0] carry00_HA;

    wire [1:0] tmp001_HA;
    wire [1:0] tmp002_HA;

    assign tmp001_HA = {1'b1,PP_0[3]};
    assign tmp002_HA = {PP_2[32],PP_1[1]};


    genvar i002;
    generate
        for (i002 = 0; i002 < 2; i002 = i002 + 1)
            begin : pp_HAd200
            HAd2 pp_HAd2(tmp001_HA[i002],tmp002_HA[i002],carry00_HA[i002],sum00_HA[i002]);
            end
    endgenerate

    // Second group
    wire [32:0] sum01_FA;
    wire [32:0] carry01_FA;
  

    wire [32:0] tmp011_FA;
    wire [32:0] tmp012_FA;
    wire [32:0] tmp013_FA;

    assign tmp011_FA = {1'b1,E_MSB[3],PP_3[32],PP_3[32:4],PP_3[2]};
    assign tmp012_FA = {PP_4[32],PP_4[32:2],PP_4[0]};
    assign tmp013_FA = {PP_5[31:0],sign_factor[4]};

    genvar i011;
    generate
        for (i011 = 0; i011 < 33; i011 = i011 + 1)
            begin : pp_FAd201
            FAd2 pp_FAd2(tmp011_FA[i011],tmp012_FA[i011], tmp013_FA[i011], carry01_FA[i011],sum01_FA[i011]);
            end
    endgenerate

    wire [1:0] sum01_HA;
    wire [1:0] carry01_HA;

    wire [1:0] tmp011_HA;
    wire [1:0] tmp012_HA;

    assign tmp011_HA = {E_MSB[4],PP_3[3]};
    assign tmp012_HA = {PP_5[32],PP_4[1]};

    
    
    genvar i012;
    generate
        for (i012 = 0; i012 < 2; i012 = i012 + 1)
            begin : pp_HAd201
            HAd2 pp_HAd2(tmp011_HA[i012],tmp012_HA[i012],carry01_HA[i012],sum01_HA[i012]);
            end
    endgenerate

    // Second reduction
        
    wire [33:0] sum10_FA;
    wire [33:0] carry10_FA;
  

    wire [33:0] tmp101_FA;
    wire [33:0] tmp102_FA;
    wire [33:0] tmp103_FA;

    assign tmp101_FA = {E_MSB[2],sum00_HA[1],sum00_FA[33:3],sum00_FA[1]};
    assign tmp102_FA = {carry00_HA[1],carry00_FA[33:2],carry00_HA[0]};
    assign tmp103_FA = {sum01_FA[29:1],sum01_HA[0],sum01_FA[0],PP_3[1:0],sign_factor[2]};

    genvar i010;
    generate
        for (i010 = 0; i010 < 34; i010 = i010 + 1)
            begin : pp_FAd210
            FAd2 pp_FAd2(tmp101_FA[i010],tmp102_FA[i010], tmp103_FA[i010], carry10_FA[i010],sum10_FA[i010]);
            end
    endgenerate

    wire [1:0] sum10_HA;
    wire [1:0] carry10_HA;

    wire [1:0] tmp101_HA;
    wire [1:0] tmp102_HA;

    assign tmp101_HA = {1'b1,sum00_FA[2]};
    assign tmp102_HA = {sum01_FA[30],carry00_FA[1]};

    
    
    genvar i013;
    generate
        for (i013 = 0; i013 < 2; i013 = i013 + 1)
            begin : pp_HAd211
            HAd2 pp_HAd2(tmp101_HA[i013],tmp102_HA[i013],carry10_HA[i013],sum10_HA[i013]);
            end
    endgenerate

    // Third reduction

    wire [32:0] sum20_FA;
    wire [32:0] carry20_FA;
  

    wire [32:0] tmp201_FA;
    wire [32:0] tmp202_FA;
    wire [32:0] tmp203_FA;

    assign tmp201_FA = {carry10_HA[1],sum10_HA[1],sum10_FA[33:4],sum10_FA[1]};
    assign tmp202_FA = {sum01_FA[31],carry10_FA[33:3],carry10_HA[0]};
    assign tmp203_FA = {carry01_FA[30:1],carry01_HA[0],carry01_FA[0],sign_factor[3]};

    genvar i020;
    generate
        for (i020 = 0; i020 < 33; i020 = i020 + 1)
            begin : pp_FAd220
            FAd2 pp_FAd2(tmp201_FA[i020],tmp202_FA[i020], tmp203_FA[i020], carry20_FA[i020],sum20_FA[i020]);
            end
    endgenerate

    wire [3:0] sum20_HA;
    wire [3:0] carry20_HA;

    wire [3:0] tmp201_HA;
    wire [3:0] tmp202_HA;

    assign tmp201_HA = {sum01_HA[1],sum01_FA[32],sum10_FA[3:2]};
    assign tmp202_HA = {carry01_FA[32:31],carry10_FA[2:1]};

    genvar i021;
    generate
        for (i021 = 0; i021 < 4; i021 = i021 + 1)
            begin : pp_HAd221
            HAd2 pp_HAd2(tmp201_HA[i021],tmp202_HA[i021],carry20_HA[i021],sum20_HA[i021]);
            end
    endgenerate

 
    // Fourth reduction

    wire  sum30_FA;
    wire  carry30_FA;
    
    FAd2 pp_FAd2(sum20_FA[2],carry20_FA[1], sign_factor[5], carry30_FA,sum30_FA);

    wire [32:0] sum30_HA;
    wire [32:0] carry30_HA;

    wire [32:0] tmp301_HA;
    wire [32:0] tmp302_HA;

    assign tmp301_HA = {carry01_HA[1],sum20_HA[3:2],sum20_FA[32:3]};
    assign tmp302_HA = {carry20_HA[3:2],carry20_FA[32:2]};

    genvar i031;
    generate
        for (i031 = 0; i031 < 33; i031 = i031 + 1)
            begin : pp_HAd231
            HAd2 pp_HAd2(tmp301_HA[i031],tmp302_HA[i031],carry30_HA[i031],sum30_HA[i031]);
            end
    endgenerate
    
    
    //Final addition



    wire [44:0] tmp_sum;
    wire [44:0] tmp_add1;
    wire [44:0] tmp_add2;

    assign tmp_add1 = {1'b0,sum30_HA,sum30_FA,sum20_FA[1],sum20_HA[1:0],sum20_FA[0],sum10_HA[0],sum10_FA[0],sum00_HA[0],sum00_FA[0],PP_0[1:0]};
    assign tmp_add2 = {carry30_HA,carry30_FA,1'b0,carry20_HA[1:0],carry20_FA[0],1'b0,carry10_FA[0],1'b0,carry00_FA[0],2'b0,sign_factor[0]}; 

    assign tmp_sum = tmp_add1 + tmp_add2;

    assign p = tmp_sum[41:10];

endmodule


module FAd2(a,b,c,cy,sm);
	input a,b,c;
	output cy,sm;
	wire x,y,z;
	xor x1(x,a,b);
	xor x2(sm,x,c);
	and a1(y,a,b);
	and a2(z,x,c);
	or o1(cy,y,z);
endmodule 

module HAd2(a,b,cy,sm);
	input a,b;
	output cy,sm;
	xor x1(sm,a,b);
	and a1(cy,a,b);
endmodule 