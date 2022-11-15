#!/bin/zsh

function _popList() {
  _result=$(head -n 1 $LIST_FILE)
  sed -i.bak '1d' $LIST_FILE && rm $LIST_FILE.bak
  echo $_result
}

function _addToSprint() {
  echo "Select a Sprint..."
  _optNum=1
  while read -s line
  do
    echo "(${_optNum}) $(echo $line | jq .name)"
    (( _optNum++ ))
  done < $JIMUX_SPRINT_FILE
  while read -sk; do
    case $REPLY in
      [1-9])
        _selectedLine=$(sed -n "${REPLY}p" $JIMUX_SPRINT_FILE)
        echo "Adding to Sprint $(echo $_selectedLine | jq .name)"
        jira sprint add $(echo $_selectedLine | jq .id) $1
        break ;;
      *) echo "Try again..." ;;
    esac
  done
}

function _printCurrentTicket () {
  echo "\n\n${Blue}Current Ticket:\n${BIBlue}$(echo $1 | sed -E 's/\t+/  ||  /g')\n\n${Color_Off}"
}

function _logChange () {
  echo "$(date +'%m/%d @ %H:%M') -- $1" | tee -a ${LOG_FILE}
}

# Helper function since jira-cli has no way to get an issue parent
# Note: ${JIRA_BASIC} must be set on the environment
# JIRA_BASIC=$(echo -n david.erichsen@konghq.com:${JIRA_API_TOKEN} | base64)
function _viewParent() {
  jira issue view --plain $(curl --request GET \
    --url "https://konghq.atlassian.net/rest/api/3/issue/${1}" \
    --header "Authorization: Basic ${JIRA_BASIC}" \
    --header 'Accept: application/json' --silent | jq -r '.fields.parent.key')
}
function jirepl() {
  clear
  LIST_FILE=$1
  LOG_FILE=$2
  _line=$(_popList)
  key=$(cut -f 1 <<< $_line)
  _printCurrentTicket $_line
  while echo "${BWhite}Choose an action\n${Color_Off}" && read -sk; do case $REPLY in
    # Jira Commands
    a) _logChange "$key | Assigned" && jira issue assign $key ;;
    e) _logChange "$key | Edited" && jira issue edit $key ;;
    m) _logChange "$key | Moved" && jira issue move $key ;;
    o) echo "Opening Issue...\n\n\n" && jira open $key ;;
    p) echo "Fetching Parent...\n\n\n" && _viewParent $key ;;
    s) _addToSprint $key ;;
    v) echo "Fetching Issue...\n\n\n" && jira issue view $key --plain ;;

    # Quick-Change Commands
    # Consider making the component add be a function, and having it remove other components.
    # Consider adding to a 'history' array to display on next issue
    A) _logChange "$key | Adding Component: admin-cx-tool" && jira issue edit $key -Cadmin-cx-tool --no-input ;;
    B) _logChange "$key | Adding Component: billing-provisioning" && jira issue edit $key -Cbilling-provisioning --no-input ;;
    C) _logChange "$key | Closing Issue" && jira issue move $key "Resolved" ;;
    D) _logChange "$key | Adding Label: deprioritized" && jira issue edit $key -ldeprioritize --no-input ;;
    K) _logChange "$key | Adding Component: konnect-backend" && jira issue edit $key -Ckonnect-backend --no-input ;;
    N) _logChange "$key | Adding Label: needs-refinement" && jira issue edit $key -lneeds-refinement --no-input ;;
    P) _logChange "$key | Adding Label: prioritized" && jira issue edit $key -lprioritize --no-input ;;
    R) _logChange "$key | Adding Component: runtime-manager" && jira issue edit $key -Cruntime-manager --no-input ;;
    S) _logChange "$key | Adding Component: service-hub" && jira issue edit $key -Cservice-hub --no-input ;;
    U) _logChange "$key | Adding Component: konnect-ui" && jira issue edit $key -Ckonnect-ui --no-input ;;

    # TMUX Commands 
    x) 
      _line=$(_popList)
      key=$(cut -f 1 <<< $_line)
      clear
      _printCurrentTicket
      remoteKey "s"
      ;;
    \?) 
      echo "Displaying History...\n\n\n"
      remoteKey "h" ;;
    z) remoteKey "z" ;;
    q) remoteKey "q" ;;
    *) echo "Try again..." ;;
    esac
  done
}
