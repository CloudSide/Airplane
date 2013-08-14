#!/usr/bin/python

import sys
import os
import glob
import zlib
import struct

MAGIC_CRYPT_START = 0x01;
MAGIC_COMPRESS_CRYPT_START = 0x02;
MAGIC_END  = 0x00;
BASE_KEY  = 0xCC;

def IsGoodLogBuffer(_buffer, _offset, count):
	
	if _offset == len(_buffer): return True;
	if _offset + 1 + 4 + 1 + 1 > len(_buffer): return False
		
	if MAGIC_CRYPT_START!=_buffer[_offset] and MAGIC_COMPRESS_CRYPT_START!=_buffer[_offset]: return False
	
	length = struct.unpack_from("I", buffer(_buffer, _offset+1, 4))[0]	
	if _offset + 1 + 4 + length + 1 > len(_buffer): return False
	if MAGIC_END!=_buffer[_offset + 1 + 4 + length]: return False
	
	if (1>=count): return True
	else: return IsGoodLogBuffer(_buffer, _offset+1+4+length+1, count-1)
		
	
def GetLogStartPos(_buffer):
	offset = 0
	while True:
		if offset >= len(_buffer) : break
		
		if MAGIC_CRYPT_START==_buffer[offset] or MAGIC_COMPRESS_CRYPT_START==_buffer[offset]:
			if IsGoodLogBuffer(_buffer, offset, 2): return offset
		offset+=1
		
	return -1	
	
def DecodeBuffer(_buffer, _offset, _outbuffer):
	
	if _offset == len(_buffer): return -1;
	if not IsGoodLogBuffer(_buffer, _offset, 1): return -1
	iscompress = False	
	if MAGIC_COMPRESS_CRYPT_START==_buffer[_offset]: iscompress = True
	length = struct.unpack_from("I", buffer(_buffer, _offset+1, 4))[0]	
	if iscompress:
		key = BASE_KEY ^ (0xff & length) ^ MAGIC_COMPRESS_CRYPT_START
	else:
		key = BASE_KEY ^ (0xff & length) ^ MAGIC_CRYPT_START
		
	tmpbuffer = bytearray(length)
	for i in range(length):
		tmpbuffer[i] = key ^ _buffer[_offset+1+4+i]
		
	if iscompress: tmpbuffer = zlib.decompress(str(tmpbuffer))
	for i in tmpbuffer: _outbuffer.append(i)
	
	return _offset+1+4+length+1


def ParseFile(_file, _outfile):
	fp = open(_file, "rb")
	_buffer = bytearray(os.path.getsize(_file))
	fp.readinto(_buffer)
	fp.close()
	startpos = GetLogStartPos(_buffer)
	if -1==startpos:
		return
	
	outbuffer = bytearray()
	
	while True:
		startpos = DecodeBuffer(_buffer, startpos, outbuffer)
		if -1==startpos: break;
	
	if 0==len(outbuffer): return
	
	fpout = open(_outfile, "wb")
	fpout.write(outbuffer)
	fpout.close()
	
def main(args):
	if 2!=len(args):
		filelist = glob.glob("*.xlog")
		for filepath in filelist:
			ParseFile(filepath, filepath+".log")	
	else: 
		ParseFile(args[0], args[1])	

if __name__ == "__main__":
    main(sys.argv[1:])
