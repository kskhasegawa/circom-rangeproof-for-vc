pragma circom 2.0.3;

include "bigint.circom";
include "bls12-381_params.circom";
include "bigint_binary_function.circom";

//input : 384bit blake2b hash value
//output: 256bit field element mod p
template Hash_to_Fr() {//n=8, k=32固定
    signal input a[384];

    signal output out[256];
    
    var p[8] = Prime_field_modulus();
    var f_2_192[8] = F_2_192();

    signal a_new[12];
    component b2n[12];
    for (var i=0; i<12; i++) {
        b2n[i] = Bits2Num(32);
    }
    for (var i=0; i<32; i++) {
        b2n[11].in[i] <== a[32-1-i];
        b2n[10].in[i] <== a[32*2-1-i];
        b2n[9].in[i] <== a[32*3-1-i];
        b2n[8].in[i] <== a[32*4-1-i];
        b2n[7].in[i] <== a[32*5-1-i];
        b2n[6].in[i] <== a[32*6-1-i];
        b2n[5].in[i] <== a[32*7-1-i];
        b2n[4].in[i] <== a[32*8-1-i];
        b2n[3].in[i] <== a[32*9-1-i];
        b2n[2].in[i] <== a[32*10-1-i];
        b2n[1].in[i] <== a[32*11-1-i];
        b2n[0].in[i] <== a[32*12-1-i];
    }

    // log("-------------------");
    // for(var i=0; i<12; i++) {
    //     log("b2n[",i,"] is");
    //     log(b2n[i].out);
    // }
    // log("-------------------");

    a_new[0] <== b2n[0].out;
    a_new[1] <== b2n[1].out;
    a_new[2] <== b2n[2].out;
    a_new[3] <== b2n[3].out;
    a_new[4] <== b2n[4].out;
    a_new[5] <== b2n[5].out;
    a_new[6] <== b2n[6].out;
    a_new[7] <== b2n[7].out;
    a_new[8] <== b2n[8].out;
    a_new[9] <== b2n[9].out;
    a_new[10] <== b2n[10].out;
    a_new[11] <== b2n[11].out;

    component multmodp = BigMultModP(32, 8);
    for (var i=0; i<8; i++) {
        if (i < 4) {
            multmodp.a[i] <== a_new[i+8];
        }
        else {
            multmodp.a[i] <== 0;
        }
        multmodp.b[i] <== f_2_192[i];
        multmodp.p[i] <== p[i];
    }
    // for (var i=0; i<8; i++) {
    //     if (i < 6) {
    //         multmodp.a[i] <== a_new[i+6];
    //     }
    //     else {
    //         multmodp.a[i] <== 0;
    //     }
    //     multmodp.b[i] <== f_2_192[i];
    //     multmodp.p[i] <== p[i];
    // }
    
    component add = BigAdd(32, 8);
    for (var i=0; i<8; i++) {
        add.a[i] <== a_new[i];
        add.b[i] <== multmodp.out[i];        
    }
    // for (var i=0; i<8; i++) {
    //     if (i < 6) {
    //         add.a[i] <== a_new[i];
    //     }
    //     else {
    //         add.a[i] <== 0;
    //     }
    //     add.b[i] <== multmodp.out[i];        
    // }

    component mod = BigMod(32, 8);
    for (var i=0; i<8; i++) {
        mod.a[i] <== add.out[i];
        mod.a[8+i] <== 0;
        mod.b[i] <== p[i];        
    }

    // log("-------------------");
    // for(var i=0; i<8; i++) {
    //     log("mod.out[",i,"].out is");
    //     log(mod.mod[i]);
    // }
    // log("-------------------");

    component bint2bin = Bigint2Binary(32, 8);
    for (var i=0; i<8; i++) {
        bint2bin.in[i] <== mod.mod[i];
    }
    for (var i=0; i<256; i++) {
        out[i] <== bint2bin.out[i];
    }

}

// component main = Hash_to_Fr();