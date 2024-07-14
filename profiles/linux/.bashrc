###############################################################################################
# MANDATORY VARIABLES #########################################################################
###############################################################################################

: "${BASE_GREENHOUSE_WORKSPACE:? The variable needs to be defined}"

###############################################################################################
## ENVIRONMENT VARIABLE #######################################################################
###############################################################################################

export GREENHOUSE_INFRA="${BASE_GREENHOUSE_WORKSPACE}/ivy-automation"
export GREENHOUSE_FRONTEND="${BASE_GREENHOUSE_WORKSPACE}/orquid-frontend"

###############################################################################################
## ALIAS ######################################################################################
###############################################################################################

alias status="git status"
alias commit="git commit -m"
alias pull="git pull"
alias push="git push"

###############################################################################################
## FUNCTIONS ##################################################################################
###############################################################################################

function init() {
	echo -e "########################################################################################################"
	echo -e "# Main Bash Profile Loaded. ############################################################################"
	echo -e "########################################################################################################"
	echo -e "+------------------------------------------------------------------------------------------------------+"
	echo -e "|  Function                   | Description                                                            |"
	echo -e "+------------------------------------------------------------------------------------------------------+"
	echo -e "|  Profile Functionalities    |                                                                        |"
	echo -e "|      |                      |                                                                        |"
	echo -e "|      +----> reloadProfile   | Based on System (Linux, Windows, Mac...) it will reload the            |"
	echo -e "|      |                      | .bash_profile file.                                                    |"
	echo -e "|      |                      |                                                                        |"
	echo -e "|      +----> editProfile     | It will Open the current .bash_profile with:                           |"
	echo -e "|      |                      |     - Windows: Visual Studio Code                                      |"
	echo -e "|      |                      |     - Linux: NANO (WIP)                                                |"
	echo -e "|      |                      |                                                                        |"
	echo -e "|      +----> copyProfile     | Given the path of the GreenHouse workspace by the environmen variable  |"
	echo -e "|                             | BASE_GREENHOUSE_WORKSPACE, it will copy the file .bashrc.              |"
	echo -e "|                             | If there is a previous .bash_profile, it will create a copu as backup. |"
	echo -e "|                             |                                                                        |"
	echo -e "|  goto {whereToGo}           | Write goto and where do you aim to go to jump to the folder:           |"
	echo -e "|                             |    + Workspace       -> gh                                             |"
	echo -e "|                             |    + Ivy Automation  -> infra                                          |"
	echo -e "|                             |    + Orchid FrontEnd -> fe                                             |"
	echo -e "|                             |                                                                        |"
	echo -e "|                             | Example:                                                               |"
	echo -e "|                             |    > goto gh                                                           |"
	echo -e "|                             |                                                                        |"
	echo -e "|  gotoHelp                   | Provides a table with shortcuts where you can jump and the fullpath    |"
	echo -e "+------------------------------------------------------------------------------------------------------+"
	echo -e "|  Alias                      | Command                                                                |"
	echo -e "+------------------------------------------------------------------------------------------------------+"
	echo -e "|  status                     | git status                                                             |"
	echo -e "|  commit                     | git commit -m                                                          |"
	echo -e "|  pull                       | git pull                                                               |"
	echo -e "|  push                       | git push                                                               |"
	echo -e "+------------------------------------------------------------------------------------------------------+"
}

function reloadProfile() {
	echo "Loading Profile for OS [$OSTYPE]"
	if [[ "$OSTYPE" == "msys"* ]]; then # Windows | GitBash
		. /c/Users/$USERNAME/.bash_profile
	elif [[ "$OSTYPE" == "cygwin"* ]]; then # Windows | Cygwin
		. /c/Users/$USERNAME/.bash_profile
	elif [[ "$OSTYPE" == "darwin"* ]]; then # Mac OS X
		echo "WIP for Mac OS X"
	else # Linux
		echo "WIP for Linux"
	fi
}

function editProfile() {
	echo "Editing Profile for OS [$OSTYPE]"
	if [[ "$OSTYPE" == "msys"* ]]; then # Windows | GitBash
		code -r /c/Users/$USERNAME/.bash_profile
	elif [[ "$OSTYPE" == "cygwin"* ]]; then # Windows | Cygwin
		code -r /c/Users/$USERNAME/.bash_profile
	elif [[ "$OSTYPE" == "darwin"* ]]; then # Mac OS X
		echo "WIP for Mac OS X"
	else # Linux
		echo "WIP for Linux"
	fi
}

function copyProfile() {
	echo "Loading profile from Repository Folder: $GREENHOUSE_INFRA"

	bashPath="/c/Users/$USERNAME/.bash_profile"
	bashPathBackup="/c/Users/$USERNAME/.bash_profile_backup"
	ivyBash="$GREENHOUSE_INFRA/profiles/.bashrc"

	if [ -e "$bashPathBackup" ]; then
		# Delete backup file.
		echo "Deleting current backup file $bashPathBackup."
		rm "$bashPathBackup"
	fi

	if [ -e "$bashPath" ]; then
		# If the file exists, make a backup
		cp "$bashPath" "$bashPathBackup"
		echo "Backup Completed."
	fi

	echo "Copying [$ivyBash] to [$bashPath]"  
	cp $ivyBash $bashPath
	echo "Copy Completed."
}

function gotoHelp() {
	echo -e "+---------------------------------------------------------------------------------------------+"
	echo -e "  Description                | Shortcut | Folder "
	echo -e "+---------------------------------------------------------------------------------------------+"
	echo -e "  Greenhouse                 |          |  "
	echo -e "      |----> Workspace       | gh       | $BASE_GREENHOUSE_WORKSPACE "
	echo -e "      |----> Ivy Automation  | infra    | $GREENHOUSE_INFRA "
	echo -e "      |----> Orchid FrontEnd | fe       | $GREENHOUSE_FRONTEND "
	echo -e "+----------------------------------------------------------------------------------------------+"
}

function goto() {
    if [ $# -eq 0 ]; then 
        echo -e "go where?"
        gotoHelp
    elif [ $# -eq 1 ]; then 
        case "$1" in
        'gh')
            echo -e "cd $BASE_GREENHOUSE_WORKSPACE "
            cd $BASE_GREENHOUSE_WORKSPACE
        ;;
        'infra')
            echo -e "cd $GREENHOUSE_INFRA "
            cd $GREENHOUSE_INFRA
        ;;
        'fe')
            echo -e "cd $GREENHOUSE_FRONTEND "
            cd $GREENHOUSE_FRONTEND
        ;;
        esac
    else
        gotoHelp
    fi
	pwd
}

init