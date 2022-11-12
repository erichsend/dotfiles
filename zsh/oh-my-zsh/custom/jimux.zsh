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

# Helper function since jira-cli has no way to get an issue parent
# Note: ${JIRA_BASIC} must be set on the environment
# JIRA_BASIC=$(echo -n david.erichsen@konghq.com:${JIRA_API_TOKEN} | base64)
function _getParent() {
  curl --request GET \
    --url "https://konghq.atlassian.net/rest/api/3/issue/${1}" \
    --header "Authorization: Basic ${JIRA_BASIC}" \
    --header 'Accept: application/json' --silent | jq -r '.fields.parent.key'
}

function _searchHistory() {
  tmux display-popup "tail -r $LOG_FILE | fzf"
} 

function _loadList() {
  local _jira_cmd="jira issue list -q \"$(echo $1 | xargs)\" --plain --columns key,summary,status,assignee | tail -n +2"
  (eval $_jira_cmd) > $LIST_FILE
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
  # this looks bad. Maybe only do it on search change or refresh
  _listSummary
}

function _resetSearch() {
  LIST_FILE=$LIST_FILE_BASE.$1
  LOG_FILE=$LOG_FILE_BASE.$1
  _printStatus
  tmux send -t right "q" Enter "clear" Enter \
    "jirepl $LIST_FILE $LOG_FILE" Enter
  tmux select-pane -t right
}

function _jiraSearchLoopCache() {
   clear
  _loadList $1
  _printStatus
  tmux send -t right "q" Enter "clear" Enter \
    "jirepl $LIST_FILE $LOG_FILE" Enter
  tmux select-pane -t right
  while read -sk && [[ $REPLY != q ]]; do
    case $REPLY in
      s) _printStatus ;;
      h) _searchHistory ;;
      [0-9]) _resetSearch $REPLY ;;
      *) echo "Try again..." ;;
    esac
  done
}

function _listSummary() {
  for file in "$JIMUX_DIR/"*list*;do
    _searchNumber="${file##*.}"
    _search=$(sed -n "${_searchNumber}p" $JIMUX_CONFIG_FILE | cut -f1 -d '|')
    _listFile="${LIST_FILE_BASE}.${_searchNumber}"
    _timeStamp=$(date -r ${_listFile} +'%m/%d @ %H:%M')
    _listSize=$(wc -l < $_listFile | xargs)
    echo "${BIPurple}(press ${_searchNumber}) ${Green}[${_listSize}]\t${Yellow}${_timeStamp}\t${BICyan}${_search}${Color_Off}"
  done
}

function jimux() {
  mkdir -p $JIMUX_DIR
  tmux kill-pane -a
  clear
  selection=$(cat $JIMUX_CONFIG_FILE | cut -f1 -d '|' | fzf)
  tmux split-window -h -l 55%
  tmux select-pane -t left
  clear
  query=$(grep $selection $JIMUX_CONFIG_FILE | cut -f2 -d '|')
  lineNum=$(grep -n $selection $JIMUX_CONFIG_FILE | cut -f1 -d ':')
  LIST_FILE="${LIST_FILE_BASE}.$lineNum"
  LOG_FILE="${LOG_FILE_BASE}.$lineNum"
	_jiraSearchLoopCache $query
}

#######
# The section below defines functions meant to be called from 'jrepl'. 
# Just doing this to keep all of the tmux commands in one file.
#########
# Assumes we are already in a side-by-side jimux/jrepl split
function remoteKey() {
  tmux send -t left "$1"
}
