# $1 = function name
# $2 = bucket name
# $3 = bucket object name (zipped folder)

. ./cook_notebook.sh

aws s3 cp $3 s3://$2/$3
aws lambda update-function-code --function-name $1 --s3-bucket $2 --s3-key $3