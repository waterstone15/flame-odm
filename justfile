[private]
default:
  just --list

[private]
buid-coffee:
  yarn coffee --compile --no-header --output ./build ./lib

build: buid-coffee

bump:
  yarn bump --tag

publish:
  npm publish

test file='*': build
  yarn mocha --parallel --require coffeescript/register --reporter list ./tests/**/{{file}}.coffee