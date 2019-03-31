const webpack = require("webpack");
const webpackMerge = require("webpack-merge");
const HtmlWebpackPlugin = require("html-webpack-plugin");
const CopyWebpackPlugin = require("copy-webpack-plugin");
const StyleLintPlugin = require("stylelint-webpack-plugin");

const modeConfig = env => require(`./build-utils/webpack.${env}`)(env);
const presetConfig = require("./build-utils/loadPresets");

module.exports = ({ mode, presets } = { mode: "production", presets: [] }) => {
  console.log(`Building for: ${mode}`);

  return webpackMerge(
    {
      mode,

      resolve: {
        alias: {}
      },

      entry: {
        index: "./src/index.js",
        graph: "./src/graph.js"
      },

      module: {
        noParse: /\.elm$/,
        rules: [
          {
            test: /\.(eot|ttf|woff|woff2|svg)$/,
            use: "file-loader?publicPath=../../&name=fonts/[name].[ext]"
          },
          {
            test: /\.(jpg|png)$/,
            use: "file-loader?publicPath=../../&name=img/[name].[ext]"
          }
        ]
      },

      plugins: [
        new HtmlWebpackPlugin({
          template: "src/index.html",
          inject: "body",
          chunks: ["index"],
          filename: "index.html"
        }),

        new HtmlWebpackPlugin({
          template: "src/graph.html",
          inject: "body",
          chunks: ["graph"],
          filename: "graph.html"
        }),

        new StyleLintPlugin()

        // new CopyWebpackPlugin([
        //   { from: 'src/assets/favicon.ico' }
        // ]),
      ]
    },
    modeConfig(mode),
    presetConfig({ mode, presets })
  );
};
