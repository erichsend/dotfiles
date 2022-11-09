#!/bin/zsh

function _popList() {
  _result=$(head -n 1 $LIST_FILE)
  sed -i.bak '1d' $LIST_FILE && rm $LIST_FILE.bak
  echo $_result
}

function jirepl() {
  clear
  LIST_FILE=$1
  line=$(_popList)
  key=$(cut -f 1 <<< $line)
  echo "\n\n${Blue}Current Ticket:\n${BIBlue}$line\n\n${Color_Off}"
  while echo "${BWhite}Choose an action\n${Color_Off}" && read -sk && [[ $REPLY != q ]]; do case $REPLY in
    # Change current issue
    a) jira issue assign $key;;
    e) jira issue edit $key;;
    m) jira issue move $key;;
    o) jira open $key;;
    v) jira issue view $key --plain;;

    # Quick-Change Commands
    # Consider making the component add be a function, and having it remove other components.
    # Consider adding to a 'history' array to display on next issue
    A) echo "Adding Component: admin-cx-tool" && jira issue edit $key -Cadmin-cx-tool --no-input ;;
    B) echo "Adding Component: billing-provisioning" && jira issue edit $key -Cbilling-provisioning --no-input ;;
    D) echo "Adding Label: deprioritized" && jira issue edit $key -ldeprioritize --no-input ;;
    K) echo "Adding Component: konnect-backend" && jira issue edit $key -Ckonnect-backend --no-input ;;
    N) echo "Adding Label: needs-refinement" && jira issue edit $key -lneeds-refinement --no-input ;;
    P) echo "Adding Label: prioritized" && jira issue edit $key -lprioritize --no-input ;;
    R) echo "Adding Component: runtime-manager" && jira issue edit $key -Cruntime-manager --no-input ;;
    S) echo "Adding Component: service-hub" && jira issue edit $key -Cservice-hub --no-input ;;
    U) echo "Adding Component: konnect-ui" && jira issue edit $key -Ckonnect-ui --no-input ;;

    # TMUX Commands 
    x) 
      line=$(_popList)
      key=$(cut -f 1 <<< $line)
      clear
      echo "\n\nCurrent Ticket >>> $line\n"
      tmux send -t left "s"
      ;;
    # x) remoteJimux "b" && break ;;
    *) echo "Try again..." ;;
    esac
  done
}
