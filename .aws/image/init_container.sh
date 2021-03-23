#!/bin/bash

######### Artisan commands ##########
#####################################
php artisan clear-compiled
php artisan optimize
php artisan migrate
#####################################

/usr/bin/supervisord
