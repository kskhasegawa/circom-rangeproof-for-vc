/**
 * commitment.circom
 * @Package circom_range_proof_for_vc
 * @author ZKSHT
 * @copyright 2023 ZKSHT. All rights reserved.
 * @license GPL-v3.0
 */


pragma circom  2.0.0;

include "bigint.circom";
include "bls12-381_params.circom";


template Commit(k, n) {//k bit * n block
    signal input secret[n];//hash of statement
    signal input c[n];//proof chellenge
    signal input s[n];//blinding factor
    signal output out[n];

    var p[n] = Prime_field_modulus();

    component multmodp = BigMultModP(k, n);
    for (var i=0; i<n; i++) {
        multmodp.a[i] <== c[i];
        multmodp.b[i] <== secret[i];
        multmodp.p[i] <== p[i];
    }

    component sub = BigSubModP(k, n);
    for (var i=0; i<n; i++) {
        sub.a[i] <== s[i];
        sub.b[i] <== multmodp.out[i];
        sub.p[i] <== p[i];   
    }

    for (var i=0; i<n; i++) {
        out[i] <== sub.out[i];      
    }
}