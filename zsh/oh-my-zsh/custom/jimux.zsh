# Colors (https://ethanschoonover.com/solarized/#usage-development)
_epic_border="#cb4b16" # Orange
_epic_issue_border="#dc322f" # Red
_sprint_border="#6c71c4" # Violet
_sprint_issue_border="#2aa198" # Blue
_subtask_border="#859900" # Green

# Primary Search Behavior
# - Load a search based on parameters
# - On return, start jira-cli "issue loop" in "issue" panel
# - Repeat
# $1 should be the jira cli subcommand and flags, i.e. "sprint list --current"
# $2 should be JQL (within context of default project)
# $3 should be the border color to use
function _jiraSearchLoop() {
  clear
  while true
  do
    _jira_cmd="jira $1 -q '$2' --plain --columns key,type,status,assignee,summary | fzf --height 100% --border --color 'border:$3' | cut -f 1"
    _key=$(eval $_jira_cmd)
    if [ -z "$_key"  ]; then break; fi
    tmux send -t right "clear" Enter \
  	  "jira issue view $_key --plain" Enter
  done
  clear
}

# Two-step search: find epic and start issue search.
function jiraQuickEpicSearch() {
  clear
  _jira_cmd="jira epic list --table --plain --columns key,status,summary | fzf --height 100% --border --color 'border:$_epic_border' | cut -f 1"
 _iss=$(eval $_jira_cmd)
 jiraEpicIssueList $_iss
}

####################################
#  Search loops for specific issue #
#  collections                     #
#  $1 should be an issue key       #
#  $2 should be a JQL              #
####################################

function jiraEpicIssueList() {
  _jiraSearchLoop "epic list $1" "$2" "$_epic_issue_border"
}

function jiraIssueSubtaskList() {
  _jiraSearchLoop "issue list -P $1" "$2" "$_subtask_border"
}

####################################
# Search loops without issue keys  #
# To be re-used with different JQL #
# $1 should be JQL                 #
####################################
function jiraCurrentSprintList() {
  _jiraSearchLoop "sprint list --current" "$1" "$_sprint_issue_border"
}

function jiraEpicsList() {
  _jiraSearchLoop "epic list --table" "$1" "$_epic_border"
}

##########################
# Search Aliases         #
# mnemonic:              #
# js*  (jira search *)   #
########################## 

##### Sprints #####
# Unfinished stories or tasks in current (s)print
alias jss="jiraCurrentSprintList 'type in (Story, Task) AND status not in (Resolved, Done)'" 

# Current (s)print Items in (r)eview
alias jssr="jiraCurrentSprintList 'status in (\"In Review\")'"

# Sprint Items in Verification
alias jssv="jiraCurrentSprintList 'status in (\"In Verification\")'"

# Sprint Items in Progress
alias jssp="jiraCurrentSprintList 'status in (\"In Progress\")'"

##### Epics #####
# All (e)pics in default project that are not resolved or done
alias jse="jiraEpicsList 'status not in (Resolved, Done)'"

# All helium epics
alias jseh="jiraEpicsList 'status not in (Resolved, Done) AND labels in (helium, hydrogen)'"

