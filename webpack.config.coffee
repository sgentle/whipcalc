path = require 'path'
webpack = require 'webpack'
# extractor = require 'extract-text-webpack-plugin'
uglifyer = webpack.optimize.UglifyJsPlugin

path = require 'path'

srcs = ['src[]=bower_components/purescript-*/src/**/*.purs', 'src[]=src/**/*.purs']

ffis = ['ffi[]=bower_components/purescript-*/src/**/*.js', 'ffi[]=src/**/*FFI.js']

output = 'output'

modulesDirectories = [
  'node_modules'
  'bower_components/purescript-prelude/src'
];

module.exports =
  entry: './src/entry'
  output:
    filename: './public/app.js'
  module:
    loaders: [
      { test: /\.json$/, loader: "json" }
      # { test: /\.coffee$/, loader: "coffee" }
      # { test: /\.(coffee\.md|litcoffee)$/, loader: "coffee-loader?literate" }
      # { test: /\.css$/, loader:  extractor.extract "style", "css" }
      { test: /\.purs$/, loader: 'purs-loader?output=' + output + '&' + srcs.concat(ffis).join('&') }
    ]
  resolve: {
    modulesDirectories: modulesDirectories
    extensions: ['', '.js']
  }
  resolveLoader: { root: path.join(__dirname, 'node_modules') }
  plugins: [
    # new extractor("./public/style.css", allChunks: true)
    new webpack.SourceMapDevToolPlugin(
      '[file].map', null,
      "[absolute-resource-path]", "[absolute-resource-path]") if process.env.NODE_ENV isnt 'production'
    new uglifyer(minimize: true, sourceMap: true) if process.env.NODE_ENV is 'production'
  ].filter(Boolean)