#!/bin/sh

append_cr () {
	sed -e 's/$/Q/' | tr Q '\015'
}

remove_cr () {
	tr '\015' Q | sed -e 's/Q$//'
}

test_description='merge conflict in crlf repo

		b---M
	       /   /
	initial---a

'

. ./test-lib.sh

test_expect_success setup '
	git config core.autocrlf true &&
	echo foo | append_cr >file &&
	git add file &&
	git commit -m "Initial" &&
	git tag initial &&
	git branch side &&
	echo line from a | append_cr >file &&
	git commit -m "add line from a" file &&
	git tag a &&
	git checkout side &&
	echo line from b | append_cr >file &&
	git commit -m "add line from b" file &&
	git tag b &&
	git checkout master
'

test_expect_success 'Check "ours" is CRLF' '
	git reset --hard initial &&
	git merge side -s ours &&
	cat file | remove_cr | append_cr >file.temp &&
	test_cmp file file.temp
'

test_expect_success 'Check that conflict file is CRLF' '
	git reset --hard a &&
	test_must_fail git merge side &&
	cat file | remove_cr | append_cr >file.temp &&
	test_cmp file file.temp
'

test_done