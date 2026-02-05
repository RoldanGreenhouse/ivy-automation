#!/bin/bash

# set -e
# -e : Exit immediately if any command exits with a non-zero status
# -u : Treat unset variables as an error
# -x : Print commands and their arguments as they're executed (useful for debugging)
# -o pipefail : Consider a pipeline failed if any command in the pipeline fails

function getProfileOsName() {
    if [[ "$OSTYPE" == "msys"* ]]; then # Windows | GitBash
		echo ".bash_profile"
	elif [[ "$OSTYPE" == "cygwin"* ]]; then # Windows | Cygwin
		echo ".bash_profile"
	elif [[ "$OSTYPE" == "darwin"* ]]; then # Mac OS X
		echo ".zshrc"
	else # Linux or in this case Raspberry Pi OS
		echo ".bashrc"
	fi
}

function getBasePath() {
    if [[ "$OSTYPE" == "msys"* ]]; then # Windows | GitBash
		echo "/c/Users/$USERNAME"
	elif [[ "$OSTYPE" == "cygwin"* ]]; then # Windows | Cygwin
		echo "/c/Users/$USERNAME"
	elif [[ "$OSTYPE" == "darwin"* ]]; then # Mac OS X
		echo "/Users/$USERNAME"
	else # Linux or in this case Raspberry Pi OS
		echo "/home/$USER"
	fi
}

function getProfileOS() {
    profileHome=$(getBasePath)
    profileName=$(getProfileOsName)
    if [[ "$OSTYPE" == "msys"* ]]; then # Windows | GitBash
		echo "$profileHome/$profileName"
	elif [[ "$OSTYPE" == "cygwin"* ]]; then # Windows | Cygwin
		echo "$profileHome/$profileName"
	elif [[ "$OSTYPE" == "darwin"* ]]; then # Mac OS X
		echo "$profileHome/$profileName"
	else # Linux or in this case Raspberry Pi OS
		echo "$profileHome/$profileName"
	fi
}

function getProfilePath() {
    echo "$BASE_PATH_SCRIPTS/$(getProfileOsName)"
}

function getProfileConfigPath() {
    if [[ "$OSTYPE" == "msys"* ]]; then # Windows | GitBash
		echo "$BASE_PATH_SCRIPTS/$PROFILE_CONFIG_SCRIPT_NAME"
	elif [[ "$OSTYPE" == "cygwin"* ]]; then # Windows | Cygwin
		echo "$BASE_PATH_SCRIPTS/$PROFILE_CONFIG_SCRIPT_NAME"
	elif [[ "$OSTYPE" == "darwin"* ]]; then # Mac OS X
		echo "$BASE_PATH_SCRIPTS/$PROFILE_CONFIG_SCRIPT_NAME"
	else # Linux or in this case Raspberry Pi OS
		echo "$BASE_PATH_SCRIPTS/greenhouse/$PROFILE_CONFIG_SCRIPT_NAME"
	fi
}

function getProfileColorsPath() {
    if [[ "$OSTYPE" == "msys"* ]]; then # Windows | GitBash
		echo "$BASE_PATH_SCRIPTS/$PROFILE_COLORS_SCRIPT_NAME"
	elif [[ "$OSTYPE" == "cygwin"* ]]; then # Windows | Cygwin
		echo "$BASE_PATH_SCRIPTS/$PROFILE_COLORS_SCRIPT_NAME"
	elif [[ "$OSTYPE" == "darwin"* ]]; then # Mac OS X
		echo "$BASE_PATH_SCRIPTS/$PROFILE_COLORS_SCRIPT_NAME"
	else # Linux or in this case Raspberry Pi OS
		echo "$BASE_PATH_SCRIPTS/greenhouse/$PROFILE_COLORS_SCRIPT_NAME"
	fi
}

: "${BASE_PATH_SCRIPTS:=$(getBasePath)}"

export PROFILE_SCRIPT=$(getProfilePath)

export PROFILE_CONFIG_SCRIPT_NAME=.greenhouse.config
export PROFILE_CONFIG_SCRIPT_PATH=$(getProfileConfigPath)

export PROFILE_COLORS_SCRIPT_NAME=.greenhouse.colors
export PROFILE_COLORS_SCRIPT_PATH=$(getProfileColorsPath)

