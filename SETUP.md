TINA Connector
================

Setup
-----
1. Install Chiminey (https://github.com/chiminey/docker-chiminey)
2. Go to docker-chiminey directory
```
	$ cd docker-chiminey
```
3. Enter into the Chiminey container
```
	$ ./chimineyterm
```
4. Go to chiminey directory
```
	$ cd /opt/chiminey/current/chiminey
```
5. Modify the SMART_CONNECTORES dictionary in settings_change.py file to have following:
```
	'tina':  {'init': 'chiminey.tinaconnector.initialise.TinaInitial',
             	      'name': 'tina',
            	      'description': 'The TINA Model Checker',
             	      'payload': '/opt/chiminey/current/chiminey/tinaconnector/payload_tina',
             	      'sweep': True
                    },
```
However, to keep the TINA Connector invisible in Smart Connectors list
```
        'tina':  {'init': 'chiminey.tinaconnector.initialise.TinaInitial',
                      'name': 'tina',
                      'description': 'The TINA Model Checker',
                      'payload': '/opt/chiminey/current/chiminey/tinaconnector/payload_tina',
                      'sweep': True,
                      'hide_config': True
                    },
```
6. Modify the INPUT_FIELDS dictionary in settings_change.py file to have following:
```
	'tina':  SCHEMA_PREFIX + "/input/tina",
```
7. Clone the git repository https://github.com/alahmedabdullah/tinaconnector.git in /opt/chiminey/current/chiminey
```
	$ git clone https://github.com/alahmedabdullah/tinaconnector.git
```
8. Change ownership of the newly created uppalconnector directory
```
	$ chown -R chiminey.nginx tinaconnector
```
9. Exit from the chiminey container
```
	$ exit
```
10. Restart the chiminey container
```
	$ docker-compose restart chiminey
```
11. Check that tina connector is listed in available smart connectors list
```
	$ ./listscs
```
12. Activate the tina connector and follow the prompts
```
	$ ./activatesc tina
```
