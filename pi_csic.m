#!/usr/bin/octave -qf

arg_list = argv ();
if nargin != 2
  printf ("ERROR: There should be 2 args. A .csv file containing the experiment data and a .yaml file containing the anthropometric data of the subject\n");
  printf ("Usage:\n");
  printf ("\t./pi_csic.m csv_filename yaml_anthropometric_filename\n\n");
  exit(127);
endif

printf ("csv file: %s", arg_list{1});
printf ("anthropometric file: %s", arg_list{2});

computePI(arg_list{1}, arg_list{2})