echo "Loading Base Profile file [$PROFILE_SCRIPT]"
echo "Loading Config for Profile from file [$PROFILE_CONFIG_SCRIPT_PATH]"
echo "Loading Colors for Profile from file [$PROFILE_COLORS_SCRIPT_PATH]"

if [[ -z "${CONFIG_IMPORTED}" ]]; then
    . $PROFILE_CONFIG_SCRIPT_PATH
    : "${CONFIG_IMPORTED:? Not able to read configuration}" 
fi

if [[ -z "${COLORS_SH_IMPORTED}" ]]; then
    . $PROFILE_COLORS_SCRIPT_PATH
    : "${COLORS_SH_IMPORTED:? The variable needs to be defined}" 
fi

: "${WORKSPACE_PATH:=$BASE_PATH_SCRIPTS/Workspace}"
echo "Workspace defined at: [$WORKSPACE_PATH]"
echo -e "${YEL}Remember that this can be modified if you add the variable on your .greenhouse.config$NC"

export DOCKER_UDEMY_PATH=$WORKSPACE_PATH/udemy-docker-mastery
export GREENHOUSE_PATH=$WORKSPACE_PATH/greenhouse
: "${IVY_PATH:=$GREENHOUSE_PATH/ivy-automation}"
echo "IVY_PATH defined at: [$IVY_PATH]"
echo -e "${YEL}Remember that this can be modified if you add the variable on your .greenhouse.config$NC"
export GREENHOUSE_PROFILE_SCRIPT=$IVY_PATH/profiles/.profile

FPATH="$BASE_PATH_SCRIPTS/.zshrc.docker.completion:$FPATH"
autoload -Uz compinit
compinit

# if ! confirmContinue; then
#    DO WHATEVER AND STOP
# fi
function confirmContinue() {
    while true; do
        echo -e "${YEL}Continue?${BLUE} [y/n] ${NC}"
        read -r response
        case "$response" in
            [Yy]) return 0 ;;
            [Nn]) return 1 ;;
            *) echo "${RED}Your input ${GRE}[$response]${RED} is not valid. Use 'y' or 'n'.${NC}" ;;
        esac
    done
}


function loadProfiling() {
    doBackup

    echo -e "${BLU}All configuration will be copied from [$GREENHOUSE_PATH]${NC}"
    echo -e "${RED}The configuration is not copied. Is only a template that you have to apply manually${NC}"
    if ! confirmContinue; then
        echo -e "${GRE}Nothing to do then${NC}"
        return 1
    fi 

    ghProfilesPath=$IVY_PATH/profiles
    echo "${BYEL}Loading profile from Greenhouse: [$ghProfilesPath]${NC}"

    echo -e "${CYA}Copying profile file [$GREENHOUSE_PROFILE_SCRIPT] to [$PROFILE_SCRIPT]${NC}"
    cp -f $GREENHOUSE_PROFILE_SCRIPT $PROFILE_SCRIPT

    ghColors=$ghProfilesPath/$PROFILE_COLORS_SCRIPT_NAME
    echo -e "${CYA}Copying [$ghColors] to [$PROFILE_COLORS_SCRIPT_PATH]${NC}"
    cp -f $ghColors $PROFILE_COLORS_SCRIPT_PATH

    echo -e "${YEL}Do you want to copy the configuration? It will delete the current configs that you have now.$NC"
    if confirmContinue; then
        ghConfig=$ghProfilesPath/$PROFILE_CONFIG_SCRIPT_NAME
        echo -e "${YCYAEL}Copying [$PROFILE_CONFIG_SCRIPT_NAME] to [$PROFILE_CONFIG_SCRIPT_PATH]${NC}"
        cp -f $ghConfig $PROFILE_CONFIG_SCRIPT_PATH
    fi 

    echo -e "${GRE}Load completed.$NC"

    echo "${BYEL}Reload the profile?${NC}"
    if confirmContinue; then
        reloadProfile
    fi 
}

