# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"
export ZK_CONFIG_DIR="$HOME/.config/zk"

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=( git zsh-syntax-highlighting zsh-history-substring-search fzf zsh-autosuggestions )

source $ZSH/oh-my-zsh.sh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Thisis for yazi to change directories
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}
# Account for already installed vim
alias vi=nvim
alias vim=nvim
# Open files with nvim in yazi
export EDITOR=nvim

# Detect operating system
case "$(uname -s)" in
  Darwin)
    # macOS

    # Source local env file if it exists
    [ -f "$HOME/.local/bin/env" ] && source "$HOME/.local/bin/env"

    # Homebrew
    if [ -x /opt/homebrew/bin/brew ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x /usr/local/bin/brew ]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
    ;;

  Linux)
    # Linux

    # Source local env file if it exists
    [ -f "$HOME/.local/bin/env" ] && source "$HOME/.local/bin/env"

    # Linuxbrew/Homebrew
    if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
      eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    elif [ -x "$HOME/.linuxbrew/bin/brew" ]; then
      eval "$("$HOME/.linuxbrew/bin/brew" shellenv)"
    fi
    ;;
esac


export PATH=$PATH:~/.cargo/bin

function agy() {
  local model=""
  local conv_volume=""
  local effort=""
  local args=()

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -m|--model)
        model="$2"
        shift 2
        ;;
      -v|--volume|-c|--conversation)
        conv_volume="$2"
        shift 2
        ;;
      -e|--effort)
        effort="$2"
        shift 2
        ;;
      *)
        args+=("$1")
        shift
        ;;
    esac
  done

  local podman_cmd=(podman run --rm -it)
  podman_cmd+=(--secret gemini_key,type=env,target=GEMINI_API_KEY)
  podman_cmd+=(-v "$(pwd):/home/agent/workspace")

  if [[ -n "$conv_volume" ]]; then
    podman_cmd+=(-v "$conv_volume:/home/agent/.gemini/antigravity-cli/brain")
  fi

  podman_cmd+=(agy)

  if [[ -n "$model" ]]; then
    podman_cmd+=(--model "$model")
  fi

  if [[ -n "$effort" ]]; then
    podman_cmd+=(--effort "$effort")
  fi

  podman_cmd+=("${args[@]}")

  "${podman_cmd[@]}"
}

function agy_spill() {
  if [[ -z "$1" ]]; then
    echo "Usage: agy_spill <container_name_or_id> [destination_path]"
    echo "Example: agy_spill my_agent_container ./saved_brains/"
    return 1
  fi

  local container="$1"
  local destination="${2:-.}" 
  
  local brain_path="/home/agent/.gemini/antigravity-cli/brain"

  # Find the conversation ID folder inside the container
  local conv_id=$(podman exec "$container" ls -1 "$brain_path" 2>/dev/null | head -n 1)

  if [[ -n "$conv_id" ]]; then
    echo "Found Conversation ID: $conv_id"
    echo "Copying specific conversation brain to '${destination}/${conv_id}'..."
    podman cp "${container}:${brain_path}/${conv_id}" "${destination}/"
  else
    echo "No Conversation ID found. Copying the entire brain folder..."
    podman cp "${container}:${brain_path}" "${destination}"
  fi

  if [[ $? -eq 0 ]]; then
    echo "Successfully copied brain!"
  else
    echo "Failed to copy brain. Is the container name correct?"
    return 1
  fi
}
