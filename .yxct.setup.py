#!/usr/bin/env python3

import sys
import os
import argparse
import subprocess

__author__ = 'yuxi'

	
SCRIPT_NAME = 'yxct'
APP_NAME = 'yxct.setup'







def install(args):
	# print('install: pin_path=%s command=%s' % (args.bin_path, args.command))
	
	
	script_path=os.getcwd()
	
	if args.bin_path is None:
		raise TypeError('bin path is empty')
		
	if args.command is None:
		raise TypeError('command is empty')
		
	if args.command != SCRIPT_NAME:
		raise TypeError('Invalid script:%s' % args.command)
	
#	print("sudo cp --force %s/%s %s" % (script_path, SCRIPT_NAME, args.bin_path))
	subprocess.call("cp --force %s %s" % (os.path.join(script_path, SCRIPT_NAME), args.bin_path), shell=True)
	subprocess.call("chmod +x %s" % os.path.join(script_path, SCRIPT_NAME), shell=True)
	





def uninstall(args):
	# print('uninstall: pin_path=%s command=%s' % (args.bin_path, args.command))
	
	if args.bin_path is None:
		raise TypeError('bin path is empty')
		
	if args.command is None:
		raise TypeError('command is empty')
	
	if args.command != SCRIPT_NAME:
		raise TypeError('Invalid script:%s' % args.command)
		
	
	execute_file=os.path.join(args.bin_path, args.command)
	if os.access(execute_file, os.X_OK):
		subprocess.call("rm -f %s" % execute_file, shell=True)
	else:
		raise TypeError("Can not found script %s on path:%s" % (SCRIPT_NAME, execute_file))




if __name__ == "__main__":
	parser = argparse.ArgumentParser(prog=APP_NAME)
	subparsers = parser.add_subparsers()
	
	parser_install = subparsers.add_parser('install')
	parser_install.add_argument('--bin-path', type=str)
	parser_install.add_argument('--command', type=str)
	parser_install.set_defaults(func=install)
	
	parser_uninstall = subparsers.add_parser('uninstall')
	parser_uninstall.add_argument('--bin-path', type=str)
	parser_uninstall.add_argument('--command', type=str)
	parser_uninstall.set_defaults(func=uninstall)
	
#	args = parser.parse_args('install --bin-path /usr/local/sbin/ --command yxct'.split())
	args = parser.parse_args()
	args.func(args)
	