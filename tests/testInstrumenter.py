import os
import unittest
import instrumenter

class InstrumentationTestcase(unittest.TestCase):
    def testLoadHooks(self):
        if len(instrumenter.instr_data)>=0:
            instrumenter.instr_data={}
        instrumenter.load_hooks(instrumenter.hook_file)
        assert len(instrumenter.instr_data)>0

    def testInstrumentation(self):
        filename = 'SkeletonApp.apk'
        instrumenter.main()
        assert os.path.exists(os.path.splitext(filename)[0]+'_new.apk')
