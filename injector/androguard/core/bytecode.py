# This file is part of Androguard.
#
# Copyright (C) 2012/2013, Anthony Desnos <desnos at t0t0.fr>
# All rights reserved.
#
# Androguard is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Androguard is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with Androguard.  If not, see <http://www.gnu.org/licenses/>.

import hashlib
from xml.sax.saxutils import escape
from struct import unpack, pack
import textwrap

from androconf import Color, warning, error, CONF, disable_colors, enable_colors, remove_colors, save_colors, color_range

def disable_print_colors() :
  colors = save_colors()
  remove_colors()
  return colors 

def enable_print_colors(colors) :
  enable_colors(colors)

# Handle exit message
def Exit( msg ):
    warning("Error : " + msg)
    raise("oops")

def Warning( msg ):
    warning(msg)

def _PrintBanner() :
    print_fct = CONF["PRINT_FCT"]
    print_fct("*" * 75 + "\n")

def _PrintSubBanner(title=None) :
  print_fct = CONF["PRINT_FCT"]
  if title == None :
    print_fct("#" * 20 + "\n")
  else :
    print_fct("#" * 10 + " " + title + "\n")

def _PrintNote(note, tab=0) :
  print_fct = CONF["PRINT_FCT"]
  note_color = CONF["COLORS"]["NOTE"]
  normal_color = CONF["COLORS"]["NORMAL"]
  print_fct("\t" * tab + "%s# %s%s" % (note_color, note, normal_color) + "\n")

# Print arg into a correct format
def _Print(name, arg) :
    buff = name + " "

    if type(arg).__name__ == 'int' :
        buff += "0x%x" % arg
    elif type(arg).__name__ == 'long' :
        buff += "0x%x" % arg
    elif type(arg).__name__ == 'str' :
        buff += "%s" % arg
    elif isinstance(arg, SV) :
        buff += "0x%x" % arg.get_value()
    elif isinstance(arg, SVs) :
        buff += arg.get_value().__str__()

    print buff

def PrettyShowEx( exceptions ) :
    if len(exceptions) > 0 :
        CONF["PRINT_FCT"]("Exceptions:\n")
        for i in exceptions : 
          CONF["PRINT_FCT"]("\t%s%s%s\n" % (CONF["COLORS"]["EXCEPTION"], i.show_buff(), CONF["COLORS"]["NORMAL"]))

def _PrintXRef(tag, items) :
  print_fct = CONF["PRINT_FCT"]
  for i in items :
    print_fct("%s: %s %s %s %s\n" % (tag, i[0].get_class_name(), i[0].get_name(), i[0].get_descriptor(), ' '.join("%x" % j.get_idx() for j in i[1])))

def _PrintDRef(tag, items) :
  print_fct = CONF["PRINT_FCT"]
  for i in items :
    print_fct( "%s: %s %s %s %s\n" % (tag, i[0].get_class_name(), i[0].get_name(), i[0].get_descriptor(), ' '.join("%x" % j for j in i[1]) ) )

def _PrintDefault(msg) :
  print_fct = CONF["PRINT_FCT"]
  print_fct(msg)

