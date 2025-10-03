# bicrypto-trading-platform
bicrypto V5.5.3 +Addons new update + Mobileapp ios & android latest version V5:
must read readme file . download   :

https://www.mediafire.com/file/8y23oudjulq3w0g/Bicrypto5.3.3.zip/file

reboot after adding your exchange api and secret
some user got error while pnpm install they failed to install modules because of virtualmin disk quota is by default 2GB  go to edit server on virtualmin then click quotas and limits then choose unlimited then restart vps it will work  

they are related to virtualmin disk quota default to 2GB 
you can generate tokens (smart contract) in ecosystem easy to start your own coin by going to yourwebsite//admin/ecosystem/token/create then choose deploy token or import if you already has your own

my eth address 0xFf04647D7FbC5897c6a439D811eBB8deAdeF4033 to support me i have paid for some addons. read the full readme:
FULL INSTALL DOC
https://docs.mash3div.com/#virtualmin-setup

to activate deposit got to https://yourwebsite.com/admin/system/settings?tab=wallet  and check deposit box

deposit & withdrawal errors :

activate trades /currencies /withdrawal on api binance/kucoin/xt  allow the api to work  on your vps ip (do not use USA ip for vps change it will not work unless you are resident of USA BINANCE KUCOIN XT will block connection)

+ ecosystem you have to run the extension 12 mnemonic everytime you restart bicrypto or reboot your vps:

in yourwebsite.com/admin/ext/ecosystem click on initiate Vault enter your mnemonic 

+ error fetching means you did not import currencies for spot . after you choose for example binance added your api you have to import and activate currencies : go to yourwebsite.com/admin/finance/exchange then click view button then currencies click import and choose btc to activate it. if you are using kucoin or kraken make sure to allow trades/currencies/withdrawal/deposit from your account by whitelisting your vps ip or you will get error fetching currencies because your api does not have full permission
 https://imgur.com/a/3pF9fiI


upload files follow the dev documentation 

https://support.mash3div.com/ 
common issues:
1 Always pay attention to folder ownership and with which user you are running your terminal command for example you craeted directory named crypton all files folders in public_html should have ownership of crypton 

2 do not forget to use cd public_html/ to run your command pnpm start or pnpm install  those are common bigginers mistakes 
who has not knowlege on linux not related to script

3 about firewall and port some vps came with security measures you should use port opening from command
for example use chatgpt to check if port are allowed vurtualmin ports: 10000 20000 database port 3306 ssh 22   
port of scylladb when running ecosystem port:
 9042 10001 check if port and open and restart use chatgpt if you are not familiar with linux commands 
 
when app finish builds 

# 1 IMPORTANT: 
go to datbase ...table extensions…..coloumn status…. write 1 instead of 0
 if extensions did not show just restart your database server or restart your apache server 
 
# to activate sol ton tron
go to public_html/backend/blockchains/ and create empty files sol.bin.ts ton.bin.ts tron.bin.ts
go to database table ecosystem_blockchain changed status from 0 to 1
https://imgur.com/a/dpQIUbq
https://imgur.com/5CkWTI7
if your extensions did not show add this file merge.mjs to folder scripts/merge.mjs
https://github.com/oktopastrade/bicrypto-trading-platform/blob/main/merge.mjs

2 go to folder public_html run pnpm updator wait until build is finished 
error may happen to pnpm if your folder node_module have not permission of the user of the cmd
in installer from bicrypto they mention the permission of folders check the doculentation 
you always use pnpm updator if you changed something in .env or in files because it is anext.js app

3 use phpMyAdmin it is easy go to app install on virtualmin and then install app choose phpmyadmin install . new folder named phpMyAdmin is created
navigate to https://yourdomainname/phpmyadmin login with database 

if you successfully installed and made some money do not forget to buy some addons to support the real dev  
full source code 

# OKX + KRAKEN + BAINANCE US ==


after login with phpMyAdmin select your database

click on sql

# run this sql code without // to create missing coloumns:


//

INSERT INTO exchange (id, name, title, status, username, licenseStatus, version, productId, type) VALUES

(4, 'binanceus', 'Binance US', '0', NULL, '0', '1.0.0', '2816DB47', 'spot'),

(5, 'okx', 'OKX', '0', NULL, '0', '1.0.0', '34BDAB64', 'spot'),

(6, 'kraken', 'Kraken', '0', NULL, '0', '1.0.0', 'AB56F8DE', 'spot');


//





#- Exchange first 3 letters of the alias (kucoin, binance, kraken, okx, xt)
NEXT_PUBLIC_EXCHANGE="ku" you make the changes based on exchange you want
from dashboard you can only use one exchange as the dev documentation stated they did not devlopped arbitrage yet


go to terminal bellow file manager and click terminal cd public_html/ then run:

pnpm updator

NB: for binance us i am not sure if the script still supporting it i Don't have binance

my eth address 0xFf04647D7FbC5897c6a439D811eBB8deAdeF4033



for the xmr i can not find it on dev documentation but you can figure the vars from the file /backend/blockchains/xmr.ts search for process.env and add them and i think it depends on redis i dont know if you have to host your own node using it just give it a try .
for people who already has bicrypto and just uploaded but can not see them even after changing 0 to 1 because you are missing a file you will find it on  /scripts/merge.mjs as it is important in builds it merge the extensions on build pages just copy it from the zip file to your script folder and extensions will show
