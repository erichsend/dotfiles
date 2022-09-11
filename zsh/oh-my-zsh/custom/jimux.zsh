# Colors (https://ethanschoonover.com/solarized/#usage-development)
_epic_border="#cb4b16" # Orange
_epic_issue_border="#dc322f" # Red
_sprint_border="#6c71c4" # Violet
_sprint_issue_border="#2aa198" # Blue
_subtask_border="#859900" # Green

# Helper function since jira-cli has no way to get an issue parent
# Note: ${JIRA_BASIC} must be set on the environment
# JIRA_BASIC=$(echo -n david.erichsen@konghq.com:${JIRA_API_TOKEN} | base64)
function _getParent(){
  curl --request GET \
    --url "https://konghq.atlassian.net/rest/api/3/issue/${1}" \
    --header "Authorization: Basic ${JIRA_BASIC}" \
    --header 'Accept: application/json' --silent | jq -r '.fields.parent.key'
}

# Primary Search Behavior
# - Load a search based on parameters
# - On return, start jira-cli "issue loop" in "issue" panel
# - Repeat
# $1 should be the jira cli subcommand and flags, i.e. "sprint list --current"
# $2 should be JQL (within context of default project)
# $3 should be the border color to use
#
# Changes: send the args to jirepl so it can refresh 
# Consider: 
# - all searches are issue searches (gets rid of 'subcommand'). use jql for sprint= or type=epic.
# - JQL is already passed in
# - Need to accept an 'original search context', or set originalSearchContect=jql if not passed in
# - Need to send original seach context to jrepl.
function _jiraSearchLoop() {
  clear
  while true
  do
    _jira_cmd="jira issue list -q '$1' --plain --columns key,type,summary,status,assignee | tail -n +2 | fzf --height 100% --border --color 'border:$2' | cut -f 1"
    _key=$(eval $_jira_cmd)
    if [ -z "$_key"  ]; then break; fi
    parent=$(_getParent $_key)
    tmux send -t right "q" Enter "clear" Enter \
          "jirepl $_key $parent" Enter
    tmux select-pane -t right
  done
  clear
}

# others could be 'refine triage' for needs refinement, etc
function jiraIssueBacklogTriage() {
	_jiraSearchLoop "type in standardIssueTypes() AND statusCategory != Done AND (component not in (billing-provisioning, runtime-manager, admin-cx-tool, service-hub, konnect-backend, konnect-ui, users-teams, kongponents, kong-auth-elements) OR component is EMPTY) AND project = KHCP" "$_subtask_border"
}

# Should take flag args like
# -k KHCP-1234  -- to open the issue with subtasks on left (would pass parent from stack to re-open parent)
# -f backlog  -- to provide a filter option
# -n -- to automatically open the first result of the search if -s is provided
function jimux() {
  # Reset the window
  clear
  tmux kill-pane -a
  tmux split-window -h -l 65%
  tmux select-pane -t left
  if [ $1 = "b" ]; then 
    jiraIssueBacklogTriage
  elif [ $1 = "p" ]; then
    echo "change this to check for a khcp key, open jirepl on right with parent. Do not change left sidebar (have a jimux function that simply kills jrepl, opens the new ticket in jrepl, and and adds it to the jrepl stack)"
  else
    echo "Pick a search: (b)acklog" && read -sk
    case $REPLY in
      b) jiraIssueBacklogTriage;;
    esac
  fi
}

#######
# The section below defines functions meant to be called from 'jrepl'. 
# Just doing this to keep all of the tmux commands in one file.
#########
# Assumes we are already in a side-by-side jimux/jrepl split
function remoteJimux() {
  tmux select-pane -t left
  # tmux split-window -bh -l 35%
  tmux send -t left C-c
  tmux send -t left C-c "jimux $@" Enter
}

######
# Evertying below is considered deprecated.
# Just keeping for reference until refactor is complete.
######

# Two-step search: find epic and start issue search.
# Deprecate: Use regular search with type=epic and then in jrepl use 'list children'
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

# Do we need these? Seems like the thing calling this could send the jql right to loop since we
# only want issue+jql searches.

# add one of these for "stories with same parent as passed in issue"
# Needs to take in originalSearchContect
function jiraIssueSiblingList() {
  _jiraSearchLoop "issue list $1" "$2" "$_subtask_border"
}

# These need to forward the originalSearchContect
# This should be rewritten to use issue list with -P=epic
function jiraEpicIssueList() {
  _jiraSearchLoop "epic list $1" "$2" "$_epic_issue_border"
}

# These need to forward the originalSearchContect
function jiraIssueSubtaskList() {
  _jiraSearchLoop "issue list -P $1" "$2" "$_subtask_border"
}

####################################
# Search loops without issue keys  #
# To be re-used with different JQL #
# $1 should be JQL                 #
####################################
# Deprecate
function jiraCurrentSprintList() {
  _jiraSearchLoop "sprint list --current" "$1" "$_sprint_issue_border"
}

#Deprecate
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
alias jssm="jiraCurrentSprintList 'assignee = 61b8ce29401429007007bc36'"

# Sprint Items in Progress
alias jssp="jiraCurrentSprintList 'status in (\"In Progress\")'"

##### Epics #####
# All (e)pics in default project that are not resolved or done
alias jse="jiraEpicsList 'status not in (Resolved, Done)'"

# All helium epics
alias jseh="jiraEpicsList 'status not in (Resolved, Done) AND labels in (helium, hydrogen)'"

