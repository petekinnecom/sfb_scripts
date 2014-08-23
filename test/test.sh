
__VERSION=$1
gem build sfb_scripts.gemspec
rvm @global do gem install sfb_scripts-${__VERSION}.gem

cd test/test_app

git reset --hard 8d2b16a1ffbd3687e5ccef98fadbcdbf4548bd61
test_runner find test_one | grep test_one_success
test_runner find thing_test | grep thing_test_success

git reset --hard aa0e2d230903ce5d0afa946e25253865f7874a4c
test_runner find multiple | grep multiple_matches_success

git reset --hard 49a28f1c7715403765c9b03e647dde146feed64b
git reset @~1
git add --all
test_runner status | grep test_status_success
