# NOTE: up-to-date versions of this file are at: /mnt/homedir/fenix/.bashrc
# Unlike earlier versions, Bash4 sources your bashrc on non-interactive shells.
# The line below prevents anything in this file from creating output that will
# break utilities that use ssh as a pipe, including git and mercurial.
[ -z "$PS1" ] && return

# Source global definitions
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

# User specific aliases and functions for all shells
export EDITOR=vim
export VISUAL=vim
export PATH=$PATH:$HOME/devtools/
alias more='less -s'
alias less='less -s'
if ls --color $HOME >&/dev/null; then
  alias ls='ls --color'
fi

# tell bash to reset the window size when it changes.
shopt -s checkwinsize
set editing-mode vi

ISROOT=false
if [ $(id -u) -eq 0 ]; then
  ISROOT=true #  I'm root.
fi

ISDEVHOST=false
if [[ $HOSTNAME =~ ^dev.* ]]; then
  ISDEVHOST=true # I'm on my dev server.
fi # Username shall then be red and bold and draw attention.

# wiki.bash-hackers.org/scripting/terminalcodes is a good resource for codes.
# 256 colors fg:
#  \033[38;5;Xm
# 256 colors bg:
#  \033[48;5;Xm
# True color fg:
#  \033[38;2;r;g;b
# True color bg:
#  \033[48;2;r;g;b
YELLOW="\[\033[38;5;226m\]"
ORANGE="\[\033[38;5;214m\]"
RED="\[\033[38;5;160m\]"
GREEN="\[\033[38;5;10m\]"
WHITE="\[\033[38;5;15m\]"
BLUE="\[\033[38;5;39m\]"
LIGHT_BLUE="\[\033[38;5;14m\]"
PURPLE="\[\033[38;5;54m\]"
GREY="\[\033[38;5;8m\]"
RST="\[\033[0m\]"
BOLD="\[\033[1m\]"
TTY="$(tty)"
HOST=${HOSTNAME/.*}  # extract up-to the first dot.
SEP_STRING='='
GREYBG="\[\033[48;2;16;16;16m\]"

# prints out all available xterm-256 bg colors
do_bg_colors () {
  for i in {1..255} ; do
    echo -ne "\033[48;5;${i}m$i\033[0m|"
  done
}

# prints out all available xterm-256 fg colors
do_fg_colors () {
  for i in {1..255} ; do
    echo -ne "\033[38;5;${i}m$i\033[0m|"
  done
}

# prints out all 256 greyscale "truecolor" fg colors.
do_true_fg_colors () {
  for i in {1..255} ; do
    echo -ne "\033[38;2;${i};${i};${i}m$i\033[0m|"
  done
}

# prints out all 256 greyscale "truecolor" bg colors.
do_true_bg_colors () {
  for i in {1..255} ; do
    echo -ne "\033[48;2;${i};${i};${i}m$i\033[0m|"
  done
}

# The mac doesn't do the %()T printf format, so test for this.
# Being able to use printf for date typically saves ~100ms per prompt.
PRINTF_FOR_DATE=true
if ! printf '%()T' >&/dev/null; then
  PRINTF_FOR_DATE=
fi


