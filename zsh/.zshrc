# Suppress Powerlevel10k instant prompt warnings
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

# Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Oh-My-Zsh settings
export ZSH="$HOME/.oh-my-zsh"            # Path to Oh-My-Zsh installation
ZSH_THEME="powerlevel10k/powerlevel10k"  # Use Powerlevel10k as the prompt theme
plugins=(git wd)                          # git: aliases & branch info, wd: bookmark directories
source $ZSH/oh-my-zsh.sh                 # Start Oh-My-Zsh (required — loads theme + plugins)

# Colors
BOLD="\e[1m"
CYAN="\e[36m"
ENDCOLOR="\e[0m"
MAGENTA="\e[35m"

# Background colors
BG_MAGENTA="\e[45m"

# Emojis
BEER='\U1F37A'
NERD='\U1F913'

# Print a full-width bar with a repeating string
# Example usage: fullbar "-" "${MAGENTA}"
function fullbar() {
  local chars=$1
  local color=${2:-$ENDCOLOR}
  local width=$(tput cols)
  local line=""

  while [ ${#line} -lt $width ]; do
    line+="${chars}"
  done

  line=${line:0:$width}
  printf "%b%s%b\n" "${color}" "${line}" "${ENDCOLOR}"
}

# Print a full-width bar with a repeating emoji
# Example usage: fullbarEmoji $WRENCH
function fullbarEmoji() {
  local emoji=$1
  local width=$(tput cols)
  local line=""
  local emojiWidth=2

  for ((i = 0; i < width / emojiWidth; i++)); do
    line+="${emoji}"
  done
  echo -e "${line}"
}

# Custom styled prompt
function custom_prompt() {
  echo "${MAGENTA}""${BOLD}${MAGENTA}||||(${ENDCOLOR} ${BEER} ${NERD} ${BOLD}${MAGENTA})>${ENDCOLOR}" "${BOLD}${BG_MAGENTA} $1 ${ENDCOLOR}\n"
}

# Open .zshrc in VS Code
function config() {
  custom_prompt "code ~/.zshrc";
  cd ~;
  code ~/.zshrc;
}

# Show available custom functions
function commands() {
  fullbar "." "${MAGENTA}"
  echo -e "   ${BOLD}${MAGENTA}Available commands:${ENDCOLOR}${NERD}";
  echo "   Commands:
    commands     Show this help
    config       Open .zshrc in VS Code
    root()       Go to ~/
    update()     git fetch && git pull
    myinfo       Show current terminal information
    claudeInit() Set up Claude AI team
    fullbar()    Print a full-width bar with string char
    fullbarEmoji() Print a full-width bar with an emoji";
  fullbar "." "${MAGENTA}";
}

# Initialize Claude AI team configurator
function claudeInit() {
  echo -e "\n${BOLD}${MAGENTA}Initializing team configurator...${ENDCOLOR}"
  claude "Use team-configurator to set up my AI development team"
}

# Display system and environment info (runs in subshell to avoid changing cwd)
function myinfo() {(
  cd ~/Code 2>/dev/null
  echo "${MAGENTA}-----------------------------------------------------${ENDCOLOR}"
  echo "   User: ${CYAN}$(whoami)${ENDCOLOR}"
  echo "   Time: ${CYAN}$(date +"%T")${ENDCOLOR}"
  echo "   Date: ${CYAN}$(date +"%Y-%m-%d")${ENDCOLOR}"
  echo "   Computer Name: ${CYAN}$(hostname)${ENDCOLOR}"
  echo "   Node Version: ${CYAN}$(node -v)${ENDCOLOR}"
  echo "   Current Directory: ${CYAN}$(pwd)${ENDCOLOR}"
  if [ -d .git ] || git rev-parse --git-dir > /dev/null 2>&1; then
    echo "   Current Git Branch: ${CYAN}$(git symbolic-ref --short HEAD 2>/dev/null)${ENDCOLOR}"
  else
    echo "   Not in a Git repository"
  fi
  echo "${MAGENTA}-----------------------------------------------------${ENDCOLOR}"
  echo ""
)}

# Show info on shell start
myinfo;

# Navigation
function root() {
  custom_prompt "cd ~"
  cd ~
}

function update() {
  custom_prompt "git fetch && git pull"
  git fetch;
  git pull;
}

# Source Powerlevel10k configuration
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
