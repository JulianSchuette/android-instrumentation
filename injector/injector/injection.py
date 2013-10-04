#!/usr/bin/env python
# -*- coding: utf-8 -*-
# 
# Injects hook methods into dex bytecode
#
# @author: Julian Schuette
# @contact: julian.schuette@aisec.fraunhofer.de
# @organization: Fraunhofer AISEC

import sys
import os
import copy
import re

from smali import ClassNode, MethodNode, InsnNode, \
                  TypeNode
from api import AndroidAPI, AndroidClass, AndroidMethod

PKG_PREFIX = "monitor"

BASIC_TYPES = {
        'V': "void",
        'Z': "boolean",
        'B': "byte",
        'S': 'short',
        'C': "char",
        'I': "int",
        'J': "long",
        'F': "float",
        'D': "double"
        }

METHOD_TYPE_BY_OPCODE = {
        "invoke-virtual": "instance",
        "invoke-super": "instance",
        "invoke-direct": "constructor",
        "invoke-static": "static",
        "invoke-interface": "instance",
        "invoke-virtual/range": "instance",
        "invoke-super/range": "instance",
        "invoke-direct/range": "constructor",
        "invoke-static/range": "static",
        "invoke-interface/range": "instance"
        }

OPCODE_MAP = {
        "invoke-virtual": "invoke-static",
        "invoke-super": "invoke-static",
        "invoke-direct": "invoke-static",
        "invoke-static": "invoke-static",
        "invoke-interface": "invoke-static",
        "invoke-virtual/range": "invoke-static/range",
        "invoke-super/range": "invoke-static/range",
        "invoke-direct/range": "invoke-static/range",
        "invoke-static/range": "invoke-static/range",
        "invoke-interface/range": "invoke-static/range"
        }

