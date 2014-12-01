# About this Repo

This is the Git repo of the Docker image for [ImpressPages](https://www.impresspages.org) version 4.4.0 .
This Docker file based on original wordpress docerfile from this repo [github](https://github.com/docker-library/wordpress)

Usage
-----

To create the image `lexaficus/impresspages`, execute the following command on docker-impresspages directory:
  
    docker build -t lexaficus/impresspages .

You can now push your new image to the registry:
  
    docker push lexaficus/impresspages

Running your ImpressPages docker image
--------------------------------------

Start your MySQL image or use your own:
  
    docker run --name mysql -e MYSQL_ROOT_PASSWORD=mysecretpassword -d mysql

Start your image:

    docker run -d -p 80:80 --link mysql:mysql lexaficus/impresspages

Test your deployment:

    curl http://localhost/

Your can now start configuring your ImpressPages container!

More information
----------------

You can change default database parameters by environment variables:
* `-e IMPRESSPAGES_DB_USER=...` (defaults to “root”)
* `-e IMPRESSPAGES_DB_PASSWORD=...` (defaults to the value of the MYSQL_ROOT_PASSWORD environment variable from the linked mysql container)
* `-e IMPRESSPAGES_DB_NAME=...` (defaults to “impresspages”)
  