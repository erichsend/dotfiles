# Simple loop wrapper around jira-cli
# Consider passing in the parent if known, and the type...
function jirepl() {
  issue=$1
  parent=$2
  clear
  jira issue view $issue --plain
  if [ -z "$parent"  ]; then echo "This issue does not have a parent"; else echo "This issue has a parent: $parent"; fi;
  while echo "What's Next for ${issue}?" && read -sk && [[ $REPLY != q ]]; do echo $REPLY && case $REPLY in
    # Change current issue
    a) jira issue assign $issue;;
    e) jira issue edit $issue;;
    m) jira issue move $issue;;
    o) jira open $issue;;
    v) jira issue view $issue --plain;;

    # Quick-Change Commands
    A) echo "Adding Component: admin-cx-tool" && jira issue edit $issue -Cadmin-cx-tool --no-input ;;
    B) echo "Adding Component: billing-provisioning" && jira issue edit $issue -Cbilling-provisioning --no-input ;;
    D) echo "Adding Label: deprioritized" && jira issue edit $issue -ldeprioritize --no-input ;;
    G) echo "Ading Component: kongponents" && jira issue edit $issue -Ckongponents --no-input ;;
    K) echo "Adding Component: konnect-backend" && jira issue edit $issue -Ckonnect-backend --no-input ;;
    N) echo "Adding Label: needs-refinement" && jira issue edit $issue -lneeds-refinement --no-input ;;
    P) echo "Adding Label: prioritized" && jira issue edit $issue -lprioritize --no-input ;;
    R) echo "Adding Component: runtime-manager" && jira issue edit $issue -Cruntime-manager --no-input ;;
    S) echo "Adding Component: service-hub" && jira issue edit $issue -Cservice-hub --no-input ;;
    U) echo "Adding Component: konnect-ui" && jira issue edit $issue -Ckonnect-ui --no-input ;;

    # TMUX Commands 
    1) #echo "open parent (needs to send parent from context)" ;;
       if [ -z "$parent"  ]; 
         then echo "Cannot open parent - Issue does not have a Parent Key";
         else remoteJimux "b" && break  
       fi ;;
    2) echo "open siblings in left nav (needs to send parent from context)" ;;
    3) echo "open children in left nav" ;;
    ## Epic Workflow: Search epics. Choose epic. (3) shows stories. Choose story. (3) shows subtasks. Select subtask. (1) goes back to story. (2) shows other stories in epic. (1) goes back to epic. 
    x) remoteJimux "b" && break ;;
    *) echo "Try again..." ;;
    esac
  done
}
