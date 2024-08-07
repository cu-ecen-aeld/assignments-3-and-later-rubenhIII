#!/bin/sh

if [ $# -gt 1 ]
then
	writefile=$1
	writestr=$2
	path=$(dirname ${writefile})

	if [ -e ${path} ]
	then
		touch -f ${writefile}
	else
		mkdir -p ${path} && touch ${writefile}
	fi

	echo ${writestr} > ${writefile}

else
	echo "Any of the arguments were not specified" 1>&2
	return 1
fi
