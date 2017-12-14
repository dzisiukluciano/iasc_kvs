if [ $# -ne 1 ]; then
	echo "Enter webserver number from 1 to 3"
	exit 1
fi
iex --name webserver${1}@127.0.0.1 --erl "-config config/cordinator${1}.config" -S mix run