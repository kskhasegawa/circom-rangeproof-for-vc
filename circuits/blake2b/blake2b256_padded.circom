pragma circom  2.0.0;

include "blake2bcompression.circom";

/* from RFC7693
FUNCTION BLAKE2( d[0..dd-1], ll, kk, nn )
Key and data input are split and padded into "dd" message blocks
d[0..dd-1], each consisting of 16 words (or "bb" bytes).

If a secret key is used (kk > 0), it is padded with zero bytes and
set as d[0].  Otherwise, d[0] is the first data block.  The final
data block d[dd-1] is also padded with zero to "bb" bytes (16 words).

The number of blocks is therefore dd = ceil(kk / bb) + ceil(ll / bb).
However, in the special case of an unkeyed empty message (kk = 0 and
ll = 0), we still set dd = 1 and d[0] consists of all zeros.

The following procedure processes the padded data blocks into an
"nn"-byte final hash value.

bb = 128(bytes)
Input bytes : ll
Key bytes   : kk = 0 (secret key is not used)
Hash bytes  : nn = 64 (Blake2b-256)
*/
//input : 1024bit padded message
template Blake2b256_padded(nBlocks) {
    var bits = 1024;
    var out_len = 256;
    signal input in[bits*nBlocks];
    signal input message_length;
    signal output out[out_len];
    var bb = 128;
    var i, j, k;
    var h[8][64];
    //h[0..7] := IV[0..7]
    for (i=1; i<8; i++) {
        h[i] = H(i);
    }
    //h[0] := h[0] ^ 0x01010000 ^ (kk << 8) ^ nn
    // h[0] = [0,0,0,1,0,0,1,0,1,0,0,1,0,0,1,1,1,0,1,1,1,1,0,1,0,1,0,0,1,1,1,1, //nn=64(output=512bit)
    //         1,1,1,0,0,1,1,0,0,1,1,0,0,1,1,1,1,0,0,1,0,0,0,0,0,1,0,1,0,1,1,0];
    h[0] = [0,0,0,1,0,1,0,0,1,0,0,1,0,0,1,1,1,0,1,1,1,1,0,1,0,1,0,0,1,1,1,1, //nn=32(output=256bit)
            1,1,1,0,0,1,1,0,0,1,1,0,0,1,1,1,1,0,0,1,0,0,0,0,0,1,0,1,0,1,1,0];


    component comp[nBlocks];
    for (i=0; i<nBlocks;i++) {
        comp[i] = Blake2bcompression();
    }
    var counter=0;
    var m_len = 0;
    if (nBlocks > 1) {
        for (counter=0; counter<nBlocks-1; counter++) {
            for (j=0; j<8; j++) {
                for (k=0; k<64; k++) {
                    if (counter==0) {
                        comp[counter].h[j][k] <== h[j][k];
                    }
                    else {
                        comp[counter].h[j][k] <== comp[counter-1].out[j][k];
                    }
                }
            }
            comp[counter].t <== (counter+1)*bb;
            comp[counter].f <== 0;
        }
        for (j=0; j<16; j++) {
            for (k=0; k<64; k++) {
                comp[counter].m[j][k] <== in[m_len];
                m_len++;
            }
            
        }
    }

    for (i=0; i<8; i++) {
        for (j=0; j<64; j++) {
            if (counter==0) {
                comp[counter].h[i][j] <== h[i][j];
            }
            else {
                comp[counter].h[i][j] <== comp[counter-1].out[i][j];
            }  
        }
    }
    for (j=0; j<16; j++) {
        for (k=0; k<64; k++) {
            comp[counter].m[j][k] <== in[m_len];
            m_len++;
        }
    }

    comp[counter].t <== message_length;
    comp[counter].f <== 1;

    for (j=0; j<out_len/64; j++) {
        for (k=0; k<8; k++) {
            out[64*j + 8*k] <== comp[counter].out[j][8*(k+1) - 1];
            out[64*j + 8*k + 1] <== comp[counter].out[j][8*(k+1) - 2];
            out[64*j + 8*k + 2] <== comp[counter].out[j][8*(k+1) - 3];
            out[64*j + 8*k + 3] <== comp[counter].out[j][8*(k+1) - 4];
            out[64*j + 8*k + 4] <== comp[counter].out[j][8*(k+1) - 5];
            out[64*j + 8*k + 5] <== comp[counter].out[j][8*(k+1) - 6];
            out[64*j + 8*k + 6] <== comp[counter].out[j][8*(k+1) - 7];
            out[64*j + 8*k + 7] <== comp[counter].out[j][8*(k+1) - 8];
        }
    }

    // log("output bit start");
    // for (i=0; i<8; i++) {
    //     log("i= ", i);
    //     for (j=0; j<512; j++) {
    //         //log(comp[counter].out[i][63-j]);
    //         log(out[511 - j]);
    //     }
    // }
    // log("output bit end");
    
}

component main = Blake2b256_padded(1);