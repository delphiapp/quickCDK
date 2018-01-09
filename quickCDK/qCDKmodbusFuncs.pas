unit qCDKmodbusFuncs;

interface

uses qCDKclasses,qCDKmodbusTypes,qCDKmodbusClasses,uProgresses;

  // Modbus-������ �� �������������� � ������
  function mbGetErrorStr(me:integer):AnsiString;

  // Modbus-���������� � ������  
  function mbExceptionToString(const me:byte):AnsiString;

  // Modbus-������� � ������  
  function mbFunctionToString(const mf:byte):AnsiString;

////////// ������� ��� ������ �� Modbus-���������
// cb:TTransactionWaitCallBack - ��������� ��������� ������ ��� ����������� �������� � � ����������
// pcc:TProgressCallBack - ������� ��������� ������ ��� �������������� � ��������� ��������
  // ���������� mbReadBuffer_Sync
  function mbReadBuffer(cd:TModbusDevice; arrPacket:array of Int64; pDst:pointer=nil; iDstSize:integer=0):integer;
  // ������ ���������� � ����� Dst �������� iDstSize
  function mbReadBuffer_Sync(cd:TModbusDevice; arrPacket:array of Int64; pDst:pointer=nil; iDstSize:integer=0):integer;
  // ������ ����������� � ����� Dst �������� iDstSize
  function mbReadBuffer_Async(cd:TModbusDevice; arrPacket:array of Int64; pDst:pointer=nil; iDstSize:integer=0; cb:TTransactionWaitCallBack=nil):integer;

  // ���������� mbWriteBuffer_Sync
  function mbWriteBuffer(cd:TModbusDevice; arrPacket:array of Int64; pDst:pointer=nil; iDstSize:integer=0):integer;
  // ������ ���������� � ������� � ����� pDst �������� iDstSize
  function mbWriteBuffer_Sync(cd:TModbusDevice; arrPacket:array of Int64; pDst:pointer=nil; iDstSize:integer=0):integer;
  // ������ ����������� � ������� � ����� pDst �������� iDstSize
  function mbWriteBuffer_Async(cd:TModbusDevice; arrPacket:array of Int64; pDst:pointer=nil; iDstSize:integer=0; cb:TTransactionWaitCallBack=nil):integer;

  // ������ ������������ ����� ������, �� ������� �������� �� ����������� ����� ������ ������ � 255 ����
  function mbReadDataBlock(cd:TModbusDevice; wOrgAddr:word; pDst:pointer; iBytes:integer; {mf:TModbusFunction=mfReadHoldingRegisters;}
    pcc:TProgressCallBack=nil; PID:pointer=nil):integer;

  // ������ ������������ ����� ������, �� ������� �������� �� ����������� ����� ������ ������ � 255 ����
  function mbWriteDataBlock(cd:TModbusDevice; wOrgAddr:word; pSrc:pointer; iBytes:integer; {mf:TModbusFunction=mfWriteMultipleRegisters;}
    pcc:TProgressCallBack=nil; PID:pointer=nil):integer;

  // ������ ������������ ����� ������ �� �����, �� ������� �������� �� ����������� ����� ������ ������ � 255 ����
  function mbReadFileDataBlock(cd:TModbusDevice; wFileNum,wOrgAddr:word; pDst:pointer; iBytes:integer;
    pcc:TProgressCallBack=nil; PID:pointer=nil):integer;

  // ������ ������������ ����� ������ � ����, �� ������� �������� �� ����������� ����� ������ ������ � 255 ����
  function mbWriteFileDataBlock(cd:TModbusDevice; wFileNum,wOrgAddr:word; pSrc:pointer; iBytes:integer;
    pcc:TProgressCallBack=nil; PID:pointer=nil):integer;

