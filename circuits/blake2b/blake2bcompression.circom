/**
 * blake2b256compression.circom
 * @Package circom_range_proof_for_vc
 * @author ZKSHT
 * @copyright 2023 ZKSHT. All rights reserved.
 * @license GPL-v3.0
 */


pragma circom  2.0.0;

include "constants.circom";
include "mixing.circom";

template Blake2bcompression() {
    signal input h[8][64];
    signal input m[16][64];
    signal input t;//2*w bit offset counter
    signal input f;//final block indicator
    signal output out[8][64];

    var i, j;

    signal v[16][64];
    component b2n[3];
    component n2b[3];
    for (i=0; i<3; i++) {
        b2n[i] = Bits2Num(64);
        n2b[i] = Num2Bits(64);
    }
    var temp;
    for (i=0; i<8; i++) {
        for (j=0; j<64; j++) {
            v[i][j] <== h[i][j];
        }
    }
    for (i=8; i<16; i++) {
        var iv[64] = H(i-8);

        if (i!=12 && i!= 13 && i!=14) {
            for (j=0; j<64; j++) {
                v[i][j] <== iv[j];//IV
            }
        }
        else if (i==12) {//v[i][j] <-- iv[j] ^ (t % (2**64));
            for (j=0; j<64; j++) {
                b2n[0].in[j] <== iv[j];
            }
            temp = b2n[0].out ^ (t % (2**64));
            n2b[0].in <-- temp;
            for (j=0; j<64; j++) {
                v[i][j] <== n2b[0].out[j]; 
            }
        }

        else if (i==13) {//v[13] <-- H(5) ^ (t >> 64);
            for (j=0; j<64; j++) {
                b2n[1].in[j] <== iv[j];
            }
            temp = b2n[1].out ^ (t >> 64);
            n2b[1].in <-- temp;
            for (j=0; j<64; j++) {
                v[i][j] <== n2b[1].out[j]; 
            }  

        }
        else {//i==14 v[14] <-- H(6) ^ (0xFFFFFFFFFFFFFFFF & (f*0xFFFFFFFFFFFFFFFF));
            for (j=0; j<64; j++) {
                b2n[2].in[j] <== iv[j];
            }
            temp = b2n[2].out ^ (0xFFFFFFFFFFFFFFFF & (f*0xFFFFFFFFFFFFFFFF));
            n2b[2].in <-- temp;
            for (j=0; j<64; j++) {
                v[i][j] <== n2b[2].out[j]; 
            }  
        }
    }

    var sigma[12][16];
    component g[12][8];
    for (i=0; i<12; i++) {
        sigma[i] = Sigma(i);

        g[i][0] = G(0, 4, 8, 12);
        g[i][1] = G(1, 5, 9, 13);
        g[i][2] = G(2, 6, 10, 14);
        g[i][3] = G(3, 7, 11, 15);
        g[i][4] = G(0, 5, 10, 15);
        g[i][5] = G(1, 6, 11, 12);
        g[i][6] = G(2, 7, 8, 13);
        g[i][7] = G(3, 4, 9, 14);
        
        var j, k, l;
        for (j=0; j<8; j++) {
            for (k=0; k<16; k++) {
                for (l=0; l<64; l++) {
                    if (i==0 && j==0) {
                        g[0][0].v[k][l] <== v[k][l];
                    }
                    else if (j==0) {
                        g[i][0].v[k][l] <== g[i-1][7].out[k][l];
                    }
                    else {
                        g[i][j].v[k][l] <== g[i][j-1].out[k][l];
                    }
                }
            }
            for (var k=0; k<64; k++) {
                    g[i][j].x[k] <== m[sigma[i][2*j]][k];
                    g[i][j].y[k] <== m[sigma[i][2*j+1]][k];
            }
        }
    }

    for (i=0; i<8; i++) {
        for (j=0; j<64; j++) {
            out[i][j] <-- h[i][j] ^ g[11][7].out[i][j] ^ g[11][7].out[i+8][j];
        }
    }

    // log("---------------------");
    // for(i=0; i<64; i++) {
    //     //log(g[11][7].out[0][63-i]);
    //     log(out[7][63-i]);
    // }
    // log("--------------------");


}

// component main = Blake2bcompression();
/*
proof.input = {
    "h": [0x6A09E667F3BCC908,
            0xBB67AE8584CAA73B,
            0x3C6EF372FE94F82B,
            0xA54FF53A5F1D36F1,
            0x510E527FADE682D1,
            0x9B05688C2B3E6C1F,
            0x1F83D9ABFB41BD6B,
            0x5BE0CD19137E2179],
    "m": [636261, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    "t": 0,
    "f": 0
}
*/
