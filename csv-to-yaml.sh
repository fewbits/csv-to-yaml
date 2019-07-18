#!/bin/bash

##########
# Config #
##########
optDelimiter=","
optHeader="Lowbit Tools - CSV to YAML"
optNull="Null"
optTempFile="/tmp/csv-to-yaml.tmp"
optVersion="v1.0.0-dev"

#########
# Flags #
#########
flagDebug="false"
flagStep="false"
flagTranspose="false"

#############
# Functions #
#############

getHelp() {
  echo "${optHeader}"
  echo
  echo "Syntax:"
  echo
  echo "  `basename $0` [--debug] --file FILE [--delimiter DELIMITER] [--transpose] [--step]"
  echo "  `basename $0` --help"
  echo "  `basename $0` --version"
  echo
  echo "All options:"
  echo
  echo "  -d|--delimiter DELIMITER"
  echo "      Optional - The DELIMITER character to be used"
  echo "      Defaults to comma (,)"
  echo
  echo "  -f|--file FILE"
  echo "      Required - The input CSV FILE to be converted"
  echo
  echo "  -h|--help"
  echo "      Shows this help message"
  echo
  echo "  -s|--step"
  echo "      Optional - Asks for confirmation before each step"
  echo "      (Used for debugging)"
  echo
  echo "  -t|--transpose"
  echo "      Optional - Transposes the input CSV file before converting it to YAML"
  echo
  echo "  -v|--version"
  echo "      Shows the version of the script"
  echo
  echo "  -D|--debug"
  echo "      Optional - Displays debug messages"
  echo "      (Used for debugging)"
  exit 0
}

getVersion() {
  echo "${optHeader}"
  echo "Version: ${optVersion}"
  exit 0
}

logMessage() { # Logs a message

  # Validating the number of arguments
  if [[ ! "${2}" ]]; then
    echo "Error: 'logMessage' function called with wrong number of arguments (expected 2)"
    exit 1
  fi

  # Setting the args
  logType=$1        # Log Type (info/debug/error)
  logString="${2}"  # Log Message (any string)

  # Validating the logType argument
  case $logType in
    "info")
      # Valid - Always log
      logFlag=true
      logTypeColor="\e[36minfo \e[0m"
      ;;

    "debug")
      # Valid - Log only when DEBUG=1 is set
      if [[ $flagDebug == "true" ]]; then
        logFlag=true
      else
        logFlag=false
      fi
      logTypeColor="\e[90mdebug\e[0m"
      ;;

    "error")
      # Valid - Always log
      logFlag=true
      logTypeColor="\e[31merror\e[0m"
      ;;

    *)
      echo "Error: 'sysLogMessage' function called with wrong log type"
      exit 1
      ;;
  esac

  if [ $logFlag == "true" ]; then
    echo -e "[`date +'%Y-%m-%d %H:%M:%S'`] [$logTypeColor] ${logString}"
  fi

  # Exiting if this is an error message
  if [ $logType == "error" ]; then
    exit 1
  fi

}

nextStep() {
  if [[ $flagStep == "true" ]]; then
    read -p "Step mode - Hit [ENTER] to continue..."
  fi
}

writeYAML() {
  yamlLine="${1}"

  logMessage info "YAML line: ${yamlLine}"
  echo "${yamlLine}" >> "${outputFile}"
}

readArguments() {

  # User must pass at least one argument, or we print a help message
  if [[ ! $1 ]]; then
    getHelp
  fi

  # Looping through the user arguments
  while [[ $1 ]]; do
    logMessage debug "Processing argument: ${1}"

    case "${1}" in
      "-D"|"--debug")
        flagDebug="true"
        logMessage debug "Debug option enabled"
        ;;
      "-d"|"--delimiter")
        shift

        if [[ $1 ]]; then

          # Validating the lenght of the delimiter
          if [[ ${#1} -eq 1 ]]; then
            optDelimiter="${1}"
            logMessage debug "New delimiter: ${optDelimiter}"
          else
            logMessage error "The delimiter must be exactly 1 character (received '${1}')"
          fi

        else
            logMessage error "Missing the DELIMITER value"

        fi

        ;;
      "-f"|"--file")
        shift

        if [[ $1 ]]; then

          # Validating if this is a valid file
          if [[ -f ${1} ]]; then
            inputFile="${1}"
            logMessage info "Input file: $inputFile"
          else
            logMessage error "Input file not found (received '${1}')"
          fi

        else
            logMessage error "Missing the FILE value"

        fi

        ;;
      "-h"|"--help")
        getHelp
        ;;

      "-s"|"--step")
        flagStep="true"
        logMessage debug "Step option enabled"
        ;;

      "-t"|"--transpose")
        flagTranspose="true"
        logMessage debug "Transpose option enabled"
        ;;
      
      "-v"|"--version")
        getVersion
        ;;

      *)
        logMessage debug "Unknown argument - Ignoring"
        ;;

    esac

    shift
  done
}

