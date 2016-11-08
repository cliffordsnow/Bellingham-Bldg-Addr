UPDATE bellingham_addr SET unit = REGEXP_REPLACE(main_addre, '[0-9A-Z ]+ (STE|APT|BLDG) ' ,'') WHERE main_addre SIMILAR TO '% (STE|APT|BLDG) %'