class Injector(object):

    def to_java_notation(self, clazz, meth):
        qualified_name = clazz.name.replace('/','.').replace(';','.') + meth.descriptor.replace(' (', '(')
        if qualified_name[0]=='L':
            qualified_name = qualified_name[1:]
        return qualified_name

    def str_to_java(self, string):
        qualified_name = string.replace('/','.').replace(';->','.') + string.replace(' (', '(')
        if qualified_name[0]=='L':
            qualified_name = qualified_name[1:]
        return qualified_name

    def __init__(self, db_dir, entries=[], config=""):
        self.db_dir = ""
        self.entries = []
        self.method_descs = [] 
        self.android_api = None 

        self.db_dir = db_dir
        self.entries = entries
        if (not entries) and config:
            if os.path.isfile(config):
                f = open(config, 'r')
                line = f.readline()
                while line:
                    if line.isspace():
                        line = f.readline()
                        continue
                    line = line.strip()
                    segs = line.split(None, 1)
                    if segs[0][0] == '#':
                        line = f.readline()
                        continue
                    if not line in self.entries:
                        self.entries.append(line)
                    line = f.readline()
                f.close()
            else:
                print "[error] Config file not found: %s" % config
                sys.exit(1)

    def __repr__(self):
        return '\n'.join(self.method_descs)
    
    def load_api(self, level):
        if level > 16:
            level = 16
        elif level < 3:
            level = 3
        self.android_api = AndroidAPI()
        data_path = os.path.join(self.db_dir, "android-%d.db" % level)
        while not os.path.exists(data_path):
            level += 1
            data_path = os.path.join(self.db_dir, "android-%d.db" % level)
        self.android_api.load(data_path)
        return level
    
    def count_params(self,m):
        """
        Count the parameters of a method, in terms of "p" registers. This can differ from len(m.paras), if wide registers (64b) are used as parameters
        """
        ps = []
        i=0
        if 'static' not in m.access:
            ps.append('p0')
            i = 1
        for param in m.paras:
            if param.words==2:
                ps.append('p%d'%i)
                i += 1
            ps.append('p%d'%i)
            i += 1
        return len(ps)
                
        
    
    def inject(self, smali_tree, level, hooks):
        # get a copy of smali tree
        st = copy.deepcopy(smali_tree)
        
        # load api database
        print "Loading and processing API database..."
        level = self.load_api(level)
        print "Target API Level: %d" % level
        # check and fix apis in API_LIST
        method_descs = []
        for m in self.entries: #self.entries = list of APIs to instrument
            c = ""
            api_name = ""
            method_name = ""

            ia = m.find("->")
            ilb = m.find('(')

            if ia >= 0:
                c = m[:ia] # c is the class name (e.g. Landroid/content/Intent;)
                if ilb >= 0:
                    method_name = m[ia + 2:ilb]
                    api_name = m[ia + 2:]
                else:
                    method_name = m[ia + 2:] # name of method (e.g., <init>)
            else:
                c = m

            if not self.android_api.classes.has_key(c):
                print "[Warn] Class not found in API-%d db: %s" % (level, m)
                continue
            # just class name
            if not method_name:
                ms = self.android_api.classes[c].methods.keys()
                method_descs.extend(ms)
            # full signature
            elif api_name:
                if not self.android_api.classes[c].methods.has_key(m):
                    if method_name == "<init>":
                        print "[Warn] Method not found in API-%d db: %s" % (level, m)
                        continue
                    c_obj = self.android_api.classes[c]
                    existed = False
                    q = c_obj.supers
                    while q:
                        cn = q.pop(0)
                        c_obj = self.android_api.classes[cn]
                        nm = c_obj.desc + "->" + api_name
                        if c_obj.methods.has_key(nm):
                            existed = True
                            if not nm in self.entries:
                                print "[Warn] Inferred API: %s" % (nm, )
                                method_descs.append(nm)
                        else:
                            q.extend(self.android_api.classes[cn].supers)

                    if not existed:
                        print "[Warn] Method not found in API-%d db: %s" % (level, m)
                else:
                    method_descs.append(m)
            # signature without parameters
            else:
                own = False
                if self.android_api.classes[c].methods_by_name.has_key(method_name):
                    ms = self.android_api.classes[c].methods_by_name[method_name]
                    method_descs.extend(ms)
                    own = True

                if method_name == "<init>":
                    continue
                c_obj = self.android_api.classes[c] # an instance of AndroidClass
                existed = False
                q = c_obj.supers    # super classes of the current class represented by c_obj
                while q:
                    cn = q.pop(0)
                    c_obj = self.android_api.classes[cn]
                    if c_obj.methods_by_name.has_key(method_name):
                        existed = True
                        inferred = "%s->%s" % (c_obj.desc, method_name)
                        if not inferred in self.entries:
                            print "[Warn] Inferred API: %s" % inferred
                            method_descs.extend(c_obj.methods_by_name[method_name])
                    else:
                        q.extend(self.android_api.classes[cn].supers)

                if (not own) and (not existed):
                    print "[Warn] Method not found in API-%d db: %s" % (level, m)

        self.method_descs = list(set(method_descs))


        print "Injecting..."
        for c in st.classes:    # we now transform a SmaliTree-Class to and AndroidClass
            class_ = AndroidClass()
            class_.isAPI = False

            class_.desc = c.name
            class_.name= c.name[1:-1].replace('/', '.') # the "real" class name in canonical form
            class_.access = c.access
            if "interface" in c.access:                 # if this is an Interface ...
                class_.supers.extend(c.implements)
            else:
                class_.implements = c.implements
                class_.supers.append(c.super_name)

            for m in c.methods:
                method = AndroidMethod()
                method.isAPI = False
                method.desc = "%s->%s" % (c.name, m.descriptor)
                method.name = m.descriptor.split('(', 1)[0]
                #print method.desc
                method.sdesc = method.desc[:method.desc.rfind(')') + 1]
                method.access = m.access
                class_.methods[method.sdesc] = method 
            self.android_api.add_class(class_)
        self.android_api.build_connections(False)
        
        #add TrackerClass
        st.classes.append(ClassNode(os.path.join(os.path.dirname(__file__), 'TrackerClass.smali')))
        
        # Number of registers added to a method
        MORE_REGS = 6
        
        methods_to_fix = {} #key: classname.methodname, value: method object

        ######## CHECK FOR NEED OF FIXING PARAMS SHIFTED ABOVE v15 AND REPLACE pX by vY ################
        for c in st.classes:                # iterate over all classes ...
            for m in c.methods:             # ... and all methods.
                qualified_name = self.to_java_notation(c,m)
