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
git reset --hard 1392ec653a68e9566cd8d0c39cc8d6a192932576 > /dev/null
run_test `app_up --no-git | egrep 'bundle_me|migrate_me' | wc -l` 3

git reset --hard fad523ac3479099dda2e16dc4ac642e6e991a751 > /dev/null
run_test `app_up | egrep 'bundle_me|migrate_me' | wc -l` 3

git reset --hard origin/master
