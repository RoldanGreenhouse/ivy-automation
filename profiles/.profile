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
	else # Linux
		echo "WIP"
	fi
}

function getProfileOS() {
    if [[ "$OSTYPE" == "msys"* ]]; then # Windows | GitBash
		echo "/c/Users/$USERNAME/.bash_profile"
	elif [[ "$OSTYPE" == "cygwin"* ]]; then # Windows | Cygwin
		echo "/c/Users/$USERNAME/.bash_profile"
	elif [[ "$OSTYPE" == "darwin"* ]]; then # Mac OS X
		echo "/Users/$USERNAME/.zshrc"
	else # Linux
		return "WIP"
	fi
}

: "${BASE_PATH_SCRIPTS:="/Users/$USERNAME"}"

export PROFILE_SCRIPT="$BASE_PATH_SCRIPTS/$(getProfileOsName)"

export PROFILE_CONFIG_SCRIPT_NAME=.greenhouse.config
export PROFILE_CONFIG_SCRIPT_PATH="$BASE_PATH_SCRIPTS/$PROFILE_CONFIG_SCRIPT_NAME"

export PROFILE_COLORS_SCRIPT_NAME=.greenhouse.colors
export PROFILE_COLORS_SCRIPT_PATH="$BASE_PATH_SCRIPTS/$PROFILE_COLORS_SCRIPT_NAME"

if [[ -z "${CONFIG_IMPORTED}" ]]; then
    . $PROFILE_CONFIG_SCRIPT_PATH
    : "${CONFIG_IMPORTED:? Not able to read configuration}" 
fi

if [[ -z "${COLORS_SH_IMPORTED}" ]]; then
    . $PROFILE_COLORS_SCRIPT_PATH
    : "${COLORS_SH_IMPORTED:? The variable needs to be defined}" 
fi

export WORKSPACE_PATH=$BASE_PATH_SCRIPTS/Workspace
export DOCKER_UDEMY_PATH=$WORKSPACE_PATH/udemy-docker-mastery
export GREENHOUSE_PATH=$WORKSPACE_PATH/greenhouse
export IVY_PATH=$GREENHOUSE_PATH/ivy-automation
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
    echo -e "${BLU}      workspace       - $WORKSPACE_PATH ${NC}"
    echo -e "${BLU}      lirio|home      - $BASE_PATH_SCRIPTS ${NC}"
    echo -e "${BLU}      docker-udemy|du - $DOCKER_UDEMY_PATH ${NC}"
    echo -e "${BLU}      greenhouse|gh   - $GREENHOUSE_PATH ${NC}"
    echo -e "${BLU}      ivy|i           - $IVY_PATH ${NC}"
    echo -e "${BLU}      ivy-docker|d    - $IVY_PATH/docker ${NC}"
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
    echo -e "${BBLU}      ls     ${BLU}= ls -a${NC}"
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

alias gotow="goto workspace"
alias gotol="goto lirio"
alias gotoh="goto home"
alias gotod="goto docker"
alias gotogh="goto greenhouse"
alias gotoi="goto ivy"
alias ls="ls -a"

info