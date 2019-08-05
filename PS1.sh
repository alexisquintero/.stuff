#!/bin/bash

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

  DETACHEDCOLOR="\001\e[91m\002"

  EVERYTHINGUNSTAGEDCOLOR="\001\e[91m\002"
  MIXEDSTAGEDUNSTAGEDCOLOR="\001\e[93m\002"
  EVEYTHINGSTAGEDCOLOR="\001\e[92m\002"

  OUTPUT=""
  #Check if it's a new repository
  if [ -z "$(git branch)" ]
  then
    OUTPUT=$OUTPUT$MAINCHAR
    printf "$OUTPUT"
    return
  fi

  #Rebase in progress
  if git branch -v | grep -q "no branch, rebasing"
  then
    OUTPUT=$OUTPUT$REBASECHAR
    printf "$OUTPUT"
    return
  fi

  #Bisect in progress
  if git branch -v | grep -q "no branch, bisect"
  then
    OUTPUT=$OUTPUT$BISECTCHAR
    printf "$OUTPUT"
    return
  fi

  #Check if detached
  if git branch -v | grep -q "HEAD detached "
  then
    OUTPUT=$OUTPUT$DETACHEDCOLOR$DETACHEDCHAR
    printf "$OUTPUT"
    return
  fi

  REMOTES=$(git remote)
  FLAG=true
  REMOTE=""
  for remote in $REMOTES
  do
    while [ "$FLAG" = "true" ]
    do
      REMOTE=$remote
      FLAG=false
    done
  done
  CURRENT=$(git symbolic-ref --short -q HEAD)

  MAINBRANCH="master"
  DEVELOP="develop"
  #Check if develop exists
  if git branch | grep -q -E "^[*]{0,1}[[:space:]]+${DEVELOP}$"
  then
    MAINBRANCH=$DEVELOP
  #Check if master exists
  elif [ -z "$(git branch | grep -E "^[*]{0,1}[[:space:]]+${MAINBRANCH}$")" ]
  then
    MAINBRANCH=""
  fi

  if [ -z $MAINBRANCH ]
  then
    CURRENTUPSTREAM=$CURRENT
  else
    CURRENTUPSTREAM="$REMOTE/$CURRENT"
  fi
  #Check if current branch exists upstream
  if ! [ "$(git branch -r | grep -E "^[[:space:]]+${CURRENTUPSTREAM}$")" ]
  then
    CURRENTUPSTREAM=$CURRENT
  fi

  UPSTREAMMAIN="$REMOTE/$MAINBRANCH"
  #Check if main branch exists upstream
  if ! [ "$(git branch -r | grep -E "^[[:space:]]+${UPSTREAMMAIN}$")" ]
  then
    UPSTREAMMAIN=$MAINBRANCH
  fi

  RPCURRENT=$(git rev-parse "$CURRENT")
  RPCURRENTUPSTREAM=$(git rev-parse "$CURRENTUPSTREAM")

  #Check if there are edited files
  STAGEDCHANGES=false
  UNSTAGEDCHANGES=false
  if [ -n "$(git diff)" ]
  then
    UNSTAGEDCHANGES=true
  fi
  if [ -n "$(git diff --staged)" ]
  then
    STAGEDCHANGES=true
  fi
  if [ "$STAGEDCHANGES" = "true" ]
  then
    if [ "$UNSTAGEDCHANGES" = "true" ]
    then
      OUTPUT=$OUTPUT$MIXEDSTAGEDUNSTAGEDCOLOR
    else
      OUTPUT=$OUTPUT$EVEYTHINGSTAGEDCOLOR
    fi
  else
    if [ "$UNSTAGEDCHANGES" = "true" ]
    then
      OUTPUT=$OUTPUT$EVERYTHINGUNSTAGEDCOLOR
    fi
  fi

  #Check if current is up to date
  if [ "$RPCURRENT" = "$RPCURRENTUPSTREAM" ]
  then
    OUTPUT=$OUTPUT$CURRENTCHAR
  else
    #Check if current is ahead
    if git log --format='%H' "${CURRENTUPSTREAM}" | grep -q -E "^${RPCURRENT}$"
    then
      #NOT ahead
      OUTPUT=$OUTPUT$CURRENTBEHINDCHAR
    else
      #Ahead
      #Check if current is behind
      if git log --format='%H' | grep -q -E "^${RPCURRENTUPSTREAM}$"
      then
        #NOT behind
        OUTPUT=$OUTPUT$CURRENTAHEADCHAR
      else
        #Behind
        OUTPUT=$OUTPUT$PROBLEMCHAR
      fi
    fi
  fi
  #Check current != main
  if  [ -z $MAINBRANCH ] || [ "$CURRENT" = $MAINBRANCH ]
  then
    printf "$OUTPUT"
    return
  fi

  RPMAINBRANCH=$(git rev-parse $MAINBRANCH)
  RPUPSTREAMMAIN=$(git rev-parse $UPSTREAMMAIN)

  #Check if main is up to date
  if git log --format='%H' | grep -q "${RPUPSTREAMMAIN}"
  then
    OUTPUT=$OUTPUT$MAINCHAR
  else
    OUTPUT=$OUTPUT$MAINBEHINDCHAR
  fi
  printf "$OUTPUT"
}

insideGit () {
  if git rev-parse --git-dir > /dev/null 2>&1; then
    #echo "inside git repo"
    echo "$(branchStatus)"
    git fetch > /dev/null 2>&1 &
  else
    echo '⬥'
  fi
}
