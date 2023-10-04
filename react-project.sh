#!/bin/bash

# Create a barebones React + TypeScript + Airbnb + Prettier project in Docker.
# Copy the file to the parent directory of the project and run
#   ./react-project.sh <project name>

set -e

function install_tools {
    npm install create-react-app install-peerdeps
}

function create_app {
    local app="$1"
    npx create-react-app "$app" --template typescript
    cd $app
    # https://www.npmjs.com/package/eslint-config-airbnb
    npx install-peerdeps --dev eslint-config-airbnb

    # https://www.npmjs.com/package/eslint-config-airbnb-typescript
    npm install eslint-config-airbnb-typescript \
                @typescript-eslint/eslint-plugin@^5.13.0 \
                @typescript-eslint/parser@^5.0.0 \
                --save-dev

    npm install --save-dev eslint-config-prettier eslint-plugin-prettier prettier 

    # https://typescript-eslint.io/linting/typed-linting/
    cat << EOF  > .eslintrc.cjs
module.exports = {
  env: {
    'browser': true,
    'es2021': true
  },
  extends: [
    'airbnb',
    'airbnb-typescript',
    'airbnb/hooks',
    'eslint:recommended',
    'plugin:@typescript-eslint/recommended-type-checked',
    'plugin:@typescript-eslint/stylistic-type-checked',
    'plugin:prettier/recommended',
  ],
  parser: "@typescript-eslint/parser",
  parserOptions: {
    ecmaVersion: 'latest',
    sourceType: 'module',
    project: true,
    tsconfigRootDir: __dirname,
  },
  plugins: [
    '@typescript-eslint',
    'prettier'
  ],
  root: true,
  rules: {
  }
}
EOF
    npm  install
}

function run_in_container {
  dir="$(pwd)"
  cd
  install_tools
  cd "$dir"
  create_app "$app"
}

function run_on_host {
  if [[ -z "$app" ]]; then
    echo "No app name" >&2
    exit 1
  fi
  if [[ -d "$app" ]]; then
    echo "Directory $dir already exists"
    exit 1
  fi
  dir="$(pwd)"

  docker run --rm -it \
    --user node \
    --volume $(pwd):/home/node/proj \
    --workdir=/home/node/proj \
    node /home/node/proj/react-project.sh "$app"
}

app="$1"
export app
if command -v docker; then
  run_on_host
else
  run_in_container
fi
