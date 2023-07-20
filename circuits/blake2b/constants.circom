/**
 * constants.circom
 * @Package circom_range_proof_for_vc
 * @author ZKSHT
 * @copyright 2023 ZKSHT. All rights reserved.
 * @license GPL-v3.0
 */


pragma circom  2.0.0;

//initialization vector for BLAKE2b
function H(x) {
    //signal output out[64];
    // signal output out;
    var out[64];
    var c[8] = [0x6A09E667F3BCC908,
             0xBB67AE8584CAA73B,
             0x3C6EF372FE94F82B,
             0xA54FF53A5F1D36F1,
             0x510E527FADE682D1,
             0x9B05688C2B3E6C1F,
             0x1F83D9ABFB41BD6B,
             0x5BE0CD19137E2179];

    for (var i=0; i<64; i++) {
        out[i] = (c[x] >> i) & 1;
    }

    return out;
}

//parameter block
template P(x) {
    signal output out[32];
    var c[8] = [0x01010040,//unkeyed hashing, and hash size is 64bytes
                0x00000000,
                0x00000000,
                0x00000000,
                0x00000000,
                0x00000000,
                0x00000000,
                0x00000000];

    for (var i=0; i<32; i++) {
        out[i] <== (c[x] >> i) & 1;
    }
}

//G rotation constants
template RotConst(x) {
    signal output out;
    var c[4] = [32, 24, 16, 63];//R1, R2, R3, R4

    out <== c[x];
}

//message word schedule permutations, SIGMA
function Sigma(x) {
    // signal output out[16];
    var out[16];
    var c[12][16] = [[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15],
                     [14, 10, 4, 8, 9, 15, 13, 6, 1, 12, 0, 2, 11, 7, 5, 3],
                     [11, 8, 12, 0, 5, 2, 15, 13, 10, 14, 3, 6, 7, 1, 9, 4],
                     [7, 9, 3, 1, 13, 12, 11, 14, 2, 6, 5, 10, 4, 0, 15, 8],
                     [9, 0, 5, 7, 2, 4, 10, 15, 14, 1, 11, 12, 6, 8, 3, 13],
                     [2, 12, 6, 10, 0, 11, 8, 3, 4, 13, 7, 5, 15, 14, 1, 9],
                     [12, 5, 1, 15, 14, 13, 4, 10, 0, 7, 6, 3, 9, 2, 8, 11],
                     [13, 11, 7, 14, 12, 1, 3, 9, 5, 0, 15, 4, 8, 6, 2, 10],
                     [6, 15, 14, 9, 11, 3, 0, 8, 12, 2, 13, 7, 1, 4, 10, 5],
                     [10, 2, 8, 4, 7, 6, 1, 5, 15, 11, 9, 14, 3, 12, 13, 0],
                     [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15],
                     [14, 10, 4, 8, 9, 15, 13, 6, 1, 12, 0, 2, 11, 7, 5, 3]
    ];

    for (var i=0; i<16; i++) {
        out[i] = c[x][i];
    }
    return out;
}
