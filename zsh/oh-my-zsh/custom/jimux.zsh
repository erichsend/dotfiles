#!/bin/zsh
# Is it bad? Yes. Does it work? Yes.
LIST_FILE="$HOME/.config/.jira/.jimux.tmp"

# Reset
Color_Off='\033[0m'       # Text Reset

# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

# Bold
BBlack='\033[1;30m'       # Black
BRed='\033[1;31m'         # Red
BGreen='\033[1;32m'       # Green
BYellow='\033[1;33m'      # Yellow
BBlue='\033[1;34m'        # Blue
BPurple='\033[1;35m'      # Purple
BCyan='\033[1;36m'        # Cyan
BWhite='\033[1;37m'       # White

# Underline
UBlack='\033[4;30m'       # Black
URed='\033[4;31m'         # Red
UGreen='\033[4;32m'       # Green
UYellow='\033[4;33m'      # Yellow
UBlue='\033[4;34m'        # Blue
UPurple='\033[4;35m'      # Purple
UCyan='\033[4;36m'        # Cyan
UWhite='\033[4;37m'       # White

# Background
On_Black='\033[40m'       # Black
On_Red='\033[41m'         # Red
On_Green='\033[42m'       # Green
On_Yellow='\033[43m'      # Yellow
On_Blue='\033[44m'        # Blue
On_Purple='\033[45m'      # Purple
On_Cyan='\033[46m'        # Cyan
On_White='\033[47m'       # White

# High Intensity
IBlack='\033[0;90m'       # Black
IRed='\033[0;91m'         # Red
IGreen='\033[0;92m'       # Green
IYellow='\033[0;93m'      # Yellow
IBlue='\033[0;94m'        # Blue
IPurple='\033[0;95m'      # Purple
ICyan='\033[0;96m'        # Cyan
IWhite='\033[0;97m'       # White

# Bold High Intensity
BIBlack='\033[1;90m'      # Black
BIRed='\033[1;91m'        # Red
BIGreen='\033[1;92m'      # Green
BIYellow='\033[1;93m'     # Yellow
BIBlue='\033[1;94m'       # Blue
BIPurple='\033[1;95m'     # Purple
BICyan='\033[1;96m'       # Cyan
BIWhite='\033[1;97m'      # White

# High Intensity backgrounds
On_IBlack='\033[0;100m'   # Black
On_IRed='\033[0;101m'     # Red
On_IGreen='\033[0;102m'   # Green
On_IYellow='\033[0;103m'  # Yellow
On_IBlue='\033[0;104m'    # Blue
On_IPurple='\033[0;105m'  # Purple
On_ICyan='\033[0;106m'    # Cyan
On_IWhite='\033[0;107m'   # White

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


(x) Next Issue
(?) Show History (not implemented)
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

function _loadList() {
  local _jira_cmd="jira issue list -q '$1' --plain --columns key,summary | tail -n +2"
  (eval $_jira_cmd) > $LIST_FILE
}

function _printStatus() {
  clear
  echo "${BIPurple}"
  echo "Tickets Remaining: $(cat $LIST_FILE | wc -l)\n\n"
  echo "${BIBlue}Coming Up...${Blue}"
  sed -n '2,10p' $LIST_FILE
  echo "----------------------------------"
  echo "${BIGreen}\n\nJiREPL Key Bindings"
  echo "${Green}\n$JIRPL_USAGE${Color_Off}"
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
      *) echo "Try again..." ;;
    esac
  done
}

# others could be 'refine triage' for needs refinement, etc
function jiraIssueBacklogTriage() {
	_jiraSearchLoopCache "type in standardIssueTypes() AND type != Epic AND statusCategory != Done AND (component not in (billing-provisioning, runtime-manager, admin-cx-tool, service-hub, konnect-backend, konnect-ui, users-teams, kongponents, kong-auth-elements) OR component is EMPTY) AND project = KHCP"
}

function jimux2() {
  # Reset the window
  clear
  tmux kill-pane -a
  tmux split-window -h -l 65%
  tmux select-pane -t left
  if [[ $1 == "b" ]]; then 
    jiraIssueBacklogTriage
  elif [[ $1 == "p" ]]; then
    echo "change this to check for a khcp key, open jirepl on right with parent. Do not change left sidebar (have a jimux function that simply kills jrepl, opens the new ticket in jrepl, and and adds it to the jrepl stack)"
  else
    echo "Pick a search: (b)acklog" && read -sk
    case $REPLY in
      b) jiraIssueBacklogTriage;;
    esac
  fi
}

####### -- This should be changed to probably be some kind of List Reload and restart repl
# The section below defines functions meant to be called from 'jrepl'. 
# Just doing this to keep all of the tmux commands in one file.
#########
# Assumes we are already in a side-by-side jimux/jrepl split
function remoteRefresh() {
  tmux send -t left "s"
}

######
# Evertying below is considered deprecated.
# Just keeping for reference until refactor is complete.
# Re-use some of the searches and feed them into the cache list
######

# Two-step search: find epic and start issue search.
# Deprecate: Use regular search with type=epic and then in jrepl use 'list children'
function jiraQuickEpicSearch() {
  clear
  _jira_cmd="jira epic list --table --plain --columns key,status,summary | fzf --height 100% --border --color 'border:$_epic_border' | cut -f 1"
 _iss=$(eval $_jira_cmd)
 jiraEpicIssueList $_iss
}

