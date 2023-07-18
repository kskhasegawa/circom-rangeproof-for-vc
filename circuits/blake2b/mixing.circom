pragma circom  2.0.0;

include "../../node_modules/circomlib/circuits/bitify.circom";
include "../../node_modules/circomlib/circuits/binsum.circom";
include "../../node_modules/circomlib/circuits/gates.circom";
include "rotate.circom";


template G(a, b, c, d) {
    signal input v[16][64];
    signal input x[64];
    signal input y[64];
    var R1 = 32;
    var R2 = 24;
    var R3 = 16;
    var R4 = 63;

    signal output out[16][64];

    var i, j;
    for (i=0; i<16; i++) {
        if (i!=a && i!=b && i!=c && i!=d) {
            for (var j=0; j<64; j++) {
                out[i][j] <== v[i][j];
            }
        }
    }

    component sum[4];
    for (i=0; i<4; i++) {
        if (i==0 || i==2) {
            sum[i] = BinSum(64, 3);
        }
        else {
            sum[i] = BinSum(64, 2);
        }
    }
    component xor[4][64];
    for (i=0; i<4; i++) {
        for (j=0; j<64; j++) {
            xor[i][j] = XOR();
        }
    }

    component rotater[4];
    rotater[0] = RotR(64, R1);
    rotater[1] = RotR(64, R2);
    rotater[2] = RotR(64, R3);
    rotater[3] = RotR(64, R4);

    signal vaprime[2][64];
    signal vbprime[2][64];
    signal vcprime[2][64];
    signal vdprime[2][64];

    //v[a] := (v[a] + v[b] + x) mod 2**w
    for (i=0; i<64; i++) {
        sum[0].in[0][i] <-- v[a][i];
        sum[0].in[1][i] <-- v[b][i];
        sum[0].in[2][i] <-- x[i];
    }
    for (i=0; i<64; i++) {
        vaprime[0][i] <== sum[0].out[i];
    }


    //v[d] := (v[d] ^ v[a]) >>> R1
    for (i=0; i<64; i++) {
        xor[0][i].a <== v[d][i];
        xor[0][i].b <== vaprime[0][i];
    }
    for (i=0; i<64; i++) {
        rotater[0].in[i] <== xor[0][i].out;
    }
    for (i=0; i<64; i++) {
        vdprime[0][i] <== rotater[0].out[i];
    }

    //v[c] := (v[c] + v[d])     mod 2**w
    for (i=0; i<64; i++) {
        sum[1].in[0][i] <== v[c][i];
        sum[1].in[1][i] <== vdprime[0][i];
    }
    for (i=0; i<64; i++) {
        vcprime[0][i] <== sum[1].out[i];
    }

    //v[b] := (v[b] ^ v[c]) >>> R2
    for (i=0; i<64; i++) {
        xor[1][i].a <== v[b][i];
        xor[1][i].b <== vcprime[0][i];
    }
    for (i=0; i<64; i++) {
        rotater[1].in[i] <== xor[1][i].out;
    }
    for (i=0; i<64; i++) {
        vbprime[0][i] <== rotater[1].out[i];
    }

    //v[a] := (v[a] + v[b] + y) mod 2**w
    for (i=0; i<64; i++) {
        sum[2].in[0][i] <== vaprime[0][i];
        sum[2].in[1][i] <== vbprime[0][i];
        sum[2].in[2][i] <-- y[i];
    }
    for (i=0; i<64; i++) {
        vaprime[1][i] <== sum[2].out[i];
    }

    //v[d] := (v[d] ^ v[a]) >>> R3
    for (i=0; i<64; i++) {
        xor[2][i].a <== vdprime[0][i];
        xor[2][i].b <== vaprime[1][i];
    }
    for (i=0; i<64; i++) {
        rotater[2].in[i] <== xor[2][i].out;
    }
    for (i=0; i<64; i++) {
        vdprime[1][i] <== rotater[2].out[i];
    }

    //v[c] := (v[c] + v[d])     mod 2**w
    for (i=0; i<64; i++) {
        sum[3].in[0][i] <== vcprime[0][i];
        sum[3].in[1][i] <== vdprime[1][i];
    }
    for (i=0; i<64; i++) {
        vcprime[1][i] <== sum[3].out[i];
    }

    //v[b] := (v[b] ^ v[c]) >>> R4
    for (i=0; i<64; i++) {
        xor[3][i].a <== vbprime[0][i];
        xor[3][i].b <== vcprime[1][i];
    }
    for (i=0; i<64; i++) {
        rotater[3].in[i] <== xor[3][i].out;
    }
    for (i=0; i<64; i++) {
        vbprime[1][i] <== rotater[3].out[i];
    }

    for (i=0; i<64; i++) {
        out[a][i] <== vaprime[1][i];
        out[b][i] <== vbprime[1][i];
        out[c][i] <== vcprime[1][i];
        out[d][i] <== vdprime[1][i];
    }
    
    // for(i=0; i<64; i++) {
    //     log(vaprime[1][63-i]);
    // }
}
// component main = G(0, 4, 8, 12);