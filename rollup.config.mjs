export default {
  input: ".build/index.js",
  external: (id) => !id.startsWith(".") && !id.startsWith("/"),
  output: [
    { dir: "dist-commonjs", format: "cjs", preserveModules: true },
    { dir: "dist", format: "es", preserveModules: true },
  ],
}
