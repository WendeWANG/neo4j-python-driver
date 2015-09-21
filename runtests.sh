#!/usr/bin/env bash

HOME=$(pwd)/$(dirname $0)
DOWNLOAD=0
RUNNING=0

function runserverandtests {

    PYTHON_VERSION=$(python --version)
    NEO_VERSION=$1

    echo "======================================================================"
    echo "Running with ${PYTHON_VERSION} against Neo4j ${NEO_VERSION}"
    echo "----------------------------------------------------------------------"

    mkdir -p ${HOME}/.test 2> /dev/null

    cd ${HOME}/.test
    if [ ${DOWNLOAD} -ne 0 ]
    then
        rm -rf *
    fi
    tar xf $(${HOME}/neoget.sh -ex ${NEO_VERSION})
    NEO_HOME=$(ls -1Ft | grep "/$" | head -1)      # finds the newest directory
    echo "xx.bolt.enabled=true" >> ${NEO_HOME}/conf/neo4j-server.properties
    ${NEO_HOME}/bin/neo4j start
    STATUS=$?
    if [ ${STATUS} -ne 0 ]
    then
        exit ${STATUS}
    fi

    cd ${HOME}
    echo -n "Testing"
    coverage run -m unittest test

    cd ${HOME}/.test
    ${NEO_HOME}/bin/neo4j stop
    rm -rf ${NEO_HOME}

    cd ${HOME}
    coverage report --show-missing

    echo "======================================================================"
    echo ""

}

function runtests {

    PYTHON_VERSION=$(python --version)

    echo "======================================================================"
    echo "Running with ${PYTHON_VERSION} against running Neo4j instance"
    echo "----------------------------------------------------------------------"

    cd ${HOME}
    echo -n "Testing"
    coverage run -m unittest test

    cd ${HOME}
    coverage report --show-missing

    echo "======================================================================"
    echo ""

}

while getopts ":dr" OPTION
do
  case ${OPTION} in
    d)
      DOWNLOAD=1
      ;;
    r)
      RUNNING=1
      ;;
    \?)
      echo "Invalid option: -${OPTARG}" >&2
      ;;
  esac
done

if [ ${RUNNING} -eq 1 ]
then
    runtests
else
    runserverandtests "3.0.0-alpha"
fi
