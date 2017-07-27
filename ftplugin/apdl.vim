function! AnsysHelpFF()
    let anscommand = toupper(expand('<cword>'))
    let g:anshelppath = '/opt/ansys130_updated/v130/commonfiles/help/en-us/help/ans_cmd/Hlp_C_'
    exec "Silent firefox ". anshelppath.anscommand.".html"
endfunction
noremap <F3> :call AnsysHelpFF()<CR>

function! AnsysHelp()
    let anscommand = expand('<cword>') 
    python << endpython
from HTMLParser import HTMLParser
import urllib2 as url
from os.path import expanduser
import glob
import vim

class htp(HTMLParser):
    def __init__(self):
        HTMLParser.__init__(self)
        self.flag=""    
        self.title=""
        self.syntax=""
        self.description=""
    def handle_starttag(self,tag,attrs):
        if tag=="div" or tag=="b": 
            attrs=dict(attrs)
            if len(attrs)>0:
                if attrs.get("class")=="refentrytitlehtml":
                    self.flag="title"
                elif attrs.get("class")=="refnamediv":
                    self.flag="syntax"
                elif attrs.get("class")=="refpurpose":
                    self.flag="description"
                else:
                    self.flag=""
    def handle_endtag(self,tag):
        if tag=="div" or tag=="b":
            self.flag=""
    def handle_data(self,data):
        if self.flag=="title":
            self.title=data.strip()
            self.flag=""
        elif self.flag=="syntax":
            self.syntax+=data.strip()
        elif self.flag=="description":
            self.description=data.strip()
    def output(self):
        return [self.title,self.syntax,self.description]

def PyAnsysHelp(command):
    command = command.upper()
    parser = htp()
    helplocprefix="/opt/ansys130_updated/v130/commonfiles/help/en-us/help/ans_cmd/Hlp_C_"
    helplocsuffix=".html"
    helploc=helplocprefix+command+"*"+helplocsuffix
    helpfiles=sorted(glob.glob(helploc))
    if len(helpfiles)>0:
        mypage = url.urlopen("file://"+helpfiles[0])
        mytext=mypage.read()
        parser.feed(mytext)
        parser.close()
        #print "\n".join(parser.output())
        helpfile = open(expanduser('~') + "/AnsysHelp.vim",'w')
        helpfile.write("\n".join(parser.output()))
        helpfile.close()
    else:
        #print "Help for " + command + " does not exist"
        helpfile = open(expanduser('~') + "/AnsysHelp.vim",'w')
        helpfile.write("Help for " + command + " does not exist")
        helpfile.close()
anscommand = vim.eval("anscommand")
PyAnsysHelp(anscommand)
endpython
set pvh=4
pedit ~/AnsysHelp.vim
endfunction

function! AnsysHelpLine()
    let curline = getline('.') 
    python << endpython2
from HTMLParser import HTMLParser
import urllib2 as url
import os.path
import glob
import vim

class htp(HTMLParser):
    def __init__(self):
        HTMLParser.__init__(self)
        self.flag=""    
        self.title=""
        self.syntax=""
        self.description=""
    def handle_starttag(self,tag,attrs):
        if tag=="div" or tag=="b": 
            attrs=dict(attrs)
            if len(attrs)>0:
                if attrs.get("class")=="refentrytitlehtml":
                    self.flag="title"
                elif attrs.get("class")=="refnamediv":
                    self.flag="syntax"
                elif attrs.get("class")=="refpurpose":
                    self.flag="description"
                else:
                    self.flag=""
    def handle_endtag(self,tag):
        if tag=="div" or tag=="b":
            self.flag=""
    def handle_data(self,data):
        if self.flag=="title":
            self.title=data.strip()
            self.flag=""
        elif self.flag=="syntax":
            self.syntax+=data.strip()
        elif self.flag=="description":
            self.description=data.strip()
    def output(self):
        return [self.title,self.syntax,self.description]

def PyAnsysHelp(command):
    command=command.upper()
    if command[0]=="/" or command[0]=="*":
        command=command[1:]
    parser = htp()
    helplocprefix="/opt/ansys130_updated/v130/commonfiles/help/en-us/help/ans_cmd/Hlp_C_"
    helplocsuffix=".html"
    helploc=helplocprefix+command+"*"+helplocsuffix
    helpfiles=sorted(glob.glob(helploc))
    if len(helpfiles)>0:
        mypage = url.urlopen("file://"+helpfiles[0])
        mytext=mypage.read()
        parser.feed(mytext)
        parser.close()
        return parser.output()
    else:
        return ["Does Not Exist","Help for " + command + " does not exist",""]
curline = vim.eval("curline")
search_text=curline.strip().split(",")
if search_text[0]!="":
    comhelp = PyAnsysHelp(search_text[0])
    arglist = comhelp[1].split(",")
    for i in range(len(arglist)):
        if i == len(search_text):
            arglist[i]="<"+arglist[i]+">"
    comhelp[1]=",".join(arglist)
    helpfile = open(expanduser('~') + "/AnsysHelp.vim",'w')
    helpfile.write("\n".join(comhelp))
    helpfile.close()
endpython2
set pvh=4
pedit ~/AnsysHelp.vim
endfunction
inoremap <F2> <ESC>:call AnsysHelp()<CR>a
noremap <F2> :call AnsysHelp()<CR>
