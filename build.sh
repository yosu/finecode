#!/bin/bash

# Initial setup
mix deps.get --only prod
MIX_ENV=prod mix compile

# Compile assets
MIX_ENV=prod mix assets.deploy

# Remove the existing release directory and build the release
rm -rf "_build"
MIX_ENV=prod mix release

# for auto DB migration upon deploy
# MIX_ENV=prod mix ecto.migrate
