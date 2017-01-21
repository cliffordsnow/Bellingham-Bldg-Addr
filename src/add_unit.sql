UPDATE bellingham_addr SET unit = REGEXP_REPLACE(main_address_display, '[0-9A-Z ]+ (STE|APT|BLDG) ' ,'') WHERE main_address_display SIMILAR TO '% (STE|APT|BLDG) %'
