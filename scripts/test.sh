#!/bin/env bash
# This script is used to test : open the map in Chromium

chromium --disable-web-security --user-data-dir=. public/map.html 
