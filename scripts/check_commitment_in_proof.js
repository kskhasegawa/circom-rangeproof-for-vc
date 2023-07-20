/**
 * chec_commitment_in_proof.js
 * @Package circom_range_proof_for_vc
 * @author ZKSHT
 * @copyright 2023 ZKSHT. All rights reserved.
 * @license GPL-v3.0
 */


const fs = require('fs');


const proofFile = process.argv[2];
const commitmentFile = process.argv[3];


if (!proofFile || !commitmentFile) {
  console.log('Usage: node script.js <proofFile> <commitmentFile>');
  process.exit(1);
}

// main
function main() {
  // proof
  const proof = JSON.parse(fs.readFileSync(proofFile, 'utf-8'));
  const proofValue = proof.proof.proofValue;

//   console.log(proofValue);

  // commitment
  const commitmentHexArray = JSON.parse(fs.readFileSync(commitmentFile, 'utf-8'));

  // generate commitment from hex
  const commitmentBits = commitmentHexArray.slice(0, 256).join('');
  const commitment = BigInt(`0b${commitmentBits}`).toString(16);


  function checkCommitmentInProof(proofValue, commitment) {
    // Convert base64 proofValue to byte array
    const proofValueBytes = Uint8Array.from(atob(proofValue), c => c.charCodeAt(0));

    // Convert hex commitment to byte array
    const commitmentBytes = hexToBytes(commitment);

    // Check if commitmentBytes is contained in proofValueBytes
    for (let i = 0; i <= proofValueBytes.length - commitmentBytes.length; i++) {
      let found = true;
      for (let j = 0; j < commitmentBytes.length; j++) {
        if (proofValueBytes[i + j] !== commitmentBytes[j]) {
          found = false;
          break;
        }
      }
      if (found) {
        return true;
      }
    }

    return false;
  }

  // Helper function to convert hex string to byte array
  function hexToBytes(hex) {
    const bytes = [];
    for (let i = 0; i < hex.length; i += 2) {
      bytes.push(parseInt(hex.substr(i, 2), 16));
    }
    return bytes;
  }


  const isContained = checkCommitmentInProof(proofValue, commitment);
  console.log("Commitment is contained in proofValue:", isContained);
}


main();