function doBackup() {
    echo -e "${YEL}Starting backup${NC}"
    profileBackup=$BASE_PATH_SCRIPTS/.greenhouse/backup

    echo -e "${YEL}Checking backup folder....${NC}"
    if [ -d $profileBackup ]; then
        echo -e "${YEL}Backup folder located${NC}"
    else
        echo -e "${YEL}Creating backup folder [$profileBackup]${NC}"
        mkdir -p $profileBackup
    fi

    echo -e "${BLU}Backing up profile [$PROFILE_SCRIPT]${NC}"
    cp -f $PROFILE_SCRIPT $profileBackup/$(getProfileOsName)

    echo -e "${BLU}Backing up config [$PROFILE_CONFIG_SCRIPT_PATH]${NC}"
    cp -f $PROFILE_CONFIG_SCRIPT_PATH $profileBackup/$PROFILE_CONFIG_SCRIPT_NAME

    echo -e "${BLU}Backing up colors [$PROFILE_COLORS_SCRIPT_PATH]${NC}"
    cp -f $PROFILE_COLORS_SCRIPT_PATH $profileColorsFile/$PROFILE_COLORS_SCRIPT_NAME

    echo -e "Backup completed"
}

function reloadProfile() {
    profile=$(getProfileOS)
	echo "Loading Profile for OS [$OSTYPE]: [$profile]"
    . $profile
}

function editProfile() {
    profile=$(getProfileOS)
	echo "Editing Profile for OS [$OSTYPE]: [$profile]"
	code -r $profile
}

function editGhProfile() {
    echo "${BYEL}Editing profile from Greenhouse: [$GREENHOUSE_PROFILE_SCRIPT]${NC}"
    code -r $GREENHOUSE_PROFILE_SCRIPT
}

function goto() {
    if [ $# -eq 0 ]; then 
        echo -e "${YEL} go where?${NC}"
        gotoHelp
    elif [ $# -eq 1 ]; then 
        case "$1" in
        'workspace')
            DoGoTo $WORKSPACE_PATH
        ;;
        'lirio'|'home')
            DoGoTo $BASE_PATH_SCRIPTS
        ;;
        'du'|'docker-udemy')
            DoGoTo $DOCKER_UDEMY_PATH
        ;;
        'gh'|'greenhouse')
            DoGoTo $GREENHOUSE_PATH
        ;;
        'ivy')
            DoGoTo $IVY_PATH
        ;;
        'd'|'docker')
            DoGoTo $IVY_PATH/docker
        ;;
        esac
    else
        gotoHelp
    fi
}

