# 24iDemo ROKU application

Author: Honza Lacina <info@laki.cz>


## Initialization

`npm install` to install gulp and other dependencies

Requires: Node v12+ / NPM 6+ 
      
      
## Development

`gulp help`

demo application is located in `./apps/app/` directory


## Configuration

edit `./apps/app/config` for demo application behavior
edit `./rokudeploy.json` for configure automatic deploy applications to ROKU device
edit `./apps/app/locale/*.*` for increase localization of demo application (default is en_US, for demo of localization change device to de_DE)      


## Informations

see `./apps/app/manifest` and `./apps/app/source/main.brs` comments 


## Examples

use `gulp _app --appname=app` for build and deploy demo app to ROKU device wih debug informations on Brightscript console (port 8085)

use `gulp app --appname=app --production=true` for create final ROKU demo app package (into `./dist/app.zip`)

use `gulp deploy --appname=app` for deploy last builded "app" (`./dist/app.zip`) to ROKU device
