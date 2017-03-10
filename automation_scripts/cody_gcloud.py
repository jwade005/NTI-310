#TODO: Create django script function



#TODO: Add a way to dynamically insert firewall rules, A way to do automate IP addressing, and a way to catch errors, and a way to list the instances, and in general just making the code prettier and better.

from oauth2client.client import GoogleCredentials
credentials = GoogleCredentials.get_application_default()

from googleapiclient import discovery
compute = discovery.build('compute', 'v1', credentials=credentials)

import os, subprocess, re

# def list_instances(compute, project, zone):
#     result = compute.instances().list(project=project, zone=zone).execute()
#     return result['items']
def create_external_ip():
    name_of_external_ip = raw_input("What would you like to call the static External IP Address?: ")
    output = subprocess.check_output('gcloud compute addresses create ' + name_of_external_ip, shell=True)
    regex = re.compile(r"\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b") # a regular expression that returns the external IP address
    external_ip_address = regex.findall(output)[0]
    return external_ip_address

def create_internal_ip():
    return raw_input("Please enter the IP Address on the subnet 10.128.0.0/20 which you'd like to use for this instance: " or '')

def create_project(project_name):
    '''
    Creates a project using the Alpha GCloud command
    '''
    os.system('gcloud alpha projects create ' + project_name)

def create_firewall_rule(name, protocol_and_or_port):
    '''
    Uses the gcloud BASH API to create a firewall rule and returns the name of said firewall rule
    port can be a range and must use the following notation -> tcp:80,icmp
    where if the port is TCP or UDP it must have a port number or range of port numbers, and protocols are separated by commas
    '''
    os.system('gcloud compute firewall-rules create ' + name + ' --allow ' + protocol_and_or_port)
    print('firewall rule ' + name + ' created!')

def choose_configuration():
    '''
    Allows the user to specify a configuration
    '''

    configuration = raw_input("Please enter the configuration you'd like to build (Django, NFS, etc.): ")
    startup_script = ''

    if configuration == 'Django':
        INTERNAL_IP_ADDRESS = create_internal_ip()
        EXTERNAL_IP_ADDRESS = create_external_ip()
        startup_script = """#!/usr/bin/python

import os, time

def create_dir(directory):
    '''
    Creates a directory if one doesn't exist
    '''
    if not os.path.exists(directory):
        os.makedirs(directory)

def django():
    print("installing virtualenv so we can give django its own version of python")
    #os.system('sudo rpm -iUvh https://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-r\
#elease-7-8.noarch.rpm')
    os.system('sudo yum install -y epel-release')
    time.sleep(5)
    os.system('sudo yum install -y python-pip')
    time.sleep(5)
    os.system('sudo pip install virtualenv')
    time.sleep(5)
    directory = '/opt/django'
    create_dir(directory)
    os.system('sudo chown -R $USER ' + directory) # set the owner of the directory to the user recursively down the directory tree
    print('activating virtualenv')
    os.system('sudo virtualenv ' + directory + '/django-env')
    os.system('sudo source ' + directory + '/django-env/bin/activate')
    print('to switch out of virtualenv, type deactivate')
    print('now using:')
    os.system('which python')
    print('installing django')
    os.system('sudo pip install Django')
    time.sleep(5)
    print('django admin is version:')
    os.system('django-admin --version')
    os.system('django-admin startproject project1')
    os.system('sudo mv ' + os.getcwd() + '/project1 ' + directory) #moves the django project1 to the appropriate folder
    os.system('sudo mv ' + os.getcwd() + '/django-env ' + directory)
    os.system('sudo yum -y install tree')
    print('heres our new django project dir')
    os.system('tree ' + directory + '/project1')
    time.sleep(1)

    #ipaddr = subprocess.check_output("curl http://checkip.amazonaws.com", shell=True)
    ipaddr = """ + EXTERNAL_IP_ADDRESS + """
    f = open('/opt/django/project1/project1/settings.py','r')
    filedata = f.read()
    f.close()


    newdata = filedata.replace('ALLOWED_HOSTS = []', 'ALLOWED_HOSTS = [\'' + ipaddr + '\']')

    f = open('/opt/django/project1/project1/settings.py','w')
    f.write(newdata)
    f.close()

    print('Please be aware that you can only successfully access the django server by going to the IP address of your server in the browser, due to the ALLOWED_HOSTS stringin the project1.settings configuration\n Your IP Address to connect to Django web server is: ' + ipaddr + ':8000')
    os.system('python ' + directory + '/project1/manage.py migrate') # make Django happy by running migrations
    time.sleep(5)
    #make it persistent (if you want)
    os.system('sudo yum -y install screen')
    os.system('screen')
    time.sleep(5)
    os.system('python ' + directory + '/project1/manage.py runserver 0.0.0.0:8000') # start Django server
django()
"""
    elif configuration == 'NFS':
        #TODO: finish NFS automation
        INTERNAL_IP_ADDRESS = create_internal_ip()
        EXTERNAL_IP_ADDRESS = create_external_ip()
        startup_script = """#!/usr/bin/python
# automation of NFS install in Python, because why not?
# Ensure that the proper ports are open for NFS

# Check which setting umask needs to be returned to for security.

import os, time

def create_dir(directory):
    '''
    Creates a directory if one doesn't exist (handles exceptions by passing on them)
    '''
    try:
        os.makedirs(directory)
    except OSError:
        pass

def main():
    os.system('sudo umask a+rw')
    create_dir('/root/NFS/testing')
    create_dir('/root/NFS/development')
    create_dir('/root/NFS/configuration')
    nfsdirectory = '/root/NFS'

    #sleep so that yum can properly install nfs-utils
    time.sleep(10)
    os.system('sudo yum install -y nfs-utils')

    #TODO: create NFS file structure
    os.system('sudo chmod -R 777 /NFS/sharedfiles')
    os.system('sudo systemctl enable nfs-server')
    os.system('sudo systemctl enable nfs-idmap')
    os.system('sudo systemctl enable nfs-lock')
    os.system('sudo systemctl enable rpcbind')
    os.system('sudo systemctl start rpcbind')
    os.system('sudo systemctl start nfs-server')
    os.system('sudo systemctl start nfs-idmap')
    os.system('sudo systemctl start nfs-lock')

    create_dir('/root/NFS/sharedfiles/test')

    file = open('/etc/exports','a+')
    file.write('/NFS/sharedfiles/test  """ + INTERNAL_IP_ADDRESS + """(rw,sync,no_root_squash)') # Add the internal IP address here
    file.close()

    os.system('sudo exportfs -r')

    os.system('sudo firewall-cmd --permanent --zone public --add-service nfs')
    os.system('sudo firewall-cmd --permanent --zone public --add-service rpc-bind')
    os.system('sudo firewall-cmd --permanent --zone public --add-service mountd')
    os.system('sudo firewall-cmd --reload')
main()
"""
    elif configuration == 'LDAP':
        print('ldap not configured!')
    else:
        print('no config selected!')
    create_instance(compute, INTERNAL_IP_ADDRESS, EXTERNAL_IP_ADDRESS, startup_script)



