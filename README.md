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

sh $INPUT_DIR/run.sh $@

# --- EOF ---
```
The "main.sh" executes "run.sh" which internally generated file based on "run.sh_template". The template filename must have "_template" suffix and need to be placed in the "Input Location" which is specified in "Create Job" tab of the Chiminey-Portal. Following is the content of "run.sh_template" that executes a given TINA job :

```
#!/bin/sh

INPUT_DIR=$1
OUTPUT_DIR=$2

find $INPUT_DIR -name '*.zip' -exec sh -c 'unzip -d `dirname {}` {}' ';'

tina_exe=$(find /opt -name 'tina' 2>&1)

$tina_exe {{param_string}} $INPUT_DIR/{{tina_model}} $OUTPUT_DIR/outfile $OUTPUT_DIR/digestfile $OUTPUT_DIR/errorfile
# --- EOF ---
```
All the template tags specified in  the run.sh_template file will be internally replaced by Chiminey with corresponding values that are passed in from "Chiminey Portal" as Json dictionary. This "runs.sh_template" is  also renamed to "run.sh" with all template tags replaced with corresponding values. 

"{{tina_model}}" is name of the tina model file loacated in the input directory, and "{{param_string}}" is the string with all various option that TINA allows for model-checking. For example let us assume following shell command is used to execute a TINA model "train.tpn":

```
/opt/tina64-4.1.19/bin-Linux/verifyta -R -TPN -v -tc train.tpn 
```  
So the "Internal sweep map", which is a JSON dictionary to be passed in from Chiminey-Portal's "Create Job" tab:

```
{ "tina_model" :  [ "train.tpn" ], "param_string" :  [ "-R -TPN -v -tc" ] }

```
Note that the "tina_model" and "param_string" are the tag names defined in the run.sh_template.

The Input Directory
-------------------
A connector in Chiminey system specifes a "Input Location" through "Create Job" tab of the Chimney-Portal. Files located in the "Input Location" directory is loaded to each VM for cloud execution. The content of "Input Location" may vary for different runs. Chiminey allows parameteisation of the input envrionment. Any file with "_template" suffix located in the input directory is regarded as template file. Chiminey internally replaces values of the template tags based on the sweep maps provied as Json Dictionary from "Create Job" tab.

Configure, Create and Execute a TINA Job
------------------------------------------
"Create Job" tab in "Chiminey Portal" lists "sweep_tina" form for creation and submission of tina job. "sweep_tina" form require definition of "Compute Resource Name" and "Storage Location". Appropiate "Compute Resource" and "Storage Resource" need to be defined  through "Settings" tab in the "Chiminey portal".

External Sweep
--------------
To perform external sweep "TINA Smart Connector" in Chiminey System, splecify appropiate JSON dictionary in "Values to sweep over" field  of the "sweep_tina" form accessible through Chiminey-Portal. An example JSON dictionary to perform external sweep for the "train.tpn" could be as following:

```
{ "tina_model" :  [ "train.tpn" ], "param_string" :  [ "-R -TPN -v -tc", "-C -TPN -v -tc", "-V -TPN -v -tc"] }
``` 

Above sweep map would create three individual process and one cloud VM will be allocated for each process.

```
Number of VM instances : 1
Minimum No. VMs : 1
```
Internal Sweep
--------------
Inxternal sweep for "TINA Smart Connector" in Chiminey System may be performed by specifying appropiate JSON dictionary in "Internal sweep map" field  of the "sweep_tina" form. An example JSON dictionary to run internal sweep for the "train.tpn" could be as following:

```
{ "tina_model" :  [ "train.tpn" ], "param_string" :  [ "-R -TPN -v -tc", "-C -TPN -v -tc", "-V -TPN -v -tc"] }
``` 
Above would create three individual process. To allocate maximum two cloud VMs - thus execute two TINA job in the same VM,  input fields in "Cloud Compute Resource" for "sweep_tina" form has to be:

```
Number of VM instances : 2
Minimum No. VMs : 1
```
