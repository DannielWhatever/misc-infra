#!/usr/bin/env bash

vagrant up master
vagrant ssh master -c "cat /vagrant/tmp/join.sh" > join.sh
vagrant up node01