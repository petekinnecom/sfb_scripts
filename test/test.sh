function run_test {
if [ "$1" -eq "$2" ]; then
  echo -e '\033[32msuccess\033[0m'
else
  echo -e '\033[31mfail\033[0m'
fi
}

# yes, this is horrible
# DON'T CARE
__VERSION=`grep "s\.version" sfb_scripts.gemspec | tr -s ' ' | cut -d ' ' -f 4 | tr \" ' ' | tr -d ' '`

gem build sfb_scripts.gemspec
gem install sfb_scripts-${__VERSION}.gem

cd test/test_app
git checkout master > /dev/null

#test_runner
git reset --hard e2754e5449e66157590e5c8694c36f9843df114c > /dev/null
run_test `test_runner find test_one | grep test_one_success | wc -l`  1

run_test `test_runner find thing_test | grep thing_test_success | wc -l` 1

run_test `test_runner find ThingTest | grep thing_test_success | wc -l` 1

git reset --hard fad523ac3479099dda2e16dc4ac642e6e991a751 > /dev/null
run_test `test_runner find multiple | grep multiple_matches_success | wc -l` 2

git reset --hard c7e5f59b0a11337134f53b1252641300e2cfd34d > /dev/null
git reset @~1
git add --all
run_test `test_runner status | grep test_status_success | wc -l` 1

#app_up

##no_git
git reset --hard 1392ec653a68e9566cd8d0c39cc8d6a192932576 > /dev/null
run_test `app_up --no-git | egrep 'bundle_me|migrate_me' | wc -l` 3

# reset back one, rebase on master
git reset --hard fad523ac3479099dda2e16dc4ac642e6e991a751 > /dev/null
run_test `app_up | egrep 'bundle_me|migrate_me' | wc -l` 3

# checkout test branch
# move back one
# rebase on branch
# should only bundle
git checkout feature_branch > /dev/null
git reset --hard 1392ec653a68e9566cd8d0c39cc8d6a192932576 > /dev/null
run_test `app_up --on-branch | egrep 'bundle_me' | wc -l` 1

git reset --hard 1392ec653a68e9566cd8d0c39cc8d6a192932576 > /dev/null
run_test `app_up --on-branch | egrep 'migrate_me' | wc -l` 0

git reset --hard 9322a4766accf20d5398fd5f36ed98364d9e3488 > /dev/null
run_test `app_up --action 'reset --hard 1392ec653a68e9566cd8d0c39cc8d6a192932576' | egrep 'bundle_me' | wc -l` 1


git fetch origin > /dev/null
git checkout feature_branch > /dev/null
git reset --hard origin/feature_branch

git checkout master > /dev/null
git reset --hard origin/master
