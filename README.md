TINA Smart Connector for Chiminey
==================================
TINA allows formal model checking of a system modeled as timed petrinet. 

Verifying a complex tina model may become compute-intensive - thus make it a suitable candidate for parallel execution utilising compute resources over the cloud using Chiminey. "Tina Smart Connector for Chiminey" allows parameter sweep i.e. internal sweep and external sweep over tina perti net models which facilitates scheduling computes over the cloud for parallel execution.

Once "Tina Smart Connector" is activated in Chiminey, Chiminey portal then allows to configure and submit a TINA job for execution.

TINA Smart Connector Core Function
-----------------------------------
A payload (http://chiminey.readthedocs.io/en/latest/payload.html#payload) provides the core functionality of TINA SC. The payload structure of TINA SC is as following:

```
payload_tina/
|--- bootstrap.sh
|--- process_payload
|    |---main.sh
```
The TINA SC needs to install Uppaal binary and Java runtime environment. During activation of TINA SC, the user is required to download appropriate version of tina and place in the 'package' directory.

"bootstrap.sh" installs all dependencies required to prepeare the Uppaal jobs execution environment. The "bootstrap.sh" installs TINA  and latest version of JDK. Please note that both TINA and JAVA are installed in "/opt" directory. Following is the content of "bootstrap.sh" for TINA SC:    

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

The "main.sh" is a simple script that executes a shell script "run.sh" which must be already available in "INPUT_DIR". It also passes on commmand line arguments i.e. INPUT_DIR and OUTPUT_DIR to "run.sh". Recall that Chiminey sends the path to input (INPUT_DIR) and output (OUTPUT_DIR) directories via command-line arguments<payload>. Here, the SC developer passes on INPUT_DIR, where TINA model file is available. Following is the content of "main.sh" for TINA SC:

```
#!/bin/sh

INPUT_DIR=$1

sh $INPUT_DIR/run.sh $@

# --- EOF ---
```
The "main.sh" executes "run.sh" and passes on values of INPUT_DIR and OPUTPUT_DIR to it. The "run.sh" is template file that must be named as "run.sh_template" and be already made available in INPUT_DIR. "run.sh_template" will be explained further in the following paragraphs. Following is the content of "run.sh_template" that executes a given TINA job :

```
#!/bin/sh

INPUT_DIR=$1
OUTPUT_DIR=$2

find $INPUT_DIR -name '*.zip' -exec sh -c 'unzip -d `dirname {}` {}' ';'

tina_exe=$(find /opt -name 'tina' 2>&1)

$tina_exe {{param_string}} $INPUT_DIR/{{tina_model}} $OUTPUT_DIR/outfile $OUTPUT_DIR/digestfile $OUTPUT_DIR/errorfile
# --- EOF ---
```
So "run.sh_template" file must be located in INPUT_DIR. Since it is a template file, all template tags specified in this file will be replaced by Chiminey with corresponding values that are passed in from "Chiminey Portal" as Json dictionary. This "runs.sh_template" is renamed as "run.sh" when all template tags are replaced by corresponding values. 

"{{tina_model}}" is name of the tina model file loacated in the input directory, and "{{param_string}}" is the string with all various option that TINA allows for model-checking. The latest version of TINA includes query properties within the model file. For example let's assume we have tina model "train.tpn" (assuming the model file contains all querries to be verified against it). Therefore, following is the command to execute this model against TINA:

```
/opt/tina64-4.1.19/bin-Linux/verifyta -R -TPN -v -tc train.tpm 
```  
Thus JSON dictionary to be passed from "Chiminey Protal" for above command to execute this tina model would be:

```
{ "tina_model" :  [ "train.tpn" ], "param_string" :  [ "-R -TPN -v -tc" ] }
```

The Input Directory
-------------------
Each connector in Chiminey system may specify a payload directory that is loaded to each VM for cloud execution. This payload directory content may vary for different runs. It is done through indicating input directory for a specific run. This also allows parameteisation on the input envrionment.  Any file located in the input directory may be regarded as a template file by adding "_template" suffix. 

Configure, Create and Execute a Uppaal Job
------------------------------------------
"Create Job" tab in "Chiminey Portal" lists "tina_sweep" form for creation and submission of tina job. "sweep_tina" form require definition of "Compute Resource Name" and "Storage Location". Appropiate "Compute Resource" and "Storage Resource" need to be defined  through "Settings" tab in the "Chiminey portal".

External Sweep
--------------
To perform external sweep "TINA Smart Connector" in Chiminey System, splecify appropiate JSON dictionary in "Values to sweep over" field  of the "sweep_tina" form accessible through "Chiminey Portal". An example JSON dictionary to perform external sweep for the "train.tpn" could be as following:

```
{ "tina_model" :  [ "train.tpn" ], "param_string" :  [ "-R -TPN -v -tc", "-C -TPN -v -tc", "-V -TPN -v -tc"] }
``` 

Above would create three individual process. To allocate one cloud VM for each process, input fieldis in "Cloud Compute Resource" for "sweep_tina" form has to be:

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
