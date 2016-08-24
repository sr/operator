import sys
from ldif import LDIFParser,LDIFWriter

class MyLDIF(LDIFParser):
  def __init__(self,input,output):
    LDIFParser.__init__(self,input)
    self.writer = LDIFWriter(output)

  def handle(self, dn, entry):
    if 'sshPublicKey' in entry:
      del entry['sshPublicKey']
    if 'userPassword' in entry:
      del entry['userPassword']
    if 'pwdChangedTime' in entry:
      del entry['pwdChangedTime']
    if 'pwmEventLog' in entry:
      del entry['pwmEventLog']
    if 'pwdFailureTime' in entry:
      del entry['pwdFailureTime']
    if 'pwdInHistory' in entry:
      del entry['pwdInHistory']
    if 'pwdHistory' in entry:
      del entry['pwdHistory']
    if 'pwmLastPwdUpdate' in entry:
      del entry['pwmLastPwdUpdate']
    if 'pwmResponseSet' in entry:
      del entry['pwmResponseSet']
    if 'yubiKeyId' in entry:
      del entry['yubiKeyId']
    self.writer.unparse(dn, entry)

parser = MyLDIF(open(sys.argv[1], 'rb'), sys.stdout)
parser.parse()
