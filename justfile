[private]
default:
  just --list

# Bump Version
bump:
  yarn bump --tag

# Publish to NPM
publish:
  npm publish

[private]
compile-coffee:
  yarn coffee --compile --no-header --output ./build ./lib

# Build Flame ODM
build: compile-coffee

