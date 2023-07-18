pragma circom  2.0.0;


template Bigint2Binary(k, n) {//k bit * n block
    signal input in[n];
    signal output out[k*n];

    component n2b[n];
    for (var i=0; i<n; i++) {
        n2b[i] = Num2Bits(k);
        n2b[i].in <== in[i];
    }

    for (var i=0; i<n; i++) {
        for (var j=0; j<k; j++) {
            out[k*i+j] <== n2b[i].out[j];
        }
    }

}

template Binary2Bigint(k, n) {//k bit * n block
    signal input in[k*n];
    signal output out[n];

    component b2n[n];
    for (var i=0; i<n; i++) {
        b2n[i] = Bits2Num(k);
        for (var j=0; j<k; j++) {
            b2n[i].in[j] <== in[k*i+j];
        }
    }

    for (var i=0; i<n; i++) {
        out[i] <== b2n[i].out;
    }

}