def PrettyShow(basic_blocks, notes={}):
    idx = 0
    nb = 0

    offset_color = CONF["COLORS"]["OFFSET"]
    offset_addr_color = CONF["COLORS"]["OFFSET_ADDR"]
    instruction_name_color = CONF["COLORS"]["INSTRUCTION_NAME"]
    branch_false_color = CONF["COLORS"]["BRANCH_FALSE"]
    branch_true_color = CONF["COLORS"]["BRANCH_TRUE"]
    branch_color = CONF["COLORS"]["BRANCH"]
    exception_color = CONF["COLORS"]["EXCEPTION"]
    bb_color = CONF["COLORS"]["BB"]
    normal_color = CONF["COLORS"]["NORMAL"]
    print_fct = CONF["PRINT_FCT"]

    for i in basic_blocks:
        print_fct("%s%s%s : \n" % (bb_color, i.name, normal_color))
        instructions = i.get_instructions()
        for ins in instructions:
        #for ins in i.ins :

            if nb in notes:
              for note in notes[nb]:
                _PrintNote(note, 1)

            print_fct("\t%s%-3d%s(%s%08x%s) " % (offset_color, nb, normal_color, offset_addr_color, idx, normal_color))
            print_fct("%s%-20s%s %s" % (instruction_name_color, ins.get_name(), normal_color, ins.get_output(idx)))

            op_value = ins.get_op_value()
            if ins == instructions[-1] and i.childs:
                print_fct(" ")

                # packed/sparse-switch
                if (op_value == 0x2b or op_value == 0x2c) and len(i.childs) > 1:
                      values = i.get_special_ins(idx).get_values()
                      print_fct("%s[ D:%s%s " % (branch_false_color, i.childs[0][2].name, branch_color))
                      print_fct(' '.join("%d:%s" % (values[j], i.childs[j + 1][2].name) for j in range(0, len(i.childs) - 1)) + " ]%s" % normal_color)
                else:
                    if len(i.childs) == 2:
                        print_fct("%s[ %s%s " % (branch_false_color, i.childs[0][2].name, branch_true_color))
                        print_fct(' '.join("%s" % c[2].name for c in i.childs[1:]) + " ]%s" % normal_color)
                    else:
                        print_fct("%s[ " % branch_color + ' '.join("%s" % c[2].name for c in i.childs) + " ]%s" % normal_color)

            idx += ins.get_length()
            nb += 1

            print_fct("\n")

        if i.get_exception_analysis():
          print_fct("\t%s%s%s\n" % (exception_color, i.exception_analysis.show_buff(), normal_color))

        print_fct("\n")


