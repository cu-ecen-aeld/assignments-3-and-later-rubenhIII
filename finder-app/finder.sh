#!/bin/sh

if [ $# -gt 1 ]
then
	filesdir=$1
	searchstr=$2

	if [ -e ${filesdir} ]
	then
		filesnumber=$(find ${filesdir} -mindepth 1 | grep assignment* | wc -l)
		#filematches=$(find ${filesdir} -mindepth 1 | awk -v var="${filesdir}/.*" -v var2="${searchstr}.*" '$0 ~ var var2' | wc -l)
		filematches=$(awk -v var="${searchstr}" -F : '$0 ~ var' "${filesdir}/assignment"* | wc -l) 
		echo "The number of files are" ${filesnumber} "and the number of matching lines are" ${filematches}
	else
		echo "The path does not exist" 1>&2
		return 1
	fi

else
	echo "Any of the arguments were not specified" 1>&2
	return 1
fi
