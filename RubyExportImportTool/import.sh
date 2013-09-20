#!/bin/sh
# $1 is the server name - either demo or preview or iteration
# $2 is the Workspace name
ruby eximporter.rb demodata/online-store/project.properties $1/slm "$2"
ruby eximporter.rb demodata/online-store/api-team/project.properties $1/slm "$2"
ruby eximporter.rb demodata/online-store/consumer-site/project.properties $1/slm "$2"
ruby eximporter.rb demodata/online-store/consumer-site/fulfillment-team/project.properties $1/slm "$2"
ruby eximporter.rb demodata/online-store/consumer-site/payment-team/project.properties $1/slm "$2"
ruby eximporter.rb demodata/online-store/consumer-site/shopping-team/project.properties $1/slm "$2"
ruby eximporter.rb demodata/online-store/reseller-site/project.properties $1/slm "$2"
ruby eximporter.rb demodata/online-store/reseller-site/analytics-team/project.properties $1/slm "$2"
ruby eximporter.rb demodata/online-store/reseller-site/reseller-portal-team/project.properties $1/slm "$2"
ruby eximporter.rb demodata/online-store/discussion-project.properties $1/slm "$2"
