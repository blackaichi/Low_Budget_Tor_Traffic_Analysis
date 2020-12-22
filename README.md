# Low_Budget_Tor_Traffic_Analysis

**WARNING: Me or anyone else related to this project will not be responsible for misuse of this repository**

The goal of this project is to analyze tor traffic with only a few dollars to educational purposes. We recommend (as we have done) to delete all collected data once the analysis is complete to prevent the data to end up in the wrong hands. 

This project work 100% for Ubuntu 18.04 LTS, for other server versions you must change the server_files/tor_deploy.sh file. You can download the tor_deploy file here: https://tor-relay.co/

## Prerequisites
- VPS (Anonymous if it is possible and recommended to pay with cryptocurrencies)
- A few dollars
- Some knowledge in linux shell (bash)

## Deployment Steps

Recomended tree for this project (I will asume all commands from root/tma/)

root  
 ├── go             (installation of golang)  
 ├── go1.15.5.linux-amd64.tar.gz  (tar to install golang, working with 1.15.5, unknown with other versions)    
 └── tma    
    ├── httpdump       (httpdump tool)  
    ├── logs        (where we will save logs)  
    ├── scripts       (where we will place scripts)  
    └── tor_deploy.sh    (tor script to deploy the relay)  
    
0. Install Golang: https://golang.org/doc/install
    
1. Download the whole repository and the other necessary ones:   
``` console
$ git clone https://github.com/blackaichi/Low_Budget_Tor_Traffic_Analysis   
$ git clone https://github.com/rogercoll/httpdump
$ git clone https://github.com/rogercoll/shallalist
$ git clone https://github.com/rogercoll/urlCategorization
```

2. Copy the server files to your VPS and copy the files inside scripts_maintenance inside root/tma/scripts and tor_deploy in root/tma

3. Execute tor_deploy.sh:  
```console
$ bash tor_deploy.sh
```

4. Execute the check memory script:  
```console 
$ bash scripts/checkMem.sh
```

5. Execute httpdump to grab logs:
```console
$ nohup bash httpdump/httpdump -level tma -output httpdump/aux.txt &
```
After all this steps we will grab all the http requests and responses that we will do.

## Host Scripts

The host scripts are 2:
- downloadLogs.sh: Download the logs from the server and then delete the logs.
- order_Parser.sh: Parse the data to make it easy to introduce it into the database.

## Data_Analyzer

- categorize_country_domains.cc: Thats a program to automate the categorization of the top domain levels inside a csv.

## Usefull code on other Githubs

- https://github.com/rogercoll/httpdump
- https://github.com/rogercoll/shallalist
- https://github.com/rogercoll/urlCategorization
