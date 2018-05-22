# Deploy Jupyter Notebook to AWS Lambda
## example for [medium article](https://medium.com/p/a57e87c53f37)
![all text](https://cdn-images-1.medium.com/max/880/1*F9DLYPTkrq6UUPvzXaV8PA.png)

### run locally:
```bash
$ git clone https://github.com/RodionChachura/deploy-notebook.git  
$ cd deploy-notebook # set credentials in main.tf  
$ . ./cook_notebook.sh  
$ terraform init  
$ terraform apply 
$ curl --request POST --data '{"a": 3, "b": 4}' <URL_FROM_OUTPUT>/function
```

## update function code:
```bash
$ . ./deploy.sh tf-lambda tf-lambdas function.zip
```