def method2dot(mx, tainted1=None, tainted2=None, tainted3=None, annotation=None, variables=None, variables_total=None, colors={}):
    """
        Export analysis method to dot format

        @param mx : MethodAnalysis object
        @param colors : MethodAnalysis object

        @rtype : dot format buffer (it is a subgraph (dict))
    """
    
    tainted1 = tainted1 or {}
    tainted2 = tainted2 or {}
    tainted3 = tainted3 or {}
    annotation = annotation or {}
    variables = variables or {}
    variables_total = variables_total or {}
    
    colors = colors or {"true_branch": "green",
                        "false_branch": "red",
                        "default_branch": "purple",
                        "jump_branch": "blue",
                        "bg_idx": "lightgray",
                        "idx": "blue",
                        "bg_start_idx": "yellow",
                        "bg_instruction": "lightgray",
                        "instruction_name": "black",
                        "instructions_operands": "yellow",

                        "raw": "red",
                        "string": "red",
                        "literal": "green",
                        "offset": "#4000FF",
                        "method": "#DF3A01",
                        "field": "#088A08",
                        "type": "#0000FF",

                        "registers_range": ("#999933", "#6666FF")
                        }

    node_tpl = "\nstruct_%s [label=<\n<TABLE BORDER=\"2\" CELLBORDER=\"0\" CELLSPACING=\"3\" >\n%s</TABLE>>];\n"#STYLE=\"ROUNDED\"
    #                                                                                                                               v first tainting stuff       v second tainting stuff                       v third tainting stuff                     v annotation             v variables    
    label_tpl = "<TR><TD ALIGN=\"LEFT\" BGCOLOR=\"%s\"> <FONT FACE=\"Times-Bold\" color=\"%s\">%x</FONT> </TD><TD ALIGN=\"RIGHT\" BGCOLOR=\"%s\"> %s </TD><TD ALIGN=\"RIGHT\" BGCOLOR=\"%s\"> %s </TD><TD ALIGN=\"RIGHT\" BGCOLOR=\"%s\"> %s </TD><TD ALIGN=\"RIGHT\"> %s </TD><TD ALIGN=\"LEFT\"> %s </TD><TD ALIGN=\"LEFT\" BGCOLOR=\"%s\"> <FONT FACE=\"Times-Bold\" color=\"%s\">%s </FONT> %s </TD></TR>\n"
    link_tpl = "<TR><TD PORT=\"%s\"></TD></TR>\n"

    edges_html = ""
    blocks_html = ""

    method = mx.get_method()
    sha256 = hashlib.sha256("%s%s%s" % (mx.get_method().get_class_name(), mx.get_method().get_name(), mx.get_method().get_descriptor())).hexdigest()

    registers = {}
    if method.get_code():
        for i in range(method.get_code().get_registers_size()):
            registers[i] = 0

    #for DVMBasicMethodBlock in mx.basic_blocks.gets():
    #    ins_idx = DVMBasicMethodBlock.start

        # loop over method instructions
    #    for DVMBasicMethodBlockInstruction in DVMBasicMethodBlock.get_instructions():
    #        operands = DVMBasicMethodBlockInstruction.get_operands(ins_idx)
    #        for register in operands:
    #            if register[0] == 0:
    #                if register[1] not in registers:
    #                    registers[register[1]] = 0
    #                registers[register[1]] += 1

    if registers:
        registers_colors = color_range(colors["registers_range"][0],
                                       colors["registers_range"][1],
                                       len(registers))
        for i in registers:
            registers[i] = registers_colors.pop(0)

    new_links = []
    
    params = []
    method_information = method.get_information()
    if method_information:
        if "params" in method_information:
            for register, _ in method_information["params"]:
                params.append('v'+str(register))

    for DVMBasicMethodBlock in mx.basic_blocks.gets():
        ins_idx = DVMBasicMethodBlock.start
        block_id = hashlib.md5(sha256 + DVMBasicMethodBlock.name).hexdigest()

        content = link_tpl % 'header'

        for DVMBasicMethodBlockInstruction in DVMBasicMethodBlock.get_instructions():
            if DVMBasicMethodBlockInstruction.get_op_value() == 0x2b or DVMBasicMethodBlockInstruction.get_op_value() == 0x2c:
                new_links.append((DVMBasicMethodBlock, ins_idx, DVMBasicMethodBlockInstruction.get_ref_off() * 2 + ins_idx))
            elif DVMBasicMethodBlockInstruction.get_op_value() == 0x26:
                new_links.append((DVMBasicMethodBlock, ins_idx, DVMBasicMethodBlockInstruction.get_ref_off() * 2 + ins_idx))

            operands = DVMBasicMethodBlockInstruction.get_operands(ins_idx)
            output = ", ".join(mx.get_vm().get_operand_html(i, registers, colors, escape, textwrap.wrap) for i in operands)
            
            if ins_idx in tainted1:
                output_tainted1 = ", ".join([i for i in tainted1[ins_idx][1] if i not in params])
                params_tainted1 = [i for i in tainted1[ins_idx][1] if i in params]
                if output_tainted1 and params_tainted1:
                    output_tainted1 += " | "
                if params_tainted1:
                    output_tainted1 += "<FONT color=\"red\">"+", ".join(params_tainted1)+"</FONT>"
            else:
                output_tainted1 = ''
            
            if ins_idx in tainted2:
                output_tainted2 = ", ".join([i for i in tainted2[ins_idx][1] if i not in params])
                params_tainted2 = [i for i in tainted2[ins_idx][1] if i in params]
                if output_tainted2 and params_tainted2:
                    output_tainted2 += " | "
                if params_tainted2:
                    output_tainted2 += "<FONT color=\"red\">"+", ".join(params_tainted2)+"</FONT>"
            else:
                output_tainted2 = ''
                
            if ins_idx in tainted3:
                output_tainted3 = ", ".join([i for i in tainted3[ins_idx][1] if i not in params])
                params_tainted3 = [i for i in tainted3[ins_idx][1] if i in params]
                if output_tainted3 and params_tainted3:
                    output_tainted3 += " | "
                if params_tainted3:
                    output_tainted3 += "<FONT color=\"red\">"+", ".join(params_tainted3)+"</FONT>"
            else:
                output_tainted3 = ''
                
            if ins_idx in annotation:
                temp = []
                for bla, lol in annotation[ins_idx].items():
                    temp.append("%s: %s" % (bla, ", ".join(lol)))
                output_annotation = "; ".join(temp)  
            else:
                output_annotation = ''
            
            if ins_idx in variables:
                output_variables = ", ".join(sorted(variables[ins_idx]))
            else:
                output_variables = ''

            formatted_operands = DVMBasicMethodBlockInstruction.get_formatted_operands()
            if formatted_operands:
                output += " ; %s" % str(formatted_operands)

            bg_idx = colors["bg_idx"]
            if ins_idx == 0 and "bg_start_idx" in colors:
                bg_idx = colors["bg_start_idx"]

            content += label_tpl % (bg_idx,
                                    colors["idx"],
                                    ins_idx,
                                    colors["bg_instruction"],
                                    output_tainted1,
                                    colors["bg_instruction"],
                                    output_tainted2,
                                    colors["bg_instruction"],
                                    output_tainted3,
                                    output_annotation,
                                    output_variables,
                                    colors["bg_instruction"],
                                    colors["instruction_name"],
                                    DVMBasicMethodBlockInstruction.get_name(),
                                    output)

            ins_idx += DVMBasicMethodBlockInstruction.get_length()
            last_instru = DVMBasicMethodBlockInstruction

        # all blocks from one method parsed
        # updating dot HTML content
        content += link_tpl % 'tail'
        blocks_html += node_tpl % (block_id, content)

        # Block edges color treatment (conditional branchs colors)
        val = colors["true_branch"]
        if len(DVMBasicMethodBlock.childs) > 1:
            val = colors["false_branch"]
        elif len(DVMBasicMethodBlock.childs) == 1:
            val = colors["jump_branch"]

        values = None
        if (last_instru.get_op_value() == 0x2b or last_instru.get_op_value() == 0x2c) and len(DVMBasicMethodBlock.childs) > 1:
            val = colors["default_branch"]
            values = ["default"]
            values.extend(DVMBasicMethodBlock.get_special_ins(ins_idx - last_instru.get_length()).get_values())

        # updating dot edges
        for DVMBasicMethodBlockChild in DVMBasicMethodBlock.childs:
            label_edge = ""

            if values:
                label_edge = values.pop(0)

            child_id = hashlib.md5(sha256 + DVMBasicMethodBlockChild[-1].name).hexdigest()
            edges_html += "struct_%s:tail -> struct_%s:header  [penwidth=\"2\",color=\"%s\", label=\"%s\"];\n" % (block_id, child_id, val, label_edge)
            # color switch
            if val == colors["false_branch"]:
                val = colors["true_branch"]
            elif val == colors["default_branch"]:
                val = colors["true_branch"]

        exception_analysis = DVMBasicMethodBlock.get_exception_analysis()
        if exception_analysis:
            for exception_elem in exception_analysis.exceptions:
                exception_block = exception_elem[-1]
                if exception_block:
                    exception_id = hashlib.md5(sha256 + exception_block.name).hexdigest()
                    edges_html += "struct_%s:tail -> struct_%s:header  [penwidth=\"2\",color=\"%s\", label=\"%s\"];\n" % (block_id, exception_id, "black", exception_elem[0])

    for link in new_links:
        DVMBasicMethodBlock = link[0]
        DVMBasicMethodBlockChild = mx.basic_blocks.get_basic_block(link[2])

        if DVMBasicMethodBlockChild:
            block_id = hashlib.md5(sha256 + DVMBasicMethodBlock.name).hexdigest()
            child_id = hashlib.md5(sha256 + DVMBasicMethodBlockChild.name).hexdigest()

            edges_html += "struct_%s:tail -> struct_%s:header  [penwidth=\"2\",color=\"%s\", label=\"data(0x%x) to @0x%x\", style=\"dashed\"];\n" % (block_id, child_id, "yellow", link[1], link[2])

    method_label = method.get_class_name() + "." + method.get_name() + "->" + method.get_descriptor()

    method_information = method.get_information()
    if method_information:
        method_label += "\\nLocal registers v%d ... v%d" % (method_information["registers"][0], method_information["registers"][1])
        if "params" in method_information:
            for register, rtype in method_information["params"]:
                method_label += "\\nparam v%d = %s" % (register, rtype)
        method_label += "\\nreturn = %s" % (method_information["return"])
        method_label += "\\nTypes:\\n"
        for k, v in variables_total.items():
            method_label += "%s: %s\\n" % (k, ", ".join(v))
        method_label += "\\nMarked at -1:"
        if tainted1.get(-1):
            method_label += "\\nBackward: %s" % ", ".join(tainted1.get(-1)[1])
        if tainted2.get(-1):
            method_label += "\\nForward: %s" %  ", ".join(tainted2.get(-1)[1])
        if tainted3.get(-1):
            method_label += "\\nCombined: %s" %  ", ".join(tainted3.get(-1)[1])

    return {'name': method_label,
            'nodes': blocks_html,
            'edges': edges_html}