checkEnvironment() {

  # The input CSV file is required
  if [[ ! ${inputFile} ]]; then
    logMessage error "Missing file parameter (--file FILE)"
  fi

}

prepareEnvironment() {
  # Setting Output file name
  outputFile=`echo "${inputFile}" | sed s/'.csv'/'.yml'/g`
  logMessage info "Output file: ${outputFile}"

  # Emptying files
  logMessage debug "Emptying files"
  > ${optTempFile}  # Temporary file
  > ${outputFile}   # Output file
  nextStep

  # Generating initial temporary file
  logMessage debug "Creating temp file"
  cp "${inputFile}" "${optTempFile}"
  nextStep

  # Transposing, if needed
  if [[ $flagTranspose == "true" ]]; then
    logMessage debug "Transposing input file"
    csvtool transpose "${optTempFile}" > "${optTempFile}.1"
    mv "${optTempFile}.1" "${optTempFile}"
    nextStep
  fi

  # Ordering temporary file
  logMessage debug "Ordering temp file"
  sort "${optTempFile}" > "${optTempFile}.1"
  mv "${optTempFile}.1" "${optTempFile}"
  nextStep

}

convertFile() {

  logMessage debug "Starting file convertion"

  # Writing the initial YAML syntax
  writeYAML "---"

  nextStep

  # Looping through the lines
  IFS=$'\n'
  for line in `cat ${optTempFile}`; do
    IFS=$'\n'

    # Getting line
    logMessage debug "Line: ${line}"

    # Getting Key
    key=`echo ${line} | cut -d${optDelimiter} -f1`
    logMessage debug "  Key: ${key}"

    # Getting Value
    value=`echo ${line} | cut -d${optDelimiter} -f2`
    if [[ $value == "" ]]; then
      value="${optNull}"
    fi
    logMessage debug "  Value: ${value}"

    # Counting the number of elements in key
    elements=`echo "${key}" | tr "." "\n" | wc -l`
    logMessage debug "  Key elements: ${elements}"

    nextStep

    # Loop though key elements
    IFS="."
    identation="" # Identation starts at 0
    level=1 # Level starts at 1
    pointerLine=1 # Starting the pointer at line 1
    unset value_if_any # Unseting the value flag
    for element in ${key}; do

      # Pointer position
      logMessage debug "    Pointer: ${pointerLine}"

      logMessage debug "    Key element #${level}: ${element}"

      # Checking if the element is already in the file
      if [[ `grep -e "^${identation}${element}:" "${outputFile}"` ]]; then

        # Element found in file - Getting last ocurrence
        lineFound=`grep -n -e "^${identation}${element}:" "${outputFile}" | tac | head -n1 |cut -d: -f1`
        logMessage debug "    Element found at line: ${lineFound}"

        # Checking if it's our element
        if [[ $lineFound -gt $pointerLine ]]; then
          # OK - This is our line
          logMessage debug "    Found after pointer - This is our line"
          willWrite="false"
          pointerLine="${lineFound}" # Updating the pointer
        else
          logMessage debug "    Found before pointer - Not our line"
          willWrite="true"
        fi

      else
        # Line not found - will write
        logMessage debug "    No element found"
        willWrite="true"
      fi

      # Deciding wether to write the line
      if [[ $willWrite == "true" ]]; then

        # Writing the line
        logMessage debug "    ! New line"

        # Checking if the element is the last (to append the value)
        if [[ ${level} -eq ${elements} ]]; then
          logMessage debug "    ! Last element - Appending value"
          value_if_any=" ${value}"
        fi

        writeYAML "${identation}${element}:${value_if_any}"

      else

        logMessage debug "    Line already exists (line ${pointerLine}) - Ignoring"

      fi

      # Updating the pointer and ignoring the line
      pointerLine=`grep -n -e "^${identation}${element}:" "${outputFile}" | tac | head -n1 |cut -d: -f1`

      # Preparing the next iteration
      identation="${identation}  "
      ((level++))

      nextStep

    done

  logMessage debug "End of line"
  nextStep

  done

  logMessage debug "End of file"
  nextStep

  unset IFS

}

validateFile() {
  # Validating the generated YAML
  logMessage info "Validating the generated YAML file"
  yamllint --config-data "{extends: relaxed, rules: {line-length: disable}}" ${outputFile}
}

cleanEnvironment() {
  # Cleaning the mess
  logMessage debug "Cleaning temporary files"
  rm "${optTempFile}"
}

##########
# Script #
##########

readArguments $@
checkEnvironment
prepareEnvironment
convertFile
validateFile
cleanEnvironment

logMessage info "End of file convertion"
