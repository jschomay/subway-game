const path = require("path");
const DashboardPlugin = require('webpack-dashboard/plugin');
const webpack = require('webpack');

module.exports = () => ({
  module: {
    rules: [
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        use: [
          { loader: 'elm-hot-webpack-loader' },
          {
            loader: 'elm-webpack-loader',
            options: {
              cwd: path.join(__dirname, '../'),
              debug: true
            }
          }
        ]
      },
      {
        test: /\.s?css$/,
        use: ['style-loader', 'css-loader', 'postcss-loader']
      },
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
    new webpack.HotModuleReplacementPlugin(),

    new DashboardPlugin(),
  ],

  devServer: {
    contentBase: './src',
    historyApiFallback: true,
    inline: true,
    stats: 'errors-only',
    hot: true,
  }
});
