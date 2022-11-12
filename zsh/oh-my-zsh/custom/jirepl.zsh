#!/bin/zsh

function _popList() {
  _result=$(head -n 1 $LIST_FILE)
  sed -i.bak '1d' $LIST_FILE && rm $LIST_FILE.bak
  echo $_result
}

function _printCurrentTicket () {
  echo "\n\n${Blue}Current Ticket:\n${BIBlue}$(echo $line | sed -E 's/\t+/  ||  /g')\n\n${Color_Off}"
}

function _logChange () {
  echo "$(date +'%m/%d @ %H:%M') -- $1" | tee -a ${LOG_FILE}
}

function jirepl() {
  clear
  LIST_FILE=$1
  LOG_FILE=$2
  line=$(_popList)
  key=$(cut -f 1 <<< $line)
  _printCurrentTicket
  while echo "${BWhite}Choose an action\n${Color_Off}" && read -sk && [[ $REPLY != q ]]; do case $REPLY in
    # Change current issue
    a) _logChange "$key | Assigned" && jira issue assign $key;;
    e) _logChange "$key | Edited" && jira issue edit $key;;
    m) _logChange "$key | Moved" && jira issue move $key;;
    o) jira open $key;;
    v) jira issue view $key --plain;;

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
      line=$(_popList)
      key=$(cut -f 1 <<< $line)
      clear
      _printCurrentTicket
      remoteKey "s"
      ;;
    \?) 
      echo "Displaying History...\n\n\n"
      remoteKey "h" ;;
    [1-9]) remoteKey "${REPLY}" ;;
    *) echo "Try again..." ;;
    esac
  done
}