# This executes 'ps' once per shell level.
# Given this happens only when a login shell is created, this should be OK.
# This will consider a tmux session to be a red-shell, as it will for a login.
find_parents () {
  PARENTS=
  REDSHELL=
  local -i parent=$$
  local -a ps_out=""
  local tty=${TTY//\/dev\/}
  local -i depth=0
  local sep=""
  while true ; do
    local -a ps_out=(`ps -p $parent -o ppid= -o tty= -o comm= `)
    parent=${ps_out[0]}
    local ptty=${ps_out[1]}
    local -a comm_arr=(${ps_out[2]//\// })
    local comm=${comm_arr[@]:(-1)}

    depth=$(($depth+1))
    if [[ $depth -gt 3 ]]; then
      #echo "break because depth>3"
      PARENTS="...$PARENTS"
      break
    fi
    PARENTS="$comm$sep$PARENTS"
    sep="->"
    if [[ $depth -eq $SHLVL ]] ; then
      #echo "break because SHLVL"
      break;
    fi
    if [[ $parent -eq 1 || $ptty = "?" ]] ; then
      #echo "break because parent=1"
      if [[ $depth -le 2 ]]; then
        #echo "shell should be red"
        REDSHELL=1
      fi
      break
    fi
  done
  #echo DONE: depth:$depth SHLVL:$SHLVL parent:$parent
}

# ... and find the shell's parents for real.
find_parents

# Attempts to find the root of the mercurial repo from the CWD.
hg_root () {
  local root_dir=$(hg root 2> /dev/null)
  if ! [[ -n $? ]] ; then
    root_dir=
  fi
  echo -n $root_dir
}

# Attempts to find the root of the git repo from the CWD.
git_root () {
  local root_dir=$(git rev-parse --show-toplevel 2> /dev/null)
  if ! [[ -n $? ]] ; then
    root_dir=
  fi
  echo -n $root_dir
}

# Attempts to find the root of the repo from the CWD.
repo_root () {
  local root_dir=$(hg_root)
  if [[ -z $root_dir ]] ; then
    root_dir=$(git_root)
  fi
  echo -n $root_dir
}


get_hg_bookmark () {
  echo "$(hg bookmark 2>/dev/null| grep '*' | awk '{print $2}')"
}

get_git_branch() {
  echo "$(git branch 2>/dev/null | grep '*' | awk  '{print $2}')"
}

function_exists() {
  # -f  -> declare as function
  # -F  -> (bash specific) don't print the contents.
  declare -f -F $1 > /dev/null
  return $?
}

get_change_name() {
  #if the function _dotfiles_scm_info exists (and is a shell func)
  if function_exists _dotfiles_scm_info ; then
    echo $(_dotfiles_scm_info)
  else
    local change_name=$(get_hg_bookmark)
    if [[ -z $change_name ]] ; then
      change_name=$(get_git_branch)
    fi
    echo -n $change_name
  fi
}

# Look at: http://bashrcgenerator.com/
# as a quick reference/setup generator for a cmd line args.

# usage: line 'pattern here' cols rows
# if 'rows' is omitted, 1 is assumed.
# if 'cols' is ommitted, $COLUMNS is assumed.
#           is <= 0    , $COLUMNS - $cols is used.
# Emits cols worth of characters, rows times.
line () {
  local cols=$COLUMNS
  local pat='#'
  if [[ $# -gt 0 ]] ; then
    pat="$1"
  elif [[ ! -z "$SEP_STRING" ]] ; then
    pat="$SEP_STRING"
  fi

  local -i repeats=1
  if [[ $# -gt 1 && $2 -gt 0 ]] ; then
    repeats=$2
  fi

  if [[ $# -gt 2 ]] ; then
    if [[ $3 -lt 1 ]] ; then
      cols=$(($COLUMNS + $3))
    else
      cols=$3
    fi
  fi


  local dashes="$pat"
  while [[ ${#dashes} -le $cols ]] ; do
    dashes="$dashes$dashes"
  done
  dashes=${dashes:0:$cols}
  local out="$dashes"
  local i=0
  for ((i=2; i<=repeats; i++)); do
    out="$out\n$dashes"
  done
  echo -ne "$out"
}

delim () {
  echo
  line "$@"
  echo
}

echoxec () {
  # One might also do this by doing set +x before the cmd, then set -x after
  # this would turn on bash debugging mode, then execute the cmd, then turn it
  # off.
  echo "$@"
  $@
}

# Finds the latest file which matches the glob, and echos it to stdout.
#
# inspired from http://stackoverflow.com/questions/5885934/bash-function-to-find-newest-file-matching-pattern
#
# This (unlike the code from which this is inspired) *does* work for dot files.
# One could do this by accepting filenames on the cmdline, but that would fail
# when the filenames are numerous enough to be longer than the cmdline. As a
# result, this approach of doing the glob expansion in this function is superior.
# This function does require the glob to be appropriately escaped so it is not
# expanded before the function is invoked. As a result, it is suggested that
# you use the 'latest' alias (see below) instead, which disables expansion
# before invoking this function.
latest_glob () {
  #echo "$FUNCNAME: $# '$@'"
  # assume just looking for latest in CWD if no glob passed
  local pat=''
  if (( $# == 1 )) ; then
    pat="$1"
  elif (( $# == 0 )) ; then
    pat='*'
  else
    (>&2 echo "Usage: $FUNCNAME [glob]")
  fi
  #echo "pat: $pat"
  local -r glob_pattern="${pat}"

  # Ignore .. and .
  local -r old_globignore=${GLOBIGNORE}
  GLOBIGNORE=".:.."
  # Allow globing for dotfiles
  local -i need_to_unset_dotglob=0
  if [[ ":$BASHOPTS:" =~ *:dotglob:* ]] ; then
    shopt -s dotglob
    need_to_unset_dotglob=1
  fi

  # Sometimes nothing matches. Set 'nullglob' to ensure we don't get random
  # output when that happens.
  local -i need_to_unset_nullglob=0
  if [[ ":$BASHOPTS:" =~ *:nullglob:* ]] ; then
    shopt -s nullglob
    need_to_unset_nullglob=1
  fi

  local -i need_to_unset_f=0
  if [[ -o f  ]] ; then
    need_to_unset_f=1
  fi
  set +f

  #echo "glob_pattern: '$glob_pattern'"
  local newest=
  for file in $glob_pattern ; do
    #echo "examining file: '$file'"
    [[ -z $newest || $file -nt $newest ]] \
        && newest=$file
    #echo "newest_file: '$newest'"
  done

  # To avoid unexpected behaviour elsewhere, unset
  # f/nullglob/dotglob/globignore as necessary.
  (( need_to_unset_f )) && set -f
  (( need_to_unset_nullglob )) && shopt -u nullglob
  (( need_to_unset_dotglob )) && shopt -u dotglob
  GLOBIGNORE=${old_globignore}

  # If the file-name begins with '-', then echo will barf. Use printf instead.
  [[ -n $newest ]] && printf '%s\n' "$newest"
  return 0
}

# 'reset_expansion' inspired from http://stackoverflow.com/questions/11456403/stop-shell-wildcard-character-expansion
reset_expansion () {
  CMD="$1";
  shift;
  $CMD $@;
  set +f
}
# allows one to look for the most recently changed thin in CWD without needing
# to escape '*'
# e.g. "latest log_*"
alias latest='set -f;reset_expansion latest_glob'

# Removes (or at least attempts to) ANSI color codes from its input.
# More specifically, it removes ANSI colors codes that are to be interpreted
# within PS1 (i.e. are bracketed with \[ \], which is necessary to ensure
# scrolling doesn't go wonky.
strip_colors () {
  local text=""
  if [[ $# -eq 0 ]] ; then
    text="$(cat -)"
  else
    text="$1"
  fi
  esc="\033"
  code_pattern="\\$esc\[([0-9]{1,2}(;[0-9]{1,3}){0,2}){0,1}[m]{0,1}"
  cp_and_brace='\\\['"${code_pattern}"'\\\]'
  pattern="^(.*)(${cp_and_brace})(.*)$"
  input="$text"
  while [[ $input =~ $pattern ]] ; do
    # After a regexp, BASH_REMATCH contains the captured parts of the pattern.
    first="${BASH_REMATCH[1]}"                             # we only care about
    last="${BASH_REMATCH[$((${#BASH_REMATCH[*]}-1))]}"     # the first and last.
    input="${first}${last}"
  done
  echo -n "$input"
}

# Also note that this attempts to use bash builtins instead of shelling out to
# external program in an attempt to ensure robustness/speed as much as possible.
make_prompt () {
  prompt_maker="make_prompt"
  local last_status=${PIPESTATUS[*]}
  local host=$HOST
  local parents=$PARENTS
  local user=$USER
  local path=$PWD
  local date=""
  if [ $PRINTF_FOR_DATE ]; then
    date=$(printf '%(%Y-%m-%d %H:%M:%S)T' -1);
  else
    date=$(date +%Y-%m-%d\ %H:%M:%S)
  fi

  # at around 100ms, the following is the slowest thing in this function.
  local change_name=$(get_change_name)

  local c1="" c2="" c3="" c4="" c5="" c6="" c7="" rst="" bold=""

  # Compute count of visible chars first.
  l_ps1="$c1$USER$c2@$c3$host $c4$PARENTS $c5$PWD $c6$last_status "
  r_ps1=" $change_name $c7$date"
  local c_l_ps1=${#l_ps1}
  local c_r_ps1=${#r_ps1}

  # Now that we've computed the visible count, we can add in the colors
  c1=$YELLOW    # username
  c2=$WHITE     # @
  c3=$GREEN     # host
  c4=$PURPLE    # shell-ancestors
  c5=$BLUE      # path
  c6=$RED       # status (not really used)
  c7=$ORANGE    # time/date
  rst=$RST
  bold=$BOLD

  if $ISROOT; then
    c1="$RED$BOLD"          # so username shall become red and bold
    c2="$c2$RST"            # but we don't want everything to else be bold
  fi
  # REDSHELL documents findings of find_parent (which sets/clears it)
  if [[ $REDSHELL -eq 1 || $SHLVL -eq 1 || ( $0 =~ ^- && $SHLVL -eq 2 ) ]]; then
  # Unfortunately, because of a buggy interaction with mosh, SHLVL will not
  # equal 1 (it will equal two).
  #if [[ $SHLVL -eq 1 ]]; then # this shell is root shell of the tty session.
    c4=$RED                 # and so it shall become red to warn the user...
  fi
  if $ISDEVHOST; then       # I'm on my dev server.
    c3=$BOLD$LIGHT_BLUE     # and so it shall become boldly blue...
    c4=$RST$c4              # but we don't want everything else to be bold
  fi

  local status_output=""
  local maybespace=""
  for s in $last_status; do
    if [[ $s -eq 0 ]]; then
      status_output=$status_output$maybespace$GREEN$s
    else
      status_output=$status_output$maybespace$RED$s
    fi
    maybespace=" "
  done

  l_ps1="$c1$USER$c2@$c3$host $c4$PARENTS $c5$PWD $c6$status_output "
  r_ps1=" $change_name $c7$date"

  local space_count=$((- ($c_l_ps1 + $c_r_ps1)))
  local dashes="${GREY}$(line "$SEP_STRING" 1 $space_count)"
  echo -n "$rst\n$l_ps1$dashes$r_ps1\n$rst> "
}

make_prompt2 () {
  prompt_maker="make_prompt2"
  local last_status=${PIPESTATUS[*]}
  local host=$HOST
  local parents=$PARENTS
  local user=$USER
  local path=$PWD
  local date=""
  if [ $PRINTF_FOR_DATE ]; then
    date=$(printf '%(%Y-%m-%d %H:%M:%S)T' -1);
  else
    date=$(date +%Y-%m-%d\ %H:%M:%S)
  fi

  # at around 100ms, the following is the slowest thing in this function.
  local change_name=$(get_change_name)

  if $ISROOT; then
    user="$RED$BOLD$user$RST"
  else
    user="$YELLOW$user"
  fi
  # REDSHELL documents findings of find_parent (which sets/clears it)
  if [[ $REDSHELL -eq 1 || $SHLVL -eq 1 || ( $0 =~ ^- && $SHLVL -eq 2 ) ]]; then
    parents="$RED$parents"
  # Unfortunately, because of a buggy interaction with mosh, SHLVL will not
  # equal 1 (it will equal two).
  #if [[ $SHLVL -eq 1 ]]; then # this shell is root shell of the tty session.
    c4=$RED                 # and so it shall become red to warn the user...
  else
    parents="$PURPLE$parents"
  fi
  if $ISDEVHOST; then       # I'm on my dev server.
    # and so it shall become boldly blue...
    host="$LIGHT_BLUE$host$RST"
  else
    host="$GREEN$host"
  fi

  local status_output=""
  local maybespace=""
  for s in $last_status; do
    if [[ $s -eq 0 ]]; then
      status_output=$status_output$maybespace$GREEN$s
    else
      status_output=$status_output$maybespace$RED$s
    fi
    maybespace=" "
  done

  local l_ps1="$user$WHITE@$host $parents $BLUE$PWD $status_output "
  local r_ps1=" $change_name $ORANGE$date"
  local count_me="$(strip_colors "$l_ps1$r_ps1")"
  local space_count=$(( -${#count_me} ))
  local dashes="${GREY}$(line "$SEP_STRING" 1 $space_count)"
  echo -n "$RST\n$l_ps1$dashes$r_ps1$RST\n> "
}

set_prompt() {
  PS1="$(make_prompt)"
}

# Cause PS1 to be set for each command-line by calling function set_prompt
# for each prompt.
export PROMPT_COMMAND="set_prompt 2>/dev/null"

#end of bashrc
