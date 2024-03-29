const path = require('path');
const glob = require('glob');
const webpack = require("webpack");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const CopyWebpackPlugin = require('copy-webpack-plugin')
const TerserPlugin = require('terser-webpack-plugin');
const PurgecssPlugin = require('purgecss-webpack-plugin');
const ImageminPlugin = require('imagemin-webpack-plugin').default;
const OptimizeCSSAssetsPlugin = require('optimize-css-assets-webpack-plugin');

module.exports = () => ({
  output: {
    filename: '[name].[contenthash].js'
  },

  module: {
    rules: [
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        use: {
          loader: 'elm-webpack-loader',
          options: {
            optimize: true,
          },
        },
      },
      {
        test: /\.(sa|sc|c)ss$/,
        use: [
          MiniCssExtractPlugin.loader,
          'css-loader',
          'postcss-loader'
        ],
      },
      {
        test: /\.(eot|ttf|woff|woff2)$/,
        use: "file-loader?publicPath=../../&name=fonts/[name].[ext]"
      },
      {
        test: /\.(jpg|png|svg)$/,
        use: "file-loader?publicPath=../../&name=img/[name].[ext]"
      }
    ]
  },

  optimization: {
    minimizer: [
      // https://elm-lang.org/0.19.0/optimize
      new TerserPlugin({
        extractComments: false,
        terserOptions: {
          mangle: false,
          compress: {
            pure_funcs: ['F2','F3','F4','F5','F6','F7','F8','F9','A2','A3','A4','A5','A6','A7','A8','A9'],
            pure_getters: true,
            keep_fargs: false,
            unsafe_comps: true,
            unsafe: true,
          },
        },
      }),
      new TerserPlugin({
        extractComments: false,
        terserOptions: { mangle: true },
      }),
    ],
  },

  plugins: [
    new MiniCssExtractPlugin({
      filename: 'assets/css/[name].[contenthash].css',
    }),

    // Removes dynamically added markup from markdown causing lost styles so don't use
    // new PurgecssPlugin({
    //   paths: glob.sync(path.join(__dirname, '../src/**/*.elm'), { nodir: true })
    // }),

    new CopyWebpackPlugin({
      patterns: [
        {from: 'src/img', to: 'img/'},
        {from: 'src/audio', to: 'audio/'},
      ]
    }),

    new ImageminPlugin({
      test: /\.(jpe?g|png|gif|svg)$/i,
      cache: true,
    }),

    new OptimizeCSSAssetsPlugin(),


    // config
    new webpack.DefinePlugin({
      "process.env.SERVER_URL": JSON.stringify("/"),
      "process.env.VERSION": Date.now()
    }),
  ]
});
