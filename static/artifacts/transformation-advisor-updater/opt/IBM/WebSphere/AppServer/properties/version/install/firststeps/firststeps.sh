#!/bin/sh
CUR_DIR=`pwd`
cd `dirname ${0}`
.  ${PROFILEROOT}/bin/setupCmdLine.sh
.  ${PROFILEROOT}/firststeps/fbrowser.sh

${JAVAROOT} \
  -classpath ${HTMLSHELLJAR}:${WASROOT}/plugins/com.ibm.ws.runtime.jar \
  com.ibm.ws.install.htmlshell.Launcher 2> /dev/null > /dev/null \
  --file ${PROFILEROOT}/firststeps/firststeps \
  --width 653 \
  --height 555 \
  --resizable false \
  --icon ${PROFILEROOT}/firststeps/ws16x16.gif \
  --profilepath ${PROFILEROOT} \
  --cellname ${CELLNAME} \
  --wasroot ${WASROOT} \
  --FirstStepsDefaultBrowser $FirstStepsDefaultBrowser \
  --FirstStepsDefaultBrowserPath $FirstStepsDefaultBrowserPath
  
  cd ${CUR_DIR}
