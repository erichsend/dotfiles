# Simple loop wrapper around jira-cli
# Consider passing in the parent if known, and the type...
function jirepl() {
  issue=$1
  clear
  jira issue view $1 --plain
  while echo "What's Next for ${issue}?" && read -sk && [[ $REPLY != q ]]; do case $REPLY in
    v) jira issue view $1 --plain;;
    e) jira issue edit $1;;
    m) jira issue move $1;;
    a) jira issue assign $1;;
    o) jira open $1;;
    s) jira issue create -P $issue;;
    *) echo "Try again..."
    esac
  done
}
