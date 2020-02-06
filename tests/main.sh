#!/bin/sh

tests="test/compiling.sh
test/unknown_command.sh
test/help.sh
test/init.sh
test/add_hello.sh
test/rm_hello.sh
test/du.sh
test/list.sh"

touch test.log

for test in $tests; do
	printf "\e[1m\e[33mRunning %s... \e[39m\e[0m" "$test"

	if ! sh "$test" > test.log 2>&1; then
		echo "\e[1m\e[31m[FAILED]\e[39m\e[0m"
		tail test.log
		exit 1
	fi

	echo "\e[1m\e[33m[OK]\e[39m\e[0m"
done

echo "\e[1m\e[32mAll passed!\e[39m\e[0m"
