#!/bin/bash

input_file="users.csv"

get_users_in_group() {
    local group="$1"
    local user_array=($(grep "^$group:" /etc/group | cut -d: -f4 | tr ',' ' '))
    echo "${user_array[@]}"
}

is_user_in_group() {
    local user="$1"
    local group="$2"
    #echo "Checked $user in group $group"
    users=($(get_users_in_group "$group"))
    for u in "${users[@]}"; do
        #echo "User $user in $u"
        if [[ "$u" == "$user" ]]; then
            #echo "Sucsesfull found"
            return 0  # User found in the group
        fi
    done

    return 1 
}



awk 'NR > 1' "$input_file" | while IFS=',' read -r username password group fullname
do
    if grep -q "^$username:" /etc/passwd; then
		echo "User $username already exist"
    else		
    	if synouser --add "$username" "$password" "$fullname" 0 "" ""> /dev/null 2>&1; then
			  echo "User $username has been created"
    	else
			  echo "Error"
		  fi
    fi

    if [[ $group == '-' ]]; then
      continue
    fi

    if grep -q "^$group:" /etc/group; then
		    if is_user_in_group "$username" "$group"; then
		      #echo "privet"
			    echo "User $username already in group $group"
		    else
		      users=($(get_users_in_group "$group"))
		      users+=("$username")
		      if synogroup --member $group "${users[@]}"> /dev/null 2>&1; then
            echo "User $username added to the group $group"
			    else
			      echo "Error"
			    fi
			  fi
		else
		    if synogroup --add $group $username> /dev/null 2>&1; then
            echo "User $username added to the creted group $group"
			  else
			      echo "Error"
			  fi
	  fi

done
