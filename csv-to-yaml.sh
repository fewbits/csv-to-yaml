#!/bin/bash

# TODO: -f FILE
# TODO: -d DELIMITER
# TODO: -t (TRANSPOSE)

##########
# Config #
##########
optTempFile="/tmp/csv-to-yaml.tmp"
optDelimiter="|"

#############
# Functions #
#############

getHelp() {
  echo "Lowbit Tools - CSV to YAML"
  echo
  echo "Syntax:"
  echo "  `basename $0` -f FILE [-d DELIMITER] [--step]"
}

readArguments() {

  # First argument must be a CSV file
  if [[ $1 ]]; then
    if [[ -f $1 ]]; then
      echo "OK - valid file"
    else
      echo "File not found"
      exit 1
    fi
  else
    echo "Missing file argument"
    exit 1
  fi

  # Saving the file to a variable
  inputFile=$1
  outputFile=`echo "${inputFile}" | sed s/'.csv'/'.yml'/g`

  echo "Input file => ${inputFile}"
  echo "Output file => ${outputFile}"


}

##########
# Script #
##########

# The temp files must be empty
> ${optTempFile}.1
> ${optTempFile}.2

# The CSV file must be alphabetically ordered
sort ${inputFile} >> ${optTempFile}.1

# Writing the initial YAML syntax
echo "---" >> "${optTempFile}.2"

# Loop through the lines
IFS=$'\n'
for line in `cat ${optTempFile}.1`; do
  IFS=$'\n'

  # Getting line
  echo "Line => ${line}"

  # Getting Key
  key=`echo ${line} | cut -d${optDelimiter} -f1`
  echo "Key => ${key}"

  # Getting Value
  value=`echo ${line} | cut -d${optDelimiter} -f2`
  if [[ $value == "" ]]; then
    value="Null"
  fi
  echo "Value => ${value}"

  # Counting the number of elements in key
  elements=`echo "${key}" | tr "." "\n" | wc -l`
  echo "Elementos => ${elements}"

  # Loop though key elements
  IFS="."
  identation="" # Identation starts in zero
  level=1 # Level starts in one
  unset value_if_any # Unseting the value flag
  for element in ${key}; do
    echo "Elemento (${level}) => ${element}"

    # Checking if the element is already in the file
    if [[ `grep -e "^${identation}${element}:" "${optTempFile}.2"` ]]; then
      # Line found - skipping
      true

    else
      # Line not found - writing
      # Checking if the element is the last (to append the value)
      if [[ ${level} -eq ${elements} ]]; then
        value_if_any=" ${value}"
      fi

      # Finally writing the line
      echo "${identation}${element}:${value_if_any}" >> "${optTempFile}.2"

    fi

    # Preparing the next iteration
    identation="${identation}  "
    ((level++))

  done

done

unset IFS

# Wow! I think this worked. Lets save the file
echo "Saving the final YAML to ${outputFile}"
cp "${optTempFile}.2" "${outputFile}"

# Cleaning the mess
rm "${optTempFile}.1"
rm "${optTempFile}.2"

# The End, my friend.
echo "CSV file converted (I guess)"; echo
cat "${outputFile}"; echo

# Validating the awesome YAML
yamllint ${outputFile}