#                 if qualified_name in hooks:
                    #Test if we need to rewrite registers (has pX been moved to X>15?)
                if m.registers-len(m.paras)+MORE_REGS>15 and m.registers-len(m.paras)-1 <= 15:
                    if ''.join([c.name,m.name]) not in methods_to_fix:
                        for i, insn in enumerate(m.insns):
                            if insn.opcode_name in OPCODE_MAP:
                                if len([value for key, value in hooks.items() if key in self.str_to_java(insn.buf)])>0:
                                    print insn
                                    print m.descriptor
                                    methods_to_fix[''.join([c.name,m.name,m.descriptor])] = m
                                    all_ps = re.findall(r'[\s|\{]p(\d)', str(insn))
                                    ins_buf = insn.buf
                                    for p in all_ps:
                                        pos = m.registers-self.count_params(m) + int(p[0])                                  
                                        print '        this statement uses parameter %s which should be rewritten to v%s'%(p,pos)
                                        ins_buf = ins_buf.replace('p%s'%p,'v%d'%pos)
                                        new_ins = InsnNode(ins_buf)
                                        print '          the new ins is now %s '%new_ins
                                        m.insns[i] = new_ins
                                    
        ################ MOVE PARAMETERS TO THEIR ORIGINAL POSITIONS ###############################
        for methodname in methods_to_fix:
            m = methods_to_fix[methodname]
            #p0 is not contained in m.paras
            pos = m.registers-self.count_params(m)
            i=0
            if 'static' not in m.access:    #non-static methods have this->p0
                instr = InsnNode("move-object/16 v%d, p0"%(pos))
                m.insert_insn(instr, 0, 0)
                i += 1
            for p in m.paras:
                print 'Fixing %s in %s'%(i,methodname)
                # Rename pX to v(old_reg_count + MORE_REGS)
                pos = m.registers-self.count_params(m) + i
                if p.basic and not p.dim > 0:
                    if p.words <= 1:
                        instr = InsnNode("move/16 v%d, p%s"%(pos,i))
                        i += 1
                    elif p.words >= 2:
                        instr = InsnNode("move-wide/16 v%d, p%s"%(pos,i)) #@todo have wide regs been considered when adding registers to the method?
                        i += 2
                else:
                    instr = InsnNode("move-object/16 v%d, p%s"%(pos,i))
                    i+=1
                m.insert_insn(instr, 0, 0)          
        #########################################################################
        
        for c in st.classes:                # iterate over all classes ...
            for m in c.methods:             # ... and all methods.
                i = 0 
                ADDED_LINES = 0
                if ''.join([c.name,m.name,m.descriptor]) in methods_to_fix:
                    ADDED_LINES = len(m.paras)+1
                    i += ADDED_LINES
                    if 'static' in m.access:
                        i -= 1
                        ADDED_LINES -= 1
                new_i = i #new_i: saves position of new code and jumps over newly added code
                #print "new_i starts at %d (%d parameters and %d added hooks. This is 0:%s)"%(new_i,len(m.paras),ADDED_LINES, (i-ADDED_LINES))
                
                # Check if method contains call to instrument
                skip_method = True
                for ix in m.insns:
                    if ix.opcode_name.startswith('invoke'):
                        if len([value for key, value in hooks.items() if key in self.str_to_java(ix.buf)])>0:
                            skip_method = False
                            break
                if skip_method:
                    break
                            
                print "relevant: %s"%ix.opcode_name                      

                
                #Add MORE_REGS more registers for additional info
                m.set_registers(m.registers+MORE_REGS)
                new_regs = []
                for i in range(0,MORE_REGS-1):
                    print "j: %s , %s"%(i,m.registers-MORE_REGS+i)
                    new_regs.append("v%d"%(m.registers-MORE_REGS+i)) 
                       
                while new_i < len(m.insns):     # m.insns = list of bytecode instructions as strings (e.g. "invoke-direct {p0}, ..")
                    insn = m.insns[new_i]       # iterate over all statements of the current method 
                    if str(insn).startswith('#'):   # skip getter and setter comments in smali which would otherwise be considered a statement 
                        new_i += 1
                        insn = m.insns[new_i]
                    if insn.buf.startswith('invoke-'):
                        applicable_hooks = [value for key, value in hooks.items() if key in self.str_to_java(insn.buf)]
                        if len(applicable_hooks)>0:                            
                            # Get parameters
                            params = self._parse_paras(insn.buf)
                            regs = insn.obj.registers
                            if 'range' in insn.opcode_name:
                                print "Invoke-Range not yet implemented!: %s, %s"%regs,insn.buf
                            
                            #create an array
                            instr = InsnNode("const/4 %s, %d"%(new_regs[1], len(regs)))
                            m.insert_insn(instr, new_i, 0)
                            new_i += 1
                            instr = InsnNode("new-array %s, %s, [Lde/aisec/utils/Register;"%(new_regs[0],new_regs[1]))
                            m.insert_insn(instr, new_i, 0)
                            new_i += 1
                            for j,r in enumerate(regs):
                                instr = InsnNode("move-object/16 %s, %s "%(new_regs[j+2],r))
                                m.insert_insn(instr, new_i, 0)
                                new_i += 1
                            # Call hook
                            instr = InsnNode("invoke-static %s %s"%(new_regs[0],applicable_hooks[0])) #TODO call more than one hook, if any
                            m.insert_insn(instr, new_i, 0)
                            new_i += 1
                                                                                  
                    i += 1  
                    new_i += 1  
  
        print "Instrumentation done!"

        return st
    
    def _parse_paras(self, insn):
        p1 = insn.find('(')
        p2 = insn.find(')')
        result = []
        paras = insn[p1 + 1:p2]
        index = 0
        dim = 0
        while index < len(paras):
            c = paras[index]
            if c == '[':
                dim += 1
                index += 1
            elif BASIC_TYPES.has_key(c):
                result.append(TypeNode(paras[index - dim:index + 1]))
                index += 1
                dim = 0
            else:
                tmp = paras.find(';', index)
                result.append(TypeNode(paras[index - dim:tmp + 1]))
                index = tmp + 1
                dim = 0
        return result
    
    def _parse_regs(self, insn):
        p1 = insn.find('(')
        p2 = insn.find(')')
        result = []
        paras = insn[p1 + 1:p2]
        index = 0
        dim = 0
        while index < len(paras):
            c = paras[index]
            if c == '[':
                dim += 1
                index += 1
            elif BASIC_TYPES.has_key(c):
                result.append(TypeNode(paras[index - dim:index + 1]))
                index += 1
                dim = 0
            else:
                tmp = paras.find(';', index)
                result.append(TypeNode(paras[index - dim:tmp + 1]))
                index = tmp + 1
                dim = 0
        return result
    
    def _add_stub_class(self, className, superClassName, st ):
        """
        @param className: Name of new class; example: Lcom/test;
        @param superClassName: Name of super class; example: Ljava/lang/Object;
        @param st: Smali tree to save class
        """
        
        stub_class = ClassNode()
        stub_class.set_name("L" + PKG_PREFIX + "/" + className[1:])
        stub_class.add_access("public")
        stub_class.set_super_name(superClassName)

        self.stub_classes[className] = stub_class
        self.class_map[className] = "L" + PKG_PREFIX + "/" + className[1:]

        method = MethodNode()
        method.set_desc("<init>()V")
        method.add_access(["public", "constructor"])
        method.set_registers(1)
