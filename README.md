# omar-app

A small node.js api that runs on aws lambda, with a sql server database.

Everything in aws is built with terraform. When code in `app/` changes on `main`, github actions deploys it to lambda automatically.

The app is just a placeholder that says hello. The main part of this task is the aws setup and the pipeline.

## How it works

1. You call the lambda's url.
2. The lambda runs inside a private network.
3. The database sits in the same private network. Only the lambda can reach it.
4. The database password is made by aws and stored in secrets manager, so it's never in the code.
5. Github logs in to aws without any saved keys, and can only update this one lambda.

## Folders

- app/ - the lambda code
- create-s3-tfstate/ - makes the s3 bucket terraform uses to keep track of what it built
- infra/ - the main terraform setup, run terraform from here
- tf_modules/ - the building blocks: network, database, lambda and github access
- .github/workflows/ - the pipeline

## Before you start

You'll need:

- terraform 1.10 or newer
- aws cli
- an aws account you can log in to from your terminal

Check you're logged in:

    aws sts get-caller-identity

## How to deploy it

1. The state bucket is called omar-app-tfstate-test. If that's taken, change it in create-s3-tfstate/main.tf and infra/versions.tf.

2. Create the bucket:

        cd create-s3-tfstate
        terraform init
        terraform apply

3. Build everything:

        cd ../infra
        terraform init
        terraform apply

4. When it finishes, terraform prints the lambda's url as api_url. Open it in a browser and you should see a hello message.
