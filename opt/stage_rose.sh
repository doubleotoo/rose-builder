#!/bin/sh

#DEFAULT ARGUMENTS
SRC_IGNORED_FILES=( )
SRC_MULTI_TARGET_FILES=( )
TARGET_STAGGED_FILES=( )
TARGET_SKIP_FILES=( )
SRC_SKIP_FILES=( )
SRC_FOLDER=
TARGET_FOLDER=
CONFIRM=1
DEBUG=0
VERBOSE=1

# Prints acript usage information
usage()
{
    cat << EOF
usage: $0 [OPTIONS] SOURCE TARGET

This script will stage rose output into the original source location, overwriting the original source code.  Use with caution!    

OPTIONS:
   -h      Show this message
   -f      Force staging.  Don't prompt for confirmation.
   -q      Quiet
   -t      Skip targets ending with strings. This is a file, newline delimited.
   -s      Skip sources ending with strings. This is a file, newline delimited.
   -d      Debug
EOF
}

# Presents a yes/no option to the user
function confirm() {
    while true; do
        read -p "$1 [y/n] " yn
        case $yn in
            [Yy] | [Yy][Ee][Ss] )
                echo "y"
                break
                ;;
            [Nn] | [Nn][Oo] )
                echo "n"
                break
                ;;
        esac
    done
}

#walk up n directories
function walkupn() {
    local PARENT_PATH=$1
    for (( i=1; i <= $2; i++ ))
    do
        local PARENT_PATH=$(dirname "$PARENT_PATH")
	if [[ "$PARENT_PATH" == "." || "$PARENT_PATH" == "/" ]];
        then
            local PARENT_PATH=""
            break
        fi
    done
    echo "$PARENT_PATH"
}

