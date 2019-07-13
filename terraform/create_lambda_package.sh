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

pushd ./lambda_functions/$function
zipfile="function.zip"
if [ -f $zipfile ]; then
    echo "Existing function.zip file found - will replace"
    mv $zipfile $zipfile.old
fi

echo "Creating new function.zip file"

zip -r $zipfile ./*
if [ $? -eq 0 ]; then
    rm -f $zipfile.old
else
    echo "Error - restoring original function.zip file"
    mv $zipfile.old $zipfile
    popd
    exit 1
fi
popd

echo "Success - $zipfile created. Now run terraform to update infra with new function code"
exit 0