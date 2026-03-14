#!/bin/bash

cd ~/dotfiles
for app in nvim nushell ghostty fish tmux starship zsh; do
    stow $app
done