function DoGoTo() {
    if [ $# -eq 1 ]; then
        echo -e "${YEL} cd $1 ${NC}"
        cd $1
    fi
}

function gotoHelpAlias() {
    echo -e "${BBLU}      gotow  ${BLU}= goto ${YEL}workspace ${NC}"
    echo -e "${BBLU}      gotol  ${BLU}= goto ${YEL}lirio ${NC}"
    echo -e "${BBLU}      gotoh  ${BLU}= goto ${YEL}home ${NC}"
    echo -e "${BBLU}      gotodu ${BLU}= goto ${YEL}docker-udemy ${NC}"
    echo -e "${BBLU}      gotogh ${BLU}= goto ${YEL}greenhouse ${NC}"
    echo -e "${BBLU}      gotoi  ${BLU}= goto ${YEL}ivy ${NC}"
    echo -e "${BBLU}      gotod  ${BLU}= goto ${YEL}ivy-docker ${NC}"
}

function gotoHelp() {
    echo -e "${YEL} You can go to....${NC}"
    echo -e "${BLU}      workspace       ${BBLU}- ${BIBLU}$WORKSPACE_PATH ${NC}"
    echo -e "${BLU}      lirio|home      ${BBLU}- ${BIBLU}$BASE_PATH_SCRIPTS ${NC}"
    echo -e "${BLU}      docker-udemy|du ${BBLU}- ${BIBLU}$DOCKER_UDEMY_PATH ${NC}"
    echo -e "${BLU}      greenhouse|gh   ${BBLU}- ${BIBLU}$GREENHOUSE_PATH ${NC}"
    echo -e "${BLU}      ivy|i           ${BBLU}- ${BIBLU}$IVY_PATH ${NC}"
    echo -e "${BLU}      ivy-docker|d    ${BBLU}- ${BIBLU}$IVY_PATH/docker ${NC}"
    echo -e "${BYEL} Alias ${YEL}defined:${NC}"
    gotoHelpAlias
}

function sshInfo() {
    echo -e "   ${YEL}Available connections: ${#sshkeys[@]}${NC}"

    for sshuser in "${sshusers[@]}"; do
        sshkey="${sshkeys[$sshuser]}"
        sship="${sships[$sshuser]}"
        echo -e "      ${GRE}ssh -i ${YEL}$sshkey $sshuser${GRE}@${YEL}$sship${NC}"
    done
}

function ssh-with() {
    if [ $# -eq 0 ]; then
        sshInfo
    elif [ $# -eq 1 ]; then 
        echo -e "${YEL}Checking user [$1]...  "
        if [[ -n "${sshuser_lookup[$1]}" ]]; then
            echo -e "${YEL}Connecting with user [$1]..."
            sshkey="${sshkeys[$1]}"
            sship="${sships[$1]}"
            ssh -i $sshkey $1@$sship
        else
            echo -e "${YEL}The user ${RED}$1 ${YEL}does NOT exist in the list..."
            sshInfo
        fi
    fi
}

function greenhouse-help() {
    echo -e "${GRE}Usage: greenhouse ${BLU}<environment> ${PUR}<command>${NC}"
    echo -e ""
    echo -e "${GRE}Manage docker-compose environments.${NC}"
    echo -e ""
    echo -e "${YEL}Parameters:${NC}"
    echo -e "  ${BLU}environment: ${GRE}Target environment ${BGRE}[dev | test | preprod | prod].${NC}"
    echo -e "  ${PUR}command:     ${GRE}Action to perform.${NC}"
    echo -e ""
    echo -e "${YEL}Available commands:${NC}"
    echo -e "${PUR}  up, u        ${BPUR}- ${GRE}Start containers in detached mode.${NC}"
    echo -e "${PUR}  down, d      ${BPUR}- ${GRE}Stop and remove containers, networks.${NC}"
    echo -e "${PUR}  stop, s      ${BPUR}- ${GRE}Stop containers without removing them.${NC}"
    echo -e "${PUR}  restart, r   ${BPUR}- ${GRE}Restart containers.${NC}"
    echo -e "${PUR}  stop-up, su  ${BPUR}- ${GRE}Stop containers then start them again.${NC}"
    echo -e "${PUR}  down-up, du  ${BPUR}- ${GRE}Remove containers then start them again.${NC}"
    echo -e ""
    echo -e "${CYA}Examples:${NC}"
    echo -e "  ${GRE}greenhouse ${BLU}dev ${PUR}up${NC}"
    echo -e "  ${GRE}greenhouse ${BLU}prod ${PUR}stop${NC}"
    echo -e "  ${GRE}greenhouse ${BLU}test ${PUR}restart${NC}"
    echo -e "  ${GRE}greenhouse ${BLU}preprod ${PUR}su${NC}"
}

function greenhouse() {
    # Check parameter count
    if [ $# -ne 2 ]; then
        echo -e "${RED}Error: ${YEL}Invalid number of parameters $NC"
        greenhouse-help
        return 1
    fi

    local environment="$1"
    local command="$2"
    local compose_file="docker-compose.yml"

    # Validate environment
    case "$environment" in
        dev|test|prod|preprod)
            # Valid environment, continue
            ;;
        *)
            echo -e "${RED}Error: ${YEL}Invalid environment '$environment'$NC"
            greenhouse-help
            return 1
            ;;
    esac
    

    # Check if we're in the correct directory
    if [ "$(pwd)" != "$IVY_PATH/docker" ]; then
        if ! command -v gotod >/dev/null 2>&1; then
            echo -e "${RED}Error: ${BYEL}gotod ${YEL}function not available and not in correct directory$NC"
            return 1
        fi
        goto docker
    fi

    # Check if compose file exists
    if [ ! -f "$compose_file" ]; then
        echo -e "${RED}Error: ${YEL}Docker compose file not found: $compose_file $NC"
        return 1
    fi

    local env_file=""
    # Check if env file exists
    if [ "$environment" == "prod" ]; then
        env_file="$GREENHOUSE_PATH/config/${environment}/.env"
    elif [ "$environment" == "preprod" ]; then
        env_file="$GREENHOUSE_PATH/config/${environment}/.env"
    else
        env_file="./env/${environment}/.env"
    fi

    echo "Using env file [$env_file]"
    if [ ! -f "$env_file" ]; then
        echo -e "${RED}Error: ${YEL}Environment file not found: $env_file $NC"
        return 1
    fi

    # Execute the appropriate command
    case "$command" in
        up|u)
            echo -e "${GRE}Starting $environment environment... $NC"
            docker compose -f "$compose_file" --env-file "$env_file" -p "$environment" up -d
            ;;
        down|d)
            echo -e "${GRE}Stopping and removing $environment environment... $NC"
            docker compose -f "$compose_file" --env-file "$env_file" -p "$environment" down
            ;;
        stop|s)
            echo -e "${GRE}Stopping $environment environment... $NC"
            docker compose -f "$compose_file" --env-file "$env_file" -p "$environment" stop
            ;;
        restart|r)
            echo -e "${GRE}Restarting $environment environment... $NC"
            docker compose -f "$compose_file" --env-file "$env_file" -p "$environment" restart
            ;;
        stop-up|su)
            echo -e "${GRE}Stopping then starting $environment environment... $NC"
            docker compose -f "$compose_file" --env-file "$env_file" -p "$environment" stop
            docker compose -f "$compose_file" --env-file "$env_file" -p "$environment" up -d
            ;;
        down-up|du)
            echo -e "${GRE}Removing then starting $environment environment... $NC"
            docker compose -f "$compose_file" --env-file "$env_file" -p "$environment" down
            docker compose -f "$compose_file" --env-file "$env_file" -p "$environment" up -d
            ;;
        *)
            echo -e "${RED}Error: ${YEL}Invalid command '$command'${NC}"
            greenhouse-help
            return 1
            ;;
    esac
}

