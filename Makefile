#Useful sources:
# C++
# https://hiltmon.com/blog/2013/07/03/a-simple-c-plus-plus-project-structure/
# https://stackoverflow.com/questions/448910/what-is-the-difference-between-the-gnu-makefile-variable-assignments-a
# http://www.cs.colby.edu/maxwell/courses/tutorials/maketutor/
#
# Python
# https://blog.horejsek.com/makefile-with-python/
# https://krzysztofzuraw.com/blog/2016/makefiles-in-python-projects.html

#C++ setup
CXX = g++
PYTHON = python3
#CXXLIBDIR = .
#CXXFLAGS = -I$(LIBDIR) #C++ compiler flags

#Python setup
VENV_NAME?=venv
VENV_ACTIVATE=. $(VENV_NAME)/bin/activate
PYTHON=${VENV_NAME}/bin/python3

#CXXFLAGS = --coverage
GCOVFLAGS = -fprofile-arcs -ftest-coverage -fPIC -O0

SENSOR_REPORT_DIR := sensor/reports
SENSOR_TEST_DIR := sensor/test
SENSOR_GCOV_DIR := $(SENSOR_REPORT_DIR)/gcov
SENSOR_GCOV_COV_DIR := $(SENSOR_GCOV_DIR)/cov
SENSOR_GCOV_FILES := $(patsubst $(SENSOR_SRC_DIR)/%.cpp,$(SENSOR_GCOV_DIR)/%.gcov,$(SENSOR_SRC_FILES))
SENSOR_CPPCHECK_DIR := $(SENSOR_REPORT_DIR)/cppcheck
SENSOR_CPPCHECK_XML := $(SENSOR_CPPCHECK_DIR)/cppcheck_output.xml
SENSOR_CPPCHECK_HTML := $(SENSOR_CPPCHECK_DIR)/index.html
SENSOR_CLANG_ANALYZER_DIR := $(SENSOR_REPORT_DIR)/clang_analyzer
SENSOR_CLANG_ANALYZER_HTML := $(SENSOR_CLANG_ANALYZER_DIR)/index.html
SENSOR_BIN_DIR := sensor/bin
SENSOR_SRC_DIR := sensor/src
SENSOR_OBJ_DIR := sensor/obj
SENSOR_SRC_FILES := $(wildcard $(SENSOR_SRC_DIR)/*.cpp )
SENSOR_OBJ_FILES := $(patsubst $(SENSOR_SRC_DIR)/%.cpp,$(SENSOR_OBJ_DIR)/%.o,$(SENSOR_SRC_FILES))
SENSOR_BIN_FILES := $(patsubst $(SENSOR_OBJ_DIR)/%.o,$(SENSOR_BIN_DIR)/%,$(SENSOR_OBJ_FILES))

HUB_SRC_DIR := hub/src
HUB_TEST_DIR := hub/src/test
HUB_REPORT_DIR := hub/reports
HUB_PYTEST_DIR := $(HUB_REPORT_DIR)/pytest
HUB_DJANGO_DIR := hub/src/django

#Specifies that those commands don't create files
.PHONY: clean clean_hub clean_sensor all sensor hub help flash_sensor sensor_cppcheck sensor_cppcheck_no_report sensor_clang_analyzer check_sensor eslint prospector pip pip-prospector python npm cpplint pip-cpplint gcov init prettier pip-gcovr

.DEAFULT: help
help:
	@echo "TODO list targets and what they do here"
	@echo "make prepare-dev"
	@echo "	       prepare development environment, use only once"
	@echo "make test"
	@echo "       run tests"
	@echo "make lint"
	@echo "	      run pylint and mypy"
	@echo "make run"
	@echo "	      run project"
	@echo "make doc"
	@echo "	      build sphinx documentation"
	
#Various commands to set up repo and dev environment
init: prettier
	git config core.hooksPath .githooks

prettier: npm
	npm install --save-dev --save-exact prettier

all: hub sensor

$(SENSOR_OBJ_DIR)/%.o: $(SENSOR_SRC_DIR)/%.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

$(SENSOR_BIN_DIR)/%: $(SENSOR_OBJ_DIR)/%.o
	$(CXX) $(CXXFLAGS) -o $@ $^

flash_sensor:
	@echo "TODO Depends on having hardware."

sensor: $(SENSOR_BIN_FILES)

check_sensor: sensor_clang_analyzer sensor_cppcheck gcov

$(SENSOR_CPPCHECK_XML):
	mkdir -p $(SENSOR_CPPCHECK_DIR)
	cppcheck $(SENSOR_SRC_DIR) --xml 2> $(SENSOR_CPPCHECK_XML)

$(SENSOR_CPPCHECK_HTML): $(SENSOR_CPPCHECK_XML)
	cppcheck-htmlreport --file=$< --report-dir=$(SENSOR_CPPCHECK_DIR)

sensor_cppcheck: $(SENSOR_CPPCHECK_HTML)
	@echo "cppcheck and cppcheck-htmlreport must be installed on your system and in your \$$PATH"

sensor_cppcheck_no_report:
	@echo "cppcheck must be installed on your system and in your \$$PATH"
	cppcheck $(SENSOR_SRC_DIR)

$(SENSOR_CLANG_ANALYZER_HTML):
	mkdir -p $(SENSOR_CLANG_ANALYZER_DIR)
	scan-build -k -o $(SENSOR_CLANG_ANALYZER_DIR) make sensor

sensor_clang_analyzer: $(SENSOR_CLANG_ANALYZER_HTML)
	@echo "clang analyzer must be installed with scan-build in your \$$PATH"
	@echo "Apparently \"Windows users must have Perl installed\""
	@echo "check http://clang-analyzer.llvm.org/scan-build.html if you're having issues"

pip-cpplint: pip
	pip3 install cpplint

cpplint: pip-cpplint
	#may need to change output format
	cpplint --recursive $(SENSOR_SRC_DIR)

pip-gcovr: pip
	pip3 install gcovr

gcov: pip-gcovr
	#https://courses.cs.washington.edu/courses/cse333/11sp/lectures/lec10_exercises/Makefile.html
	#http://gcovr.com/en/stable/guide.html
	#basically need to recompile everything with gcov flags, including the testcoverage file, then run gcovr to generate the html report
	#change the working directory to the test directory
	cd $(SENSOR_TEST_DIR)
	#recompile everything for testing purposes. Assumes all tests included in testing.c
	$(CXX) $(CXXFLAGS) $(GCOVFLAGS) -o testing -I$(SENSOR_SRC_DIR) testing.c
	#Run the tests
	./testing
	#generate the html report
	gcovr -r . --html -o $(SENSOR_REPORT_DIR)/gcov/index.html



hub:
	@echo "TODO set up hub directory structure, and what commands need to be run to build it and start it"
	@echo "See the horejsek source in the Makefile for tips on using python in a Makefile"

clean: clean_sensor clean_hub

clean_sensor:
	#TODO clean out the unnecessary stuff in the test directory
	rm -rf $(SENSOR_OBJ_DIR)/*
	rm -rf $(SENSOR_BIN_DIR)/*
	rm -rf $(SENSOR_REPORT_DIR)

clean_hub:
	@echo "TODO, depends what files the hub code generates"

npm:
	@echo "We should change this to say make sure npm is installed, since it'll be different on mac, windows, and different linux distros"
	apt install nodejs npm node-semver

#May need to change these depending on how raspberry pi deals with python 2 vs 3. I'm assuming we'll be using 3
python:
	@echo "We should change this to say make sure python and pip are installed, since it'll be different on mac, windows, and different linux distros"
	apt install $(PYTHON) $(PYTHON)-pip virtualenv

pip: python
	$(PYTHON) -m ensurepip --upgrade

pip-prospector: pip
	pip3 install prospector

pip-pytest: pip
	pip3 install -U pytest

pip-django: pip
	pip3 install Django

prospector: pip-prospector
	prospector $(HUB_SRC_DIR)

# testing GitHub connection from terminal to GitHub 

# simple makefile tools

#Reference https://docs.djangoproject.com/en/2.2/intro/tutorial01/
django: pip-django
	mkdir -p $(HUB_DJANGO_DIR)
	#Unsure if these are needed/how they should be written
	#django-admin startproject mysite
	#python manage.py runserver
	#python manage.py startapp polls

#Reference for testing, https://docs.pytest.org/en/latest/getting-started.html
pytest: pip-pytest
	mkdir -p $(HUB_PYTEST_DIR)
	pytest --cov-report=html:$(HUB_PYTEST_DIR) --cov-branch $(HUB_TEST_DIR)
  
setup-server: pip 
	pip install gunicorn
	cd ~
	echo 'export PATH:$PATH:/home/pi/.local/bin/' >> .local
	gunicorn -w 4 -b 192.168.2.2:8080 SolarDjango.wsgi:

wifi: 
	sudo apt install dnsmasq hostapd
	sudo systemctl stop dnsmasq
	sudo systemctl stop hostapd
	sudo cp ~/config/dhcpcd.conf /etc/dhcpcd.conf
	sudo service dhcpcd restart
	sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
	sudo cp ~/config/dnsmasq.conf /etc/dnsmasq.conf
	sudo service dhcpcd restart
	sudo systemctl start dnsmasq
	sudo cp ~/config/hostapd.conf /etc/hostapd/hostapd.conf
	sudo cp ~/config/hostapd /etc/default/hostapd
	sudo systemctl unmask hostapd
	sudo systemctl enable hostapd
	sudo systemctl start hostapd
	sudo cp ~/config/sysctl.conf /etc/sysctl.conf
	sudo iptables -t nat -A  POSTROUTING -o eth0 -j MASQUERADE
	sudo sh -c "iptables-save > /etc/iptables.ipv4.nat"
	sudo cp ~/config/rc.local /etc/rc.local
	sudo reboot -h now
