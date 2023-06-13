#!/bin/bash

showHelp(){
    echo "---------------------------------------"
    echo "Usage: $0 -o <owner> -m <month>"
    echo -e "\t File owner is parameter -o"
    echo -e "\t Creation month is parameter -m"
    echo "---------------------------------------"
    exit 1 # Exit script after showing help
}

showLinesCount(){
    nlines=$(wc -l < $1)
    # since wc -l starts counting from 0
    totalPlusOne=`expr $nlines + 1`
    echo -e "File: $1, \t Lines: $totalPlusOne"
}

noDataFoundHelper(){
    #param1Len=`echo $1 | wc -c`
    #param2Len=`echo $2 | wc -c`
    echo "No data found for defined search criteria" ;
    #if [ $param1Len -gt 3 ] ; then echo "owner: $1" ; fi
    #if [ $param2Len -gt 3 ] ; then echo "creation month: $2" ; fi
}

# checking parameter values
if [[ $# -eq 0 ]] ; then
    >&2 showHelp
    exit 1
fi

# assign variable values from parameters received
while getopts "o:m:" opt
do
    case "$opt" in
        o ) paramOwner="$OPTARG" ;;
        m ) paramMonth="$OPTARG" ;;
        ? ) showHelp ;;
    esac
done

# setting variables length 
param1Len=`echo $paramOwner | wc -c`
param2Len=`echo $paramMonth | wc -c`


# displaying results
echo "Looking for files where " ;
if [ $param1Len -gt 3 ] ; then echo "owner is: $paramOwner" ; fi
if [ $param2Len -gt 2 ] ; then echo "creation month is: $paramMonth" ; fi

#if [ -n $param1Len ] ; then echo "owner is: $paramOwner" ; fi
#if [ -n $param2Len ] ; then echo "creation month is: $paramMonth" ; fi

# no data found flag
noDataFound=0

# iterating over current directory to retrieve files
for f in * ; do
    # get file owner
    fileOwner=`stat -f "%Su" $f`
    # get creation date
    fileCreationDate=`stat -f "%Sm" $f`
    # get creation month using bash substring expansion
    fileCreationMonth=`echo ${fileCreationDate:0:3}`
    #echo "Fileowner is: $fileOwner"
    #echo "Creation month is: $fileCreationMonth"


    # compare file owner and creation month
    if [ $param1Len -gt 3 ] && [ $param2Len -gt 2 ] ; then
        if [ "$paramOwner" = "$fileOwner" ] && [ "$paramMonth" = "$fileCreationMonth" ] ; then
            showLinesCount $f
        else 
                noDataFound=1
        fi
    
    # compare file owner
    elif [ $param1Len -gt 3 ] ; then 
        if [ $paramOwner = $fileOwner ] ; then
            showLinesCount $f
        else
                noDataFound=1
        fi
    
    # compare creation month
    elif [ $param2Len -gt 2 ] ; then 
        if [ $paramMonth = $fileCreationMonth ] ; then
            showLinesCount $f
        else
                noDataFound=1
        fi
    # no matching condition
    else
        noDataFound=1
    fi
done

# show no data found message
if [ $noDataFound -eq 1 ] ; then
    noDataFoundHelper
fi