function colors-info() {
    echo -e "   ${BGRE}List of Colors:$NC"
    echo -e "      ${BLA}BLA|BLACK      ${RED}RED      ${GRE}GRE|GREEN       ${CYA}CYA|CYAN"
    echo -e "      ${YEL}YEL|YELLOW     ${BLU}BLUE     ${PUR}PUR|PURPLE      ${WHI}WHI|WHITE"
    echo -e "   ${BGRE}Format:$NC"
    echo -e "      ${RED}Regular|{COLOR}$NC    ${BRED}Bold|B{COLOR}$NC    ${URED}Underline|UN{COLOR}$NC "
    echo -e "      ${BIRED}BoldHigh Intens|BI{COLOR}$NC    ${ON_RED}Background|ON_{COLOR}$NC   ${IRED}High Intensity|I{COLOR}$NC"
    echo -e "      ${ON_IRED}High Intensity Backgrounds|ON_I{COLOR}$NC"
}

function info() {
    echo -e "${GRE} ############################################################################################${NC}"
    echo -e "${GRE} # ${YEL}Alias     ${GRE}################################################################################${NC}"
    echo -e "${GRE} ############################################################################################${NC}"
    echo ""
    echo -e "${BBLU}      ls      ${BLU}= ls -a${NC}"
    echo ""
    echo -e "${BBLU}      status  ${BLU}= git status${NC}"
    echo -e "${BBLU}      commit  ${BLU}= git commit -m${NC}"
    echo -e "${BBLU}      pull    ${BLU}= git pull${NC}"
    echo -e "${BBLU}      push    ${BLU}= git push${NC}"
    echo -e "${BBLU}      add     ${BLU}= git add${NC}"
    echo -e "${BBLU}      restore ${BLU}= git restore${NC}"
    echo -e "${BBLU}      dbranch ${BLU}= git branch -d${NC}"
    echo ""
    gotoHelpAlias
    echo ""
    echo -e "${GRE} ############################################################################################${NC}"
    echo -e "${GRE} # ${YEL}Functions ${GRE}################################################################################${NC}"
    echo -e "${GRE} ############################################################################################${NC}"
    echo ""
    echo -e "${RED} -$BRED loadProfiling ${GRE}:${YEL} Copy from the workspace ivy-greenhouse repository the profile ${BYEL}[$GREENHOUSE_PROFILE_SCRIPT]${YEL}.  ${NC}"
    echo -e "${RED} -$BRED editProfile ${GRE}:${YEL} Edit main profile ${BYEL}[$PROFILE_SCRIPT]${YEL} opening VS Code. ${NC}"
    echo -e "${RED} -$BRED editGhProfile ${GRE}:${YEL} Edit Greenhouse profile ${BYEL}[$GREENHOUSE_PROFILE_SCRIPT]${YEL} opening VS Code. ${NC}"
    echo -e "${RED} -$BRED reloadProfile ${GRE}:${YEL} Reload profile ${BYEL}[$PROFILE_SCRIPT]${YEL}. ${NC}"
    echo ""
    echo -e "${RED} -$BRED getProfileOS ${GRE}:${YEL} Get OS Name. ${NC}"
    echo -e "${RED} -$BRED getProfileOsName ${GRE}:${YEL} Get OS profile name. ${NC}"
    echo ""
    echo -e "${RED} -$BRED greenhouse ${GRE}:${YEL} Deploy docker-compose of greenhouse. ${NC}"
    echo -e "${RED} -$BRED greenhouse-help ${GRE}:${YEL} greenhouse documentation function. ${NC}"
    greenhouse-help
    echo ""
    echo -e "${RED} -$BRED goto ${GRE}:${YEL} giving the \"where\" will do a cd to that address. ${NC}"
    gotoHelp
    echo ""
    echo -e "${RED} -$BRED ssh-with ${GRE}:${YEL} giving the \"user\" will connect using ssh to the giving configured key & ip. ${NC}"
    echo -e "${YEL}   SSH Info: users stored [${#sshusers[@]}] | keys stored [${#sshkeys[@]}] | connections stored [${#sships[@]}].${NC}"
    echo -e "${RED}   WARN: If numbers are not matching, some connection could not work${NC}"
    sshInfo
    echo ""
    echo -e "${RED} -$BRED colors-info ${GRE}:${YEL} Shows list of colors and formats. ${NC}"
    colors-info
    echo ""
    echo -e "${GRE} ############################################################################################${NC}"
}

