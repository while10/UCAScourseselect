# UCAScourseselect [![Build Status](https://travis-ci.org/PENGZhaoqing/CourseSelect.svg?branch=master)](https://travis-ci.org/PENGZhaoqing/CourseSelect)


此项目主要实现选课系统功能的增加。最终项目在heroku云上部署成功，可点击[选课系统](https://ucaswhile10.herokuapp.com)进行访问。

### 以前功能：

* 多角色登陆（学生，老师，管理员）
* 学生动态选课，退课
* 老师动态增加，删除课程
* 老师对课程下的学生添加、修改成绩
* 权限控制：老师和学生只能看到自己相关课程信息

### 新增功能：


*  统计选课总学分与总课时     
*  学生已选课程列表分页      
*  学生查看选课列表分页
*  管理员审核课程 
*  管理员重置密码
*  选课冲突判断
*  选课人数限制
*  精确查找
*  模糊查找
*  首次登陆初始化密码
*  课程信息
*  界面美化


### 截图

<img src="/lib/home.png" width="700">  

<img src="/lib/admin.png" width="700">

<img src="/lib/select.png" width="700">   

<img src="/lib/select1.png" width="700">

<img src="/lib/teacher.png" width="700">

## 说明

目前使用的库和数据库：

* 使用[Bootstrap](http://getbootstrap.com/)作为前端库
* 使用[Rails_admin Gem](https://github.com/sferik/rails_admin)作为后台管理
* 使用[Postgresql](http://postgresapp.com/)作为数据库

使用前需要安装Bundler，Gem，Ruby，Rails等依赖环境。

请根据本地系统下载安装[postgresql](https://devcenter.heroku.com/articles/heroku-postgresql#local-setup)数据库，并运行`psql -h localhost`检查安装情况。


## 安装

在终端（MacOS或Linux）中执行以下代码

```
$ git clone https://github.com/PENGZhaoqing/CourseSelect
$ cd CourseSelect
$ bundle install
$ rake db:migrate
$ rake db:seed
$ rails s 
```

在浏览器中输入`https://ucaswhile10.herokuapp.com/`访问主页

##使用

1.学生登陆：

账号：`student6@test.com`

密码：`password`

2.老师登陆：

账号：`teacher3@test.com`

密码：`password`


3.管理员登陆：

账号：`admin@test.com`

密码：`password`

账号中数字都可以替换成1,2,3...等等


## Heroku云部署

项目直接在Heroku上免费部署

1.fork此项目到自己Github账号下

2.创建Heroku账号以及Heroku app

3.将Heroku app与自己Github下的fork的项目进行连接

4.下载配置[Heroku CLI](https://devcenter.heroku.com/articles/heroku-command-line)命令行工具

5.运行`heroku login`在终端登陆，检查与heroku app的远程连接情况`git config --list | grep heroku`，

6.运行部署

`heroku create hrcourseselect
git push heroku master
heroku run rake db:migrate
heroku run rake db:seed`


## 测试

本项目包含了部分的测试（integration/fixture/model test），测试文件位于/test目录下。运行测试：

```
PENG-MacBook-Pro:IMS_sample PENG-mac$ rake test
Run options: --seed 15794

# Running:
.........

Finished in 1.202169s, 7.4865 runs/s, 16.6366 assertions/s.

9 runs, 20 assertions, 0 failures, 0 errors, 0 skips
```


## Fork

先fork此项目，在分支修改后，pull request到主分支

fork后，同步我的代码：

添加源

```
git remote add upstream https://github.com/while10/UCAScourseselect

git remote -v

git remote -v 后，应该出现我的地址。

```

然后

```
git fetch upstream

git merge upstream/master

```

每次同步代码后，可以执行如下重新构建一下数据库（若rake db:migrate 不行的话，那就加上reset）
```

rake db:migrate:reset

rake db:seed

```
由于可能加了新的包，所以最好还要
```
bundle install
```
更新自己的github仓库（git push)

最后通过pull request即可。

## Future work

*  添加邮箱通知功能
*  添加聊天功能
*  管理员发布公告功能





