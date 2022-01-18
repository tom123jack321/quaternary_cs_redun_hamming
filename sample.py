#!/usr/bin/env python3
##!/usr/bin/env python2
# Sample script for python users to use quaternary checksum, redundancy and their combination as well as quaternary Hamming code. Works for both python2 and python3.

import subprocess
import re
#mark a#

#mark b#
## type                   | input data
# encode_q_cs             | a string
# is_intact_q_cs          | a string
# decode_q_cs             | string, string
# encode_q_redun          | array of strings 
# is_intact_q_redun       | array of strings
# decode_q_redun          | array of strings, string, string
# encode_comb_q_cs_redun  | array of strings
# decode_comb_q_cs_redun  | array of strings, string 
# encode_q_hamming        | a string
# decode_q_hamming        | a string

print('================================================')
print('Encoding algorithm of quaternary checksum')
if 'result' in locals():
  del result
if 'string' in locals(): 
  del string 
# Encode the input data with quaternary checksum prepended
type = "encode_q_cs"    
data = "200131233101231"    # change this as necessary
print( 'type   ', type)
print( 'data   ', data)
cmd = ["./lib/QEDC_py.pl", type, data]
pipe = subprocess.Popen(cmd, stdout = subprocess.PIPE)
result = pipe.stdout.read()
encoded_data = result.decode('UTF-8')   # 3200131233101231
print( 'encoded_data   ', encoded_data)   

print('================================================')
print('Detect the occurence of errors using quaternary checksum')
if 'result' in locals():
  del result
if 'string' in locals(): 
  del string 
# Check whether the encoded data is correct, of which the first number is quaternary checksum
# data : the encoded data
# 1 : intact
# 0 : erroneous
type = "is_intact_q_cs"    
data = "3200131233101231"    # change this as necessary
print( 'type   ', type)
print( 'data   ', data)
cmd = ["./lib/QEDC_py.pl", type, data]
pipe = subprocess.Popen(cmd, stdout = subprocess.PIPE)
result = pipe.stdout.read()
is_correct = result.decode('UTF-8')   
print( 'is_correct   ', is_correct)

print('================================================')
print('Decoding algorithm of quaternary checksum')
if 'result' in locals():
  del result
if 'string' in locals(): 
  del string 
# data : the encoded data, of which the first number is quaternary checksum and the (q+1)th number is erroneous (counting from 1), q > 1
type = "decode_q_cs"
# change this as necessary
data = "3210131233101231"   # the third number is erroneous
q = "2"   # the data type should be string
print( 'type   ', type)
print( 'data   ', data)
print( 'q   ', q)
cmd = ["./lib/QEDC_py.pl", type, data, q]
pipe = subprocess.Popen(cmd, stdout = subprocess.PIPE)
result = pipe.stdout.read()
string = result.decode('UTF-8')   
decoded_data = string
print( 'decoded_data   ', decoded_data)

print('================================================')
print('Encoding algorithm of quaternary redundancy')
if 'result' in locals():
  del result
if 'string' in locals(): 
  del string 
type = "encode_q_redun"   
data = ['0123', '22301', '3011032']   # change this as necessary
data = ' '.join(data)   # "0123 22301 3011032"
print( 'type   ', type)
print( 'data   ', data)
cmd = ["./lib/QEDC_py.pl", type, data]
pipe = subprocess.Popen(cmd, stdout = subprocess.PIPE)
result = pipe.stdout.read()
string = result.decode('UTF-8')
regex = r'(\d+)'
encoded_data = re.findall(regex, string)
print( 'encoded_data   ', encoded_data)
redun = encoded_data[-1]
print( 'redun   ', redun)

print('================================================')
print('Detect the occurence of errors using quaternary redundancy')
if 'result' in locals():
  del result
if 'string' in locals(): 
  del string 
# 1 : intact
# 0 : erroneous
type = "is_intact_q_redun"   
data = ['0123', '22301', '3011032', '1320132']    # intact, return "1"
# data = ['0123', '101', '3011032', '1320132']      # erroneous, return "0"
data = ' '.join(data)
print( 'type   ', type)
print( 'data   ', data)
cmd = ["./lib/QEDC_py.pl", type, data]
pipe = subprocess.Popen(cmd, stdout = subprocess.PIPE)
result = pipe.stdout.read()
is_correct = result.decode('UTF-8')
print( 'is_correct   ', is_correct)

print('================================================')
print('Decoding algorithm of quaternary redundancy')
if 'result' in locals():
  del result
if 'string' in locals(): 
  del string 
