#!/bin/sh

rm_script="rm_dups.sh"
search_dir="."
tempfile=tempfile

if [ -z "$2" ]
then
    echo "usage: `basename $0` [directory] [method] [scriptname] \n"
    echo "directory - where to search files"
    echo "method :\n \\t name - search files having same name \n \\t cont - files having same content" 
    echo "scriptname - name of generatable removal script ('rm_dups.sh' by default)"
    exit 0
else
    search_dir=$1
    if [ -n "$3" ]; then
	rm_script=$3+'.sh'
    fi
fi

case $2 in
name) echo "#!/bin/sh \n##### List of files having same name ##### \n" > $rm_script
      #find $search_dir -type f -printf "%f\n" | sort | uniq --all-repeated=separate -D | sed -e "s/^/#rm $search_dir\//" >> $rm_script ;;
      find $search_dir -type f  > $tempfile
      cat $tempfile | sed 's_.*/__' | sort |  uniq -d | 
      while read fileName
      do
	  grep "$fileName" $tempfile | sed "s/^/#rm /" | xargs -0 echo  >> $rm_script
      done
      rm $tempfile;;
      
cont) echo "#!/bin/sh \n\n ##### List of files having same content ##### \n" > $rm_script
      find $search_dir -type f -exec md5sum '{}' ';' \
      | sort | uniq --all-repeated=separate -w 33 | sed "s/.\{34\}/#rm /" >> $rm_script ;;
esac

chmod +x $rm_script

exit 0
