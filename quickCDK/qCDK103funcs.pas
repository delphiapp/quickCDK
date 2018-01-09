unit qCDK103funcs;

interface

uses qCDK103types,qCDK103classes;

  // iec103-������ �� �������������� � ������
  function iec103GetErrorStr(iece:integer):AnsiString;

  // ���������� ������
  function iec103WriteBuffer(cd:TIEC103Master; arrPacket:array of Int64; pLDU:PLDU=nil):integer;
  // ����� ���������� ����� - ������� ���� ������� � ����� ��� ResetFCB (bFCB �� ������������ �� ��������, �� ����� �� ��������� 0)
  // ���������� ceSuccess � ������ �������������� �������������, ieceNegAck - ��������������
  function iec103ResetCommUnit(cd:TIEC103Master):integer;
  // ����� FCB, ������� ������� �������� ������ ������, ������������, ��������� ����� (bFCB �� ������������ ����� 0)
  // ���������� ceSuccess � ������ �������������� �������������, ieceNegAck - ��������������
  function iec103ResetFCB(cd:TIEC103Master):integer;
  // �������� ������ - ���� ���� �����, �� ���������� ����������� (bFCB �� ������������ �� ��������, �� ����� �� ��������� 0)
  // ���������� ceSuccess � ������ ������������� ieceChannelState
  function iec103ChannelState(cd:TIEC103Master):integer;
  // ������ ������ 1
  // ���������� ceSuccess � ������ ������������� ieceUserData
  function iec103Class1(cd:TIEC103Master; pLDU:PLDU):integer;
  // ������ ������ 2
  // ���������� ceSuccess � ������ ������������� ieceUserData
  function iec103Class2(cd:TIEC103Master; pLDU:PLDU):integer;
  // �������������
  // ���������� ceSuccess � ������ ������������� iecePosAck
  function iec103Synchronization(cd:TIEC103Master):integer;
  // ������������� ����������������� (bFCB �� ������������ �� ��������, �� ����� �� ��������� 0)
  // ���������� ceSuccess � ������ ������������� ieceBroadCast
  function iec103SynchronizationBroadcast(cd:TIEC103Master):integer;
  // ������������� ������ ������
  // ���������� ceSuccess � ������ ������������� iecePosAck
  function iec103InitializeGI(cd:TIEC103Master; SCN:byte):integer;
  // ������ ������ ������������
  function iec103FaultsList(cd:TIEC103Master; FUN,INF:byte; pLDU:PLDU):integer;
  // ������ �������� ������ � ���������
  function iec103FaultOrder(cd:TIEC103Master; FUN,INF:byte; TOO:tagTOO; FAN:tagFAN; ACC:tagACC; pLDU:PLDU):integer;
  // ������������� �������� ������ � ���������
  function iec103FaultAcknowledge(cd:TIEC103Master; FUN,INF:byte; TOO:tagTOO; FAN:tagFAN; ACC:tagACC; pLDU:PLDU):integer;


implementation

uses Windows,Classes,uUtilsFunctions,qCDKclasses;

//var cs:TCommunicationSpace;

{$BOOLEVAL OFF}
{$RANGECHECKS OFF}
{$OVERFLOWCHECKS OFF}

  const ndxLinkControlField=0; ndxLinkAddress=1;
    ndxTypeIdentification=2; ndxVariableStructureQualifier=3; ndxCauseOfTransmission=4;
    ndxAsduAddress=5; ndxFunctionType=6; ndxInformationNumber=7;

  type TLTransactionData=class(TTransactionData);

// LinkControlField,LinkAddress,TypeIdentification,VariableStructureQualifier,CauseOfTransmission,AsduAddress,FunctionType,InformationNumber,InformationElements

////////// ������� ��� ������ �� IEC103-��������� 

  // iec103-������ �� �������������� � ������
  function iec103GetErrorStr(iece:integer):AnsiString;
  begin if not IntToIdent(iece,Result,IEC103ErrorsInfos)then Result:=GetErrorStr(iece); end;

  // ������� ��������� ���������� � ���������� ������ (cb=nil);
  // � ����������� ������ (cb<>nil) ������� �� ������� � ����� ceCallbackWait
  function iec103DoWait(cd:TCommunicationDevice; arrPacket:array of Int64; pLDU:PLDU; cb:TTransactionWaitCallBack=nil):integer;
  {var sRequest:AnsiString; ndxError,ieceResult:integer; td:TLTransactionData; thr:TCommunicationThread;} 
  begin Result:=comDoWait(cd,arrPacket,pLDU,SizeOf(pLDU^),cb);

