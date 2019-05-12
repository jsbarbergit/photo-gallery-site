cd ./site 
aws s3 sync . s3://photos.jsbarber.net --acl public-read
cd ../
exit 0