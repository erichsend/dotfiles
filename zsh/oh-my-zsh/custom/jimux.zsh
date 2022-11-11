#!/bin/zsh
# Is it bad? Yes. Does it work? Yes.
LIST_FILE="$HOME/.config/.jira/.jimux.tmp"

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
  tmux display-popup "tail -r $LIST_FILE.log | fzf"
} 

function _loadList() {
  local _jira_cmd="jira issue list -q '$1' --plain --columns key,summary,status,assignee | tail -n +2"
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
  echo "${BICyan}Recent History..."
  tail -n 10 $LIST_FILE.log | sort -r
}

function _jiraSearchLoopCache() {
   clear
  _loadList $1
  _printStatus
  tmux send -t right "q" Enter "clear" Enter \
    "jirepl $LIST_FILE" Enter
  tmux select-pane -t right
  while read -sk && [[ $REPLY != q ]]; do
    case $REPLY in
      s) _printStatus ;;
      h) _searchHistory ;;
      *) echo "Try again..." ;;
    esac
  done
}

function jiraIssueBacklogTriage() {
	_jiraSearchLoopCache "type in standardIssueTypes() AND type != Epic AND statusCategory != Done AND (component not in (open-source,billing-provisioning, runtime-manager, admin-cx-tool, service-hub, konnect-backend, konnect-ui, users-teams, kongponents, kong-auth-elements) OR component is EMPTY) AND project = KHCP"
}

function jimux() {
  # Reset the window
  clear
  tmux kill-pane -a
  tmux split-window -h -l 55%
  tmux select-pane -t left
  jiraIssueBacklogTriage
}

#######
# The section below defines functions meant to be called from 'jrepl'. 
# Just doing this to keep all of the tmux commands in one file.
#########
# Assumes we are already in a side-by-side jimux/jrepl split
function remoteKey() {
  tmux send -t left "$1"
}
