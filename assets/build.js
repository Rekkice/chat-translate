const esbuild = require("esbuild")
const sveltePlugin = require("esbuild-svelte")
const importGlobPlugin = require("esbuild-plugin-import-glob").default
const sveltePreprocess = require("svelte-preprocess")

const args = process.argv.slice(2)
const watch = args.includes("--watch")
const deploy = args.includes("--deploy")

let optsClient = {
    entryPoints: ["js/app.js"],
    bundle: true,
    minify: deploy,
    target: "es2017",
    conditions: ["svelte", "browser"],
    outdir: "../priv/static/assets",
    logLevel: "info",
    sourcemap: watch ? "inline" : false,
    watch,
    tsconfig: "./tsconfig.json",
    plugins: [
        importGlobPlugin(),
        sveltePlugin({
            preprocess: sveltePreprocess(),
            compilerOptions: {dev: !deploy, hydratable: true, css: "injected"},
        }),
    ],
}

let optsServer = {
    entryPoints: ["js/server.js"],
    platform: "neutral",
    bundle: true,
    minify: false,
    target: "esnext",
    conditions: ["svelte"],
    format: "esm",
    outdir: "../priv/svelte",
    logLevel: "info",
    sourcemap: watch ? "inline" : false,
    watch,
    tsconfig: "./tsconfig.json",
    plugins: [
        importGlobPlugin(),
        sveltePlugin({
            preprocess: sveltePreprocess(),
            compilerOptions: { dev: !deploy, hydratable: true, generate: "ssr" },
        }),
    ],
    mainFields: ["module", "main"],
    resolveExtensions: [".js", ".mjs", ".ts", ".json"],
    footer: {
        js: "globalThis.render = render;",
    },
};



const client = esbuild.build(optsClient)
const server = esbuild.build(optsServer)

if (watch) {
    client.then(_result => {
        process.stdin.on("close", () => process.exit(0))
        process.stdin.resume()
    })

    server.then(_result => {
        process.stdin.on("close", () => process.exit(0))
        process.stdin.resume()
    })
}