# GoTo Aliases

alias gotow="goto workspace"
alias gotol="goto lirio"
alias gotoh="goto home"
alias gotod="goto docker"
alias gotogh="goto greenhouse"
alias gotoi="goto ivy"

# Git Aliases

alias status="git status"
alias commit="git commit -m"
alias pull="git pull"
alias push="git push"
alias add="git add"
alias restore="git restore"
alias dbranch="git branch -d"

# Other Aliases

alias ls="ls -a"

function parse_git_branch() {
    local branch
    branch=$(git branch --show-current 2> /dev/null)
    if [[ -n "$branch" ]]; then
        # Check for uncommitted changes
        if ! git diff --no-ext-diff --quiet --exit-code 2>/dev/null || \
           ! git diff --no-ext-diff --cached --quiet --exit-code 2>/dev/null; then
            echo "*${branch}*"  # Asterisk for dirty state
        else
            echo "$branch"     # No asterisk for clean state
        fi
    else
        echo ""
    fi
}

function customizePS1() {
    local bla="\[\033[1;30m\]"
    local red="\[\033[1;31m\]"
    local gre="\[\033[1;32m\]"
    local yel="\[\033[1;33m\]"
    local blu="\[\033[1;34m\]"
    local cya="\[\033[3;36m\]" # 3 gives italic <3
    local whi="\[\033[1;37m\]"
    local rst="\[\033[00m\]"
    
    local time="${whi}[${blu}\D{%Y/%m/%d} \t${whi}]"
    local user_host="${gre}\u@\h"
    local current_path="${whi}| ${yel}\w"

    # Get git branch dynamically
    local branch="$(parse_git_branch)"
    local git=""
    if [[ -n "$branch" ]]; then
        git="${whi}| ${blu}Branch ${cya}${branch} ${rst}"
    fi

    # Set PS1 directly in the function
    PS1="${time} ${user_host} ${current_path} ${git}${gre}\\\$ ${rst}"
}

# This runs customizePS1 before each prompt
export PROMPT_COMMAND="customizePS1"

info