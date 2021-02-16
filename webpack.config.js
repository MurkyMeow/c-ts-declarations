const path = require('path')
const nodeExternals = require('webpack-node-externals')

module.exports = {
  entry: './lib/cli.js',
  mode: process.env.NODE_ENV === 'production' ? 'production' : 'development',
  target: 'node',
  externals: [nodeExternals()],
  output: {
    path: path.resolve(__dirname, './dist'),
    publicPath: '/dist/',
    filename: 'bundle.js'
  },
  module: {
    rules: [
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        use: {
          loader: 'elm-webpack-loader',
          options: {},
        },
      },
    ],
  },
}
