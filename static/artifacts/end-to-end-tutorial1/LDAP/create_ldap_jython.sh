#!/bin/bash

########
# Help #
########

usage () {

    echo
    echo "This script will configure your WebSphere Application Server to use an standalone LDAP Server for user Authentication and Authorization"
    echo
    echo "The following parameters must be specified:"
    echo
    echo "--------------"
    echo "- Parameters -"
    echo "--------------"
    echo
    echo "-f:           Read values from specified file."
    echo "-ldap_host:   Standalone LDAP Server host url."
    echo "-ldap_port:   Standalone LDAP Server port number."
    echo "-ldap_type:   Realm definition. Example: IBM_DIRECTORY_SERVER."
    echo "-bind_dn:     LDAP administrator user id."
    echo "-bind_pw:     LDAP administrator user password."
    echo "-admin_id:    WebShere Application Server administrator id."
    echo "-u:           Print usage."
    
}

###################
# Read parameters #
###################

while [ -n "$1" ]; do
    case $1 in
        -f )            shift
                        READ_FROM_FILE=true
                        FILE_TO_READ=$1
                        break
                        ;;
        -ldap_host )    shift
                        LDAP_HOST=$1
                        ;;
        -ldap_port )    shift
                        LDAP_PORT=$1
                        ;;
        -ldap_type )    shift
                        LDAP_SERVER_TYPE=$1
                        ;;
        -bind_dn )      shift
                        BIND_DN=$1
                        ;;
        -bind_pw )      shift
                        BIND_PASSWORD=$1
                        ;;
        -admin_id )     shift
                        PRIMARY_ADMIN_ID=$1
                        ;;
        -u )            usage
                        exit 0
                        ;;
        * )             echo "[ERROR]: Param $1 is not valid."
                        usage
                        exit 1
    esac
    shift
done

##################
# Read from file #
##################

if [ ${READ_FROM_FILE} ]; then
    if [ ! -f ${FILE_TO_READ} ]; then
        echo "[ERROR]: The file ${FILE_TO_READ} does not exist."
        exit 1
    fi
    . ${FILE_TO_READ}
    if [ $? -ne 0 ]; then
        echo "[ERROR]: An error occurred reading the properties file"
    fi
fi

#########################
# Parameters validation #
#########################

if ([ -z "${LDAP_HOST}" ] || [ -z "${LDAP_PORT}" ] || [ -z "${LDAP_SERVER_TYPE}" ] || [ -z "${BIND_DN}" ] || [ -z "${BIND_PASSWORD}" ] || [ -z "${PRIMARY_ADMIN_ID}" ]); then
    echo "[ERROR]: The value for one of the parameters is null."
    echo "[ERROR]: Please check your parameters"
    usage
    exit 1
fi

######################
# Create jython file #
######################

FILE="WAS_LDAP_config.py"
touch ${FILE}

if [ $? -ne 0 ]; then
    echo "[ERROR]: An error occurred while creating the jython file."
    exit 1
fi

echo "# Advanced Lightweight Directory Access Protocol (LDAP) user registry settings" >> ${FILE}
echo "AdminTask.configureAdminLDAPUserRegistry('[-userFilter (&(uid=%v)(objectclass=inetorgperson)(ou=caseinc)) -groupFilter (&(cn=%v)(objectclass=groupofuniquenames)(ou=caseinc)) -userIdMap *:uid -groupIdMap *:cn -groupMemberIdMap ibm-allGroups:member;ibm-allGroups:uniqueMember -certificateFilter -certificateMapMode EXACT_DN -krbUserFilter (&(krbPrincipalName=%v)(objectclass=ePerson)) -customProperties [\"com.ibm.websphere.security.ldap.recursiveSearch=\"] -verifyRegistry false ]')" >> ${FILE}

echo "# Standalone LDAP registry setup" >> ${FILE}
echo "AdminTask.configureAdminLDAPUserRegistry('[-ldapHost ${LDAP_HOST} -ldapPort ${LDAP_PORT} -ldapServerType ${LDAP_SERVER_TYPE} -baseDN -bindDN ${BIND_DN} -bindPassword ${BIND_PASSWORD} -searchTimeout 120 -reuseConnection true -sslEnabled false -sslConfig -autoGenerateServerId true -primaryAdminId ${PRIMARY_ADMIN_ID} -ignoreCase true -customProperties -verifyRegistry false ]')" >> ${FILE}

echo "# Verify Registry" >> ${FILE}
echo "AdminTask.configureAdminLDAPUserRegistry('[-verifyRegistry true]')" >> ${FILE}

echo "# Set LDAP registry active" >> ${FILE}
echo "AdminTask.setAdminActiveSecuritySettings ('[-activeUserRegistry LDAPUserRegistry]')" >> ${FILE}

echo "# Save config" >> ${FILE}
echo "AdminConfig.save()" >> ${FILE}

#######
# End #
#######

echo "[SUCCESS]: The LDAP jython configuration file has been successfully created."
exit 0