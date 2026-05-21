#!/bin/bash
set -e

sed -i 's/ZSH_THEME="devcontainers"/ZSH_THEME="robbyrussell"/' "$HOME/.zshrc" || true

echo "📂 current dir: $(pwd)"

bundle check || bundle install

if [ ! -f .env ]; then
    {
        echo "RAILS_ENV=development"
        echo "SECRET_KEY_BASE=$(bin/rails secret)"
    } > .env
fi

bin/rails db:prepare
