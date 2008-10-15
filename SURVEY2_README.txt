Survey2 Quick-start
===================

To get Survey2 working for a test site running off this branch:

* update your site db schema:

> mysql -u<user> -p<pass> <site_db> -e "drop table if exists Survey; drop table if exists Survey_response; source /data/WebGUI/lib/WebGUI/Asset/Wobject/Survey/Survey.sql; source /data/WebGUI/lib/WebGUI/Asset/Wobject/Survey/Survey_response.sql;"

* import survey_templates.wgpkg into your site via the package manager
