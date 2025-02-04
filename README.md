# bicrypto-trading-platform
bicrypto 4.6.3 + all addons


my eth address 0xFf04647D7FbC5897c6a439D811eBB8deAdeF4033 to support me i have paid for some addons.
full source code https://www.mediafire.com/file/j2l4h962hbofo95/bicrypto+6.4.3+all+addons.zip/file

for better experience first install nodejs and  pnpm using root login to your vps script requires vps choose a vps with virtualmin install it is better

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

1 IMPORTANT: go to datbase ...table extensions…..coloumn status…. write 1 instead of 0

2 go to folder public_html run pnpm updator wait until build is finished 
error may happen to pnpm if your folder node_module have not permission of the user of the cmd
in installer from bicrypto they mention the permission of folders check the doculentation 
you always use pnpm updator if you changed something in .env or in files because it is anext.js app

3 use phpMyAdmin it is easy go to app install on virtualmin and then install app choose phpmyadmin install . new folder named phpMyAdmin is created
navigate to https://yourdomainname/phpmyadmin login with database 

if you successfully installed and made some money do not forget to buy some addons to support the real dev  
full source code  https://www.mediafire.com/file/j2l4h962hbofo95/bicrypto+6.4.3+all+addons.zip/file

Bicrypto - Crypto Trading Platform, Exchanges, Kyc, Charting Library, Wallets, Binary Trading

========================================OKX + KRAKEN + BAINANCE US=================================


after login with phpMyAdmin select your database

click on sql

run this sql code without // to create missing coloumns:


//

INSERT INTO exchange (id, name, title, status, username, licenseStatus, version, productId, type) VALUES

(4, 'binanceus', 'Binance US', '0', NULL, '0', '1.0.0', '2816DB47', 'spot'),

(5, 'okx', 'OKX', '0', NULL, '0', '1.0.0', '34BDAB64', 'spot'),

(6, 'kraken', 'Kraken', '0', NULL, '0', '1.0.0', 'AB56F8DE', 'spot');


//




YOU will see exchanges Added now go to your .env file and add your vars:


# okx API (alias: okx)

APP_OKX_API_KEY=""

APP_OKX_API_SECRET=""

APP_OKX_API_PASSPHRASE="XXXXX"



# kraken API (alias: kraken)

APP_KRAKEN_API_KEY=""

APP_KRAKEN_API_SECRET=""


# Binance API (alias: binanceus)

APP_BINANCEUS_API_KEY=""

APP_BINANCEUS_API_SECRET=""


NB: don't forget this .env

# Exchange first 3 letters of the alias (kucoin, binance, kraken, okx, xt)
NEXT_PUBLIC_EXCHANGE="ku" you make the changes based on exchange you want



from dashboard you can only use one exchange as the dev documentation stated they did not devlopped arbitrage yet


go to terminal bellow file manager and click terminal cd public_html/ then run:

pnpm updator

NB: for binance us i am not sure if the script still supporting it i Don't have binance

my eth address 0xFf04647D7FbC5897c6a439D811eBB8deAdeF4033