def method2format(output, _format="png", mx=None, raw=None):
    """
        Export method to a specific file format

        @param output : output filename
        @param _format : format type (png, jpg ...) (default : png)
        @param mx : specify the MethodAnalysis object
        @param raw : use directly a dot raw buffer if None
    """
    try:
        import pydot
    except ImportError:
        error("module pydot not found")

    buff = "digraph {\n"
    buff += "graph [rankdir=TB]\n"
    buff += "node [shape=plaintext]\n"

    if raw:
        data = raw
    else:
        data = method2dot(mx)

    # subgraphs cluster
    buff += "subgraph cluster_" + hashlib.md5(output).hexdigest() + " {\nlabel=\"%s\"\n" % data['name']
    buff += data['nodes']
    buff += "}\n"

    # subgraphs edges
    buff += data['edges']
    buff += "}\n"

    #print buff
    d = pydot.graph_from_dot_data(buff)
    if d:
        getattr(d, "write_" + _format.lower())(output)

def method2format2( output, _format="png", mx = None, raw = False ):
    """
        Export method to a specific file format

        @param output : output filename
        @param _format : format type (png, jpg ...) (default : png)
        @param mx : specify the MethodAnalysis object
        @param raw : use directly a dot raw buffer
    """
    try:
        import pydot
    except ImportError:
        error("module pydot not found")

    buff = "digraph code {\n"
    buff += "graph [bgcolor=white];\n"
    buff += "node [color=lightgray, style=filled shape=box fontname=\"Courier\" fontsize=\"8\"];\n"

    if raw == False:
        buff += method2dot(mx)
    else:
        buff += raw

    buff += "}"

    d = pydot.graph_from_dot_data(buff)
    if d:
        getattr(d, "write_" + _format.lower())(output)


