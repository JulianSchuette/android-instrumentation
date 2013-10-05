'''
Created on 27.02.2013

Injecting bytecode into an Android APK

This module parses dex bytecode and inserts custom code at configurable points. 
Example usages are to insert debug statements into APKs, modify parameters of function 
calls, etc.

@author: Julian Schuette (julian.schuette@aisec.fraunhofer.de)
'''
import sys
import os
import shutil
import time
import argparse
import collections
import copy
from androguard.core.bytecodes import apk
from injector import smali
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
        

def instrument(filename,hooks):
    '''
    Instruments API calls with an "Injector" and repackages the modified App
    @param filename: str indicating the full path to the APK file to instrument
    @param hooks: annotation object from dftest, indicating code locations to instrument
    '''
    root_name, ext = os.path.splitext(filename)

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
    if a.get_min_sdk_version():
        min_version = int(a.get_min_sdk_version())
        print "min_sdk_version=%d" % min_version
        level = min_version
    if a.get_target_sdk_version():
        target_version = int(a.get_target_sdk_version())
    else:
        target_version = min_version
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


    
def do_sth(apk_name):
    '''
    Entry point
    '''
    root_name, ext = os.path.splitext(apk_name)
    load_hooks(hook_file)
    
    if ext != ".apk":
        print "error: not an APK file"
        sys.exit(2)
       
    # instrument and re-package the app
    with watch:
        instrument(apk_name, instr_data)

    
if __name__ == '__main__':
    '''
    Where it begins...
    '''
    app_dir='./'
    for dirname, dirnames, filenames in os.walk(app_dir):
        for filename in filenames:
            if '.apk' in filename:
                print "Instrumenting %s"%os.path.join(dirname, filename)
                do_sth(os.path.join(dirname, filename))
    
