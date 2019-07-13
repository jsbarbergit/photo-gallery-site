#!/bin/bash
if [ -z $1 ]; then
    echo "Error - must pass in function name"
    echo "Function name must correspond with a directory under ./lambda_functions/"
    exit 1
fi

function=$1
echo "Starting package process for $function"

if [ ! -d "lambda_functions/$function" ]; then
    echo "Error - Function $function not found under ./lambda_functions/"
    exit 1
fi

echo "Checking for function updates via hash file"
shafile="./.$function.sha"
newhash=$(find lambda_functions/$function -type f -print0 | sort -z | xargs -0 sha1sum | sha1sum| sed 's/ //g')
echo "newhash = $newhash"
# If hash file exists - compare. If not continue as need to generate and run regardless
if [ -f ./.$function.sha ]; then
    oldhash=$(cat $shafile | sed 's/ //g')
    echo "oldhash = $oldhash"
    if [ "$oldhash" == "$newhash" ]; then
        echo "Hashes match - no change detected. Exiting"
        exit 0
    fi
fi

pushd ./lambda_functions/$function
zipfile="function.zip"
if [ -f $zipfile ]; then
    echo "Existing function.zip file found - will replace"
    mv $zipfile $zipfile.old
fi

echo "Creating new function.zip file"

zip -r -q $zipfile ./*


if [ $? -eq 0 ]; then
    rm -f $zipfile.old
else
    echo "Error - restoring original function.zip file"
    mv $zipfile.old $zipfile
    popd
    exit 1
fi
popd
# Update hash file
newhash=$(find lambda_functions/$function -type f -print0 | sort -z | xargs -0 sha1sum | sha1sum)
echo $newhash > $shafile

echo "Success - $zipfile created. Now run terraform to update infra with new function code"
exit 0