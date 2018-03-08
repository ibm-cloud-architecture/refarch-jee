#!/bin/sh
# Licensed Materials - Property of IBM
# 5648-F10 (C) Copyright International Business Machines Corp. 2005 
# All Rights Reserved
# US Government Users Restricted Rights - Use, duplication or disclosure
# restricted by GSA ADP Schedule Contract with IBM Corp.

    supportedMozillaVersion() {
	case "$*" in
	    *rv:1.[7-9]*) return 0;;
	    *rv:[2-9].[0-9]*) return 0;;
	    *rv:*) return 1;;
	    Mozilla\ 1.[7-9]*) return 0;;
	    Mozilla\ [2-9].[0-9]*) return 0;;
	    *) return 1;;
	esac
    }

    supportedFirefoxVersion() {
	case "$*" in
            *Firefox\ [1-9].*) return 0;;
	    *Firefox/[1-9].*) return 0;;
            *Firefox*) return 1;;
            *rv:1.[7-9]*) return 0;;
            *rv:[2-9].*) return 0;;
	    *rv:*) return 1;;
	    Mozilla*\ 1.[7-9]*) return 0;;
	    Mozilla*\ [2-9].[0-9]*) return 0;;
	    *) return 1;;
	esac
    }

    FirstStepsDefaultBrowser=NoBrowser
    FirstStepsDefaultBrowserPath=
    case "$0" in
        /*) fullpath=$0;;
         *) fullpath=`pwd`/$0;;
    esac
    installsourcepath=`echo "$fullpath" | sed "s,/\./,/,g; s,/[^/][^/]*/\.\./,/,g; s,//,/,g; s,/[^/]*$,,"`
    if [ "$BROWSER" ]; then
        if versionString=`($BROWSER -version) 2>/dev/null`; then
            case "$versionString" in
	    *Firefox*) if supportedFirefoxVersion "$versionString"; then
               	           FirstStepsDefaultBrowser=Firefox
			   FirstStepsDefaultBrowserPath=firefox
           	       fi ;;
	    *Mozilla*) if supportedMozillaVersion "$versionString"; then
               	           FirstStepsDefaultBrowser=Mozilla
			   FirstStepsDefaultBrowserPath=mozilla
           	       fi ;;
            esac
        fi
    fi
    if [ $FirstStepsDefaultBrowser = NoBrowser ]; then
        if versionString=`(firefox -version) 2>/dev/null`; then
	    BROWSER=firefox; export BROWSER
	    if supportedFirefoxVersion "$versionString"; then
		FirstStepsDefaultBrowser=Firefox
		FirstStepsDefaultBrowserPath=firefox
	    fi
	fi
    fi
    if [ $FirstStepsDefaultBrowser = NoBrowser ]; then
	PATH="$PATH:/opt/firefox"
        if versionString=`(firefox -version) 2>/dev/null`; then
	    BROWSER=firefox; export BROWSER
	    if supportedFirefoxVersion "$versionString"; then
		FirstStepsDefaultBrowser=Firefox
		FirstStepsDefaultBrowserPath=/opt/firefox/firefox
	    fi
	fi
    fi
    if [ $FirstStepsDefaultBrowser = NoBrowser ]; then
	PATH="$PATH:/usr/firefox"
        if versionString=`(firefox -version) 2>/dev/null`; then
	    BROWSER=firefox; export BROWSER
	    if supportedFirefoxVersion "$versionString"; then
		FirstStepsDefaultBrowser=Firefox
		FirstStepsDefaultBrowserPath=/usr/firefox/firefox
	    fi
	fi
    fi
    if [ $FirstStepsDefaultBrowser = NoBrowser ]; then
	PATH="$PATH:/usr/firefox/sfw/lib/firefox"
        if versionString=`(firefox -version) 2>/dev/null`; then
	    BROWSER=firefox; export BROWSER
	    if supportedFirefoxVersion "$versionString"; then
		FirstStepsDefaultBrowser=Firefox
		FirstStepsDefaultBrowserPath=/usr/firefox/sfw/lib/firefox/firefox
	    fi
	fi
    fi
    if [ $FirstStepsDefaultBrowser = NoBrowser ]; then
	PATH="$PATH"
        if versionString=`(mozilla -version) 2>/dev/null`; then
	    BROWSER=mozilla; export BROWSER
	    if supportedMozillaVersion "$versionString"; then
		FirstStepsDefaultBrowser=Mozilla
		FirstStepsDefaultBrowserPath=mozilla
	    fi
	fi
    fi
    if [ $FirstStepsDefaultBrowser = NoBrowser ]; then
	PATH="$PATH:/usr/X11R6/bin"
        if versionString=`(mozilla -version) 2>/dev/null`; then
	    BROWSER=mozilla; export BROWSER
	    if supportedMozillaVersion "$versionString"; then
		FirstStepsDefaultBrowser=Mozilla
		FirstStepsDefaultBrowserPath=/usr/X11R6/bin/mozilla
	    fi
	fi
    fi
    if [ $FirstStepsDefaultBrowser = NoBrowser ]; then
	PATH="$PATH:/usr/local/bin"
        if versionString=`(mozilla -version) 2>/dev/null`; then
	    BROWSER=mozilla; export BROWSER
	    if supportedMozillaVersion "$versionString"; then
		FirstStepsDefaultBrowser=Mozilla
		FirstStepsDefaultBrowserPath=/usr/local/bin/mozilla
	    fi
	fi
    fi
    if [ $FirstStepsDefaultBrowser = NoBrowser ]; then
	PATH="$PATH:/usr/bin"
        if versionString=`(mozilla -version) 2>/dev/null`; then
	    BROWSER=mozilla; export BROWSER
	    if supportedMozillaVersion "$versionString"; then
		FirstStepsDefaultBrowser=Mozilla
		FirstStepsDefaultBrowserPath=/usr/bin/mozilla
	    fi
	fi
    fi
    if [ $FirstStepsDefaultBrowser = NoBrowser ]; then
	PATH="$PATH:/opt/mozilla:"
        if versionString=`(mozilla -version) 2>/dev/null`; then
	    BROWSER=mozilla; export BROWSER
	    if supportedMozillaVersion "$versionString"; then
		FirstStepsDefaultBrowser=Mozilla
		FirstStepsDefaultBrowserPath=/opt/mozilla/mozilla
	    fi
	fi
    fi
    if [ $FirstStepsDefaultBrowser = NoBrowser ]; then
	PATH="$PATH:/usr/mozilla"
        if versionString=`(mozilla -version) 2>/dev/null`; then
	    BROWSER=mozilla; export BROWSER
	    if supportedMozillaVersion "$versionString"; then
		FirstStepsDefaultBrowser=Mozilla
		FirstStepsDefaultBrowserPath=/usr/mozilla
	    fi
	fi
    fi
    if [ $FirstStepsDefaultBrowser = NoBrowser ]; then
	PATH="$PATH:/usr/mozilla/sfw/lib/mozilla"
        if versionString=`(mozilla -version) 2>/dev/null`; then
	    BROWSER=mozilla; export BROWSER
	    if supportedMozillaVersion "$versionString"; then
		FirstStepsDefaultBrowser=Mozilla
		FirstStepsDefaultBrowserPath=/usr/mozilla/sfw/lib/mozilla/mozilla
	    fi
	fi
    fi
    if [ $FirstStepsDefaultBrowser = NoBrowser ]; then
        PATH="$PATH:/usr/sfw/bin"
        if versionString=`(mozilla -version) 2>/dev/null`; then
            BROWSER=mozilla; export BROWSER
            if supportedMozillaVersion "$versionString"; then
                FirstStepsDefaultBrowser=Mozilla
                FirstStepsDefaultBrowserPath=/usr/sfw/bin/mozilla
            fi
        fi
    fi
    export FirstStepsDefaultBrowser
    export FirstStepsDefaultBrowserPath