////////// ������� ��� ������ �� Modbus-��������� ��� ��������� ����
  // ������ ����������������� ����� ���������� ����
  function mbReadIniFile(cd:TModbusDevice; out sFileName,sFileText:AnsiString;
    pcc:TProgressCallBack=nil; PID:pointer=nil):integer;

  // ������ LD-����� ���������� ����
  function mbReadLDFile(cd:TModbusDevice; out sFileName,sFileText:AnsiString;
    pcc:TProgressCallBack=nil; PID:pointer=nil):integer;

  // ������ LD-����� ���������� ����
  function mbWriteLDFile(cd:TModbusDevice; sFileName,sFileText:AnsiString;
    pcc:TProgressCallBack=nil; PID:pointer=nil):integer;

  // ������ ������������ ����� ������ �������������
  function mbReadScopeDataBlock(cd:TModbusDevice; wOrgAddr:word; pDst:pointer; iRecs,iRecSize:integer;
    pcc:TProgressCallBack=nil; PID:pointer=nil):integer;

implementation

uses Windows,Classes,SysUtils,uUtilsFunctions;

{$BOOLEVAL OFF}
{$RANGECHECKS OFF}
{$OVERFLOWCHECKS OFF}

const iMaxBufferSize=255; // ������ ������ 

////////// ������� ��� ������ �� Modbus-���������

  // ������� ��������� ������ �� ��������� ��� ����������� ������� �������, ���-�� ����� ������� ������� ��������� ������ ��� ��������� ��� �� ����������
  procedure DefaultWaitCallback(id:integer; td:TTransactionData); stdcall;
  begin try td.Free; except end; end; // ���������� ���������� ��������� "������ ����������"

  // Modbus-������ �� �������������� � ������
  function mbGetErrorStr(me:integer):AnsiString;
  begin if not IntToIdent(me,Result,ModbusErrorsInfos)then Result:=GetErrorStr(me); end;

  // Modbus-���������� � ������
  function mbExceptionToString(const me:byte):AnsiString; var s:AnsiString; begin
    if not IntToIdent(me,s,ModbusExceptionsInfos)then s:='�������������������� ����������';
    Result:='0x'+IntToHex(me,2)+' - '+s;
  end;

  // Modbus-������� � ������
  function mbFunctionToString(const mf:byte):AnsiString; var s:AnsiString; begin
    if not IntToIdent(mf and$7F,s,ModbusFuncsInfos)then s:='����������� �������';
    Result:='0x'+IntToHex(mf,2)+' - '+s; if(mf and$80)<>0then Result:=Result+' (����������)';
  end;

  // ���������� ������
  function mbReadBuffer(cd:TModbusDevice; arrPacket:array of Int64; pDst:pointer=nil; iDstSize:integer=0):integer;
  begin Result:=comDoWait(cd,arrPacket,pDst,iDstSize); end;

  // ���������� ������
  function mbReadBuffer_Sync(cd:TModbusDevice; arrPacket:array of Int64; pDst:pointer=nil; iDstSize:integer=0):integer;
  begin Result:=comDoWait(cd,arrPacket,pDst,iDstSize); end;

  // ����������� ������
  function mbReadBuffer_Async(cd:TModbusDevice; arrPacket:array of Int64; pDst:pointer=nil; iDstSize:integer=0; cb:TTransactionWaitCallBack=nil):integer;
  begin if@cb=nil then cb:=@DefaultWaitCallBack; Result:=comDoWait(cd,arrPacket,pDst,iDstSize,cb); end;

  // ���������� ������
  function mbWriteBuffer(cd:TModbusDevice; arrPacket:array of Int64; pDst:pointer=nil; iDstSize:integer=0):integer;
  begin Result:=comDoWait(cd,arrPacket,pDst,iDstSize); end;

  // ���������� ������
  function mbWriteBuffer_Sync(cd:TModbusDevice; arrPacket:array of Int64; pDst:pointer=nil; iDstSize:integer=0):integer;
  begin Result:=comDoWait(cd,arrPacket,pDst,iDstSize); end;

  // ����������� ������
  function mbWriteBuffer_Async(cd:TModbusDevice; arrPacket:array of Int64; pDst:pointer=nil; iDstSize:integer=0; cb:TTransactionWaitCallBack=nil):integer;
  begin if@cb=nil then cb:=@DefaultWaitCallBack; Result:=comDoWait(cd,arrPacket,pDst,iDstSize,cb); end;

  // ������ ������������ ����� ������
  function mbReadDataBlock(cd:TModbusDevice; wOrgAddr:word; pDst:pointer; iBytes:integer; {mf:TModbusFunction=mfReadHoldingRegisters;}
    pcc:TProgressCallBack=nil; PID:pointer=nil):integer;
  var iBytesLeft,iOffs,iBytesToRead:integer; pBuf:PAnsiChar; tc:longword;
    function DoProgress(const lwCurrentProgress,lwTimeEllapsed:LongWord; ps:TProgressState):boolean;
    begin Result:=(@pcc=nil)or pcc(PID,LongWord(PID),0,lwCurrentProgress,iBytes,lwTimeEllapsed,'',ps); end;
  begin Result:=ceUnknownError; if iBytes<=0then begin Result:=ceNoTransactionData; exit; end;
    try try iBytesLeft:=iBytes; tc:=GetTickCount;
      if not DoProgress(0,0,psOpened)then begin Result:=ceAbortOperation; exit; end;
      while iBytesLeft>0do begin iOffs:=iBytes-iBytesLeft; pBuf:=pAnsiChar(pDst)+iOffs;
        iBytesToRead:=(iMaxBufferSize-7)and$FE; if iBytesLeft<iBytesToRead then iBytesToRead:=iBytesLeft;
        Result:=mbReadBuffer(cd,[cd.Address,mfReadHoldingRegisters,wOrgAddr+iOffs shr 1,(iBytesToRead+1)shr 1],pBuf,iBytesToRead);
        dec(iBytesLeft,iBytesToRead); if Result<>meSuccess then break;
        if not DoProgress(iBytes-iBytesLeft,GetTickCount-tc,psWorking)then begin Result:=ceAbortOperation; exit; end;
      end;
    finally DoProgress(0,0,psClosed); end; except Result:=ceSysException; end;
  end;

    // ������ ������������ ����� ������
  function mbWriteDataBlock(cd:TModbusDevice; wOrgAddr:word; pSrc:pointer; iBytes:integer; {mf:TModbusFunction=mfWriteMultipleRegisters;}
    pcc:TProgressCallBack=nil; PID:pointer=nil):integer;
  var iBytesLeft,iOffs,iBytesToWrite,n:integer; pBuf:PAnsiChar; tc:longword; arr:array of Int64;
    function DoProgress(const lwCurrentProgress,lwTimeEllapsed:LongWord; ps:TProgressState):boolean;
    begin Result:=(@pcc=nil)or pcc(PID,LongWord(PID),0,lwCurrentProgress,iBytes,lwTimeEllapsed,'',ps); end;
  begin Result:=ceUnknownError; if iBytes<=0then begin Result:=ceNoTransactionData; exit; end;
    try try iBytesLeft:=iBytes; tc:=GetTickCount;
      if not DoProgress(0,0,psOpened)then begin Result:=ceAbortOperation; exit; end;
      while iBytesLeft>0do begin iOffs:=iBytes-iBytesLeft; pBuf:=pAnsiChar(pSrc)+iOffs;
        iBytesToWrite:=(iMaxBufferSize-11)and$FE; if iBytesLeft<iBytesToWrite then iBytesToWrite:=iBytesLeft;
        SetLength(arr,(iBytesToWrite+1)shr 1+5);
        arr[0]:=cd.Address; arr[1]:=mfWriteMultipleRegisters; arr[2]:=wOrgAddr+iOffs shr 1; arr[3]:=(iBytesToWrite+1)shr 1; arr[4]:=iBytesToWrite;
        for n:=0to(iBytesToWrite+1)shr 1-1do arr[5+n]:=psmallint(longword(pBuf)+longword(n)shl 1)^;
        Result:=mbWriteBuffer(cd,arr,nil,0);
        dec(iBytesLeft,iBytesToWrite); if Result<>meSuccess then break;
        if not DoProgress(iBytes-iBytesLeft,GetTickCount-tc,psWorking)then begin Result:=ceAbortOperation; exit; end;
      end;
    finally DoProgress(0,0,psClosed); end; except Result:=ceSysException; end;
  end;

  // ������ ������������ ����� ������ �� �����                                                       
  function mbReadFileDataBlock(cd:TModbusDevice; wFileNum,wOrgAddr:word; pDst:pointer; iBytes:integer;
    pcc:TProgressCallBack=nil; PID:pointer=nil):integer;
  var iBytesLeft,iOffs,iBytesToRead:integer; pBuf:PAnsiChar; tc:longword;
    function DoProgress(const lwCurrentProgress,lwTimeEllapsed:LongWord; ps:TProgressState):boolean;
    begin Result:=(@pcc=nil)or pcc(PID,LongWord(PID),0,lwCurrentProgress,iBytes,lwTimeEllapsed,'',ps); end;
  begin Result:=ceUnknownError; if iBytes<=0then begin Result:=ceNoTransactionData; exit; end;
    try try iBytesLeft:=iBytes; tc:=GetTickCount;
      if not DoProgress(0,0,psOpened)then begin Result:=ceAbortOperation; exit; end;
      while iBytesLeft>0do begin iOffs:=iBytes-iBytesLeft; pBuf:=pAnsiChar(pDst)+iOffs;
        iBytesToRead:=(iMaxBufferSize-7{9})and$FE; if iBytesLeft<iBytesToRead then iBytesToRead:=iBytesLeft;
        Result:=mbReadBuffer(cd,[cd.Address,mfReadFileRecord,7,6,wFileNum,wOrgAddr+iOffs shr 1,(iBytesToRead+1)shr 1],pBuf,iBytesToRead);
        dec(iBytesLeft,iBytesToRead); if Result<>meSuccess then break;
        if not DoProgress(iBytes-iBytesLeft,GetTickCount-tc,psWorking)then begin Result:=ceAbortOperation; exit; end;
      end;
    finally DoProgress(0,0,psClosed); end; except Result:=ceSysException; end;
  end;

  // ������ ������������ ����� ������ � ����
  function mbWriteFileDataBlock(cd:TModbusDevice; wFileNum,wOrgAddr:word; pSrc:pointer; iBytes:integer;
    pcc:TProgressCallBack=nil; PID:pointer=nil):integer;
  var iBytesLeft,iOffs,iBytesToWrite,n:integer; pBuf:PAnsiChar; tc:longword; arr:array of Int64;
    function DoProgress(const lwCurrentProgress,lwTimeEllapsed:LongWord; ps:TProgressState):boolean;
    begin Result:=(@pcc=nil)or pcc(PID,LongWord(PID),0,lwCurrentProgress,iBytes,lwTimeEllapsed,'',ps); end;
  begin Result:=ceUnknownError; if iBytes<=0then begin Result:=ceNoTransactionData; exit; end;
    try try iBytesLeft:=iBytes; tc:=GetTickCount;
      if not DoProgress(0,0,psOpened)then begin Result:=ceAbortOperation; exit; end;
      while iBytesLeft>0do begin iOffs:=iBytes-iBytesLeft; pBuf:=pAnsiChar(pSrc)+iOffs;
        iBytesToWrite:=(iMaxBufferSize-14)and$FE; if iBytesLeft<iBytesToWrite then iBytesToWrite:=iBytesLeft;
        SetLength(arr,(iBytesToWrite+1)shr 1+7);
        arr[0]:=cd.Address; arr[1]:=mfWriteFileRecord; arr[2]:=7+((iBytesToWrite+1)shr 1)shl 1; arr[3]:=6; arr[4]:=wFileNum;
        arr[5]:=wOrgAddr+iOffs shr 1; arr[6]:=(iBytesToWrite+1)shr 1;
        for n:=0to(iBytesToWrite+1)shr 1-1do arr[7+n]:=psmallint(longword(pBuf)+longword(n)shl 1)^;
        Result:=mbWriteBuffer(cd,arr,nil,0);
        dec(iBytesLeft,iBytesToWrite); if Result<>meSuccess then break;
        if not DoProgress(iBytes-iBytesLeft,GetTickCount-tc,psWorking)then begin Result:=ceAbortOperation; exit; end;
      end;
    finally DoProgress(0,0,psClosed); end; except Result:=ceSysException; end;
  end;

