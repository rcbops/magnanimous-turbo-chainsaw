#!/usr/bin/env python

import argparse
import os
from os import listdir, walk, getcwd, path
from os.path import isfile, join
import sys
import re

excludes_file = "exclude_file.txt"
includes_file = "include_file.txt"
whitelist_file = "whitelist_vars"
blacklist_file = "blacklist_vars"

default_file_search_pattern = [r'user_\S+.yml$']
predefined_whitelist_vars = ['maas_api_url', 'maas_auth_token', 'maas_fqdn_extension', 'maas_env_identifier']
predefined_blacklist_vars = ['maas_env_product', 'maas_use_api', 'maas_remote_check', 'maas_raxmon_ssl_verify', 
	'maas_nova_console_type', 'maas_monitor_cinder_backup', 'maas_holland_enabled',  'maas_holland_venv_enabled',  
	'maas_verify_status',  'maas_verify_registration',  'maas_proxy_url', 'ansible_host']
var_search_pattern = r'([\S]+):\s+([\S"|\(\) \{\}]+)'

mypath = getcwd()

def print_dict(d, v=0, s=False):
  '''
  for i in d:
    print "{}:".format(i)
    for l in range(len(d[i])):
      print "\t {}".format(d[i][l][0])
      print "\t {}\n".format(d[i][l][1])
    print ""
  '''
  for i in d:
    for l in range(len(d[i])):
      if v == 1:
        print "{0:<28s} {1:<12.12s} {2:}".format(i, d[i][l][0], d[i][l][1])
      elif v > 1:
        print "{}   {}   {}".format(i, d[i][l][0], d[i][l][1])

  if s:
    for i in d:
      for l in range(len(d[i])):
        print "sed -i '' '/^{}/d' {}".format(i, d[i][l][1])


def get_file_list_contents(file_list):
  list_vars = []

  with open(file_list, 'r') as lfile:
    for line in lfile:
      line = line.strip()
      if line !=  '':
        list_vars.append(line)
  lfile.close()
  return list_vars  


def add_to_dictionary(d, var, val, path):
  if var not in d:
    d[var] = [[val, path]]
  else:
    d[var].append([val, path])

  return d


def file_is_in_list(f, l):
  result = False

  for i in l:
    m = re.search(i, f)
    if m:
      result = True
      break
    else:
      pass
  return result


'''
  for the whitelist: if there are dictionary entries set...
    then this is good...
    all entries must be set, not just some

  for the blacklist: there should be no entries set
    if they are set, then they have been overridden someplace
'''
def all_vars_in_dict(dict, dict_keys, entries_exist=True):
  existing_set = set()
  missing_set = set()
  dict_keys_len = len(dict_keys)

  for e in dict_keys:
    #print "E:{}".format(e)
    if e in dict:
      #print "... the key exists in the dictionary"
      existing_set.add(e)
    else:
      #print "... the key does not exist in the dictionary"
      missing_set.add(e)

  existing_set_len = len(existing_set)
  if dict_keys_len == existing_set_len:
    #print "all keys exist in the dictionary"
    #print "SET:{}".format(existing_set)
    rval = "ALL_KEYS_EXIST"
  elif existing_set_len == 0:
    #print "no keys exist in the dictionary"
    rval = "NO_KEYS_EXIST"
  else:
    #print "only some keys exist in the dictionary"
    #print "MISSING:{}".format(missing_set)
    #print_dict(dict)
    rval = "SOME_KEYS_EXIST"

  return [rval, existing_set, missing_set]

  
def get_files_list(file_list):
  files = []
  
  with open(file_list, 'r') as fl:
    for line in fl:
      line = line.strip()
      files.append(line)
    fl.close()
    return files


def parse_file(fname, pattern, list_vars, dict):
  d = dict
  with open(fname, 'r') as f:
    for line in f:
      line = line.strip()
      m = re.search(pattern, line)
      if m:
        for lv in list_vars:
          if lv == m.group(1):
            d = add_to_dictionary(dict, lv, m.group(2), fname) 
  f.close()
  return d


