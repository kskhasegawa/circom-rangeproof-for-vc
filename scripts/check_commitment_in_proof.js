const fs = require('fs');

// コマンドライン引数を取得
const proofFile = process.argv[2];
const commitmentFile = process.argv[3];

// 入力が指定されているか確認
if (!proofFile || !commitmentFile) {
  console.log('Usage: node script.js <proofFile> <commitmentFile>');
  process.exit(1);
}

// main関数の定義
function main() {
  // proofファイルの読み込み
  const proof = JSON.parse(fs.readFileSync(proofFile, 'utf-8'));
  const proofValue = proof.proof.proofValue;

//   console.log(proofValue);

  // commitmentファイルの読み込み
  const commitmentHexArray = JSON.parse(fs.readFileSync(commitmentFile, 'utf-8'));

  // Hex配列を連結してcommitmentを作成
  const commitmentBits = commitmentHexArray.slice(0, 256).join('');
  const commitment = BigInt(`0b${commitmentBits}`).toString(16);

  // checkCommitmentInProof関数の定義と使用
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

  // checkCommitmentInProof関数を呼び出して結果を出力
  const isContained = checkCommitmentInProof(proofValue, commitment);
  console.log("Commitment is contained in proofValue:", isContained);
}

// main関数の呼び出し
main();
