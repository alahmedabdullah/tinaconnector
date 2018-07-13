TINA Smart Connector for Chiminey
==================================
TINA allows formal model checking of a system modeled as timed petri net. 

Verifying a complex tina model may become compute-intensive - thus make it a suitable candidate for parallel execution utilising compute resources over the cloud using Chiminey. "TINA Smart Connector for Chiminey" allows parameter sweep i.e. internal sweep and external sweep over tina perti net models which facilitates scheduling computes over the cloud for parallel execution.

Once "TINA Smart Connector" is activated in Chiminey, Chiminey portal then allows to configure and submit a TINA job for execution.

TINA Smart Connector(SC) Core Function
-----------------------------------
A payload (http://chiminey.readthedocs.io/en/latest/payload.html#payload) provides the core functionality of TINA SC. The payload structure of TINA SC is as following:

```
payload_tina/
|--- bootstrap.sh
|--- process_payload
|    |---main.sh
|    |---run.sh
```

The TINA SC needs to install TINA binary. During activation of TINA SC, the user is required to download appropriate version of tina and place in the 'package'(https://github.com/alahmedabdullah/tinaconnector/blob/master/SETUP.md) directory.

"bootstrap.sh" installs all dependencies required to prepeare job execution environment for TINA. Please note that TINA is installed in "/opt" directory. Following is the content of "bootstrap.sh" for TINA SC:    

```
#!/bin/sh
# version 2.0

yum -y install glibc.i686 unzip

WORK_DIR=`pwd`

TINA_PACKAGE_NAME=$(sed 's/TINA_PACKAGE_NAME=//' $WORK_DIR/package_metadata.txt)
mv $WORK_DIR/$TINA_PACKAGE_NAME /opt
cd /opt
tar xzvf $TINA_PACKAGE_NAME

cd $WORK_DIR
```

The "main.sh" is a simple script that executes a shell script "run.sh" which must be already available in INPUT_DIR. It also passes on commmand line arguments i.e. INPUT_DIR and OUTPUT_DIR to "run.sh". The INPUT_DIR is passed in to "main.sh", where TINA model files are loaded. Following is the content of "main.sh" for TINA SC:

```
#!/bin/sh

INPUT_DIR=$1
OUTPUT_DIR=$2

cp run.sh $INPUT_DIR/run.sh

RUN_DIR=`cd "$(dirname "$0")" && pwd`

echo $RUN_DIR > mainsh.output

sh $RUN_DIR/run.sh $@

# --- EOF ---
```
The "main.sh" executes "run.sh". Following is the content of "run.sh" that executes a given TINA job :

```
#!/bin/sh

INPUT_DIR=$1
OUTPUT_DIR=$2

find $INPUT_DIR -name '*.zip' -exec sh -c 'unzip -d `dirname {}` {}' ';'

tina_exe=$(find /opt -name 'tina' 2>&1)

cd $INPUT_DIR

$tina_exe $(cat cli_parameters.txt) &> ../$OUTPUT_DIR/outfile ../$OUTPUT_DIR/digestfile ../$OUTPUT_DIR/errorfile


cp ./*.txt ../$OUTPUT_DIR
# --- EOF ---
```

The "run.sh" takes in the payload parameter sweep values passed into a tina job through "cli_parameter.txt_template" file. The template filename with "_template" suffix need to be placed in the "Input Location" which is specified in "Create Job" tab of the Chiminey-Portal. Following is the content of "cli_parameter.txt_template" that contains the template tag :

```
{{cli_parameters}}
```

All the template tags specified in the cli_parameters.txt_template file will be internally replaced by Chiminey with corresponding values that are passed in from "Chiminey Portal" as Json dictionary. During job execution the template files such as "cli_parameter.txt_template" is mapped with appropiate "Payload parameter sweep" values. Files excluding the _template suffix i.e. "cli_parameter.txt" are created with all template tags replaced with appropiate sweep values specific to an individual TINA jor run. 

Following command executes a TINA job:
```
/opt/tina64-4.1.19/bin-Linux/verifyta -R -TPN -v -tc train.tpn 
```  

Therefore to execute this job from Chiminey, the "Payload parameter sweep", which is a JSON dictionary to be passed in from Chiminey-Portal's "Create Job" tab:

```
{ "cli_parameters" :  [ "train.tpn -R -TPN -v -tc" ] }
```
Note that the "cli_parameters" is the tag name defined in the "cli_parameters.txt_template" template. This file need to be placed in the INPUT_DIR.

The Input Directory
-------------------
A connector in Chiminey system specifes a "Input Location" through "Create Job" tab of the Chimney-Portal. Files located in the "Input Location" directory is loaded to each VM for cloud execution. The content of "Input Location" may vary for different runs. Chiminey allows parameteisation of the input envrionment. Any file with "_template" suffix located in the input directory is regarded as template file. Chiminey internally replaces values of the template tags based on the sweep maps provied as Json Dictionary from "Create Job" tab.

Configure, Create and Execute a TINA Job
------------------------------------------
"Create Job" tab in "Chiminey Portal" lists "tina" form for creation and submission of tina job. "tina" form require definition of "Compute Resource Name" and "Storage Location". Appropiate "Compute Resource" and "Storage Resource" need to be defined through "Settings" tab in the "Chiminey portal".

Parameter Sweep
---------------
To perform parameter sweep on "TINA Smart Connector" jobs in Chiminey System, splecify appropiate JSON dictionary in "Payload parameter sweep" field  of the "tina" form accessible through Chiminey-Portal. An example JSON dictionary to perform sweep for the "train.tpn" could be as following:

```
{ "cli_parameters" :  [ "3trains.tpn -R -TPN -v -tc", "3trains.tpn -R -TPN -v -tc", "3trains.tpn -R -TPN -v -tc" ] }
``` 

Above sweep map would create three individual process and one cloud VM will be allocated for each process.

```

In the "Cloud Compute Resouce" section, if we set following values 
Number of VM instances : 3
Minimum No. VMs : 3

With above sweep map and Clould resource configurtion, three seperate VMs will be created in the Cloud where each VM will execute one tina job parallely.

Furthermore, if we set the "Cloud Compute Resouce" configuration as following:
```
Number of VM instances : 2
Minimum No. VMs : 1
```
For above setting, a maximum of two VMs will be created where one VM will execute two tina jobs and the other VM will execute one tina job. However, if VM quota availability is no more than one VM, only one VM will be created in the Cloud and all three tina jobs will be executed in the same VM sequetially.
