pragma circom  2.0.0;

include "blake2b/blake2b384_padded.circom";
include "compareDate.circom";
include "utils/commitment.circom";
include "utils/hash_to_fr.circom";

template Hash2Fr2CommitAndCompareDate(n, index) {//input:1024*n bitのメッセージ + target
    var bits = 1024;
    signal input in[bits*n];//message input
    signal input message_length;
    signal input base[256];//proof challenge
    signal input blinding_factor[256];
    signal input target[3];//target date scalar(year, month, day)
    signal output out[257];//256bit commitment + rangeproof result

    var i;

    component blake2b384 = Blake2b384_padded(n);
    component hash2fr = Hash_to_Fr();
    component bin2bint[3];
    for (i=0; i<3; i++) {
        bin2bint[i] = Binary2Bigint(32, 8);
    }
    component comm = Commit(32, 8);
    component bint2bin = Bigint2Binary(32, 8);
    component comp = CompareDate();


    for (i=0; i<bits*n; i++) {
        blake2b384.in[i] <== in[i];
    }
    blake2b384.message_length <== message_length;

    for (i=0; i<384; i++) {
        hash2fr.a[i] <== blake2b384.out[i];
    }


    for (i=0; i<256; i++) {
        bin2bint[0].in[i] <== hash2fr.out[i];
        bin2bint[1].in[i] <== base[i];
        bin2bint[2].in[i] <== blinding_factor[i];
    }


    for (i=0; i<8; i++) {
        comm.secret[i] <== bin2bint[0].out[i];
        comm.c[i] <== bin2bint[1].out[i];
        comm.s[i] <== bin2bint[2].out[i];
    }

    for (i=0; i<8; i++) {
        bint2bin.in[i] <== comm.out[i];
    }

    for (i=0; i<256; i++) {
        out[255-i] <==  bint2bin.out[i];
    }

    for (i=0; i<80; i++) {
        comp.in[i] <== in[index+i];
    }
    comp.target[0] <== target[0];
    comp.target[1] <== target[1];
    comp.target[2] <== target[2];
    out[256] <== comp.out;


}

component main {public [target]} = Hash2Fr2CommitAndCompareDate(1, 488);