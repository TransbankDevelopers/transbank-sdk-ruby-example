#!/bin/bash
set -e

sed -i 's/ZSH_THEME="devcontainers"/ZSH_THEME="robbyrussell"/' "$HOME/.zshrc" || true

echo "📂 current dir: $(pwd)"

bundle check || bundle install

if [ ! -f .env ]; then
    secret="$(bin/rails secret)"
    if [ -z "$secret" ]; then
        echo "❌ No se pudo generar SECRET_KEY_BASE (bin/rails secret falló o devolvió vacío)" >&2
        exit 1
    fi
    {
        echo "RAILS_ENV=development"
        echo "SECRET_KEY_BASE=$secret"
    } > .env
fi

bin/rails db:prepare
