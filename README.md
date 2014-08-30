[   low quality readme below : /   ]

#Super Fun Bonus Scripts!

Ever want to load up your sever and look at something, so you start the server, but it's like, _noooo, I'm not going to load until you bundle install_, so you type 'bundle install' like the good natured developer you are and when that finishes, you're like, _Okay, let's start this server_, so you type 'rails s' or something and your stick-in-the-mud computer is all, _pssh, you haven't even migrated yet_ and so you're like, fine, I'll migrate, so you type 'rake db:migrate', and you finally start your server, but then you want to run a test, so you run the test and your computer say, _ahahahahaha, no.  You haven't migrated your **test** database yet_ and then you cry.  YOU CRY.

Well, it's time to wipe your tears away, and start living the life you deserve.

Super Fun Bonus Scripts Turbo contains two scripts that are designed for rails apps:

- __app\_up:__ Rebases, bundles, and migrates for you.

- __test\_runner:__ Easily run tests from the command line.

---

#installation

~~~
bash
gem install sfb_scripts
~~~

#updating

~~~
bash
gem update sfb_scripts
~~~

---

#app_up

Running ```app_up``` will rebase your branch onto origin/master.  Based on the rebase process, it will determine where it needs to bundle install and/or migrate the database.  These actions will work for all apps/engines in the repo.

If there is a conflict during the rebase process, the script will terminate.  This can leave your application in an unbundled, unmigrated state.  Running ```app_up --all``` will bundle install and migrate everywhere, regardless of your git diffs.

#test_runner

The test_runner has 3 sub-commands:

1.  ```test_runner find [search_query]```
1.  ```test_runner status```
1.  ```test_runner status_check```

###find

The goal of the 'find' command is to take a search string(s), find some tests, and run them.  Given a search query, the script will search the repository for a test method or file that matches that query.

Here are some examples:

---

input: ```test_runner find test_method_name```

output: runs ```ruby -I test test/unit/test_file.rb --name=test_method_name```

---

input: ```test_runner find test_file.rb```

output: runs ```ruby -I test test/unit/test_file.rb```

---

input: ```test_runner find test/unit/test_file.rb```

output: runs ```ruby -I test test/unit/test_file.rb```

---

I recommend adding the following the following alias to your ```.bash_profile```:

```alias t='test_runner find'```

This allows for a much more convenient way of running tests:

---

input: ```t test_method_name```

output: runs ```ruby -I test test/unit/test_file.rb --name=test_method_name```

---


###status

The ```test_runner status``` command will check your git status for changed test files.  It will run those files.

###status_check

The ```test_runner status_check``` attempts to pair application files with their test files.  It checks your git status and reports a failure if it finds application files that have been changed without having changes to their corresponding test file.


---

#Git hooks

app_up can install some useful git hooks for you.  Running ```app_up install_hooks``` will install two hooks:

- pre-push hook: denies destructive actions on origin master.

- pre-commit: uses ```test_runner status_check``` to warn you if you haven't fully tested your changeset.  __Does not work with Rubymine__