# Guess target file based on source path
function guess() {
    local CMP_SRC_FILE=${1}
    local CMP_TARGET_FILES=( ${2} )
    local CMP_LEVEL=${3}
    local CMP_TARGET_FILES_MATCHING=( )
    local CMP_SRC_FILE_PARENT=$(walkupn "$CMP_SRC_FILE" $CMP_LEVEL)
    if [ -z "$CMP_SRC_FILE_PARENT" ];
    then
        # We walked up to the root
        echo ""
        return
    fi

    for CMP_TARGET_FILE in ${CMP_TARGET_FILES[@]}
    do
        local CMP_TARGET_FILE_PARENT=$(walkupn "$CMP_TARGET_FILE" $CMP_LEVEL)
        if [[ "$(basename "$CMP_SRC_FILE_PARENT")" == "$(basename "$CMP_TARGET_FILE_PARENT")" ]];
        then
            CMP_TARGET_FILES_MATCHING[${#CMP_TARGET_FILES_MATCHING[*]}]="$CMP_TARGET_FILE"
        fi
    done

    local CMP_LEVEL=$[$CMP_LEVEL+1]

    # check for number of matches
    if [ ${#CMP_TARGET_FILES_MATCHING[@]} -gt 1 ];
    then
        echo "$(guess "$CMP_SRC_FILE" "${CMP_TARGET_FILES_MATCHING[*]}" $CMP_LEVEL)"
    elif [ ${#CMP_TARGET_FILES_MATCHING[@]} -eq 1 ];
    then
        echo "${CMP_TARGET_FILES_MATCHING[0]}"
    else
        echo ""
    fi
}

function contains() {
    local CMP_VALUES=( ${1} )
    local CMP_TEST=${2}
    if [[ ${CMP_VALUES[*]} =~ \\b${CMP_TEST}\\b ]];
    then
        echo "y"
    else
        echo "n"
    fi
}

function findtargetfiles() {
    local SRC_FILE=${1}

    # Check skip on source file
    if [ ${#SRC_SKIP_FILES[*]} -gt 0 ];
    then
        for SRC_SKIP_FILE in ${SRC_SKIP_FILES[@]}
        do
            if [[ "$SRC_FILE" == *"$SRC_SKIP_FILE" ]];
            then
                echo ""
                return
            fi
        done
    fi

    # Parse the filename from the path
    local SRC_FILENAME=`echo -n "$SRC_FILE" | awk 'BEGIN { FS = "/" } ; { print $NF }'`

    # Parse the target (original) file name
    local TARGET_FILENAME=`echo -n "$SRC_FILENAME" | awk '{sub(/rose_/,"")}; 1'`

    # Find the target to update
    local TARGET_FILES=( $(find "$TARGET_FOLDER" -name "$TARGET_FILENAME" -type f) )

    if [ ${#TARGET_SKIP_FILES[*]} -gt 0 ];
    then
        for TARGET_SKIP_FILE in ${TARGET_SKIP_FILES[@]}
        do
            local TARGET_FILES_INDEX=0
            while [ $TARGET_FILES_INDEX -lt ${#TARGET_FILES[*]} ]
            do
                if [[ ${TARGET_FILES[$TARGET_FILE_INDEX]} == *"$TARGET_SKIP_FILE" ]];
                then
                    unset TARGET_FILES[$TARGET_FILES_INDEX]
                    local TARGET_FILES=( "${TARGET_FILES[*]}" )
                else
                    local TARGET_FILES_INDEX=$[$TARGET_FILES_INDEX+1]
                fi
            done
        done
    fi
    
    echo "${TARGET_FILES[@]}"
}

function stagefile() {
    local SRC_FILE=${1}
    local TARGET_FILE=${2}

    if [ $VERBOSE -eq 1 ];
    then
        echo "Stagging '$SRC_FILE' -> '$TARGET_FILE'"
    fi

    if [ $CONFIRM -eq 1 ];
    then
        if [[ $(confirm "Overwrite '$TARGET_FILE'?") == "y" ]];
        then
            cp -pf "$SRC_FILE" "$TARGET_FILE"
        else
            echo "Skipping '$SRC_FILE'"
        fi
    else
        cp -pf "$SRC_FILE" "$TARGET_FILE"
    fi
}

function ignorefile() {
    local SRC_FILE=${1}
    echo "Ignoring '$SRC_FILE'.  No target found!" 1>&2
}

function multifile() {
    local SRC_FILE=${1}
    local TARGET_FILES=( $(findtargetfiles "$SRC_FILE") )

    # We found more than one target, ignore the file and log to stderr
    echo "Ignoring '$SRC_FILE'.  Multiple targets found!" 1>&2
    for TARGET_FILE in "${TARGET_FILES[@]}"
    do
        echo "     Target: '$TARGET_FILE'" 1>&2
    done
}

######################################
# MAIN SCRIPT
######################################
# Parse the arguments
while getopts “hfqds:” OPTION
do
     case $OPTION in
         h)
             usage
             exit
             ;;
         f)
             CONFIRM=0
             ;;
         d)
             DEBUG=1
             ;;
         q)
             VERBOSE=0
             ;;
         t)
             if [ -e "$OPTARG" ];
             then
                 if [ -r "$OPTARG" ];
                 then
                     OLD_IFS=$IFS
                     IFS=$'\n\r'
                     TARGET_SKIP_FILES=( $(cat "$OPTARG") )
                     IFS=$OLD_IFS
                 fi
             fi
             ;;
         s)
             if [ -e "$OPTARG" ];
             then
                 if [ -r "$OPTARG" ];
                 then
                     OLD_IFS=$IFS
                     IFS=$'\n\r'
                     SRC_SKIP_FILES=( $(cat "$OPTARG") )
                     IFS=$OLD_IFS
                 fi
             fi
             ;;
         ?)
             usage
             exit 1
             ;;
     esac
done

# Clear all options and reset the command line
shift $(( OPTIND -1 ))

# Get the root folder
if [ $# -eq 2 ];
then
    SRC_FOLDER=$1
    TARGET_FOLDER=$2
else
    echo "Received invalid arguments.  A SOURCE and TARGET folder must be specified."
    usage
    exit 1
fi

# SANITIZE INPUT
if [ ! -d "$SRC_FOLDER" ];
then
    # Source folder does not exist!
    echo "ERROR: '$SRC_FOLDER' does not exist!"
    exit 1
fi
if [ ! -d "$TARGET_FOLDER" ];
then
    # Target folder does not exist!
    echo "ERROR: '$TARGET_FOLDER' does not exist!"
    exit 1
fi


# Search for rose generated files
for SRC_FILE in $(find "$SRC_FOLDER" -name "rose_*" -type f)
do
    # Find the target to update
    TARGET_FILES=( $(findtargetfiles "$SRC_FILE") )

    # Make sure we have a target.  We might not always, as rose may inject new files.
    if [ ${#TARGET_FILES[@]} -eq 0 ];
    then
        # We found no targets, ignore the file and log to stderr
        SRC_IGNORED_FILES[${#SRC_IGNORED_FILES[*]}]="$SRC_FILE"
        continue
    elif [ ${#TARGET_FILES[@]} -gt 1 ];
    then
        # we found more than one target, try to guess based on paths
        TARGET_FILE=$(guess "$SRC_FILE" "${TARGET_FILES[*]}" 1)

        if [ -z "$TARGET_FILE" ];
        then
            # We found more than one target, ignore the file and log to stderr
            SRC_MULTI_TARGET_FILES[${#SRC_MULTI_TARGET_FILES[*]}]="$SRC_FILE"
            continue
        else
            # We found a target
            TARGET_STAGGED_FILES[${#TARGET_STAGGED_FILES[*]}]="$TARGET_FILE"
        fi
    else
        # We found one match, stage
        TARGET_FILE=${TARGET_FILES[0]}
        TARGET_STAGGED_FILES[${#TARGET_STAGGED_FILES[*]}]="$TARGET_FILE"
    fi

    if [ $DEBUG -eq 1 ];
    then
        # DEBUG INFO
        echo "SRC FILE:         $SRC_FILE"
        echo "SRC FILENAME:     $SRC_FILENAME"
        echo "TARGET FILE:      $TARGET_FILE"
        echo "TARGET FILENAME:  $TARGET_FILENAME"
        echo "TARGET TOTAL:     ${#TARGET_FILES[@]}"
    fi

    # Stage the file
    stagefile "$SRC_FILE" "$TARGET_FILE"

done

# Try to resolve the unguessed multi targets
SRC_INDEX=0
while [ $SRC_INDEX -lt ${#SRC_MULTI_TARGET_FILES[@]} ]
do
    SRC_MULTI_TARGET_FILE=${SRC_MULTI_TARGET_FILES[$SRC_INDEX]}
    
    # Find the target to update
    TARGET_MULTI_TARGET_FILES=( $(findtargetfiles "$SRC_MULTI_TARGET_FILE") )

    # Loop over targets and see if we can eliminate any based on previous guesses
    TARGET_INDEX=0
    while [ $TARGET_INDEX -lt ${#TARGET_MULTI_TARGET_FILES[@]} ]
    do
        if [[ $(contains "${TARGET_STAGGED_FILES[*]}" "${TARGET_MULTI_TARGET_FILES[$TARGET_INDEX]}") == "y" ]];
        then
            unset -v TARGET_MULTI_TARGET_FILES[$TARGET_INDEX]
            TARGET_MULTI_TARGET_FILES=( "${TARGET_MULTI_TARGET_FILES[*]}" )
        else
            TARGET_INDEX=$[$TARGET_INDEX+1]
        fi
    done
    
    # Check if we have one target now
    if [ ${#TARGET_MULTI_TARGET_FILES[@]} -eq 1 ];
    then
        # Only one target remains, stage
        stagefile "$SRC_MULTI_TARGET_FILE" "${TARGET_MULTI_TARGET_FILES[0]}"
        unset -v SRC_MULTI_TARGET_FILES[$SRC_INDEX]
        SRC_MULTI_TARGET_FILES=( "${SRC_MULTI_TARGET_FILES[*]}" )
    else
        SRC_INDEX=$[$SRC_INDEX+1]
    fi
done

# Print the ignroed files
for SRC_IGNORED_FILE in ${SRC_IGNORED_FILES[@]}
do
    ignorefile "$SRC_IGNORED_FILE"
done

# Print the multi target files
for SRC_MULTI_TARGET_FILE in ${SRC_MULTI_TARGET_FILES[@]}
do
    multifile "$SRC_MULTI_TARGET_FILE"
done
