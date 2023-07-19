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

    return c;
}