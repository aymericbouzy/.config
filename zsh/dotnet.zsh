export DOTNET_ROOT="/usr/local/share/dotnet"
export PATH="$PATH:$HOME/.dotnet:$HOME/.dotnet/tools"
export DOTNET_INSTALL_DIR="$DOTNET_ROOT/sdk"

alias d="dotnet"
compdef d=dotnet

function format {
	local range="${1:-HEAD}"
	dotnet format style apps/all.sln --include "$(git d "$range" --name-only | tr '\n' ' ')"
	dotnet format whitespace apps/all.sln --include "$(git d "$range" --name-only | tr '\n' ' ')"
}

alias b="build"
alias pb="project-build"
