#!/usr/bin/env python
#============================================================================
# Copyright (c) Microsoft Corporation. All rights reserved. See license.txt for license information.
#============================================================================

import os
import sys
import tempfile
import re
import imp
protocol=imp.load_source('protocol','../protocol.py')

# [ClassVersion("1.0.0"), FriendlyName("nxFileLine")]
# class OMI_nxFileLine : OMI_BaseResource
# {
#        [key,required] string FilePath;
#        [write] string DoesNotContainPattern;
#        [write] string ContainsLine;
# };

def Set_Marshall(FilePath,DoesNotContainPattern,ContainsLine):
    if FilePath == None or len(FilePath) is 0:
        print("Error: 'FilePath' must be specified.\n", file=sys.stdout)
        return [-1]
    if (DoesNotContainPattern == None or len(DoesNotContainPattern)<1) and (ContainsLine == None or len(ContainsLine)<1) :
        print("Error: 'DoesNotContainPattern' or 'ContainsLine' must be specified.\n",file=sys.stdout)
        return [-1]
    retval = Set(FilePath,DoesNotContainPattern,ContainsLine)
    return retval

def Test_Marshall(FilePath,DoesNotContainPattern,ContainsLine):
    if FilePath == None or len(FilePath) is 0:
        print("Error: 'FilePath' must be specified.\n",file=sys.stdout)
        return [-1]
    if (DoesNotContainPattern == None or len(DoesNotContainPattern) is 0) and (ContainsLine == None or len(ContainsLine) is 0) :
        print("Error: 'DoesNotContainPattern' or 'ContainsLine' must be specified.\n",file=sys.stdout)
        return [-1]
    retval=Test(FilePath,DoesNotContainPattern,ContainsLine)
    return retval

def Get_Marshall(FilePath,DoesNotContainPattern,ContainsLine):
    arg_names=list(locals().keys())
    if FilePath == None or len(FilePath) is 0:
        print("Error: 'FilePath' must be specified.\n",file=sys.stdout)
        return [-1,FilePath,DoesNotContainPattern,ContainsLine]
    if (DoesNotContainPattern == None or len(DoesNotContainPattern) is 0) and (ContainsLine == None or len(ContainsLine) is 0) :
        print("Error: 'DoesNotContainPattern' or 'ContainsLine' must be specified.\n",file=sys.stdout)
        return [-1,FilePath,DoesNotContainPattern,ContainsLine]
    retval = 0
    (retval,FilePath,ContainsLine) = Get(FilePath,ContainsLine)
    FilePath = protocol.MI_String(FilePath)
    DoesNotContainPattern = protocol.MI_String(DoesNotContainPattern)
    ContainsLine = protocol.MI_String(ContainsLine)
    retd={}
    ld=locals()
    for k in arg_names :
        retd[k]=ld[k]     
    return retval, retd
            
def Set(FilePath,DoesNotContainPattern,ContainsLine):
    retval=[0]
    if not os.path.isfile(FilePath):
        print("Error: " + FilePath + " not found!\n",file=sys.stdout)
        return [-1]
    if DoesNotContainPattern != None and len(DoesNotContainPattern) > 0 and FindStringInFile(FilePath,DoesNotContainPattern) != None :
        if ReplaceStringInFile(FilePath,'^.*'+DoesNotContainPattern+'.*','') == False :
            print("Error calling ReplaceStringInFile\n",file=sys.stdout)
            retval=[-1]
    if ContainsLine != None and len(ContainsLine) > 0 and FindLiteralStringInFile(FilePath,ContainsLine) == False :
        if AppendStringToFile(FilePath,ContainsLine) == False :
            print("Error calling AppendStringToFile\n",file=sys.stdout)
            retval=[-1]
    return retval

def Test(FilePath,DoesNotContainPattern,ContainsLine):
    if not os.path.isfile(FilePath):
        print("Error: " + FilePath + " not found!\n",file=sys.stdout)
        return [-1]
    if DoesNotContainPattern != None and len(DoesNotContainPattern) > 0 and FindStringInFile(FilePath,DoesNotContainPattern) != None :
        return [-1]
    if ContainsLine != None and len(ContainsLine) > 0 and FindLiteralStringInFile(FilePath,ContainsLine) == False :
        return [-1]
    return [0]

def Get(FilePath,ContainsLine):
    if not os.path.isfile(FilePath):
        print("Error: " + FilePath + " not found!\n",file=sys.stdout)
        return 0,FilePath,ContainsLine
    if ContainsLine != None and len(ContainsLine) > 0:
        if FindLiteralStringInFile(FilePath,ContainsLine) == False :
            ContainsLine=''
        print("Get returned " + ContainsLine,file=sys.stdout)
    return 0,FilePath,ContainsLine


def FindStringInFile(fname,matchs,multiline=False):
    """
    Single line: return match object if found in file.
    Multi line: return list of matches found in file.
    """
    print("%s %s %s"%(fname,matchs,multiline),file=sys.stderr)
    m=None
    try:
        ms=re.compile(matchs)
        if multiline:
            with (open(fname,'r')) as F:  
                l = F.read()
                m=re.findall(ms,l)
        else:
            with (open(fname,'r')) as F:  
                for l in F:
                    m=re.search(ms,l)
                    if m:
                        break
    except:
        raise
    return m

def FindLiteralStringInFile(fname,matchs):
    with (open(fname,'r')) as F:  
        for l in F:
            if matchs == l.strip('\n'):
                return True
    return False

def ReplaceStringInFile(fname,src,repl):
    """
    Replace 'src' with 'repl' in file.
    """
    updated=''
    try:
        sr=re.compile(src)
        if FindStringInFile(fname,src):
            for l in (open(fname,'r')):
                n=re.sub(sr,repl,l)
                if len(n)>2:
                    updated+=n
            ReplaceFileContentsAtomic(fname,updated)
            return True
    except :
        raise
    return False

def AppendStringToFile(fname,s):
    with (open(fname,'a')) as F:
        F.write(s)
        if s[-1] != '\n' :
            F.write('\n')
        F.close()
    return True

def ReplaceFileContentsAtomic(filepath, contents):
    """
    Write 'contents' to 'filepath' by creating a temp file, and replacing original.
    """
    handle, temp = tempfile.mkstemp(dir = os.path.dirname(filepath))
    if type(contents) == str :
        contents=contents.encode('latin-1')
    try:
        os.write(handle, contents)
    except IOError as e:
        print('ReplaceFileContentsAtomic','Writing to file ' + filepath + ' Exception is ' + str(e),file=sys.stderr)
        return None
    finally:
        os.close(handle)
    try:
        os.rename(temp, filepath)
        return None
    except IOError as e:
        print('ReplaceFileContentsAtomic','Renaming ' + temp+ ' to ' + filepath + ' Exception is ' +str(e),file=sys.stderr)
    try:
        os.remove(filepath)
    except IOError as e:
        print('ReplaceFileContentsAtomic','Removing '+ filepath + ' Exception is ' +str(e),file=sys.stderr)
    try:
        os.rename(temp,filepath)
    except IOError as e:
        print('ReplaceFileContentsAtomic','Removing '+ filepath + ' Exception is ' +str(e),file=sys.stderr)
        return 1
    return 0
