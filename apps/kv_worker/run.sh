if [ $# -ne 1 ]; then
	echo "Enter worker number from 1 to 3"
	exit 1
fi
iex --name datanode${1}@127.0.0.1 -S mix