#           i1 = InsnNode("invoke-direct {p0}, Ljava/lang/Object;-><init>()V")    #Error! Must not create instance of Object, but of superclass
        i1 = InsnNode("invoke-direct {p0}, "+superClassName+"-><init>()V")
        i2 = InsnNode("return-void")
        method.add_insn([i1, i2])
        stub_class.add_method(method)
        st.add_class(stub_class)

    def _add_stub_method(self, on, m, class_, registers=1):
        """
        @param on: opcode name
        @param m: method descriptor (string); example: Lcom/test;->test()V
        @param class_: class of the corresponding method
        @param registers: number of registers for that method
        """
        #segs = m.split(':', 1)
        #method_type = segs[0]
        #m = segs[1]
        method_type = METHOD_TYPE_BY_OPCODE[on]
        segs = m.rsplit("->", 1)
        
        #method_name = segs[1][:segs[1].find("(")]
        if method_type == "constructor":
            self.__add_stub_cons2(class_, m, registers)
        elif method_type == "instance":
            self.__add_stub_inst(class_, on, m, registers)
        elif method_type == "static":
            self.__add_stub_static(class_, m, registers)
            
            
    def _insert_lines(self, class_, method, lines, linenr=-1):
        #add some smali lines of code to method method in class class_ at line linenr (-1 means add it at the end)
        m = method
        for line in lines:
            instr = InsnNode(line)
            if linenr == -1:
                m.add_insn(instr)
            else:
                m.insert_insn(line, linenr, 0)
        
    def _add_method_from_file(self, on, m, class_, file, regs):
        """
        @param on: opcode name
        @param m: method descriptor (string); example: Lcom/test;->test()V
        @param class_: class of the new file (ClassNode)
        @param file: path to file with instructions
        @param regs: amount of registers of that method
        This is just a convenience method for me
        """
        segs = m.rsplit("->", 1)
        
        self._add_stub_method(on, m, class_, regs)
        method = class_.get_method(segs[1])
        
        f = open(file, "r")
        for line in f:
            if line.strip() != "":
                self._insert_lines(class_, method, [line.strip()])


    def __add_stub_inst(self, stub_class, on, m, regs=1):
        segs = m.rsplit("->", 1)

        method = MethodNode()
        method.set_desc(segs[1])
        method.add_para(TypeNode(segs[0]))
        method.add_access(["public", "static"])

        method.set_registers(regs)
        stub_class.add_method(method)

        i = m.find('(')
        self.method_map[m] = "L" + PKG_PREFIX + "/" + segs[0][1:] + "->" + \
                method.get_desc()


    def __add_stub_cons2(self, stub_class, m, regs=1):
        segs = m.rsplit("->", 1)
        desc = segs[1].replace("<init>", "droidbox_cons")
        i = desc.find(')')
        desc = desc[:i + 1] + 'V'
        method = MethodNode()
        method.set_desc(desc)
        method.add_access(["public", "static"])


        method.set_registers(regs)
        stub_class.add_method(method)

        i = m.find('(')
        self.method_map[m] = "L" + PKG_PREFIX + "/" + segs[0][1:] + "->" + \
                method.get_desc()

    def __add_stub_cons(self, stub_class, m, regs=1):
        segs = m.rsplit("->", 1)
        desc = segs[1].replace("<init>", "droidbox_cons")
        i = desc.find(')')
        desc = desc[:i + 1] + segs[0]
        method = MethodNode()
        method.set_desc(desc)
        method.add_access(["public", "static"])

        method.set_registers(regs)
        stub_class.add_method(method)

        i = m.find('(')
        self.method_map[m] = "L" + PKG_PREFIX + "/" + segs[0][1:] + "->" + \
                method.get_desc()

    def __add_stub_static(self, stub_class, m, regs=1):
        segs = m.rsplit("->", 1)

        method = MethodNode()
        method.set_desc(segs[1])
        method.add_access(["public", "static"])

        para_num = len(method.paras)
        reg_num = method.get_paras_reg_num()
        ri = 1

        method.set_registers(regs)
        stub_class.add_method(method)

        i = m.find('(')
        self.method_map[m] = "L" + PKG_PREFIX + "/" + segs[0][1:] + "->" + \
                method.get_desc()