(*    Result:=ceUnknownError; if Length(arrPacket)=0then begin Result:=ceNoTransactionData; exit; end;
    try if cd=nil then begin Result:=ceNoCommunicationDevice; exit; end;
      try cd.Lock;
        if(cd.CommunicationConnection=nil)then begin Result:=ceNoCommunicationConnection; exit; end;
        if(cd.CommunicationConnection.CommunicationSocket=nil)then begin Result:=ceNoCommunicationSocket; exit; end;
        if not(cd.CommunicationProtocol is TIEC103Protocol)then begin Result:=ceNoCommunicationProtocol; exit; end;
        ieceResult:=cd.CommunicationProtocol.MakeRequest(arrPacket,sRequest,ndxError);
        if ieceResult<>ceSuccess then begin Result:=ieceResult; exit; end;
        thr:=cs.Threads.GetConnectionThread(cd.CommunicationConnection,TIEC103Thread);
        if pLDU<>nil then ZeroMemory(pLDU,SizeOf(pLDU^));
        td:=TLTransactionData(thr.PutRequest(cd,sRequest,pLDU,SizeOf(pLDU^)));
      finally cd.Unlock; end;

      if td=nil then Result:=ceNoTransactionData  // �� ���������� ������� "������ �� ����������"
//      else if@cb<>nil then Result:=meCallbackWait // ������� ��� �������� � ����������� ��������
      else try
        if td.hCompleteEvent<>0then WaitForSingleObject(td.hCompleteEvent,INFINITE)
        else while td.tr=trProcessing do begin if bProcessMessages then Sys_HandleMessage; Sleep(16); end; // �� ��� "���������� ����������"
        case td.tr of
          trSuccess:    Result:=ceSuccess;
          trTimeout:    try Result:=ceTimeout; cd.CommunicationConnection.TrafficInfo.AddInTimeouts(1); except end;
          trProcessing: Result:=ceAbortOperation;     trAbort:        Result:=ceAbortOperation;
          trWriteError: Result:=ceWriteError;         trBroadCast:    Result:=ceBroadCast;
          trOverflow:   Result:=ceQueueOverflow;      trHandleError:  Result:=td.ce;
          trException:  Result:=ceSysException;
        end;
      finally td.Free; end; // ������ ��� ���������� ����� ���������� ����� ������ � ����
    except Result:=ceSysException; end;*)
  end;

  // ���������� ������
  function iec103WriteBuffer(cd:TIEC103Master; arrPacket:array of Int64; pLDU:PLDU=nil):integer;
  begin Result:=iec103DoWait(cd,arrPacket,pLDU); end;

  // ����� ���������� ����� - ������� ���� ������� � ����� ��� ResetFCB (bFCB �� ������������ �� ��������, �� ����� �� ��������� 0)
  function iec103ResetCommUnit(cd:TIEC103Master):integer; begin
    Result:=iec103WriteBuffer(cd,[LinkControlField1(fc1ResetCommUnit)+ord(cd.FCB)shl 5,cd.LinkAddress]);
    if Result=iecePosAck then Result:=ceSuccess;
  end;

  // ����� FCB, ������� ������� �������� ������ ������, ������������, ��������� ����� (bFCB �� ������������ ����� 0)
  function iec103ResetFCB(cd:TIEC103Master):integer; begin
    Result:=iec103WriteBuffer(cd,[LinkControlField1(fc1ResetFCB)+ord(cd.FCB)shl 5,cd.LinkAddress]);
    if Result=iecePosAck then Result:=ceSuccess;
  end;

  // �������� ������ - ���� ���� �����, �� ���������� ����������� (bFCB �� ������������ �� ��������, �� ����� �� ��������� 0)
  function iec103ChannelState(cd:TIEC103Master):integer; begin
    Result:=iec103WriteBuffer(cd,[LinkControlField1(fc1ChannelState)+ord(cd.FCB)shl 5,cd.LinkAddress]);
    if Result=ieceChannelState then Result:=ceSuccess;
  end;

  // ������ ������ 1
  function iec103Class1(cd:TIEC103Master; pLDU:PLDU):integer; begin
    Result:=iec103WriteBuffer(cd,[LinkControlField1(fc1Class1)+ord(cd.FCB)shl 5,cd.LinkAddress],pLDU);
    if Result=ieceUserData then Result:=ceSuccess;
  end;

  // ������ ������ 2
  function iec103Class2(cd:TIEC103Master; pLDU:PLDU):integer; begin
    Result:=iec103WriteBuffer(cd,[LinkControlField1(fc1Class2)+ord(cd.FCB)shl 5,cd.LinkAddress],pLDU);
    if Result=ieceUserData then Result:=ceSuccess;
  end;

  // �������������
  function iec103Synchronization(cd:TIEC103Master):integer;
  var arr:array of int64; st:TSystemTime; const ndxCP56Time2a=8;
  begin SetLength(arr,ndxCP56Time2a+1);
    arr[ndxLinkControlField]:=LinkControlField1(fc1UserSend)+ord(cd.FCB)shl 5;
    arr[ndxLinkAddress]:=cd.LinkAddress; arr[ndxAsduAddress]:=cd.AsduAddress;
    arr[ndxFunctionType]:=$FF; arr[ndxInformationNumber]:=$00;
    arr[ndxTypeIdentification]:=ti1TimeSynchronization;
    arr[ndxVariableStructureQualifier]:=$81; arr[ndxCauseOfTransmission]:=cot1TimeSynchronization;
    arr[ndxCP56Time2a]:=0; GetLocalTime(st);
    TCP56Time2a(@arr[ndxCP56Time2a]).Milliseconds:=st.wSecond*1000+st.wMilliseconds;
    TCP56Time2a(@arr[ndxCP56Time2a]).Minutes:=st.wMinute; TCP56Time2a(@arr[ndxCP56Time2a]).Hours:=st.wHour;
    TCP56Time2a(@arr[ndxCP56Time2a]).DayOfMonth:=st.wDay; TCP56Time2a(@arr[ndxCP56Time2a]).DayOfWeek:=st.wDayOfWeek;
    TCP56Time2a(@arr[ndxCP56Time2a]).Month:=st.wMonth; TCP56Time2a(@arr[ndxCP56Time2a]).Year:=st.wYear mod 100;
    Result:=iec103WriteBuffer(cd,arr); if Result=iecePosAck then Result:=ceSuccess;
  end;

  // ������������� ����������������� (bFCB �� ������������ �� ��������, �� ����� �� ��������� 0)
  function iec103SynchronizationBroadcast(cd:TIEC103Master):integer;
  var arr:array of int64; st:TSystemTime;
  const ndxLinkControlField=0; ndxLinkAddress=1;
    ndxTypeIdentification=2; ndxVariableStructureQualifier=3; ndxCauseOfTransmission=4;
    ndxAsduAddress=5; ndxFunctionType=6; ndxInformationNumber=7;
    ndxCP56Time2a=8;
  begin SetLength(arr,ndxCP56Time2a+1);
    arr[ndxLinkControlField]:=LinkControlField1(fc1UserBroadcast)+ord(cd.FCB)shl 5;
    arr[ndxLinkAddress]:=$FF; arr[ndxAsduAddress]:=$FF;
    arr[ndxFunctionType]:=$FF; arr[ndxInformationNumber]:=$00;
    arr[ndxTypeIdentification]:=ti1TimeSynchronization;
    arr[ndxVariableStructureQualifier]:=$81; arr[ndxCauseOfTransmission]:=cot1TimeSynchronization;
    arr[ndxCP56Time2a]:=0; GetLocalTime(st);
    TCP56Time2a(@arr[ndxCP56Time2a]).Milliseconds:=st.wSecond*1000+st.wMilliseconds;
    TCP56Time2a(@arr[ndxCP56Time2a]).Minutes:=st.wMinute; TCP56Time2a(@arr[ndxCP56Time2a]).Hours:=st.wHour;
    TCP56Time2a(@arr[ndxCP56Time2a]).DayOfMonth:=st.wDay; TCP56Time2a(@arr[ndxCP56Time2a]).DayOfWeek:=st.wDayOfWeek;
    TCP56Time2a(@arr[ndxCP56Time2a]).Month:=st.wMonth; TCP56Time2a(@arr[ndxCP56Time2a]).Year:=st.wYear mod 100;
    Result:=iec103WriteBuffer(cd,arr); if Result=ieceBroadCast then Result:=ceSuccess;
  end;

  // ������������� ������ ������
  function iec103InitializeGI(cd:TIEC103Master; SCN:byte):integer; var arr:array of int64; const ndxSCN=8;
  begin SetLength(arr,ndxSCN+1);
    arr[ndxLinkControlField]:=LinkControlField1(fc1UserSend)+ord(cd.FCB)shl 5;
    arr[ndxLinkAddress]:=cd.LinkAddress; arr[ndxAsduAddress]:=cd.AsduAddress;
    arr[ndxFunctionType]:=$FF; arr[ndxInformationNumber]:=$00;
    arr[ndxTypeIdentification]:=ti1GeneralInterrogation;
    arr[ndxVariableStructureQualifier]:=$81; arr[ndxCauseOfTransmission]:=cot1GeneralInterrogation;
    arr[ndxSCN]:=SCN;
    Result:=iec103WriteBuffer(cd,arr); if Result=iecePosAck then Result:=ceSuccess;
  end;

  // ������ ������ ������������
  function iec103FaultsList(cd:TIEC103Master; FUN,INF:byte; pLDU:PLDU):integer;
  begin Result:=iec103FaultOrder(cd,FUN,INF,too1FaultsListRequest,0,0,pLDU); end;

  // ������ �������� ������ � ���������
  function iec103FaultOrder(cd:TIEC103Master; FUN,INF:byte; TOO:tagTOO; FAN:tagFAN; ACC:tagACC; pLDU:PLDU):integer;
  var arr:array of int64; const ndxTOO=8; ndxTOV=9; ndxFAN=10; ndxACC=11;
  begin SetLength(arr,ndxACC+1);
    arr[ndxLinkControlField]:=LinkControlField1(fc1UserSend)+ord(cd.FCB)shl 5;
    arr[ndxLinkAddress]:=cd.LinkAddress; arr[ndxAsduAddress]:=cd.AsduAddress;
    arr[ndxFunctionType]:=FUN; arr[ndxInformationNumber]:=INF; //$00; {�� ������������}
    arr[ndxTypeIdentification]:=ti1FaultOrder;
    arr[ndxVariableStructureQualifier]:=$81; arr[ndxCauseOfTransmission]:=cot1FaultTransmission;
    arr[ndxTOO]:=TOO; arr[ndxTOV]:=tovInstantaneousValues;
    arr[ndxFAN]:=FAN; arr[ndxACC]:=ACC;
    Result:=iec103WriteBuffer(cd,arr,pLDU); if Result=iecePosAck then Result:=ceSuccess;
  end;

  // ������������� �������� ������ � ���������
  function iec103FaultAcknowledge(cd:TIEC103Master; FUN,INF:byte; TOO:tagTOO; FAN:tagFAN; ACC:tagACC; pLDU:PLDU):integer;
  var arr:array of int64; const ndxTOO=8; ndxTOV=9; ndxFAN=10; ndxACC=11;
  begin SetLength(arr,ndxACC+1);
    arr[ndxLinkControlField]:=LinkControlField1(fc1UserSend)+ord(cd.FCB)shl 5;
    arr[ndxLinkAddress]:=cd.LinkAddress; arr[ndxAsduAddress]:=cd.AsduAddress;
    arr[ndxFunctionType]:=FUN; arr[ndxInformationNumber]:=INF; //$00; {�� ������������}
    arr[ndxTypeIdentification]:=ti1FaultAcknowledge;
    arr[ndxVariableStructureQualifier]:=$81; arr[ndxCauseOfTransmission]:=cot1FaultTransmission;
    arr[ndxTOO]:=TOO; arr[ndxTOV]:=tovInstantaneousValues;
    arr[ndxFAN]:=FAN; arr[ndxACC]:=ACC;
    Result:=iec103WriteBuffer(cd,arr,pLDU); if Result=iecePosAck then Result:=ceSuccess;
  end;

//initialization
//  cs:=CommunicationSpace;

end.
