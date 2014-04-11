#!/usr/bin/env

def up_apps
  `echo 'Pull'`
  `git checkout origin master`
  `git pull origin master > ~/tmp/up.log`
  `git reset --hard origin/master`
  `echo 'update listings'`
  #`up_app listings`
  `echo 'update property'`
  #`up_app property`
  `echo 'update tportal'`
  #`up_app tportal`
end

up_apps
