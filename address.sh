#!/bin/sh
# address.sh for add/update/delete/query user contact book
# store like john:15982051317:john@test.com every line
# 1. creat or load one address book
# 2. query all address book items and count items
# 3. select action(query,add,update,delete)
# 4. save actions to the file
if [ $# -eq 0 ]; then
	echo "Please select one address book(if not exists will create)"
	exit
elif [ $# -eq 1 ]; then
	echo "Please use correct comand like this: ./address.sh filename [query|add|update|delete]"
	exit
fi

ADDR_FILE=$1
query_all() {
	if [ -e $ADDR_FILE ]; then
		echo "File exists"
	else
		echo "File not exists"
		echo "Will create it..."
        	touch $ADDR_FILE
		[ -e $ADDR_FILE ] && \
			echo "File create success" || \
			echo "File create fail"
	fi

	echo "Retrieve all items"
	awk -F: 'BEGIN{OFS="\t"; count=0; print "NO.\tNAME\tMOBILE\tEMAIL"} 
		{count +=1; print count,$1,$2,$3} 
		END{if(count!=0) print  count " rows found!" ;else print "No rows exists!"}' $ADDR_FILE
}

add_item() {
	echo "Add new address item"
	echo -en "input name [john]:"
	read NAME
	echo -en "input mobile [1234567890]:"
	read MOBILE
	echo -en "input email [john@test.com]:"
	read EMAIL
	echo "you input $NAME:$MOBILE:$EMAIL"
	echo "$NAME:$MOBILE:$EMAIL">>$ADDR_FILE
	if [ $? -ne 0 ]; then
		echo "insert fail"
	else
		echo "insert success" 
	fi
}

update_item() {
	echo -n "Enter No to update:"
	read UPDATE_NO
	ITEM=$(awk -v update_num=$UPDATE_NO '{if (NR==update_num) {print $0}}' $ADDR_FILE)
	echo "$ITEM"
	OLD_NAME=$(cut -d ':' -f 1 <<< $ITEM)
	OLD_MOBILE=$(cut -d ':' -f 2 <<< $ITEM)
	OLD_EMAIL=$(cut -d ':' -f 3 <<< $ITEM)
	echo -n "update name [$OLD_NAME]:"
	read NAME
	echo -n "update mobile [$OLD_MOBILE]:"
	read MOBILE
	echo -n "update email [$OLD_EMAIL]:"
	read EMAIL
	echo "you update $NAME:$MOBILE:$EMAIL"
	sed -i "$UPDATE_NO"'s/.*/'"$NAME:$MOBILE:$EMAIL"'/' $ADDR_FILE
	if [ $? -ne 0 ]; then
		echo "update fail"
	else
		echo "update success"
	fi
}

delete_item() {
	echo -n "Enter No to delete:"
	read UPDATE_NO
	awk -v update_num=$UPDATE_NO '{if (NR==update_num) {print "you will delete " $0}}' $ADDR_FILE
	sed -i "$UPDATE_NO"'d' $ADDR_FILE
	if [ $? -ne 0 ]; then
		echo "delete fail"
	else 
		echo "delete success"
	fi
}

case $2 in
	query)
		query_all;;
	add)
		query_all;
		add_item;;
	update)
		query_all;
		update_item;;
	delete)
		query_all;
		delete_item;;
	*)
		echo "no such command, please check it again!";;
esac
