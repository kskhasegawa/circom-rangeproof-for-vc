/**
 * copareDate.circom
 * @Package circom_range_proof_for_vc
 * @author ZKSHT
 * @copyright 2023 ZKSHT. All rights reserved.
 * @license GPL-v3.0
 */


pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/bitify.circom";
include "../node_modules/circomlib/circuits/comparators.circom";
include "../node_modules/circomlib/circuits/gates.circom";


/*
    input：①utf-8 date("yyyy-mm-dd") binary(80bit) + ②target date(yyyy, mm, dd)
    output：1 iff ① < ②
*/

template Utf2Num(n) {
    signal input in[8*n];
    signal output out;

    var zero = 48;//00110000

    var i;
    var j;
    component b2n[n];
    for (i=0; i<n; i++) {
        b2n[i] = Bits2Num(8);
    }

    for (i=0; i<n; i++) {
        for (j=0; j<8; j++) {
            b2n[i].in[j] <== in[8*i+7-j];
        }
    }

    var result = 0;
    var value;
    for (i=0; i<n; i++) {
        value = b2n[i].out -zero;
        result += value * (10**(n-i-1)); 
    }

    out <== result;

}

template CompareDate() {//return 1 iff in > target
    //e.g. 1958-07-17 = 00110001 00111001 00110111 00110001 00101101 00110000 00110011 00101101 00110010 00110000
    
    signal input in[80];//80bit input
    signal input target[3];//target date scalar(year, month, day)
    signal output out;//scalar

    component u2n[3];
    u2n[0] = Utf2Num(4);//year
    u2n[1] = Utf2Num(2);//month
    u2n[2] = Utf2Num(2);//day

    var i;
    for (i=0; i<4; i++) {
        u2n[0].in[8*i] <== in[8*(i+1)-1];
        u2n[0].in[8*i+1] <== in[8*(i+1)-2];
        u2n[0].in[8*i+2] <== in[8*(i+1)-3];
        u2n[0].in[8*i+3] <== in[8*(i+1)-4];
        u2n[0].in[8*i+4] <== in[8*(i+1)-5];
        u2n[0].in[8*i+5] <== in[8*(i+1)-6];
        u2n[0].in[8*i+6] <== in[8*(i+1)-7];
        u2n[0].in[8*i+7] <== in[8*(i+1)-8];
    }
    for (i=0; i<2; i++) {
        u2n[1].in[8*i] <== in[40+8*(i+1)-1];
        u2n[1].in[8*i+1] <== in[40+8*(i+1)-2];
        u2n[1].in[8*i+2] <== in[40+8*(i+1)-3];
        u2n[1].in[8*i+3] <== in[40+8*(i+1)-4];
        u2n[1].in[8*i+4] <== in[40+8*(i+1)-5];
        u2n[1].in[8*i+5] <== in[40+8*(i+1)-6];
        u2n[1].in[8*i+6] <== in[40+8*(i+1)-7];
        u2n[1].in[8*i+7] <== in[40+8*(i+1)-8];

        u2n[2].in[8*i] <== in[64+8*(i+1)-1];
        u2n[2].in[8*i+1] <== in[64+8*(i+1)-2];
        u2n[2].in[8*i+2] <== in[64+8*(i+1)-3];
        u2n[2].in[8*i+3] <== in[64+8*(i+1)-4];
        u2n[2].in[8*i+4] <== in[64+8*(i+1)-5];
        u2n[2].in[8*i+5] <== in[64+8*(i+1)-6];
        u2n[2].in[8*i+6] <== in[64+8*(i+1)-7];
        u2n[2].in[8*i+7] <== in[64+8*(i+1)-8];

        // u2n[1].in[i] <== in[40+i];
        // u2n[2].in[i] <== in[64+i];
    }

    component lt[3];
    lt[0] = LessThan(11);
    lt[1] = LessThan(4);
    lt[2] = LessThan(5);
    component let[3];
    let[0] = LessEqThan(11);
    let[1] = LessEqThan(4);

    lt[0].in[0] <== u2n[0].out;
    lt[0].in[1] <== target[0];
    lt[1].in[0] <== u2n[1].out;
    lt[1].in[1] <== target[1];
    lt[2].in[0] <== u2n[2].out;
    lt[2].in[1] <== target[2];

    let[0].in[0] <== u2n[0].out;
    let[0].in[1] <== target[0];
    let[1].in[0] <== u2n[1].out;
    let[1].in[1] <== target[1];

    component or[2];
    or[0] = OR();
    or[1] = OR();
    or[0].a <== lt[0].out;

    component and = AND();
    component and2 = MultiAND(3);

    and.a <== let[0].out;
    and.b <== lt[1].out;
    and2.in[0] <== let[0].out;
    and2.in[1] <== let[1].out;
    and2.in[2] <== lt[2].out;

    or[1].a <== and.out;
    or[1].b <== and2.out;

    or[0].b <== or[1].out;

    out <== or[0].out;

}

// component main {public [target]} = CompareDate();