type = "decode_q_redun"   
# The correct encoded data is ['0123', '22301', '3011032', '1320132']
# After decoding : ['0123', '22301', '3011032']
data = ['0123', '101', '3011032', '1320132']      # change this as necessary
q = '2'
nq = '5'
data = ' '.join(data)     # "0123 101 3011032 1320132"
print( 'type   ', type)
print( 'data   ', data)
print( 'nq   ', nq)
cmd = ["./lib/QEDC_py.pl", type, data, q, nq]
pipe = subprocess.Popen(cmd, stdout = subprocess.PIPE)
result = pipe.stdout.read()
string = result.decode('UTF-8')
regex = r'(\d+)'
decoded_data = re.findall(regex, string)
print( 'decoded_data   ', decoded_data)

print('================================================')
print('Encoding algorithm of the combination of quaternary checksum and redundancy')
print('Example 1, for sequences of possibly different length')
if 'result' in locals():
  del result
if 'string' in locals(): 
  del string 
type = "encode_comb_q_cs_redun"   
data = ["01223", "123", "033201"]    # change this as necessary
data = ' '.join(data)   
print( 'type   ', type)
print( 'data   ', data)
cmd = ["./lib/QEDC_py.pl", type, data]
pipe = subprocess.Popen(cmd, stdout = subprocess.PIPE)
result = pipe.stdout.read()
string = result.decode('UTF-8')
regex = r'(\d+)'
encoded_data = re.findall(regex, string)
print( 'encoded_data   ', encoded_data)

print('================================================')
print('Decoding algorithm of the combination of quaternary checksum and redundancy')
print('Example 1, for sequences of possibly different length')
if 'result' in locals():
  del result
if 'string' in locals(): 
  del string 
type = "decode_comb_q_cs_redun"   
# change data as necessary
data = ["001223", "2123", "1033201", "3120031"];   # intact
data = ["001", "2123", "1033201", "3120031"];   # erroneous
data = ' '.join(data)
nq = "5"
print( 'type   ', type)
print( 'data   ', data)
print( 'nq   ', nq)
cmd = ["./lib/QEDC_py.pl", type, data, nq]
pipe = subprocess.Popen(cmd, stdout = subprocess.PIPE)
result = pipe.stdout.read()
string = result.decode('UTF-8')
print( 'string   ', string)
regex = r'(\d+)'
decoded_data = re.findall(regex, string)
print( 'decoded_data   ', decoded_data)

print('================================================')
print('Encoding algorithm of the combination of quaternary checksum and redundancy')
print('Example 2, for sequences of the same length ')
if 'result' in locals():
  del result
if 'string' in locals(): 
  del string 
type = "encode_comb_q_cs_redun"   
data = ["01223", "12300", "03320"]   # change this as necessary
data = ' '.join(data)   
print( 'type   ', type)
print( 'data   ', data)
cmd = ["./lib/QEDC_py.pl", type, data]
pipe = subprocess.Popen(cmd, stdout = subprocess.PIPE)
result = pipe.stdout.read()
string = result.decode('UTF-8')
regex = r'(\d+)'
encoded_data = re.findall(regex, string)
print( 'encoded_data   ', encoded_data)

print('================================================')
print('Decoding algorithm of the combination of quaternary checksum and redundancy')
print('Example 2, for sequences of the same length')
if 'result' in locals():
  del result
if 'string' in locals(): 
  del string 
type = "decode_comb_q_cs_redun"   
# change data as necessary
# data = ["001223", "212300", "003320", "212003"];   # intact
data = ["001", "212300", "003320", "212003"];   # erroneous
data = ' '.join(data)
nq = "5"
print( 'type   ', type)
print( 'data   ', data)
print( 'nq   ', nq)
cmd = ["./lib/QEDC_py.pl", type, data, nq]
pipe = subprocess.Popen(cmd, stdout = subprocess.PIPE)
result = pipe.stdout.read()
string = result.decode('UTF-8')
print( 'string   ', string)
regex = r'(\d+)'
decoded_data = re.findall(regex, string)
print( 'decoded_data   ', decoded_data)

print('================================================')
print('Encoding algorithm of quaternary Hamming code')
if 'result' in locals():
  del result
if 'string' in locals(): 
  del string 
type = "encode_q_hamming"   
data = "01232311010"   # change this as necessary
print( 'type   ', type)
print( 'data   ', data)
cmd = ["./lib/QEDC_py.pl", type, data]
pipe = subprocess.Popen(cmd, stdout = subprocess.PIPE)
result = pipe.stdout.read()
encoded_data = result.decode('UTF-8')
print( 'encoded_data   ', encoded_data)

print('================================================')
print('Decoding algorithm of quaternary Hamming code')
if 'result' in locals():
  del result
if 'string' in locals(): 
  del string 
type = "decode_q_hamming"   
data = "320012302311010"   # change this as necessary
print( 'type   ', type)
print( 'data   ', data)
cmd = ["./lib/QEDC_py.pl", type, data]
pipe = subprocess.Popen(cmd, stdout = subprocess.PIPE)
result = pipe.stdout.read()
decoded_data = result.decode('UTF-8')
print( 'decoded_data   ', decoded_data)