def main():

  include_files_exists = False
  exclude_files_exists = False
  whitelist_file_exists = False

  wl_dict = {}
  bl_dict = {}

  statcode = 0

  verbose = 0
  sed = False

  parser = argparse.ArgumentParser()
  parser.add_argument("path", help="recursively scan the contents of the directory specified by path", type=str)
  parser.add_argument("-v", "--verbose", help="detailed output (count) - 1 (formatted) | 2 (long)", action="count", default=0)
  parser.add_argument("-s", "--sed", help="generate sed output", action="store_true")
  args = parser.parse_args()

  if args.verbose > 0:
    verbose = args.verbose
  
  if args.sed == True:
    sed = True;

  mypath = args.path


  # check to see if files exist to limit/restrict file scans:
  # include file as precedent... if it exists, not exclude file (for now)
  if os.path.exists(includes_file):
    include_files = get_files_list(includes_file)
    include_files_exists = True

  elif os.path.exists(excludes_file):
    exclude_files = get_files_list(excludes_file)
    exclude_files_exists = True

  else:
    include_files = default_file_search_pattern
    include_files_exists = True


  # check to see if files exist to limit/restrict/define black/white lists:
  if os.path.exists(whitelist_file):
    whitelist_file_exists = True
    whitelist_vars = get_file_list_contents(whitelist_file)
  else:
    whitelist_vars = predefined_whitelist_vars

  if os.path.exists(blacklist_file):
    blacklist_file_exists = True
    blacklist_vars = get_file_list_contents(blacklist_file)
  else:
    blacklist_vars = predefined_blacklist_vars

  # r=root, d=directories, f=files
  for r, d, f in walk(mypath):
    for file in f:
      if include_files_exists:
        if file_is_in_list(file, include_files):
          cfile = "{}".format(join(r, file))
          parse_file(cfile, var_search_pattern, whitelist_vars, wl_dict)
          parse_file(cfile, var_search_pattern, blacklist_vars, bl_dict)
      elif exclude_files_exists:
        if not file_is_in_list(file, exclude_files):
          cfile = "{}".format(join(r, file))
          parse_file(cfile, var_search_pattern, whitelist_vars, wl_dict)
          parse_file(cfile, var_search_pattern, blacklist_vars, bl_dict)
      else:
        cfile = "{}".format(join(r, file))
        parse_file(cfile, var_search_pattern, whitelist_vars, wl_dict)
        parse_file(cfile, var_search_pattern, blacklist_vars, bl_dict)

  '''
  for the whitelist: if there are dictionary entries set...
    then this is good...
    all entries must be set, not just some

  for the blacklist: there should be no entries set
    if they are set, then they have been overridden someplace

  ALL_KEYS_EXIST, SOME_KEYS_EXIST, NO_KEYS_EXIST
  '''

  r, existing_set, missing_set = all_vars_in_dict(wl_dict, whitelist_vars, True)
  if r != "ALL_KEYS_EXIST":
    print "!!! all vars do not exist in the whitelist dictionary"
    print "MISSING:{}".format(missing_set)
    print_dict(wl_dict, verbose)
    statcode = statcode + 64
  else:   # ALL_KEYS_EXIST
    print "*** WHITELIST VARS: OK!"

  r, existing_set, missing_set = all_vars_in_dict(bl_dict, blacklist_vars, False)
  if r == "NO_KEYS_EXIST":
    print "*** BLACKLIST VARS: OK!"
  else: # some or all vars are listed in blacklist
    print "!!! there are vars that have been set in the blacklist dictionary"
    print "SET:{}".format(existing_set)
    if verbose > 0:
      print "UNSET:{}".format(missing_set)
    print_dict(bl_dict, verbose, sed)
    statcode = statcode + 32

  return statcode


if __name__ == "__main__":
  #return main()
  sys.exit(main())
