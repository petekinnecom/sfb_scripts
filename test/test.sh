function run_test {
if [ "$1" -eq "$2" ]; then
  echo 'success'
else
  echo 'fail'
fi
}

# yes, this is horrible
# DON'T CARE
__VERSION=`grep "s\.version" sfb_scripts.gemspec | tr -s ' ' | cut -d ' ' -f 4 | tr \" ' ' | tr -d ' '`

gem build sfb_scripts.gemspec
rvm @global do gem install sfb_scripts-${__VERSION}.gem

cd test/test_app

#test_runner
git reset --hard 8d2b16a1ffbd3687e5ccef98fadbcdbf4548bd61 > /dev/null
run_test `test_runner find test_one | grep test_one_success | wc -l`  1


run_test `test_runner find thing_test | grep thing_test_success | wc -l` 1

git reset --hard aa0e2d230903ce5d0afa946e25253865f7874a4c > /dev/null
run_test `test_runner find multiple | grep multiple_matches_success | wc -l` 2

git reset --hard 49a28f1c7715403765c9b03e647dde146feed64b > /dev/null
git reset @~1
git add --all
run_test `test_runner status | grep test_status_success | wc -l` 1

#app_up
git reset --hard 35250b7b73024a281693bffcb132c7fce4bf7148 > /dev/null
run_test `app_up --no-git | egrep 'bundle_me|migrate_me' | wc -l` 3

git reset --hard aa0e2d230903ce5d0afa946e25253865f7874a4c > /dev/null
run_test `app_up | egrep 'bundle_me|migrate_me' | wc -l` 3

git reset --hard origin/master
