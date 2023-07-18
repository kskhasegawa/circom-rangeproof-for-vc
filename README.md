# circom-rangeproof-for-vc
circom circuits for rangeproof of birthdate described in Verifiable credentials

Do not use this repository as it is for experimental purposes.


##Getting started  

```
git clone https://github.com/kskhasegawa/circom-rangeproof-for-vc.git
cd circom-rangeproof-for-vc
npm install
```

circuit compile  
```
circom circuits/hash_to_fr_to_commit_and_compare.circom --r1cs  --wasm -p bls12381
cd hash_to_fr_to_commit_and_compare_js
snarkjs powersoftau contribute pot16_0000.ptau pot16_0001.ptau --name="First contribution" -v
snarkjs powersoftau prepare phase2 pot16_0001.ptau pot16_final.ptau -v
snarkjs groth16 setup ../hash_to_fr_to_commit_and_compare.r1cs pot16_final.ptau hashAndCompare_0000.zkey
snarkjs zkey contribute hashAndCompare_0000.zkey hashAndCompare_0001.zkey --name="1st Contributor Name" -v
snarkjs zkey export verificationkey hashAndCompare_0001.zkey verification_key.json
```

input generation  
```
node generate_input.js statement.json input.json
```

witness generation
```
cd hash_to_fr_to_commit_and_compare_js
node generate_witness.js hash_to_fr_to_commit_and_compare.wasm ../input.json witness.wtns
```

prove
```
snarkjs groth16 prove hashAndCompare_0001.zkey witness.wtns proof.json public.json
```

verify
```
snarkjs groth16 verify verification_key.json public.json proof.json
```