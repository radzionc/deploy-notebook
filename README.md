# deploy-notebook

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

## [Story on Medium](https://medium.com/@geekrodion/blog-with-asp-net-core-and-react-redux-c80857b93cb6)

## License

MIT © [RodionChachura](https://geekrodion.com)
