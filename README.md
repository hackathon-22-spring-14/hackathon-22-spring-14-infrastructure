# hackathon-22-spring-14-infrastructure

## ディレクトリ構成

* modules
  * 各awsリソースのパーツを記述
  * 各モジュールではmain.tf,variables.tf,outputs.tfの3つを用意する
* envs/production
  * moduelsで定義されたパーツを呼び出し、構成を記述していく

## ローカルでの検証

`cd envs/production` 

1. `terraform init`
2. `terraform validate`

をする。

