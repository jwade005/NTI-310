#!/bin/bash

sudo yum -y install git
git clone https://github.com/jwade005/NTI-310.git
git config --global user.name "jwade005"
git config --global user.email "jwade005@seattlecentral.edu"

echo "a clone of the jwade005 repository and NTI-300 repository is now sitting in this dir, along with a copy of this script \n"
echo "For a git command line cheet sheet check out https://services.github.com/kit/downloads/github-git-cheat-sheet.pdf \n"
echo "Basic commands:
      git pull                       # will get you repo updates
      git add .                      # will add files in your dir
      git add [dirname]/*            # will add files under a new dir
      git commit -m "your comment"   # will commit your code to your changes
      git push                       # will push your code to a reposatory
      git pull                       # will pull down new reposatory updates"
