
__VERSION=$1
gem build sfb_scripts.gemspec
rvm @global do gem install sfb_scripts-${__VERSION}.gem

cd test/test_app
test_runner find test_one | grep test_one_success
test_runner find thing_test | grep thing_test_success
