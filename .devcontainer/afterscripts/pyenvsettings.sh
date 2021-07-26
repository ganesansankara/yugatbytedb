
# (The below instructions are intended for common
# shell setups. See the README for more guidance
# if they don't apply and/or don't work for you.)

# Add pyenv executable to PATH and
# enable shims by adding the following
# to ~/.profile and your shell's login startup file:

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PYENV_ROOT/versions/3.7.9/bin:$PATH"
eval "$(pyenv init --path)"
alias so='source ~/.zshrc'

# Load pyenv into the shell by adding
# the following to your shell's interactive startup file:

eval "$(pyenv init -)"

# Make sure to restart your entire logon session
# for changes to profile files to take effect.

# Load pyenv-virtualenv automatically by adding
# the following to your profile:

eval "$(pyenv virtualenv-init -)"