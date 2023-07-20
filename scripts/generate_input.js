/**
 * generate_input.js
 * @Package circom_range_proof_for_vc
 * @author ZKSHT
 * @copyright 2023 ZKSHT. All rights reserved.
 * @license GPL-v3.0
 */

const fs = require('fs');

function getPaddedInput(input, totalBits) {
  const utf8Encoder = new TextEncoder();
  const data = utf8Encoder.encode(input);

  const binaryArray = [];
  for (let i = 0; i < data.length; i++) {
    for (let j = 0; j < 8; j++) {
      const bit = (data[i] >> j) & 1;
      binaryArray.push(bit);
    }
  }

  const paddingBits = totalBits - binaryArray.length;

  for (let i = 0; i < paddingBits; i++) {
    binaryArray.push(0);
  }

  return binaryArray;
}

function hexToLittleEndianBits(hexString) {
  // 16進数文字列をバッファに変換
  const buffer = Buffer.from(hexString, 'hex');

  // バッファの長さを取得
  const bufferLength = buffer.length;

  // バッファの各バイトをビット配列に変換
  const bitsArray = [];
  for (let i = 0; i < bufferLength; i++) {
    const byte = buffer[i];
    for (let j = 7; j >= 0; j--) {
      // リトルエンディアンでビットを配列に追加
      bitsArray.push((byte >> j) & 1);
    }
  }

  // ビット配列の長さが256ビットになるようにパディング
  const paddingLength = 256 - bitsArray.length;
  if (paddingLength > 0) {
    const paddingBits = new Array(paddingLength).fill(0);
    bitsArray.push(...paddingBits);
  }

  return bitsArray.reverse();
}

function formatInputJSON(statement) {
  const totalBits = 1024;

  const input = {
    "in": getPaddedInput(statement.statement, totalBits),
    "message_length": statement.statement.length,
    "base": hexToLittleEndianBits(statement.proof_challenge, 256),
    "blinding_factor": hexToLittleEndianBits(statement.blinding_factor, 256),
    "target": statement.target
  };

  return JSON.stringify(input, null, 2);
}

function processStatementJSON(statementPath, outputPath) {
  // Read statement.json file
  const statementData = fs.readFileSync(statementPath, 'utf8');
  const statement = JSON.parse(statementData);

  // Format input JSON
  const inputJSON = formatInputJSON(statement);

  // Write input.json file
  fs.writeFileSync(outputPath, inputJSON, 'utf8');
  console.log('input.json file has been created.');
}

// Get input and output file paths from command line arguments
const args = process.argv.slice(2);
if (args.length !== 2) {
  console.error('Usage: node process_statement.js <statement_path> <output_path>');
  process.exit(1);
}
const statementPath = args[0];
const outputPath = args[1];

// Process statement.json
processStatementJSON(statementPath, outputPath);
