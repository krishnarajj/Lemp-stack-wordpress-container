# Lemp-stack-wordpress-container
 This Bash script automates the setup of a WordPress site using Docker containers with a LEMP stack . It simplifies the process of installing Docker 
  Compose, creating necessary files and directories, and configuring the Docker environment.
# Installation
Clone the repository or download the script file wordpress-setup.sh to your local machine.

Open a terminal and navigate to the directory containing the script.

Ensure that the script has executable permissions

            chmod +x wordpress-setup.sh
# Usage
Please make sure you have sudo permission.Run the script with sudo permission or admin
Run the script with the following command:
     
     ./wordpress-setup.sh <site_name> [subcommand]

Replace <site_name> with the desired name for your WordPress site. It will be used to configure the site URL.

    Optional [subcommand] can be one of the following:
    
    enable: Starts the containers and enables the site.
    disable: Stops the containers and disables the site.
    delete: Removes the containers and associated local files, deleting the site