////////// ������� ��� ������ �� Modbus-��������� ��� ��������� ����

  type TIniHeader=packed record
    _wTotalSize,_wHeaderSize,_wHeaderVersion:word;
    _sFileName:array[0..35]of char; _wCheckSumType,_wCheckSum:word;
    _sCompressor:array[0..15]of char; _lwFileSize:longword;
  end;

  function mbReadIniFile(cd:TModbusDevice; out sFileName,sFileText:AnsiString;
    pcc:TProgressCallBack=nil; PID:pointer=nil):integer;
  var ih:TIniHeader; iRecsLeft,iRecsNum,iAddr,iRecsToRead,i:integer; tc:longword; wRetries:word; pBuf:PAnsiChar; ms:TMemoryStream;
  const sCompressedFileHeader='zlibcomr'; nRetries=3;
    function DoProgress(const lwCurrentProgress,lwTimeEllapsed:LongWord; ps:TProgressState):boolean;
    begin Result:=(@pcc=nil)or pcc(PID,LongWord(PID),0,lwCurrentProgress,(ih._wTotalSize+1)shl 1,lwTimeEllapsed,'',ps); end;
  begin pBuf:=nil; ms:=nil; 
    try try tc:=GetTickCount;
      if not DoProgress(0,0,psOpened)then begin Result:=ceAbortOperation; exit; end;
      Result:=mbReadFileDataBlock(cd,0,0,@ih,SizeOf(ih),nil,nil); if Result<>meSuccess then exit;
      if not DoProgress(SizeOf(ih),GetTickCount-tc,psWorking)then begin Result:=ceAbortOperation; exit; end;
      iRecsLeft:=ih._wTotalSize-ih._wHeaderSize-1; if iRecsLeft<=0then begin Result:=ceDataSize; exit; end;
      iRecsNum:=(iMaxBufferSize-7{9})shr 1; iAddr:=ih._wHeaderSize+2; sFileName:=ih._sFileName;
      pBuf:=GetMemory(iRecsNum shl 1); ms:=TMemoryStream.Create;
      i:=Length(sCompressedFileHeader); ms.Write(i,SizeOf(i)); ms.Write(sCompressedFileHeader[1],i);
      i:=$01; ms.Write(i,SizeOf(i)); i:=ih._lwFileSize; ms.Write(i,SizeOf(i)); i:=iRecsLeft shl 1; ms.Write(i,SizeOf(i));
      while iRecsLeft>0do begin
        iRecsToRead:=iRecsNum; if iRecsLeft<iRecsToRead then iRecsToRead:=iRecsLeft;
        Result:=ceTimeout; wRetries:=nRetries;
        while(Result<>meSuccess)and(wRetries<>0)do begin dec(wRetries);
          Result:=mbReadFileDataBlock(cd,0,iAddr,pBuf,iRecsToRead shl 1,nil,nil);
        end;
        if Result<>meSuccess then break; // ���� ����� ���������� ������� ����������� ���� �� ��������
        ms.Write(pBuf^,iRecsToRead shl 1); dec(iRecsLeft,iRecsToRead); inc(iAddr,iRecsToRead);
        if not DoProgress(iAddr shl 1,GetTickCount-tc,psWorking)then begin Result:=ceAbortOperation; exit; end;
      end;
      if not DoProgress(iAddr shl 1,GetTickCount-tc,psWorking)then begin Result:=ceAbortOperation; exit; end;
      if Result=meSuccess then begin Sleep(25); // ����� ������� �������� 100%-� ��������
        if not Z_DecompressStream(ms)then begin Result:=ceDataFormat; exit; end;
        SetLength(sFileText,ms.Size); ms.Position:=0; ms.Size:=ih._lwFileSize; ms.Read(sFileText[1],ms.Size);
        //! �������� ����������� ����� ih._wCheckSumType ����� �������
      end;
    finally DoProgress(0,0,psClosed); FreeMemory(pBuf); ms.Free; end; except Result:=ceSysException; end;
  end;

  function mbReadLDFile(cd:TModbusDevice; out sFileName,sFileText:AnsiString;
    pcc:TProgressCallBack=nil; PID:pointer=nil):integer;
  var ih:TIniHeader; iRecsLeft,iRecsNum,iAddr,iRecsToRead:integer; tc:longword; wRetries:word; pBuf:PAnsiChar; ms:TMemoryStream;
  const nRetries=3;
    function DoProgress(const lwCurrentProgress,lwTimeEllapsed:LongWord; ps:TProgressState):boolean;
    begin Result:=(@pcc=nil)or pcc(PID,LongWord(PID),0,lwCurrentProgress,(ih._wTotalSize+1{2 ����!})shl 1,lwTimeEllapsed,'',ps); end;
  begin pBuf:=nil; ms:=nil;
    try try tc:=GetTickCount;
      if not DoProgress(0,0,psOpened)then begin Result:=ceAbortOperation; exit; end;
      Result:=mbReadFileDataBlock(cd,1,0,@ih,SizeOf(ih),nil,nil); if Result<>meSuccess then exit;
      if not DoProgress(SizeOf(ih),GetTickCount-tc,psWorking)then begin Result:=ceAbortOperation; exit; end;
      iRecsLeft:=ih._wTotalSize-ih._wHeaderSize-1; if iRecsLeft<=0then begin Result:=ceDataSize; exit; end;
      iRecsNum:=(iMaxBufferSize-9)shr 1; iAddr:=ih._wHeaderSize+2; sFileName:=ih._sFileName;
      pBuf:=GetMemory(iRecsNum shl 1); ms:=TMemoryStream.Create;
      while iRecsLeft>0do begin
        iRecsToRead:=iRecsNum; if iRecsLeft<iRecsToRead then iRecsToRead:=iRecsLeft;
        Result:=ceTimeout; wRetries:=nRetries;
        while(Result<>meSuccess)and(wRetries<>0)do begin dec(wRetries);
          Result:=mbReadFileDataBlock(cd,1,iAddr,pBuf,iRecsToRead shl 1,nil,nil);
        end;
        if Result<>meSuccess then break; // ���� ����� ���������� ������� ����������� ���� �� ��������
        ms.Write(pBuf^,iRecsToRead shl 1); dec(iRecsLeft,iRecsToRead); inc(iAddr,iRecsToRead);
        if not DoProgress(iAddr shl 1,GetTickCount-tc,psWorking)then begin Result:=ceAbortOperation; exit; end;
      end;
      if not DoProgress(iAddr shl 1,GetTickCount-tc,psWorking)then begin Result:=ceAbortOperation; exit; end;
      if Result=meSuccess then begin Sleep(25); // ����� ������� �������� 100%-� ��������
        SetLength(sFileText,ms.Size); ms.Position:=0; ms.Size:=ih._lwFileSize; ms.Read(sFileText[1],ms.Size);
        //! �������� ����������� ����� ih._wCheckSumType ����� �������
      end;
    finally DoProgress(0,0,psClosed); FreeMemory(pBuf); ms.Free; end; except Result:=ceSysException; end;
  end;

  function mbWriteLDFile(cd:TModbusDevice; sFileName,sFileText:AnsiString;
    pcc:TProgressCallBack=nil; PID:pointer=nil):integer;
  var ih:TIniHeader; iBytesLeft,iAddr,iBytesToWrite:integer; tc:longword; pBuf:PAnsiChar; ms:TMemoryStream; wRetries:word;
  const nRetries=3; // iRecsLeft,iRecsNum,iAddr,iRecsToRead:integer;
    function DoProgress(const lwCurrentProgress,lwTimeEllapsed:LongWord; ps:TProgressState):boolean;
    begin Result:=(@pcc=nil)or pcc(PID,LongWord(PID),0,lwCurrentProgress,(ih._wTotalSize+1)shl 1,lwTimeEllapsed,'',ps); end;
  begin pBuf:=nil; ms:=nil;
    try try tc:=GetTickCount;
      if not DoProgress(0,0,psOpened)then begin Result:=ceAbortOperation; exit; end;
      sFileName:=ChangeFileExt(sFileName,''); if Length(sFileName)>SizeOf(ih._sFileName)-3then SetLength(sFileName,SizeOf(ih._sFileName)-3);
      sFileName:=sFileName+'.ld'; ZeroMemory(@ih,SizeOf(ih));
      FillMemory(@ih._sFileName,SizeOf(ih._sFileName),ord(#32)); FillMemory(@ih._sCompressor,SizeOf(ih._sCompressor),ord(#32));
      CopyMemory(@ih._sFileName,@sFileName[1],Length(sFileName)); ih._wHeaderSize:=31; ih._wHeaderVersion:=1;
      ih._wCheckSumType:=3; ih._wCheckSum:=CheckSum_CalculateCRC16(sFileText); ih._lwFileSize:=Length(sFileText);
      ih._wTotalSize:=31+(Length(sFileText)+1)div 2+1;
      Result:=MBWriteFileDataBlock(cd,1,0,@ih,SizeOf(ih),nil,nil); if Result<>meSuccess then exit;
      if not DoProgress(SizeOf(ih),GetTickCount-tc,psWorking)then begin Result:=ceAbortOperation; exit; end;
      iBytesLeft:=Length(sFileText); if iBytesLeft=0then begin Result:=ceDataSize; exit; end;
      iAddr:=ih._wHeaderSize+2; iBytesToWrite:=(iMaxBufferSize-14)and$FE;
      pBuf:=GetMemory(iBytesToWrite); ms:=TMemoryStream.Create; ms.Write(sFileText[1],Length(sFileText)); ms.Position:=0;
      while iBytesLeft<>0do begin
        iBytesToWrite:=(iMaxBufferSize-14)and$FE; if iBytesLeft<iBytesToWrite then iBytesToWrite:=iBytesLeft;
        Result:=ceTimeout; wRetries:=nRetries; ms.Read(pBuf^,iBytesToWrite);
        while(Result<>meSuccess)and(wRetries<>0)do begin dec(wRetries);
          Result:=mbWriteFileDataBlock(cd,1,iAddr,pBuf,iBytesToWrite,nil,nil);
          if(Result=ceTimeOut)and(iBytesLeft-iBytesToWrite<=0)then begin Result:=meSuccess; break; end; // ����� ��������� ������ ���������� ����� ���� � �����
        end;
        if Result<>meSuccess then break;
        dec(iBytesLeft,iBytesToWrite); inc(iAddr,iBytesToWrite shr 1);
        if not DoProgress(iAddr shl 1,GetTickCount-tc,psWorking)then begin Result:=ceAbortOperation; exit; end;
      end;
      if not DoProgress(iAddr shl 1,GetTickCount-tc,psWorking)then begin Result:=ceAbortOperation; exit; end;
    finally DoProgress(0,0,psClosed); FreeMemory(pBuf); ms.Free; end; except Result:=ceSysException; end;
  end;

  // ������ ������������ ����� ������ �������������
  function mbReadScopeDataBlock(cd:TModbusDevice; wOrgAddr:word; pDst:pointer; iRecs,iRecSize:integer;
    pcc:TProgressCallBack=nil; PID:pointer=nil):integer;
  var iRecsLeft,iRecsNum,iRecsToRead:integer; tc:longword; wRetries:word;
  const nRetries=3;
    function DoProgress(const lwCurrentProgress,lwTimeEllapsed:LongWord; ps:TProgressState):boolean;
    begin Result:=(@pcc=nil)or pcc(PID,LongWord(PID),0,lwCurrentProgress,iRecs,lwTimeEllapsed,'',ps); end;
  begin Result:=ceUnknownError; if iRecs<=0then begin Result:=ceNoTransactionData; exit; end;
    if iRecSize<=0then begin Result:=ceNoTransactionData; exit; end;
    try try iRecsLeft:=iRecs; iRecsNum:=(iMaxBufferSize-7)div iRecSize; tc:=GetTickCount;
      if not DoProgress(0,0,psOpened)then begin Result:=ceAbortOperation; exit; end;
      while iRecsLeft>0do begin
        iRecsToRead:=iRecsNum; if iRecsLeft<iRecsToRead then iRecsToRead:=iRecsLeft;
        Result:=ceTimeout; wRetries:=nRetries;
        while(Result<>meSuccess)and(wRetries<>0)do begin dec(wRetries);
          Result:=mbReadBuffer(cd,[cd.Address,mfReadScopeRecords,wOrgAddr,iRecsToRead],pDst,iRecsToRead*iRecSize);
        end;
        dec(iRecsLeft,iRecsToRead); inc(wOrgAddr,iRecsToRead); if Result<>meSuccess then break;
        PAnsiChar(pDst):=PAnsiChar(pDst)+iRecsToRead*iRecSize;
        if not DoProgress(iRecs-iRecsLeft,GetTickCount-tc,psWorking)then begin Result:=ceAbortOperation; exit; end;
      end;
    finally DoProgress(0,0,psClosed); end; except Result:=ceSysException; end;
  end;


end.
