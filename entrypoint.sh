#!/bin/bash
if [ -z "$USEREMAIL" ]; then
    echo "Missing user email. Please provide it in USEREMAIL envirnment variable"
    exit 1
fi

#Check if the user configuration has been provided
if [ -n "$USERCFG" ]; then
    #extracts user information
    IFS=':' read -r -a userinfo <<< $USERCFG
    if [ ${userinfo[2]} -gt 0 ]; then
        if [ -n "${userinfo[4]}" ]; then
            #extracts person information
            IFS=',' read -r -a personinfo <<< ${userinfo[4]}

            #checks if the given group exists
            if [ -z "`getent group ${userinfo[3]}`" ]; then
                #create the missing group
                addgroup --gid ${userinfo[3]} ${userinfo[0]}
            fi

            #extract group info
            IFS=':' read -r -a groupinfo <<< `getent group ${userinfo[3]}`

            #checks if the given userid already exists
            if [ -z "`getent passwd ${userinfo[2]}`" ]; then
                #create the missing user
                adduser --home $NBUSRHOME --uid ${userinfo[2]} --disabled-password --gecos "${userinfo[4]}" --ingroup ${groupinfo[0]} ${userinfo[0]}
                usermod -G docker ${userinfo[0]}
            else
                #extract existing user info
                IFS=':' read -r -a olduserinfo <<< `getent passwd ${userinfo[2]}`
                #update user configurations
                usermod -d $NBUSRHOME -l ${userinfo[0]} -g ${userinfo[3]} -G docker -c "${userinfo[4]}" ${olduserinfo[0]}
            fi            

            #Init git user identity
            su - ${userinfo[0]} -c "git config --global user.name '${personinfo[0]}'"
            su - ${userinfo[0]} -c "git config --global user.email $USEREMAIL"

            #Start the environment using the unprivileged user

            if [ -n "`echo "$@" | sed -e 's/^[ \t\n]*//'`" ]; then
                su - ${userinfo[0]} -c "$@"
                exit $?
            else
                echo "Missing command"
                exit 1
            fi
        else
            echo "Missing person information. The content of USERCFG doesn't provide it"
            exit 1
        fi
    else
        echo "Missing or forbidden userid.  The content of USERCFG doesn't provide it"
        exit 1
    fi
else
    echo "Missing user configuration. Please provide USERCFG envirnment variable ( -e \"USERCFG=\`getent passwd \$USER\`\" in docker run command)"
    exit 1
fi
