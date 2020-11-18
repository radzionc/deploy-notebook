# Deploy Notebook
These days it is possible to deploy a function from Jupiter Notebook in less than a minute.
>

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

## [Blog Post](https://geekrodion.com/blog/deploy-jupyter-lambda)

## Technologies
* Python
* Jupyter Notebook
* AWS Lambda
* Terraform

## License

MIT © [RodionChachura](https://geekrodion.com)