def method2png(output, mx, raw = False):
    """
        Export method to a png file format

        :param output: output filename
        :type output: string
        :param mx: specify the MethodAnalysis object
        :type mx: :class:`MethodAnalysis` object
        :param raw: use directly a dot raw buffer
        :type raw: string
    """
    buff = raw
    if raw == False :
        buff = method2dot( mx )

    method2format( output, "png", mx, buff )

def method2jpg( output, mx, raw = False ) :
    """
        Export method to a jpg file format

        :param output: output filename
        :type output: string
        :param mx: specify the MethodAnalysis object
        :type mx: :class:`MethodAnalysis` object
        :param raw: use directly a dot raw buffer (optional)
        :type raw: string
    """
    buff = raw
    if raw == False :
        buff = method2dot( mx )

    method2format( output, "jpg", mx, buff )

class SV :
    def __init__(self, size, buff) :
        self.__size = size
        self.__value = unpack(self.__size, buff)[0]

    def _get(self) :
        return pack(self.__size, self.__value)

    def __str__(self) :
        return "0x%x" % self.__value

    def __int__(self) :
        return self.__value

    def get_value_buff(self) :
        return self._get()

    def get_value(self) :
        return self.__value

    def set_value(self, attr) :
        self.__value = attr

class SVs :
    def __init__(self, size, ntuple, buff) :
        self.__size = size

        self.__value = ntuple._make( unpack( self.__size, buff ) )

    def _get(self) :
        l = []
        for i in self.__value._fields :
            l.append( getattr( self.__value, i ) )
        return pack( self.__size, *l)

    def _export(self) :
        return [ x for x in self.__value._fields ]

    def get_value_buff(self) :
        return self._get()

    def get_value(self) :
        return self.__value

    def set_value(self, attr) :
        self.__value = self.__value._replace( **attr )

    def __str__(self) :
        return self.__value.__str__()

