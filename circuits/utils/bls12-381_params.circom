pragma circom 2.0.3;


function Prime_field_modulus() {
    // var out[256];
    var c[8] = [0x00000001,
                0xFFFFFFFF,
                0xFFFE5BFE,
                0x53BDA402,
                0x09A1D805,
                0x3339D808,
                0x299D7D48,
                0x73EDA753
                ];
    // var c[4] = [0xFFFFFFFF00000001,
    //             0x53BDA402FFFE5BFE,
    //             0x3339D80809A1D805,
    //             0x73EDA753299D7D48];
    return c;

}

function F_2_192() {
    var c[8] = [0xfffffffe,
                0x00000001,
                0x00034802,
                0x5884b7fa,
                0xecbc4ff5,
                0x998c4fef,
                0xacc5056f,
                0x1824b159];
    // var c[8] = [0x41b4528f,
    //             0x59476ebc,
    //             0x43fcc152,
    //             0xc5a30cb2,
    //             0x40ccbd72,
    //             0x2b34e639,
    //             0xca247088,
    //             0x1e179025];

    return c;
}