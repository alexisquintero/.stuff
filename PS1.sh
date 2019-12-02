#!/bin/sh

branchStatus () {
  MAINCHAR="❙"
  MAINBEHINDCHAR="❰"
  CURRENTCHAR="❙"
  CURRENTBEHINDCHAR="❰"
  CURRENTAHEADCHAR="❱"
  DETACHEDCHAR="━"
  PROBLEMCHAR="𝌐"
  REBASECHAR="?"
  BISECTCHAR="⇲"

  DETACHEDCOLOR="\001\e[91m\002"

  UNSTAGEDCOLOR="\001\e[91m\002"
  STAGEDCOLOR="\001\e[92m\002"
  UNTRACKEDCOLOR="\001\e[37m\002"

  OUTPUT=""

  case $(git branch -v) in
    "")
      #Check if it's a new repository
      OUTPUT=$OUTPUT$MAINCHAR
      printf "$OUTPUT"
      return
      ;;
    *"no branch, rebasing"*)
      #Rebase in progress
      OUTPUT=$OUTPUT$REBASECHAR
      printf "$OUTPUT"
      return
      ;;
    *"no branch, bisect"*)
      #Bisect in progress
      OUTPUT=$OUTPUT$BISECTCHAR
      printf "$OUTPUT"
      return
      ;;
    *"HEAD detached "*)
      #Check if detached
      OUTPUT=$OUTPUT$DETACHEDCOLOR$DETACHEDCHAR
      printf "$OUTPUT"
      return
      ;;
  esac

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

  MAINUPSTREAM="$REMOTE/$MAINBRANCH"
  #Check if main branch exists upstream
  if ! [ "$(git branch -r | grep -E "^[[:space:]]+${MAINUPSTREAM}$")" ]
  then
    MAINUPSTREAM=$MAINBRANCH
  fi

  # Check if there are untracked files
  if [ "$(git status --porcelain 2>/dev/null| grep -c "^??")" != "0" ]
  then
    OUTPUT=$OUTPUT$UNTRACKEDCOLOR
  # Check if there are unstaged files
  elif [ -n "$(git diff)" ]
  then
    OUTPUT=$OUTPUT$UNSTAGEDCOLOR
  # Check if there are staged files
  elif [ -n "$(git diff --staged)" ]
  then
    OUTPUT=$OUTPUT$STAGEDCOLOR
  fi

  #Check if current is up to date
  case $(git rev-list --left-right --count "$CURRENT"..."$CURRENTUPSTREAM") in
    "0"*"0")
      #Up to date
      OUTPUT=$OUTPUT$CURRENTCHAR
      ;;
    "0"*)
      #Behind
      OUTPUT=$OUTPUT$CURRENTBEHINDCHAR
      ;;
    *"0")
      #Ahead
      OUTPUT=$OUTPUT$CURRENTAHEADCHAR
      ;;
    *)
      #Diverge
      OUTPUT=$OUTPUT$PROBLEMCHAR
      ;;
  esac

  #Check current != main
  if  [ -z $MAINBRANCH ] || [ "$CURRENT" = $MAINBRANCH ]
  then
    printf "$OUTPUT"
    return
  fi

  RPMAINUPSTREAM=$(git rev-parse $MAINUPSTREAM)

  #Check if main is up to date
  if git log --format='%H' | grep -q "${RPMAINUPSTREAM}"
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
    branchStatus
    git fetch > /dev/null 2>&1 &
  else
    echo '⬥'
  fi
}
