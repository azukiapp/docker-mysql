# `adocker` is alias to `azk docker`
all:
	adocker build -t azukiapp/mysql 5.6
	adocker build -t azukiapp/mysql:5.5 5.5

no-cache:
	adocker build --rm --no-cache -t azukiapp/mysql 5.6
	adocker build --rm --no-cache -t azukiapp/mysql:5.5 5.5
