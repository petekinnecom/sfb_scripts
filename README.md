#Super Fun Bonus Scripts!  ---->

Ever want to load up your sever and look at something, so you start the server, but it's like, _noooo, I'm not going to load until you bundle install_, so you type 'bundle install' like the good natured developer you are and when that finishes, you're like, _Okay, let's start this server_, so you type 'rails s' or something and your stick-in-the-mud computer is all, _pssh, you haven't even migrated yet_ and so you're like, fine, I'll migrate, so you type 'rake db:migrate', and you finally start your server, but then you want to run a test, so you run the test and your computer say, _ahahahahaha, no.  You haven't migrated your **test** database yet_ and then you cry.  YOU CRY.

Well, it's time to wipe your tears away and start living the life you deserve.

Super Fun Bonus Scripts Turbo contains two scripts that are designed for rails apps:

- __app\_up:__ Bundles and migrates only where needed after running a git command.

- __test\_runner:__ Easily run tests from the command line!  Like REALLY EASILY.  Doesn't matter what app/engine they are in.  `test_runner` will find them and it will run them.

---

#installation

~~~bash
gem install sfb_scripts
~~~

#updating

~~~bash
gem update sfb_scripts
~~~

---

#app_up ----->

The default behavior of `app_up` is to rebase your current branch onto origin/master.  Based on the rebase process, it will determine where it needs to bundle install and/or migrate the database.  These actions will work for all apps/engines in the repo.

If there is a conflict during the rebase process, the script will terminate.  This can leave your application in an unbundled, unmigrated state.  But don't worry!  `app_up` has lots of bells and whistles and you can easily rectify this problem.

Although the default behavior of `app_up` is to rebase on origin/master, there are a number of flags you can use to ensure that `app_up` does what you want.

__Rebasing your branch onto origin/master__:

~~~bash
app_up
~~~

__Rebasing onto your upstream branch__:

Maybe you're working on a branch named _FeatureBranch_ and you'd like to rebase onto origin/FeatureBranch.  Run:

~~~bash
app_up --on-branch
~~~

__Just bundle and migrate everywhere__

Sometimes things are in bad state and you just want to bundle and migrate everything, regardless of what state your git repo is in. Run:

~~~bash
app_up --no-git
~~~

__Ignore certain folders__

Perhaps you have a dummy application inside of your repo that other people use, but you don't really care about.  Tell `app_up` to ignore that folder by passing a regex with the `--ignore` option (don't forget surrounding quotes if needed).  In my project, we have a lot of engines that I usually don't care to deal with.  So I run:

~~~bash
app_up --ignore engines
~~~

###But wait! There's more!

You can run __any__ git command and have `app_up` decide where to bundle and migrate.  Simply use the `--action git_action` option to run your command.  There's even a handy shorter version, called `git_up`!

Like when you're checking out somebody elses branch:

~~~bash
# the following are equivalent:

app_up --git-action checkout OtherBranch
app_up --action checkout OtherBranch
app_up -g checkout OtherBranch
git_up checkout OtherBranch

# app_up will run: git checkout OtherBranch
~~~

Maybe you'd prefer to pull without the rebase:

~~~bash
# the following are equivalent:

app_up --git-action pull origin master
app_up --action pull origin master
app_up -g pull origin master
git_up pull origin master

# app_up will run: git pull origin master
~~~

Perhaps you're resetting hard for some reason.

~~~bash
# the following are equivalent:

app_up --git-action reset --hard commitsha
app_up --action reset --hard commitsha
app_up -g reset --hard commitsha
git_up reset --hard

# app_up will run: git reset --hard commitsha
~~~

###AUTOCOMPLETE?  WHAT IS THAT.

By adding the following to your `.bash_profile`, you can get autocomplete for `git_up` (probably only works if you're using bash\_completion as installed by homebrew):

~~~bash
__git_complete git_up _git
~~~


###what's next for app_up?

- A configuration file so you can set your own defaults.
- A nicer shortcut so that you can easily wrap all your git movements with app\_up. (i.e. `gup co branch` or `gup reset --hard origin/master`, with autocomplete, etc).
- Easily recover from failed rebase/merge. Compare with reflog data to decide.
- Figure out how people can write their own `git_up` so I can remove it from the repo.

----

#test_runner ----->

The test_runner has 3 sub-commands:

1.  `test_runner find [search_query]`
1.  `test_runner status`
1.  `test_runner status_check`

###test_runner find

The goal of the find' command is to take a search string, find some tests, and run them.  Given a search query, the script will search the repository for a test method or file that matches that query.

Here are some basic examples:

~~~bash
test_runner find test_method_name

#=> ruby -I test test/unit/test_file.rb --name=test_method_name

~~~

~~~bash
test_runner find test_file.rb

#=> ruby -I test test/unit/test_file.rb
~~~

~~~ bash
test_runner find test/unit/test_file.rb

#=> ruby -I test test/unit/test_file.rb
~~~

~~~bash
test_runner find '^any_.*[rR]egex?'

#=> runs up to 4 tests matching that regex
~~~

One of the goals of `test_runner` is to try to figure out what you'd like to do.  If you search for a test_method by name, but many tests match that file, it will just run all of the files.  (Minitest does not let you specify more than one `--name`, so the best we can do is run the entire file).

The test finder prefers certain matches over others.  It prefers matches in this order:

1. The name of a test method.
2. The filename of a test file.
3. Regular expression matching anything in a test file.

###Make Life easy on yourself:

I recommend adding the following the following alias to your `.bash_profile`:

~~~bash
alias t='test_runner find'
~~~

This allows for a much more convenient way of running tests:

~~~bash
t test_method_name
#=> ruby -I test test/unit/test_file.rb --name=test_method_name

t test_file.rb
#=> ruby -I test test/unit/test_file.rb

# etc.
~~~

###what's next for test_runner?

- If multiple test files are found, prompt users for what they'd like to do?
- Prefer full word regex matches over others.  (e.g. `test_runner find ModelTest`, should prefer the match `class ModelTest ...` over `class AnotherModelTest`)

#But wait!  There's more!

###test_runner status

The `test_runner status` command will check your git status for changed test files.  It will run those files.

###test_runner status_check

The `test_runner status_check` attempts to pair application files with their test files.  It checks your git status and reports a failure if it finds application files that have been changed without having changes to their corresponding test file.

---

#FOR SOME REASON, THERE'S MORE STUFF IN HERE...

#Git hooks

app_up can install some useful git hooks for you.  Running `app_up install_hooks` will install two hooks:

- pre-push hook: denies destructive actions on origin master.

- pre-commit: uses `test_runner status_check` to warn you if you haven't fully tested your changeset.  __Does not work with Rubymine__