#TODO: add firewalls as a parameter
def create_instance(compute,INTERNAL_IP_ADDRESS, EXTERNAL_IP_ADDRESS, startup_script):

    # Ask the user for parameters about their instance
    name = raw_input("Please enter your server name: ")
    project = raw_input("Please enter your project name['ldap-nfs-python-2-15-17'] : ") or "ldap-nfs-python-2-15-17"
    zone = raw_input("Please enter your zone ['us-central1-c'] : ") or "us-central1-c"

    # Get the image
    image_response = compute.images().getFromFamily(
        project=raw_input("Please enter the image project ['centos-cloud']") or 'centos-cloud',
        family=raw_input("Please enter the image family ['centos-7']") or 'centos-7').execute()
    source_disk_image = image_response['selfLink']

    # Configure the machine


#TODO: add automatic internal IP address incrementing
    # if 'increment' in locals():
    #     increment += 1
    # else:
    #     increment = 2
    #
    # IP_ADDRESS = '10.128.0.' + str(increment)
    machine_type = "zones/%s/machineTypes/f1-micro" % zone
    #Still deciding if I'm going to open them as files, or pass them in as strings from solely this script
    # startup_script = open(
    #     os.path.join(
    #         os.path.dirname(__file__), raw_input("What's the name of your startup script ['django-test.py'] : ") or 'django-test.py'), 'r').read()
    config = {
        'name': name,
        'machineType': machine_type,

        # Specify the boot disk and the image to use as a source.
        'disks': [
            {
                'boot': True,
                'autoDelete': True,
                'initializeParams': {
                    'sourceImage': source_disk_image,
                }
            }
        ],

        # Specify a network interface with NAT to access the public
        # internet.
        'networkInterfaces': [{
            'network': 'global/networks/default',
            'accessConfigs': [
                {'type': 'ONE_TO_ONE_NAT',
                 'name': 'External NAT',
                 'natIP': [EXTERNAL_IP_ADDRESS]}
            ],
            "network": "global/networks/default",
            "networkIP": [INTERNAL_IP_ADDRESS]
        }],

        "tags": {
          "items": [
            "http-server",
            "https-server"
        ]},



        # Allow the instance to access cloud storage and logging.
        'serviceAccounts': [{
            'email': 'default',
            'scopes': [
                'https://www.googleapis.com/auth/devstorage.read_write',
                'https://www.googleapis.com/auth/logging.write'
            ]
        }],

        # Metadata is readable from the instance and allows you to
        # pass configuration from deployment scripts to instances.
        'metadata': {
            'items': [{
                # Startup script is automatically executed by the
                # instance upon startup.
                'key': 'startup-script',
                'value': startup_script
            }]
        }
    }

    return compute.instances().insert(
        project=project,
        zone=zone,
        body=config).execute()



def main():
    choose_configuration()
    while(True):
        print("would you like to create an instance? (by default, http & https allowed.)")
        answer = raw_input("Please answer Yes or No: ")
        if answer in ['y', 'Y', 'yes', 'Yes', 'YES']:
            choose_configuration()
            if answer not in ['y', 'Y', 'yes', 'Yes', 'YES']:
                break;
        else:
            break;

main()
#EXTERNAL_IP_ADDRESS = create_external_ip('helloworld') #sets the static external IP address
#create_instance(compute, '104.198.62.209')
            # print("These are the currently running servers: ")
            # list_instances(compute, project, zone)
        # print("would you like to delete an instance?")
        # if answer in ['y', 'Y', 'yes', 'Yes', 'YES']:
        #     print("no functionality yet")
