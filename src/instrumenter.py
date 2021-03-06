#!/usr/bin/env python
# coding: utf8
'''
Created on 27.02.2013

Injecting bytecode into an Android APK

This module parses dex bytecode and inserts custom code at configurable points. 
Example usages are to insert debug statements into APKs, modify parameters of function 
calls, etc.

@author: Julian Schuette (julian.schuette@aisec.fraunhofer.de), 2013
'''
import sys
import os
import shutil
import argparse
from androguard.core.bytecodes import apk
import injector.injection
from subprocess import call
from stopwatch import Stopwatch

# The working dir (currently the root of APKIL)
working_dir = './injector'

hook_file = 'hooks.conf'

# Config file denoting the API calls to instrument
default_api = os.path.join(working_dir, "config", "default_api_collection")

# Output dir
outdir = './out'

watch = Stopwatch()

#Data to be instrumented. Key: substring of smali instructions to hook. Value: Code to execute upon hook..
instr_data = {}


def load_hooks(filename):
    f = open(filename)
    lines = f.readlines()
    for line in lines:
        data = line.split('=>')
        if len(data)==2:
            instr_data[data[0]]=data[1]
        else:
            raise Exception('Invalid hook file format')
        
def infer_type(dex):
    pass
        

def instrument(filename,hooks):
    '''
    Instruments API calls with an "Injector" and repackages the modified App
    @param filename: str indicating the full path to the APK file to instrument
    @param hooks: annotation object from dftest, indicating code locations to instrument
    '''
    print "Instrumenting %s"%filename
    root_name, _ = os.path.splitext(filename)

    # APK gives access to the resources of an apk file
    a = apk.APK(filename)
    api_config = default_api
    
    db_path = os.path.join(working_dir, "androidlib")
    mo = injector.injection.Injector(db_path, config=api_config)
    
    new_apk = os.path.join(outdir, os.path.split(root_name)[1] + "_new.apk")

    if os.path.exists(outdir):
        shutil.rmtree(outdir)
    os.makedirs(outdir)

    dexpath = os.path.join(outdir, "origin.dex")
    smalidir = os.path.join(outdir, "origin_smali") 
    new_dexpath = os.path.join(outdir, "new.dex")
    new_smalidir = os.path.join(outdir, "new_smali")
    
    level = 8
    min_version = level
    target_version = level
    if a.get_min_sdk_version():
        min_version = int(a.get_min_sdk_version())
        print "min_sdk_version=%d" % min_version
        level = min_version
    if a.get_target_sdk_version():
        target_version = int(a.get_target_sdk_version())
    print "target_sdk_version=%d" % target_version
    
    
    # Configuration of smali and the certificate required for signing the repackaged APK
    smali_jar = os.path.join(working_dir, "smali", "smali.jar")
    baksmali_jar = os.path.join(working_dir, "smali", "baksmali.jar")
    cert_path = os.path.join(working_dir, "config", "apkil.cert")

    # Extract dex (bytecode) file from apk
    dex_file = open(dexpath, 'w')
    dex_file.write(a.get_dex())
    dex_file.close()
        
    # call smali and write result to outdir
    print "Applying baksmali, writing to %s"%outdir
    call(args=['java', '-jar', baksmali_jar,
           '-b', '-o', smalidir, dexpath])
    s = injector.smali.SmaliTree(level, smalidir)
    
    # Instrument smali code
    print 'Injecting code, writing to %s'%new_smalidir
    s = mo.inject(s, level, hooks)
    s.save(new_smalidir)
    
    # Compile smali code to bytecode again
    print 'Applying smali, writing to %s'%new_dexpath
    call(args=['java', '-jar', smali_jar,
           '-a', str(level), '-o', new_dexpath, new_smalidir])
  
      
    # Create new APK with modified classes.dex file
    print 'Re-Package modified classes.dex into %s'%new_apk
    new_dex = open(new_dexpath).read();
    a.new_zip(filename=new_apk,
                deleted_files="(META-INF/.)", new_files = {
                "classes.dex" : new_dex } )
    
    # Finally sign the apk again
    print 'Signing the new apk with cert from %s'%cert_path
    apk.sign_apk(new_apk, cert_path, "apkilapkil", "apkil" )
    print "DONE. Have fun with %s" % new_apk


def parse_cmd_line():

    parser = argparse.ArgumentParser(description=u'Instrumenting Android Apps.\n\
                                     \n\
                                    This tool injects hook methods into Android APK.\n\
                                    (C) Julian Schütte, Fraunhofer AISEC, 2013')
    parser.add_argument('-f', metavar='apk_file', type=str,
                       help='APK file(s) to instrument. If omitted, instrument all apps in current directory')
    parser.add_argument('--hooks', dest='hooks', metavar='file', action='store', default='hooks.conf',
                       help='hooks file (default: hook.conf)')
    
    args = parser.parse_args()
    print args
    return args

    
def main(args=argparse.Namespace()):
    '''
    Entry point
    '''
    app_dir='./'
    
    if not hasattr(args, 'hooks'):
        setattr(args, 'hooks', 'hooks.conf')
    if not hasattr(args, 'f'):
        setattr(args, 'f', None)
    load_hooks(args.hooks)
    
    if args.f is None:
        for dirname, dirnames, filenames in os.walk(app_dir):
            for filename in filenames:
                if '.apk' in filename:
                    _, ext = os.path.splitext(filename)
                    
                    if ext != ".apk":
                        print "error: not an APK file"
                        sys.exit(2)
                       
                    # instrument and re-package the app
                    with watch:
                        instrument(os.path.join(dirname,filename), instr_data)
    else:
        instrument(args.f, instr_data)

    
if __name__ == '__main__':
    '''
    Where it begins...
    '''
    main(parse_cmd_line())
    
