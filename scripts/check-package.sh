#!/usr/bin/env bash
set -euo pipefail

package_path="$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
vite="$PWD/node_modules/.bin/vite"
package_manager="$(node -p 'require("./package.json").packageManager')"
consumer="$(mktemp -d)"
trap 'rm -rf "$consumer"' EXIT
cd "$consumer"

node --input-type=module - "$package_path" "$package_manager" <<'JS'
import { writeFileSync } from "node:fs"

const [packagePath, packageManager] = process.argv.slice(2)
writeFileSync("package.json", JSON.stringify({
  private: true,
  packageManager,
  dependencies: {
    "@types/react": "19.3.0",
    "@types/react-dom": "19.3.0",
    react: "19.3.1",
    "react-dom": "19.3.1",
    "react-spreadsheet-import": `file:${packagePath}`,
    typescript: "6.0.3",
  },
}))
JS

pnpm install --ignore-scripts
node --input-type=commonjs <<'JS'
const assert = require("node:assert/strict")
const { existsSync } = require("node:fs")
const path = require("node:path")
const manifestPath = require.resolve("react-spreadsheet-import/package.json")
const { module: esmEntry } = require(manifestPath)
const { ReactSpreadsheetImport } = require("react-spreadsheet-import")

assert.equal(typeof ReactSpreadsheetImport, "function")
assert.ok(existsSync(path.join(path.dirname(manifestPath), esmEntry)))
JS

cat > package-smoke.ts <<'TS'
import { ReactSpreadsheetImport } from "react-spreadsheet-import"
import type { Field } from "react-spreadsheet-import/types/types"

document.body.textContent = ReactSpreadsheetImport.name
export type ImportField = Field<string>
TS

pnpm exec tsc --noEmit --strict --skipLibCheck --module esnext --moduleResolution bundler package-smoke.ts

cat > index.html <<'HTML'
<!doctype html>
<html lang="en">
  <head><meta charset="utf-8"><title>Importer package smoke test</title></head>
  <body><script type="module" src="/package-smoke.ts"></script></body>
</html>
HTML

"$vite" build --logLevel error