def object_to_str(obj) :
    if isinstance(obj, str) :
        return obj
    elif isinstance(obj, bool) :
        return ""
    elif isinstance(obj, int) :
        return pack("<L", obj)
    elif obj == None :
        return ""
    else :
        #print type(obj), obj
        return obj.get_raw()

class MethodBC(object) :
    def show(self, value) :
        getattr(self, "show_" + value)()


class BuffHandle:
    def __init__(self, buff):
        self.__buff = buff
        self.__idx = 0

    def size(self):
        return len(self.__buff)

    def set_idx(self, idx):
        self.__idx = idx

    def get_idx(self):
        return self.__idx

    def readNullString(self, size):
        data = self.read(size)
        return data

    def read_b(self, size) :
        return self.__buff[ self.__idx : self.__idx + size ]

    def read_at(self, offset, size):
        return self.__buff[ offset : offset + size ]

    def read(self, size) :
        if isinstance(size, SV) :
            size = size.value

        buff = self.__buff[ self.__idx : self.__idx + size ]
        self.__idx += size

        return buff

    def end(self) :
        return self.__idx == len(self.__buff)

class Buff :
    def __init__(self, offset, buff) :
        self.offset = offset
        self.buff = buff

        self.size = len(buff)

class _Bytecode(object) :
    def __init__(self, buff) :
        try :
            import psyco
            psyco.full()
        except ImportError :
            pass

        self.__buff = buff
        self.__idx = 0

    def read(self, size) :
        if isinstance(size, SV) :
            size = size.value

        buff = self.__buff[ self.__idx : self.__idx + size ]
        self.__idx += size

        return buff

    def readat(self, off) :
        if isinstance(off, SV) :
            off = off.value

        return self.__buff[ off : ]

    def read_b(self, size) :
        return self.__buff[ self.__idx : self.__idx + size ]

    def set_idx(self, idx) :
        self.__idx = idx

    def get_idx(self) :
        return self.__idx

    def add_idx(self, idx) :
        self.__idx += idx

    def register(self, type_register, fct) :
        self.__registers[ type_register ].append( fct )

    def get_buff(self) :
        return self.__buff

    def length_buff(self) :
        return len( self.__buff )

    def set_buff(self, buff) :
        self.__buff = buff

    def save(self, filename) :
        fd = open(filename, "w")
        buff = self._save()
        fd.write( buff )
        fd.close()

def FormatClassToJava(input) :
    """
       Transoform a typical xml format class into java format

       :param input: the input class name
       :rtype: string
    """
    return "L" + input.replace(".", "/") + ";"

def FormatClassToPython(input) :
    i = input[:-1]
    i = i.replace("/", "_")
    i = i.replace("$", "_")

    return i

def FormatNameToPython(input) :
    i = input.replace("<", "")
    i = i.replace(">", "")
    i = i.replace("$", "_")

    return i

def FormatDescriptorToPython(input) :
    i = input.replace("/", "_")
    i = i.replace(";", "")
    i = i.replace("[", "")
    i = i.replace("(", "")
    i = i.replace(")", "")
    i = i.replace(" ", "")
    i = i.replace("$", "")

    return i

class Node:
 def __init__(self, n, s):
     self.id = n
     self.title = s
     self.children = []