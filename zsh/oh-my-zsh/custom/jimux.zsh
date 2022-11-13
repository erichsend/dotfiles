#!/bin/zsh
JIMUX_DIR="$XDG_CONFIG_HOME/jimux"
LIST_FILE_BASE="$JIMUX_DIR/jimux-list"
LOG_FILE_BASE="$JIMUX_DIR/jimux-log"
JIMUX_CONFIG_FILE="$JIMUX_DIR/jimux.conf" 

JIRPL_USAGE=$(cat <<-END
# Interactive Commands
(a)ssign    (e)dit    (m)ove
(v)iew      (o)pen in Browser     

# Quick-Change Components (Add)
(A)dmin-cx-tool    (B)illing-provisioning
(R)untime-manager  (S)ervice-hub
(U)onnect-ui

# Quick-Change Labels (Add)
(K)onnect-backend
(N)eeds-refinement
(P)rioritized
(D)eprioritized

# Quick Transition
(C)lose

(x) Next Issue
(?) Search History
(!) Refresh List (not implemented)

END
)

function _searchHistory() {
  tmux display-popup "tail -r $LOG_FILE | fzf"
} 

function _printStatus() {
  clear
  echo "${BIPurple}"
  echo "Tickets Remaining: $(cat $LIST_FILE | wc -l)\n\n"
  echo "${BIBlue}Coming Up...${Blue}"
  sed -n '2,10p' $LIST_FILE | cut -f 1-2 | cut -c -100
  echo "${BIGreen}\n\nJiREPL Key Bindings"
  echo "${Green}\n$JIRPL_USAGE"
  echo "\n${Color_Off}"
  echo "${BICyan}Recent History..."
  tail -n 10 $LOG_FILE | nl | sort -nr | cut -f 2-
}


function _startJirepl() {
  tmux send -t right "q" Enter "clear" Enter \
    "jirepl $LIST_FILE $LOG_FILE" Enter
  tmux select-pane -t right
}

function jimux() {
  mkdir -p $JIMUX_DIR
  clear
  _setSearchLoop
   clear
  _printStatus
  tmux split-window -h -l 55%
  _startJirepl
  while read -sk; do
    case $REPLY in
      s) _printStatus ;;
      h) _searchHistory ;;
      y) clear &&  tmux select-pane -t left && _setSearchLoop && clear && _printStatus && _startJirepl;;
      z) clear && tmux kill-pane -t right && _setSearchLoop && clear && _printStatus && tmux split-window -h -l 55% && _startJirepl;;
      q) tmux kill-window ;;
      *) echo "Try again..." ;;
    esac
  done
}

function _listSummary() {
  echo "${BIPurple}Select a Search: ${Color_Off}\n"
  for file in "$JIMUX_DIR/"*list*;do
    _searchNumber="${file##*.}"
    _search=$(sed -n "${_searchNumber}p" $JIMUX_CONFIG_FILE | cut -f1 -d '|')
    _listFile="${LIST_FILE_BASE}.${_searchNumber}"
    _timeStamp=$(date -r ${_listFile} +'%m/%d @ %H:%M')
    _listSize=$(wc -l < $_listFile | xargs)
    echo "${BIPurple}${_searchNumber}: ${BICyan}${_search} ${Green}[Total Issues: ${_listSize}] ${Blue}[Last Updated: ${_timeStamp}]\n"
  done
  echo "${BIPurple}Or press R to Refresh All${Color_Off}\n"
}

function _setSearchLoop() {
  _listSummary
  _selection=""
  # selection=$(cat $JIMUX_CONFIG_FILE | cut -f1 -d '|' | fzf --height 40% --reverse)
  while read -sk ; do
    case $REPLY in
      [1-9]) _selection=$(sed -n "${REPLY}p" $JIMUX_CONFIG_FILE | cut -f1 -d '|') && break ;;
      q) tmux kill-window ;;
      R) _refreshLists && _listSummary ;;
      *) echo "Try again..." ;;
    esac
  done
  echo "${Cyan}Loading Jimux for >>> ${BIYellow}$_selection${Color_Off}"
  _loadList $_selection
}

function _loadList() {
  # determine list names
  lineNum=$(grep -n $1 $JIMUX_CONFIG_FILE | cut -f1 -d ':')
  LIST_FILE="${LIST_FILE_BASE}.$lineNum"
  LOG_FILE="${LOG_FILE_BASE}.$lineNum"

  # populate with results from jira
  query=$(grep $1 $JIMUX_CONFIG_FILE | cut -f2 -d '|')
  local _jira_cmd="jira issue list -q \"$(echo $query | xargs)\" --plain --columns key,summary,status,assignee | tail -n +2"
  (eval $_jira_cmd) > $LIST_FILE
}

# used by refereshAll, otherwise only used from jirepl on current list
function _refreshLists() {
  clear
  while read -s line
  do
    echo "${BIYellow}Updating List: $(echo $line | cut -f1 -d '|' )... ${Color_Off}"
    lineNum=$(grep -n $line $JIMUX_CONFIG_FILE | cut -f1 -d ':')
    touch "${LIST_FILE_BASE}.$lineNum"
    query=$(echo $line | cut -f2 -d '|')
    local _jira_cmd="jira issue list -q \"$(echo $query | xargs)\" --plain --columns key,summary,status,assignee | tail -n +2"
    (eval $_jira_cmd) > "${LIST_FILE_BASE}.$lineNum"
    echo "${Green}\t\t\tUpdated! Issues Found:$(cat ${LIST_FILE_BASE}.$lineNum | wc -l)\n\n"
  done < $JIMUX_CONFIG_FILE
  sleep 2
  clear
}

#######
# The section below defines functions meant to be called from 'jrepl'. 
# Just doing this to keep all of the tmux commands in one file.
#########
# Assumes we are already in a side-by-side jimux/jrepl split
function remoteKey() {
  tmux send -t left "$1"
}
