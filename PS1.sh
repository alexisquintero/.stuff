branchStatus () {
  MAINCHAR="❙"
  MAINBEHINDCHAR="❰"
  MAINAHEADCHAR="❱"
  CURRENTCHAR="❙"
  CURRENTBEHINDCHAR="❰"
  CURRENTAHEADCHAR="❱"
  DETACHEDCHAR="━"
  PROBLEMCHAR="𝌐"
  REBASECHAR="?"
  BISECTCHAR="⇲"

  EDITEDFILESCOLOR="\001\e[32m\002"
  DETACHEDCOLOR="\001\e[91m\002"

  OUTPUT=""
  #Check if it's a new repository
  if [[ -z `git branch` ]]
  then
    OUTPUT+=$MAINCHAR
    echo -e $OUTPUT
    return
  fi

  #Rebase in progress
  if [[ -n `git branch -v | grep "no branch, rebasing"` ]]
  then
    OUTPUT+=$REBASECHAR
    echo -e $OUTPUT
    return
  fi

  #Bisect in progress
  if [[ -n `git branch -v | grep "no branch, bisect"` ]]
  then
    OUTPUT+=$BISECTCHAR
    echo -e $OUTPUT
    return
  fi

  #Check if detached
  if [[ -n `git branch -v | grep "HEAD detached "` ]]
  then
    OUTPUT+=$DETACHEDCOLOR$DETACHEDCHAR
    echo -e $OUTPUT
    return
  fi

  REMOTES=$(git remote)
  FLAG=true
  REMOTE=""
  for remote in $REMOTES
  do
    while [ "$FLAG" == "true" ]
    do
      REMOTE=$remote
      FLAG=false
    done
  done
  CURRENT=$(git symbolic-ref --short -q HEAD)

  MAINBRANCH="master"
  DEVELOP="develop"
  #Check if develop exists
  if [[ -n `git branch | egrep "^[*]{0,1}[[:space:]]+${DEVELOP}$"` ]]
  then
    MAINBRANCH=$DEVELOP
  #Check if master exists
  elif [[ -z `git branch | egrep "^[*]{0,1}[[:space:]]+${MAINBRANCH}$"` ]]
  then
    MAINBRANCH=""
  fi

  if [[ -z $MAINBRANCH ]]
  then
    CURRENTUPSTREAM=$CURRENT
  else
    CURRENTUPSTREAM="$REMOTE/$CURRENT"
  fi
  #Check if current branch exists upstream
  if ! [ `git branch -r | egrep "^[[:space:]]+${CURRENTUPSTREAM}$"` ]
  then
    CURRENTUPSTREAM=$CURRENT
  fi

  UPSTREAMMAIN="$REMOTE/$MAINBRANCH"
  #Check if main branch exists upstream
  if ! [ `git branch -r | egrep "^[[:space:]]+${UPSTREAMMAIN}$"` ]
  then
    UPSTREAMMAIN=$MAINBRANCH
  fi

  RPCURRENT=$(git rev-parse $CURRENT)
  RPCURRENTUPSTREAM=$(git rev-parse $CURRENTUPSTREAM)

  #Check if there are edited files
  if [[ ! -z $(git status -s) ]]
  then
    OUTPUT+=$EDITEDFILESCOLOR
  fi
  #Check if current is up to date
  if [ $RPCURRENT = $RPCURRENTUPSTREAM ]
  then
    OUTPUT+=$CURRENTCHAR
  else
    #Check if current is ahead
    if [ `git log --format='%H' ${CURRENTUPSTREAM} | egrep "^${RPCURRENT}$"` ]
    then
      #NOT ahead
      OUTPUT+=$CURRENTBEHINDCHAR
    else
      #Ahead
      #Check if current is behind
      if [ `git log --format='%H' | egrep "^${RPCURRENTUPSTREAM}$"` ]
      then
        #NOT behind
        OUTPUT+=$CURRENTAHEADCHAR
      else
        #Behind
        OUTPUT+=$PROBLEMCHAR
      fi
    fi
  fi
  #Check current != main
  if  [[ -z $MAINBRANCH ]] || [ $CURRENT = $MAINBRANCH ]
  then
    echo -e $OUTPUT
    return
  fi

  RPMAINBRANCH=$(git rev-parse $MAINBRANCH)
  RPUPSTREAMMAIN=$(git rev-parse $UPSTREAMMAIN)

  #Check if main is up to date
  if [[ -n `git log --format='%H' | grep ${RPUPSTREAMMAIN}` ]]
  then
    OUTPUT+=$MAINCHAR
  else
    OUTPUT+=$MAINBEHINDCHAR
  fi
  echo -e $OUTPUT
}

insideGit () {
  if git rev-parse --git-dir > /dev/null 2>&1; then
    #echo "inside git repo"
    echo $(branchStatus)
    git fetch > /dev/null 2>&1 &
  else
    echo '⬥'
  fi
}

KHAKI="\001\e[38;2;195;163;138m\002"

LYELLOW="\[\e[93m\]"

BOLD="\[\e[1m\]"
NORMAL="\[\e[21m\]"

RESET="\[\e[0m\]"
