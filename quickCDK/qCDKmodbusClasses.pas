unit qCDKmodbusClasses;

interface

uses uCalcTypes,qCDKclasses;

const
  tmASCII=0; tmRTU=1; tmTCP=2; // transmission modes

type
  TModbusProtocol=class(TCommunicationProtocol)
  private
  protected
    procedure DoSetUInt(const ndx:integer; const ui:UInt64); override;    // все беззнаковые целые свойства
  protected
    function MakePacket(const sHexBody:AnsiString):AnsiString; override;  // создание пакета из hex-тела пакета (символы начала и конца, контрольна€ сумма и т.д.)
  public
    class function GetClassCaption:AString; override;       // описание класса
    class function GetClassDescription:AString; override;   // подробное описание класса

    procedure SetDefault; override; // параметры по умолчанию
    function GetErrorAsText(ce:integer):AnsiString; override;                 // ошибка в виде строки

    // тип Modbus-протокола
//    property ProtocolType:TModbusProtocolType read fenProtocolType write fenProtocolType;

//     обрабатывает ответ на основе запроса, заполн€ет данными область пам€ти pDst, если нужно
//     в случае неуспешной обработки Modbus-транзакции вызываетс€ исключение
    function HandleResponse(sRequest,sResponse:AnsiString; pDst:pointer; iDstSize:integer):integer; override;

    function IsBroadcastRequest(const sRequest:AnsiString):boolean; override; // проверка на широковещательный запрос
    function IsResponseSuccess(const ce:integer):boolean; override;           // проверка кода ошибки ответа (HandleResponse) на правильность ответа

    // создаЄт Modbus-запрос на основе массива значений (адрес устройства, функци€, параметры)
    // в случае неуспешного формировани€ Modbus-запроса вызываетс€ исключение
    function MakeRequest(arrPacketData:array of Int64):AnsiString; overload; override;
    // в случае неуспешного формировани€ Modbus-запроса возвращаетс€ код ошибки, и индекс ndxError в массиве
    function MakeRequest(arrPacketData:array of Int64; out sRequest:AnsiString; out ndxError:integer):integer; overload; override;

    // создаЄт Modbus-ответ на основе массива значений (адрес устройства, функци€, параметры)
    // в случае неуспешного формировани€ Modbus-ответа вызываетс€ исключение
    function MakeResponse(arrPacketData:array of Int64):AnsiString; overload; override;
    // в случае неуспешного формировани€ Modbus-ответа возвращаетс€ код ошибки, и индекс ndxError в массиве
    function MakeResponse(arrPacketData:array of Int64; out sResponse:AnsiString; out ndxError:integer):integer; overload; override;
  end;

////////// ‘ормат запросов (сколько байт занимает каждый объект в массиве по своему индексу)
//  јдрес”стройства,mfReadCoils,StartAddress,ElementCount=1,1,2,2
//  јдрес”стройства,mfReadDiscreteInputs,StartAddress,ElementCount=1,1,2,2
//  јдрес”стройства,mfReadHoldingRegisters,StartAddress,ElementCount=1,1,2,2
//  јдрес”стройства,mfReadInputRegisters,StartAddress,ElementCount=1,1,2,2
//  јдрес”стройства,mfWriteSingleCoil,Address,Value(=0xFF00 или 0x0000)=1,1,2,2
//  јдрес”стройства,mfWriteSingleRegister,Address,Value=1,1,2,2
//  јдрес”стройства,mfReadExceptionStatus=1,1
//  јдрес”стройства,mfFetchCommEventCounter=1,1
//  јдрес”стройства,mfFetchCommEventLog=1,1
//  јдрес”стройства,mfWriteMultipleCoils,StartAddress,Count,ByteCount(=(Count+7)div 8),byte(1),...,byte=1,1,2,2,1,1,...,1
//  јдрес”стройства,mfWriteMultipleRegisters,StartAddress,Count,ByteCount(=Count*2),word(1),...,word=1,1,2,2,1,2,...,2
//  јдрес”стройства,mfReadFileRecord,ByteCount,RefType(06),FileNumber,RecordNumber,RecordCount,...,
//    RefType(06),FileNumber,RecordNumber,RecordCount=1,1,1,1,2,2,2,...,1,2,2,2
//  јдрес”стройства,mfWriteFileRecord,ByteCount,RefType(06),FileNumber,RecordNumber,RecordCount(=N),word(1),...,word(N),
//    RefType(06),FileNumber,RecordNumber,RecordCount(=M),word(1),...,word(M)=1,1,1,1,2,2,2,2,...,2,...,1,2,2,2,2,...,2
//  јдрес”стройства,mfMaskWriteRegister,Address,AndMask,OrMask=1,1,2,2,2
//  јдрес”стройства,mfReadWriteMultipleRegisters,ReadStartAddress,ReadElementCount,
//    WriteStartAddress,Count,ByteCount(=Count*2),word(1),...,word=1,1,2,2,    2,2,1,2,...,2
////////// дл€ устройств ЅЁћѕ
//  јдрес”стройства,mfReadScopeRecords,StartAddress,ElementCount=1,1,2,2

////////// ‘ормат ответов (сколько байт занимает каждый объект в массиве по своему индексу)
//  јдрес”стройства,mfReadCoils,ByteCount,byte,...,byte=1,1,1,1,...,1
//  јдрес”стройства,mfReadDiscreteInputs,ByteCount,byte,...,byte=1,1,1,1,...,1
//  јдрес”стройства,mfReadHoldingRegisters,ByteCount(=RegisterCount*2),word,...,word=1,1,1,2,...,2
//  јдрес”стройства,mfReadInputRegisters,ByteCount(=RegisterCount*2),word,...,word=1,1,1,2,...,2
//  јдрес”стройства,mfWriteSingleCoil,Address,Value(0xFF00/0x0000)=1,1,2,2
//  јдрес”стройства,mfWriteSingleRegister,Address,Value=1,1,2,2
//  јдрес”стройства,mfReadExceptionStatus,Data=1,1,1
//  јдрес”стройства,mfFetchCommEventCounter,Status,EventCount=1,1,2,2
//  јдрес”стройства,mfFetchCommEventLog,ByteCount(=N),Status,EventCount,MsgCount,Event(1),...,Event(N-6)=1,1,1,2,2,2,1,...,1
//  јдрес”стройства,mfWriteMultipleCoils,StartAddress,Count=1,1,2,2
//  јдрес”стройства,mfWriteMultipleRegisters,StartAddress,Count=1,1,2,2
//  јдрес”стройства,mfReadFileRecord,ResponseByteCount,SubrequestByteCount,RefType(06),word,...,word,...,
//    SubrequestByteCount,RefType(06),word,...,word=1,1,1,1,1,2,...,2,...,1,1,2,...,2
//  јдрес”стройства,mfWriteFileRecord,ByteCount,RefType(06),FileNumber,RecordNumber,RecordCount(=N),word(1),...,word(N),
//    RefType(06),FileNumber,RecordNumber,RecordCount(=M),word(1),...,word(M)=1,1,1,1,2,2,2,2,...,2,...,1,2,2,2,2,...,2
//  јдрес”стройства,mfMaskWriteRegister,Address,AndMask,OrMask=1,1,2,2,2
//  јдрес”стройства,mfReadWriteMultipleRegisters,ByteCount(=RegisterCount*2),word,...,word=1,1,1,2,...,2
////////// дл€ устройств ЅЁћѕ
//  јдрес”стройства,mfReadScopeRecords,ByteCount(=RegisterCount*2),word,...,word=1,1,1,2,...,2

  TModbusProtocol_BEMP=class(TModbusProtocol)
  public
    class function GetClassCaption:AString; override;       // описание класса
    class function GetClassDescription:AString; override;   // подробное описание класса

    function HandleResponse(sRequest,sResponse:AnsiString; pDst:pointer; iDstSize:integer):integer; override;
    function MakeRequest(arrPacketData:array of Int64; out sRequest:AnsiString; out ndxError:integer):integer; override;
    function MakeResponse(arrPacketData:array of Int64; out sResponse:AnsiString; out ndxError:integer):integer; override;
  end;

  TModbusDevice=class(TCommunicationDevice)
  end;


implementation

uses Windows,SysUtils,uUtilsFunctions,qCDKmodbusFuncs,qCDKmodbusTypes;

{$BOOLEVAL OFF}
{$RANGECHECKS OFF}
{$OVERFLOWCHECKS OFF}

var gfs:TFormatSettings;

const lwMaxPacketSize=255 {tmTCP};

  type TLCommunicationObject=class(TCommunicationObject);

  procedure RegisterClasses; var co:TCommunicationObject; begin co:=nil; 
    try co:=TCommunicationObject.Create;
      TLCommunicationObject(co).Owner.RegisterProtocolClass(TModbusProtocol);
      TLCommunicationObject(co).Owner.RegisterProtocolClass(TModbusProtocol_BEMP);      
//      TLCommunicationObject(co).Owner.RegisterDeviceClass(TIEC103Master);
    finally co.Free; end;
  end;


{ TModbusProtocol }

procedure TModbusProtocol.DoSetUInt(const ndx:integer; const ui:UInt64); var lw:LongWord; begin
  case ndx of
    ndxAddressSize:         exit; // размер всегда 1 байт
    ndxBroadcastAddress:    exit; // широковещательный адрес всегда 0
    ndxMaxPacketSize:       begin lw:=ui;
      if(lw=0)or(lw>lwMaxPacketSize)then lw:=lwMaxPacketSize;
      inherited DoSetUInt(ndx,lw);
    end;
    ndxTransmissionMode: if not(ui in[tmASCII,tmRTU,tmTCP])then exit else inherited DoSetUInt(ndx,ui);    // режим передачи не используетс€    
  else inherited DoSetUInt(ndx,ui); end;
end;

class function TModbusProtocol.GetClassCaption:AString;
begin Result:='протокол Modbus (TModbusProtocol)'; end;

class function TModbusProtocol.GetClassDescription:AString;
begin Result:='протокол Modbus класса TModbusProtocol реализует стандартные функции и режимы передачи ASCII,RTU,TCP'; end;

function TModbusProtocol.GetErrorAsText(ce:integer):AnsiString;
begin Result:=mbGetErrorStr(ce); end;

function TModbusProtocol.HandleResponse(sRequest,sResponse:AnsiString; pDst:pointer; iDstSize:integer):integer;
  var s:AnsiString; w:word; i:integer;
  const ndxDeviceAddress=1; ndxModbusFunction=2;
    ndxReadByteCount=3;
    ndxElementReadCount=5;
    ndxReadExceptionStatus=3;
    ndxCommStatus=3; ndxCommEventCount=5;
    ndxCommStatusLog=4; ndxCommEventCountLog=6; ndxCommMessageCountLog=8;
    ndxStartAddress=3; ndxElementCount=5;
    ndxSubrequestByteCount=4;
  procedure ChangeBytes; var i:integer; begin
    if pDst<>nil then for i:=0to iDstSize shr 1-1do // мен€ем
      begin w:=pbyte(integer(pDst)+2*i)^; pbyte(integer(pDst)+2*i)^:=pbyte(integer(pDst)+2*i+1)^; pbyte(integer(pDst)+2*i+1)^:=w; end;
  end;
begin
  try if not flwTransmissionMode in[tmASCII,tmRTU,tmTCP]then begin Result:=ceIncorrectTransmissionMode; exit; end;
    case flwTransmissionMode of
      tmASCII: begin if Length(sRequest)<6then begin Result:=ceCorruptedRequest; exit; end;
        if Length(sResponse)<6then begin Result:=ceCorruptedResponse; exit; end;
        s:=Copy(sResponse,2,Length(sResponse)-5); w:=byte(-byte(CheckSum_CalculateLRC(Text_Hex2String(s))));
        if w<>StrToInt('0x'+sResponse[Length(sResponse)-3]+sResponse[Length(sResponse)-2])then
          begin Result:=ceFrameCRC; exit; end;
        sRequest:=Text_Hex2String(Copy(sRequest,2,Length(sRequest)-5)); sResponse:=Text_Hex2String(s);
      end;
      tmRTU: begin if Length(sRequest)<4then begin Result:=ceCorruptedRequest; exit; end;
        if Length(sResponse)<4then begin Result:=ceCorruptedResponse; exit; end;
        s:=Copy(sResponse,1,Length(sResponse)-2); w:=CheckSum_CalculateCRC16(Text_Hex2String(s));
        if w<>byte(sResponse[Length(sResponse)-1])shl 8+byte(sResponse[Length(sResponse)])then
          begin Result:=ceFrameCRC; exit; end;
        sRequest:=Copy(sRequest,1,Length(sRequest)-2); sResponse:=s;
      end;
      tmTCP: begin if Length(sRequest)<8then begin Result:=ceCorruptedRequest; exit; end;
        if Length(sResponse)<8then begin Result:=ceCorruptedResponse; exit; end;
        sRequest:=Copy(sRequest,7,MaxInt); sResponse:=Copy(sResponse,7,MaxInt);
      end;
    end;
    if byte(sRequest[ndxDeviceAddress])=flwBroadcastAddress then begin Result:=ceBroadCast; exit; end; // напр€мую сравним с broadcast-адресом
    if sRequest[ndxDeviceAddress]<>sResponse[ndxDeviceAddress]then begin Result:=ceIncorrectResponse{meDeviceAddress}; exit; end;
    if byte(sResponse[ndxModbusFunction])>=$80then begin Result:=meModbusException; exit; end;
    if sRequest[ndxModbusFunction]<>sResponse[ndxModbusFunction]then begin Result:=ceIncorrectResponse; exit; end;
    case TModbusFunction(sResponse[ndxModbusFunction])of
      //  јдрес”стройства,mfReadCoils,StartAddress,ElementCount=1,1,2,2
      //  јдрес”стройства,mfReadDiscreteInputs,StartAddress,ElementCount=1,1,2,2
      //  јдрес”стройства,mfReadHoldingRegisters,StartAddress,ElementCount=1,1,2,2
      //  јдрес”стройства,mfReadInputRegisters,StartAddress,ElementCount=1,1,2,2
      //  јдрес”стройства,mfReadWriteMultipleRegisters,ReadStartAddress,ReadElementCount,
      //    WriteStartAddress,Count,ByteCount(=Count*2),word(1),...,word=1,1,2,2,    2,2,1,2,...,2
      //  јдрес”стройства,mfReadCoils,ByteCount,byte,...,byte=1,1,1,1,...,1
      //  јдрес”стройства,mfReadDiscreteInputs,ByteCount,byte,...,byte=1,1,1,1,...,1
      //  јдрес”стройства,mfReadHoldingRegisters,ByteCount(=RegisterCount*2),word,...,word=1,1,1,2,...,2
      //  јдрес”стройства,mfReadInputRegisters,ByteCount(=RegisterCount*2),word,...,word=1,1,1,2,...,2
      //  јдрес”стройства,mfReadWriteMultipleRegisters,ByteCount(=RegisterCount*2),word,...,word=1,1,1,2,...,2
      mfReadCoils,mfReadDiscreteInputs,mfReadHoldingRegisters,mfReadInputRegisters,mfReadWriteMultipleRegisters: begin
        if Length(sResponse)<ndxReadByteCount then begin Result:=ceFrameLength{meElementReadByteCount}; exit; end;
        if Length(sResponse)<ndxReadByteCount+byte(sResponse[ndxReadByteCount])then begin Result:=ceFrameLength{meElementReadValues}; exit; end;
        if Length(sRequest)<ndxElementReadCount+1then begin Result:=ceCorruptedRequest{meElementReadCount}; exit; end;
        i:=byte(sRequest[ndxElementReadCount])shl 8+byte(sRequest[ndxElementReadCount+1]);
        if TModbusFunction(sResponse[ndxModbusFunction])in[mfReadHoldingRegisters,mfReadInputRegisters,mfReadWriteMultipleRegisters]
          then i:=i*2 else i:=(i+7)div 8;
        if i<>byte(sResponse[ndxReadByteCount])then begin Result:=ceFrameLength{meElementReadCount}; exit; end;
        if pDst<>nil then begin if i>iDstSize then begin Result:=ceBufferSize; exit; end;
          CopyMemory(pDst,@sResponse[ndxReadByteCount+1],i);
          if TModbusFunction(sResponse[ndxModbusFunction])in[mfReadHoldingRegisters,mfReadInputRegisters,mfReadWriteMultipleRegisters]then ChangeBytes;
        end;
        Result:=meSuccess;
      end;
      //  јдрес”стройства,mfWriteSingleCoil,Address,Value(=0xFF00 или 0x0000)=1,1,2,2
      //  јдрес”стройства,mfWriteSingleRegister,Address,Value=1,1,2,2
      //  јдрес”стройства,mfWriteFileRecord,ByteCount,RefType(06),FileNumber,RecordNumber,RecordCount(=N),word(1),...,word(N),
      //    RefType(06),FileNumber,RecordNumber,RecordCount(=M),word(1),...,word(M)=1,1,1,1,2,2,2,2,...,2,...,1,2,2,2,2,...,2
      //  јдрес”стройства,mfMaskWriteRegister,Address,AndMask,OrMask=1,1,2,2,2
      //  јдрес”стройства,mfWriteSingleCoil,Address,Value(0xFF00/0x0000)=1,1,2,2
      //  јдрес”стройства,mfWriteSingleRegister,Address,Value=1,1,2,2
      //  јдрес”стройства,mfWriteFileRecord,ByteCount,RefType(06),FileNumber,RecordNumber,RecordCount(=N),word(1),...,word(N),
      //    RefType(06),FileNumber,RecordNumber,RecordCount(=M),word(1),...,word(M)=1,1,1,1,2,2,2,2,...,2,...,1,2,2,2,2,...,2
      //  јдрес”стройства,mfMaskWriteRegister,Address,AndMask,OrMask=1,1,2,2,2
      mfWriteSingleCoil,mfWriteSingleRegister,mfWriteFileRecord,mfMaskWriteRegister:
        if sRequest<>sResponse then begin Result:=ceIncorrectResponse; exit; end else Result:=meSuccess;
      //  јдрес”стройства,mfReadExceptionStatus=1,1
      //  јдрес”стройства,mfReadExceptionStatus,Data=1,1,1
      mfReadExceptionStatus: begin
        if Length(sResponse)<ndxReadExceptionStatus then begin Result:=ceFrameLength{meElementReadValues}; exit; end;
        if pDst<>nil then begin if iDstSize<1then begin Result:=ceBufferSize; exit; end;
          pbyte(pDst)^:=byte(sResponse[ndxReadExceptionStatus]);
        end;
        Result:=meSuccess;
      end;
      //  јдрес”стройства,mfFetchCommEventCounter=1,1
      //  јдрес”стройства,mfFetchCommEventCounter,Status,EventCount=1,1,2,2
      mfFetchCommEventCounter: begin
        if Length(sResponse)<ndxCommEventCount+1then begin Result:=ceFrameLength{meElementReadValues}; exit; end;
        if pDst<>nil then begin if iDstSize<4then begin Result:=ceBufferSize; exit; end;
          CopyMemory(pDst,@sResponse[ndxReadByteCount+1],iDstSize); ChangeBytes;
        end;
        Result:=meSuccess;
      end;
      //  јдрес”стройства,mfFetchCommEventLog=1,1
      //  јдрес”стройства,mfFetchCommEventLog,ByteCount(=N),Status,EventCount,MsgCount,Event(1),...,Event(N-6)=1,1,1,2,2,2,1,...,1
      mfFetchCommEventLog: begin
        if Length(sResponse)<ndxReadByteCount then begin Result:=ceFrameLength{meElementReadByteCount}; exit; end;
        i:=byte(sResponse[ndxReadByteCount]); if i<6then begin Result:=ceFrameLength{meElementReadByteCount}; exit; end;
        if Length(sResponse)<ndxCommStatusLog+1then begin Result:=ceFrameLength{meElementReadValues}; exit; end;
        if Length(sResponse)<ndxCommEventCountLog+1then begin Result:=ceFrameLength{meElementReadValues}; exit; end;
        if Length(sResponse)<ndxCommMessageCountLog+1then begin Result:=ceFrameLength{meElementReadValues}; exit; end;
        if Length(sResponse)<ndxReadByteCount+i then begin Result:=ceFrameLength{meElementReadValues}; exit; end;
        if pDst<>nil then begin if i>iDstSize then begin Result:=ceBufferSize; exit; end;
          CopyMemory(pDst,@sResponse[ndxReadByteCount+1],i);
          w:=pbyte(integer(pDst)+0)^; pbyte(integer(pDst)+0)^:=pbyte(integer(pDst)+1)^; pbyte(integer(pDst)+1)^:=w;
          w:=pbyte(integer(pDst)+2)^; pbyte(integer(pDst)+2)^:=pbyte(integer(pDst)+3)^; pbyte(integer(pDst)+3)^:=w;          
        end;
        Result:=meSuccess;
      end;
      //  јдрес”стройства,mfWriteMultipleCoils,StartAddress,Count,ByteCount(=(Count+7)div 8),byte(1),...,byte=1,1,2,2,1,1,...,1
      //  јдрес”стройства,mfWriteMultipleRegisters,StartAddress,Count,ByteCount(=Count*2),word(1),...,word=1,1,2,2,1,2,...,2
      //  јдрес”стройства,mfWriteMultipleCoils,StartAddress,Count=1,1,2,2
      //  јдрес”стройства,mfWriteMultipleRegisters,StartAddress,Count=1,1,2,2
      mfWriteMultipleRegisters: begin
        if Length(sRequest)<ndxStartAddress+1then begin Result:=ceCorruptedRequest{meElementWriteStartAddress}; exit; end;
        if Length(sRequest)<ndxElementCount+1then begin Result:=ceCorruptedRequest{meElementWriteCount}; exit; end;
        if Length(sResponse)<ndxStartAddress+1then begin Result:=ceFrameLength{meElementWriteStartAddress}; exit; end;
        if Length(sResponse)<ndxElementCount+1then begin Result:=ceFrameLength{meElementWriteCount}; exit; end;
        if byte(sRequest[ndxStartAddress])shl 8+byte(sRequest[ndxStartAddress+1])<>
          byte(sResponse[ndxStartAddress])shl 8+byte(sResponse[ndxStartAddress+1])then
          begin Result:=ceIncorrectResponse{meElementWriteStartAddress}; exit; end;
        if byte(sRequest[ndxElementCount])shl 8+byte(sRequest[ndxElementCount+1])<>
          byte(sResponse[ndxElementCount])shl 8+byte(sResponse[ndxElementCount+1])then
          begin Result:=ceIncorrectResponse{meElementWriteCount}; exit; end;
        Result:=meSuccess;
      end;
      //  јдрес”стройства,mfReadFileRecord,ByteCount,RefType(06),FileNumber,RecordNumber,RecordCount,...,
      //    RefType(06),FileNumber,RecordNumber,RecordCount=1,1,1,1,2,2,2,...,1,2,2,2
      //  јдрес”стройства,mfReadFileRecord,ResponseByteCount,SubrequestByteCount,RefType(06),word,...,word,...,
      //    SubrequestByteCount,RefType(06),word,...,word=1,1,1,1,1,2,...,2,...,1,1,2,...,2
      mfReadFileRecord: begin
//        i:=ndxRecordCount; w:=0; while i<Length(sResponse)do begin w:=w+byte(sRequest[i])shl 8+byte(sRequest[i+1]); inc(i,7); end;
        i:=ndxSubrequestByteCount; w:=0;
        while i+byte(sResponse[i])<=Length(sResponse)do begin
          if pDst<>nil then begin if iDstSize<w+byte(sResponse[i])-1then begin Result:=ceBufferSize; exit; end;
            CopyMemory(pointer(integer(pDst)+w),@sResponse[i+2],byte(sResponse[i])-1);
            inc(w,byte(sResponse[i])-1);
          end;
          inc(i,byte(sResponse[i])+1);
        end;
        ChangeBytes; Result:=meSuccess;
      end;
    else Result:=meUnknownFunctionCode; exit; end;
  except Result:=ceSysException; end;
end;

function TModbusProtocol.IsBroadcastRequest(const sRequest:AnsiString):boolean; begin
  case flwTransmissionMode of
    tmASCII: Result:=(Length(sRequest)>3)and(sRequest[2]='3')and(sRequest[3]='0');
    tmRTU: Result:=(sRequest<>'')and(byte(sRequest[1])=flwBroadcastAddress);
    tmTCP: Result:=(Length(sRequest)>7)and(byte(sRequest[7])=flwBroadcastAddress);
  else raise EqCDKexception.Create(GetErrorAsText(ceIncorrectTransmissionMode)); end;
end;

function TModbusProtocol.IsResponseSuccess(const ce:integer):boolean;
begin Result:=ce=meSuccess; end;

function TModbusProtocol.MakePacket(const sHexBody:AnsiString):AnsiString; var w:word; len:integer;
const sFormat='длина тела (%d) кадра переменной длины превышает максимальный размер (%d)'; begin
  len:=Length(sHexBody)div 2; if len>integer(flwMaxPacketSize)then raise EqCDKexception.Create(Format(sFormat,[len,flwMaxPacketSize],gfs));
  case flwTransmissionMode of
    tmASCII: Result:=':'+sHexBody+IntToHex(byte(-byte(CheckSum_CalculateLRC(Text_Hex2String(sHexBody)))),2)+#13#10;
    tmRTU: begin w:=CheckSum_CalculateCRC16(Text_Hex2String(sHexBody));
      Result:=sHexBody+IntToHex(lobyte(w),2)+IntToHex(hibyte(w),2); Result:=Text_Hex2String(Result);
    end;
    tmTCP: begin Result:='00000000'+IntToHex(Length(sHexBody)div 2,4)+sHexBody; Result:=Text_Hex2String(Result); end;
  else raise EqCDKexception.Create(GetErrorAsText(ceIncorrectTransmissionMode)); end;
end;

function TModbusProtocol.MakeRequest(arrPacketData:array of Int64):AnsiString; var me,ndx:integer;
const sFormat='ќшибка формировани€ запроса в позиции %d: %s';
begin me:=MakeRequest(arrPacketData,Result,ndx);
  if me<>ceSuccess then if me<>meUnknownFunctionCode then EqCDKexception.Create(Format(sFormat,[ndx,GetErrorAsText(me)],gfs))
    else raise EqCDKexception.Create(Format(sFormat,[ndx,GetErrorAsText(me)+'0x'+IntToHex(arrPacketData[1],2)],gfs));
end;

function TModbusProtocol.MakeRequest(arrPacketData:array of Int64; out sRequest:AnsiString; out ndxError:integer):integer; var i,j:integer; b:boolean;
  const ndxDeviceAddress=0; ndxModbusFunction=1;
    ndxStartAddress=2; ndxElementCount=3; ndxByteCount=4;
    ndxWriteAddress=2; ndxWriteValue=3;
    ndxRequestSize=2;
    ndxRecordType=0; ndxFileNumber=1; ndxRecordNumber=2; ndxRecordLength=3;
    ndxMaskAnd=3; ndxMaskOr=4;
    ndxReadStartAddress=2; ndxReadCount=3; ndxWriteStartAddress=4; ndxWriteCount=5; ndxWriteByteCount=6;
begin sRequest:='';
  if(Length(arrPacketData)=0)then begin Result:=meDeviceAddress; ndxError:=ndxDeviceAddress; exit; end;
  if Length(arrPacketData)<ndxModbusFunction+1then begin Result:=meFunctionCode; ndxError:=ndxModbusFunction; exit; end;
  arrPacketData[ndxDeviceAddress]:=byte(arrPacketData[ndxDeviceAddress]); arrPacketData[ndxModbusFunction]:=TModbusFunction(arrPacketData[ndxModbusFunction]);
  sRequest:=IntToHex(arrPacketData[ndxDeviceAddress],2)+IntToHex(arrPacketData[ndxModbusFunction],2);
  case arrPacketData[ndxModbusFunction]of
    //  јдрес”стройства,mfReadCoils,StartAddress,ElementCount=1,1,2,2
    //  јдрес”стройства,mfReadDiscreteInputs,StartAddress,ElementCount=1,1,2,2
    //  јдрес”стройства,mfReadHoldingRegisters,StartAddress,ElementCount=1,1,2,2
    //  јдрес”стройства,mfReadInputRegisters,StartAddress,ElementCount=1,1,2,2
    mfReadCoils,mfReadDiscreteInputs,mfReadHoldingRegisters,mfReadInputRegisters: begin
      if Length(arrPacketData)<ndxStartAddress+1then begin Result:=meElementReadStartAddress; ndxError:=ndxStartAddress; exit; end;
      if Length(arrPacketData)<ndxElementCount+1then begin Result:=meElementReadCount; ndxError:=ndxElementCount; exit; end;
      arrPacketData[ndxStartAddress]:=word(arrPacketData[ndxStartAddress]); arrPacketData[ndxElementCount]:=word(arrPacketData[ndxElementCount]);
      sRequest:=sRequest+IntToHex(arrPacketData[ndxStartAddress],4)+IntToHex(arrPacketData[ndxElementCount],4);
    end;
    //  јдрес”стройства,mfWriteSingleCoil,Address,Value(=0xFF00 или 0x0000)=1,1,2,2
    //  јдрес”стройства,mfWriteSingleRegister,Address,Value=1,1,2,2
    mfWriteSingleCoil,mfWriteSingleRegister: begin
      if Length(arrPacketData)<ndxWriteAddress+1then begin Result:=meElementWriteAddress; ndxError:=ndxWriteAddress; exit; end;
      if Length(arrPacketData)<ndxWriteValue+1then begin Result:=meElementWriteValue; ndxError:=ndxWriteValue; exit; end;
      arrPacketData[ndxWriteAddress]:=word(arrPacketData[ndxWriteAddress]);
      if arrPacketData[ndxModbusFunction]=mfWriteSingleCoil then
        if boolean(arrPacketData[ndxWriteValue])then arrPacketData[ndxWriteValue]:=$FF00 else arrPacketData[ndxWriteValue]:=word(arrPacketData[ndxWriteValue]);
      sRequest:=sRequest+IntToHex(arrPacketData[ndxWriteAddress],4)+IntToHex(arrPacketData[ndxWriteValue],4);
    end;
    //  јдрес”стройства,mfReadExceptionStatus=1,1
    //  јдрес”стройства,mfFetchCommEventCounter=1,1
    //  јдрес”стройства,mfFetchCommEventLog=1,1
    mfReadExceptionStatus,mfFetchCommEventCounter,mfFetchCommEventLog:;
    //  јдрес”стройства,mfWriteMultipleCoils,StartAddress,Count,ByteCount(=(Count+7)div 8),byte(1),...,byte=1,1,2,2,1,1,...,1
    //  јдрес”стройства,mfWriteMultipleRegisters,StartAddress,Count,ByteCount(=Count*2),word(1),...,word=1,1,2,2,1,2,...,2
    mfWriteMultipleCoils,mfWriteMultipleRegisters: begin
      if Length(arrPacketData)<ndxStartAddress+1then begin Result:=meElementWriteStartAddress; ndxError:=ndxStartAddress; exit; end;
      if Length(arrPacketData)<ndxElementCount+1then begin Result:=meElementWriteCount; ndxError:=ndxElementCount; exit; end;
      if Length(arrPacketData)<ndxByteCount+1then begin Result:=meElementWriteByteCount; ndxError:=ndxByteCount; exit; end;
      arrPacketData[ndxStartAddress]:=word(arrPacketData[ndxStartAddress]); arrPacketData[ndxElementCount]:=word(arrPacketData[ndxElementCount]);
      case arrPacketData[ndxModbusFunction]of
        mfWriteMultipleCoils: begin arrPacketData[ndxByteCount]:=(arrPacketData[ndxElementCount]+7)div 8;
          if Length(arrPacketData)<ndxByteCount+1+arrPacketData[ndxByteCount]then begin Result:=meElementWriteValues; ndxError:=Length(arrPacketData)-1; exit; end;
          sRequest:=sRequest+IntToHex(arrPacketData[ndxStartAddress],4)+IntToHex(arrPacketData[ndxElementCount],4)+IntToHex(arrPacketData[ndxByteCount],2);
          for i:=ndxByteCount+1to ndxByteCount+1+arrPacketData[ndxByteCount]-1do begin
            arrPacketData[i]:=word(arrPacketData[i]); sRequest:=sRequest+IntToHex(arrPacketData[i],2);
          end;
        end;
        mfWriteMultipleRegisters: begin arrPacketData[ndxByteCount]:=arrPacketData[ndxElementCount]*2;
          if Length(arrPacketData)<ndxByteCount+1+(arrPacketData[ndxByteCount]+1)div 2then begin Result:=meElementWriteValues; ndxError:=Length(arrPacketData)-1; exit; end;
          sRequest:=sRequest+IntToHex(arrPacketData[ndxStartAddress],4)+IntToHex(arrPacketData[ndxElementCount],4)+IntToHex(arrPacketData[ndxByteCount],2);
          for i:=ndxByteCount+1to ndxByteCount+1+(arrPacketData[ndxByteCount]+1)div 2-1do begin
            arrPacketData[i]:=word(arrPacketData[i]); sRequest:=sRequest+IntToHex(arrPacketData[i],4);
          end;
        end;
      end;
    end;
    //  јдрес”стройства,mfReadFileRecord,ByteCount,RefType(06),FileNumber,RecordNumber,RecordCount,...,
    //    RefType(06),FileNumber,RecordNumber,RecordCount=1,1,1,1,2,2,2,...,1,2,2,2
    //  јдрес”стройства,mfWriteFileRecord,ByteCount,RefType(06),FileNumber,RecordNumber,RecordCount(=N),word(1),...,word(N),
    //    RefType(06),FileNumber,RecordNumber,RecordCount(=M),word(1),...,word(M)=1,1,1,1,2,2,2,2,...,2,...,1,2,2,2,2,...,2
    mfReadFileRecord,mfWriteFileRecord: begin b:=arrPacketData[ndxModbusFunction]=mfWriteFileRecord;
      if Length(arrPacketData)<ndxRequestSize+1then begin Result:=meFileRequestSize; ndxError:=ndxRequestSize; exit; end;
      arrPacketData[ndxRequestSize]:=0; i:=ndxRequestSize+1;
      repeat if Length(arrPacketData)<i+4then break;
        if Length(arrPacketData)<i+ndxRecordType+1then begin Result:=meFileSubRequestType; ndxError:=ndxRecordType; exit; end;
        if Length(arrPacketData)<i+ndxFileNumber+1then begin Result:=meFileSubRequestFileNumber; ndxError:=i+ndxFileNumber; exit; end;
        if Length(arrPacketData)<i+ndxRecordNumber+1then begin Result:=meFileSubRequestAddress; ndxError:=i+ndxRecordNumber; exit; end;
        if Length(arrPacketData)<i+ndxRecordLength+1then begin Result:=meFileSubRequestLength; ndxError:=i+ndxRecordLength; exit; end;
        arrPacketData[i+ndxRecordType]:=6; arrPacketData[i+ndxFileNumber]:=word(arrPacketData[i+ndxFileNumber]);
        arrPacketData[i+ndxRecordNumber]:=word(arrPacketData[i+ndxRecordNumber]); arrPacketData[i+ndxRecordLength]:=word(arrPacketData[i+ndxRecordLength]);
        if b then begin
          if(Length(arrPacketData)<i+ndxRecordLength+1+arrPacketData[i+ndxRecordLength])then begin Result:=meElementWriteValues; ndxError:=Length(arrPacketData)-1; exit; end;
          for j:=i+ndxRecordLength+1to i+ndxRecordLength+1+arrPacketData[i+ndxRecordLength]-1do arrPacketData[j]:=word(arrPacketData[j]);
        end;
        inc(arrPacketData[ndxRequestSize],7);
        if b then begin inc(arrPacketData[ndxRequestSize],arrPacketData[i+ndxRecordLength]*2); inc(i,arrPacketData[i+ndxRecordLength]); end;
        inc(i,4);
      until false;
      sRequest:=sRequest+IntToHex(arrPacketData[ndxRequestSize],2);
      i:=ndxRequestSize+1;
      repeat if Length(arrPacketData)<i+4then break;
        sRequest:=sRequest+IntToHex(arrPacketData[i+ndxRecordType],2)+IntToHex(arrPacketData[i+ndxFileNumber],4)+
          IntToHex(arrPacketData[i+ndxRecordNumber],4)+IntToHex(arrPacketData[i+ndxRecordLength],4);
        if b then for j:=i+ndxRecordLength+1to i+ndxRecordLength+1+arrPacketData[i+ndxRecordLength]-1do
          sRequest:=sRequest+IntToHex(arrPacketData[j],4);
        if b then inc(i,arrPacketData[i+ndxRecordLength]); inc(i,4);
      until false;
    end;
    //  јдрес”стройства,mfMaskWriteRegister,Address,AndMask,OrMask=1,1,2,2,2
    mfMaskWriteRegister: begin
      if Length(arrPacketData)<ndxWriteAddress+1then begin Result:=meElementWriteAddress; ndxError:=ndxWriteAddress; exit; end;
      if Length(arrPacketData)<ndxMaskAnd+1then begin Result:=meElementWriteMaskAnd; ndxError:=ndxMaskAnd; exit; end;
      if Length(arrPacketData)<ndxMaskOr+1then begin Result:=meElementWriteMaskOr; ndxError:=ndxMaskOr; exit; end;
      arrPacketData[ndxWriteAddress]:=word(arrPacketData[ndxWriteAddress]);
      arrPacketData[ndxMaskAnd]:=word(arrPacketData[ndxMaskAnd]); arrPacketData[ndxMaskOr]:=word(arrPacketData[ndxMaskOr]);
      sRequest:=sRequest+IntToHex(arrPacketData[ndxWriteAddress],4)+
        IntToHex(arrPacketData[ndxMaskAnd],4)+IntToHex(arrPacketData[ndxMaskOr],4);
    end;
    //  јдрес”стройства,mfReadWriteMultipleRegisters,ReadStartAddress,ReadElementCount,
    //    WriteStartAddress,Count,ByteCount(=Count*2),word(1),...,word=1,1,2,2,    2,2,1,2,...,2
    mfReadWriteMultipleRegisters: begin
      if Length(arrPacketData)<ndxReadStartAddress+1then begin Result:=meElementReadStartAddress; ndxError:=ndxReadStartAddress; exit; end;
      if Length(arrPacketData)<ndxReadCount+1then begin Result:=meElementReadCount; ndxError:=ndxReadCount; exit; end;
      if Length(arrPacketData)<ndxWriteStartAddress+1then begin Result:=meElementWriteStartAddress; ndxError:=ndxWriteStartAddress; exit; end;
      if Length(arrPacketData)<ndxWriteCount+1then begin Result:=meElementWriteCount; ndxError:=ndxWriteCount; exit; end;
      if Length(arrPacketData)<ndxWriteByteCount+1then begin Result:=meElementWriteByteCount; ndxError:=ndxWriteByteCount; exit; end;
      arrPacketData[ndxReadStartAddress]:=word(arrPacketData[ndxReadStartAddress]); arrPacketData[ndxReadCount]:=word(arrPacketData[ndxReadCount]);
      arrPacketData[ndxWriteStartAddress]:=word(arrPacketData[ndxWriteStartAddress]); arrPacketData[ndxWriteCount]:=word(arrPacketData[ndxWriteCount]);
      arrPacketData[ndxWriteByteCount]:=arrPacketData[ndxWriteCount]*2;
      if Length(arrPacketData)<ndxWriteByteCount+1+(arrPacketData[ndxWriteByteCount]+1)div 2then begin Result:=meElementWriteValues; ndxError:=Length(arrPacketData)-1; exit; end;
      sRequest:=sRequest+IntToHex(arrPacketData[ndxReadStartAddress],4)+IntToHex(arrPacketData[ndxReadCount],4)+
        IntToHex(arrPacketData[ndxWriteStartAddress],4)+IntToHex(arrPacketData[ndxWriteCount],4)+
        IntToHex(arrPacketData[ndxWriteByteCount],2);
      for i:=ndxWriteByteCount+1to ndxWriteByteCount+1+(arrPacketData[ndxWriteByteCount]+1)div 2-1do begin
        arrPacketData[i]:=word(arrPacketData[i]); sRequest:=sRequest+IntToHex(arrPacketData[i],4);
      end;
    end;
  else Result:=meUnknownFunctionCode; exit; end;
  sRequest:=MakePacket(sRequest); Result:=meSuccess;
end;

function TModbusProtocol.MakeResponse(arrPacketData:array of Int64):AnsiString; var me,ndx:integer;
const sFormat='ќшибка формировани€ запроса в позиции %d: %s';
begin me:=MakeRequest(arrPacketData,Result,ndx);
  if me<>ceSuccess then if me<>meUnknownFunctionCode then EqCDKexception.Create(Format(sFormat,[ndx,GetErrorAsText(me)],gfs))
    else raise EqCDKexception.Create(Format(sFormat,[ndx,GetErrorAsText(me)+'0x'+IntToHex(arrPacketData[1],2)],gfs));
end;

function TModbusProtocol.MakeResponse(arrPacketData:array of Int64; out sResponse:AnsiString; out ndxError:integer):integer; var i,j:integer; b:boolean;
  const ndxDeviceAddress=0; ndxModbusFunction=1;
    ndxExceptionCode=2;
    ndxReadByteCount=2;
    ndxWriteAddress=2; ndxWriteValue=3;
    ndxReadExceptionStatus=2;
    ndxCommStatus=2; ndxCommEventCount=3;
    ndxCommStatusLog=3; ndxCommEventCountLog=4; ndxCommMessageCountLog=5;
    ndxStartAddress=2; ndxElementCount=3;
    ndxResponseSize=2;
    ndxRecordLength=0; ndxRecordType=1; 

    ndxMaskAnd=3; ndxMaskOr=4;
begin sResponse:='';
  if(Length(arrPacketData)=0)then begin Result:=meDeviceAddress; ndxError:=ndxDeviceAddress; exit; end;
  if Length(arrPacketData)<ndxModbusFunction+1then begin Result:=meFunctionCode; ndxError:=ndxModbusFunction; exit; end;
  arrPacketData[ndxDeviceAddress]:=byte(arrPacketData[ndxDeviceAddress]); arrPacketData[ndxModbusFunction]:=TModbusFunction(arrPacketData[ndxModbusFunction]);
  sResponse:=IntToHex(arrPacketData[ndxDeviceAddress],2)+IntToHex(arrPacketData[ndxModbusFunction],2);
  if arrPacketData[ndxModbusFunction]>=$80then begin
    if Length(arrPacketData)<ndxExceptionCode+1then begin Result:=meExceptionCode; ndxError:=ndxExceptionCode; exit; end;
    arrPacketData[ndxExceptionCode]:=byte(arrPacketData[ndxExceptionCode]);
    sResponse:=sResponse+IntToHex(arrPacketData[ndxExceptionCode],2);
  end else case arrPacketData[ndxModbusFunction]of
    //  јдрес”стройства,mfReadCoils,ByteCount,byte,...,byte=1,1,1,1,...,1
    //  јдрес”стройства,mfReadDiscreteInputs,ByteCount,byte,...,byte=1,1,1,1,...,1
    //  јдрес”стройства,mfReadHoldingRegisters,ByteCount(=RegisterCount*2),word,...,word=1,1,1,2,...,2
    //  јдрес”стройства,mfReadInputRegisters,ByteCount(=RegisterCount*2),word,...,word=1,1,1,2,...,2
    mfReadCoils,mfReadDiscreteInputs,mfReadHoldingRegisters,mfReadInputRegisters: begin
      b:=arrPacketData[ndxModbusFunction]in[mfReadHoldingRegisters,mfReadInputRegisters];
      if Length(arrPacketData)<ndxReadByteCount+1then begin Result:=meElementReadByteCount; ndxError:=ndxReadByteCount; exit; end;
      case arrPacketData[ndxModbusFunction]of
        mfReadCoils,mfReadDiscreteInputs: arrPacketData[ndxReadByteCount]:=byte(arrPacketData[ndxReadByteCount]);
        mfReadHoldingRegisters,mfReadInputRegisters: arrPacketData[ndxReadByteCount]:=byte(arrPacketData[ndxReadByteCount])and$FE;
      end;
      i:=byte(arrPacketData[ndxReadByteCount]); if b then i:=i div 2;
      if Length(arrPacketData)<ndxReadByteCount+1+i then begin Result:=meElementReadValues; ndxError:=Length(arrPacketData)-1; exit; end;
      sResponse:=sResponse+IntToHex(arrPacketData[ndxReadByteCount],2);
      for i:=ndxReadByteCount+1to ndxReadByteCount+1+i-1do
        if b then begin arrPacketData[i]:=word(arrPacketData[i]); sResponse:=sResponse+IntToHex(arrPacketData[i],4); end
        else begin arrPacketData[i]:=byte(arrPacketData[i]); sResponse:=sResponse+IntToHex(arrPacketData[i],2); end;
    end;
    //  јдрес”стройства,mfWriteSingleCoil,Address,Value(0xFF00/0x0000)=1,1,2,2
    //  јдрес”стройства,mfWriteSingleRegister,Address,Value=1,1,2,2
    mfWriteSingleCoil,mfWriteSingleRegister: begin Result:=MakeRequest(arrPacketData,sResponse,ndxError); exit; end;
    //  јдрес”стройства,mfReadExceptionStatus,Data=1,1,1
    mfReadExceptionStatus: begin
      if Length(arrPacketData)<ndxReadExceptionStatus+1then begin Result:=meElementReadValues; ndxError:=ndxReadExceptionStatus; exit; end;
      arrPacketData[ndxReadExceptionStatus]:=byte(arrPacketData[ndxReadExceptionStatus]);
      sResponse:=sResponse+IntToHex(arrPacketData[ndxReadExceptionStatus],2);
    end;
    //  јдрес”стройства,mfFetchCommEventCounter,Status,EventCount=1,1,2,2
    mfFetchCommEventCounter: begin
      if Length(arrPacketData)<ndxCommStatus+1then begin Result:=meElementReadValues; ndxError:=ndxCommStatus; exit; end;
      if Length(arrPacketData)<ndxCommEventCount+1then begin Result:=meElementReadValues; ndxError:=ndxCommEventCount; exit; end;
      arrPacketData[ndxCommStatus]:=word(arrPacketData[ndxCommStatus]); arrPacketData[ndxCommEventCount]:=word(arrPacketData[ndxCommEventCount]);
      sResponse:=sResponse+IntToHex(arrPacketData[ndxCommStatus],4)+IntToHex(arrPacketData[ndxCommEventCount],4);
    end;
    //  јдрес”стройства,mfFetchCommEventLog,ByteCount(=N),Status,EventCount,MsgCount,Event(1),...,Event(N-6)=1,1,1,2,2,2,1,...,1
    mfFetchCommEventLog: begin
      if Length(arrPacketData)<ndxReadByteCount+1then begin Result:=meElementReadByteCount; ndxError:=ndxReadByteCount; exit; end;
      if Length(arrPacketData)<ndxCommStatusLog+1then begin Result:=meElementReadValues; ndxError:=ndxCommStatusLog; exit; end;
      if Length(arrPacketData)<ndxCommEventCountLog+1then begin Result:=meElementReadValues; ndxError:=ndxCommEventCountLog; exit; end;
      if Length(arrPacketData)<ndxCommMessageCountLog+1then begin Result:=meElementReadValues; ndxError:=ndxCommMessageCountLog; exit; end;
      arrPacketData[ndxReadByteCount]:=byte(arrPacketData[ndxReadByteCount]); arrPacketData[ndxCommStatusLog]:=word(arrPacketData[ndxCommStatusLog]);
      arrPacketData[ndxCommEventCountLog]:=word(arrPacketData[ndxCommEventCountLog]); arrPacketData[ndxCommMessageCountLog]:=word(arrPacketData[ndxCommMessageCountLog]);
      i:=byte(arrPacketData[ndxReadByteCount]); dec(i,6); if i<0then begin Result:=meElementReadValues; ndxError:=Length(arrPacketData)-1; exit; end;
      if Length(arrPacketData)<ndxReadByteCount+1+i then begin Result:=meElementReadValues; ndxError:=Length(arrPacketData)-1; exit; end;
      sResponse:=sResponse+IntToHex(arrPacketData[ndxReadByteCount],2)+IntToHex(arrPacketData[ndxCommStatusLog],4)
        +IntToHex(arrPacketData[ndxCommEventCountLog],4)+IntToHex(arrPacketData[ndxCommMessageCountLog],4);
      for i:=ndxCommMessageCountLog+1to ndxCommMessageCountLog+1+i-1do
        begin arrPacketData[i]:=byte(arrPacketData[i]); sResponse:=sResponse+IntToHex(arrPacketData[i],2); end;
    end;
    //  јдрес”стройства,mfWriteMultipleCoils,StartAddress,Count=1,1,2,2
    //  јдрес”стройства,mfWriteMultipleRegisters,StartAddress,Count=1,1,2,2
    mfWriteMultipleCoils,mfWriteMultipleRegisters: begin
      if Length(arrPacketData)<ndxStartAddress+1then begin Result:=meElementWriteStartAddress; ndxError:=ndxStartAddress; exit; end;
      if Length(arrPacketData)<ndxElementCount+1then begin Result:=meElementWriteCount; ndxError:=ndxElementCount; exit; end;
      arrPacketData[ndxStartAddress]:=word(arrPacketData[ndxStartAddress]); arrPacketData[ndxElementCount]:=word(arrPacketData[ndxElementCount]);
      sResponse:=sResponse+IntToHex(arrPacketData[ndxStartAddress],4)+IntToHex(arrPacketData[ndxElementCount],4);
    end;
    //  јдрес”стройства,mfReadFileRecord,ResponseByteCount,SubrequestByteCount,RefType(06),word,...,word,...,
    //    SubrequestByteCount,RefType(06),word,...,word=1,1,1,1,1,2,...,2,...,1,1,2,...,2
    mfReadFileRecord: begin
      if Length(arrPacketData)<ndxResponseSize+1then begin Result:=meFileRequestSize; ndxError:=ndxResponseSize; exit; end;
      arrPacketData[ndxResponseSize]:=0; i:=ndxResponseSize+1;
      repeat if Length(arrPacketData)<i+2then break;
        if Length(arrPacketData)<i+ndxRecordLength+1then begin Result:=meFileSubRequestLength; ndxError:=i+ndxRecordLength; exit; end;
        if Length(arrPacketData)<i+ndxRecordType+1then begin Result:=meFileSubRequestType; ndxError:=ndxRecordType; exit; end;
        arrPacketData[i+ndxRecordLength]:=byte(arrPacketData[i+ndxRecordLength])or$01; arrPacketData[i+ndxRecordType]:=6;
        if(Length(arrPacketData)<i+ndxRecordType+1+arrPacketData[i+ndxRecordLength]div 2)then begin Result:=meElementReadValues; ndxError:=Length(arrPacketData)-1; exit; end;
        for j:=i+ndxRecordType+1to i+ndxRecordType+1+arrPacketData[i+ndxRecordLength]div 2-1do arrPacketData[j]:=word(arrPacketData[j]);
        inc(arrPacketData[ndxResponseSize],1+arrPacketData[i+ndxRecordLength]); inc(i,arrPacketData[i+ndxRecordLength]div 2); inc(i,2);
      until false;
      sResponse:=sResponse+IntToHex(arrPacketData[ndxResponseSize],2);
      i:=ndxResponseSize+1;
      repeat if Length(arrPacketData)<i+2then break;
        sResponse:=sResponse+IntToHex(arrPacketData[i+ndxRecordLength],2)+IntToHex(arrPacketData[i+ndxRecordType],2);
        for j:=i+ndxRecordType+1to i+ndxRecordType+1+arrPacketData[i+ndxRecordLength]div 2-1do
          sResponse:=sResponse+IntToHex(arrPacketData[j],4);
        inc(i,arrPacketData[i+ndxRecordLength]div 2); inc(i,2);
      until false;
    end;
    //  јдрес”стройства,mfWriteFileRecord,ByteCount,RefType(06),FileNumber,RecordNumber,RecordCount(=N),word(1),...,word(N),
    //    RefType(06),FileNumber,RecordNumber,RecordCount(=M),word(1),...,word(M)=1,1,1,1,2,2,2,2,...,2,...,1,2,2,2,2,...,2
    mfWriteFileRecord: begin Result:=MakeRequest(arrPacketData,sResponse,ndxError); exit; end;
    //  јдрес”стройства,mfMaskWriteRegister,Address,AndMask,OrMask=1,1,2,2,2
    mfMaskWriteRegister: begin
      if Length(arrPacketData)<ndxWriteAddress+1then begin Result:=meElementWriteAddress; ndxError:=ndxWriteAddress; exit; end;
      if Length(arrPacketData)<ndxMaskAnd+1then begin Result:=meElementWriteMaskAnd; ndxError:=ndxMaskAnd; exit; end;
      if Length(arrPacketData)<ndxMaskOr+1then begin Result:=meElementWriteMaskOr; ndxError:=ndxMaskOr; exit; end;
      arrPacketData[ndxWriteAddress]:=word(arrPacketData[ndxWriteAddress]);
      arrPacketData[ndxMaskAnd]:=word(arrPacketData[ndxMaskAnd]); arrPacketData[ndxMaskOr]:=word(arrPacketData[ndxMaskOr]);
      sResponse:=sResponse+IntToHex(arrPacketData[ndxWriteAddress],4)+
        IntToHex(arrPacketData[ndxMaskAnd],4)+IntToHex(arrPacketData[ndxMaskOr],4);
    end;
    //  јдрес”стройства,mfReadWriteMultipleRegisters,ByteCount(=RegisterCount*2),word,...,word=1,1,1,2,...,2
    mfReadWriteMultipleRegisters: begin
      if Length(arrPacketData)<ndxReadByteCount+1then begin Result:=meElementReadByteCount; ndxError:=ndxReadByteCount; exit; end;
      arrPacketData[ndxReadByteCount]:=byte(arrPacketData[ndxReadByteCount])and$FE;
      i:=byte(arrPacketData[ndxReadByteCount])div 2;
      if Length(arrPacketData)<ndxReadByteCount+1+i then begin Result:=meElementReadValues; ndxError:=Length(arrPacketData)-1; exit; end;
      sResponse:=sResponse+IntToHex(arrPacketData[ndxReadByteCount],2);
      for i:=ndxReadByteCount+1to ndxReadByteCount+1+i-1do
        begin arrPacketData[i]:=word(arrPacketData[i]); sResponse:=sResponse+IntToHex(arrPacketData[i],4); end
    end;
  else Result:=meUnknownFunctionCode; exit; end;
  sResponse:=MakePacket(sResponse); Result:=meSuccess;
end;

procedure TModbusProtocol.SetDefault; begin
  try Lock; BeginUpdate;
    inherited SetDefault; // просто измен€ем все свойства
    fsCaption:='ModbusProtocol_0x'+IntToHex(fhID,8); fsName:=fsCaption; fsDescription:=GetClassCaption;
    flwAddressSize:=1; flwBroadcastAddress:=0; flwMaxPacketSize:=lwMaxPacketSize; 
  finally EndUpdate; Unlock; end;
end;

{ TModbusProtocol_BEMP }

class function TModbusProtocol_BEMP.GetClassCaption: AString;
begin Result:='протокол Modbus дл€ устройств ЅЁћѕ (TModbusProtocol_BEMP)'; end;

class function TModbusProtocol_BEMP.GetClassDescription:AString;
begin Result:='протокол Modbus класса TModbusProtocol реализует стандартные функции, функцию чтени€ осциллограмм устройств ЅЁћѕ и режимы передачи ASCII,RTU,TCP'; end;

function TModbusProtocol_BEMP.HandleResponse(sRequest,sResponse:AnsiString; pDst:pointer; iDstSize:integer):integer; var s:AnsiString; w:word; i:integer; 
const ndxModbusFunction=2; ndxReadByteCount=3; ndxElementReadCount=5;
  procedure ChangeBytes; var i:integer; begin
    if pDst<>nil then for i:=0to iDstSize shr 1-1do // мен€ем
      begin w:=pbyte(integer(pDst)+2*i)^; pbyte(integer(pDst)+2*i)^:=pbyte(integer(pDst)+2*i+1)^; pbyte(integer(pDst)+2*i+1)^:=w; end;
  end;
begin Result:=inherited HandleResponse(sRequest,sResponse,pDst,iDstSize);
  if(Result=meUnknownFunctionCode)then try
    case flwTransmissionMode of
      tmASCII: begin if Length(sRequest)<6then begin Result:=ceCorruptedRequest; exit; end;
        if Length(sResponse)<6then begin Result:=ceCorruptedResponse; exit; end;
        s:=Copy(sResponse,2,Length(sResponse)-5); w:=byte(-byte(CheckSum_CalculateLRC(Text_Hex2String(s))));
        if w<>StrToInt('0x'+sResponse[Length(sResponse)-3]+sResponse[Length(sResponse)-2])then
          begin Result:=ceFrameCRC; exit; end;
        sRequest:=Text_Hex2String(Copy(sRequest,2,Length(sRequest)-5)); sResponse:=Text_Hex2String(s);
      end;
      tmRTU: begin if Length(sRequest)<4then begin Result:=ceCorruptedRequest; exit; end;
        if Length(sResponse)<4then begin Result:=ceCorruptedResponse; exit; end;
        s:=Copy(sResponse,1,Length(sResponse)-2); w:=CheckSum_CalculateCRC16(Text_Hex2String(s));
        if w<>byte(sResponse[Length(sResponse)-1])shl 8+byte(sResponse[Length(sResponse)])then
          begin Result:=ceFrameCRC; exit; end;
        sRequest:=Copy(sRequest,1,Length(sRequest)-2); sResponse:=s;
      end;
      tmTCP: begin if Length(sRequest)<8then begin Result:=ceCorruptedRequest; exit; end;
        if Length(sResponse)<8then begin Result:=ceCorruptedResponse; exit; end;
        if Copy(sRequest,1,4)<>Copy(sResponse,1,4)then begin Result:=ceIncorrectResponse; exit; end; // начало должно совпадать в запросе и в отвевте
        sRequest:=Copy(sRequest,7,MaxInt); sResponse:=Copy(sResponse,7,MaxInt);
      end;
    end;
    case TModbusFunction(sResponse[ndxModbusFunction])of
      mfReadScopeRecords: begin
        //  јдрес”стройства,mfReadScopeRecords,StartAddress,ElementCount=1,1,2,2
        //  јдрес”стройства,mfReadScopeRecords,ByteCount(=RegisterCount*2),word,...,word=1,1,1,2,...,2
        if Length(sResponse)<ndxReadByteCount then begin Result:=meElementReadByteCount; exit; end;
        if Length(sResponse)<ndxReadByteCount+byte(sResponse[ndxReadByteCount])then begin Result:=meElementReadValues; exit; end;
        //if Length(sRequest)<ndxElementReadCount+1then begin Result:=meElementReadCount; exit; end;
        i:=byte(sResponse[ndxReadByteCount]); //if i<>iDstSize then inc(i,256);
        if pDst<>nil then begin if i>iDstSize then begin Result:=ceBufferSize; exit; end;
          CopyMemory(pDst,@sResponse[ndxReadByteCount+1],i); ChangeBytes;
        end;
        Result:=meSuccess;
      end;
    end;
  except Result:=ceSysException; end;
end;

function TModbusProtocol_BEMP.MakeRequest(arrPacketData:array of Int64; out sRequest:AnsiString; out ndxError:integer):integer;
const ndxDeviceAddress=0; ndxModbusFunction=1; ndxStartAddress=2; ndxElementCount=3; begin
  if(Length(arrPacketData)>1)and(arrPacketData[1]=mfReadScopeRecords){and(Result=meUnknownFunctionCode)}then begin
    //  јдрес”стройства,mfReadScopeRecords,StartAddress,ElementCount=1,1,2,2
    if Length(arrPacketData)<ndxStartAddress+1then begin Result:=meElementReadStartAddress; ndxError:=ndxStartAddress; exit; end;
    if Length(arrPacketData)<ndxElementCount+1then begin Result:=meElementReadCount; ndxError:=ndxElementCount; exit; end;
    arrPacketData[ndxStartAddress]:=word(arrPacketData[ndxStartAddress]); arrPacketData[ndxElementCount]:=word(arrPacketData[ndxElementCount]);
    sRequest:=IntToHex(arrPacketData[ndxDeviceAddress],2)+IntToHex(arrPacketData[ndxModbusFunction],2)+
      IntToHex(arrPacketData[ndxStartAddress],4)+IntToHex(arrPacketData[ndxElementCount],4);
    sRequest:=MakePacket(sRequest); Result:=meSuccess;
  end else Result:=inherited MakeRequest(arrPacketData,sRequest,ndxError);
end;

function TModbusProtocol_BEMP.MakeResponse(arrPacketData:array of Int64; out sResponse:AnsiString; out ndxError:integer):integer;
var i:integer; const ndxReadByteCount=2; begin
  if(Length(arrPacketData)>1)and(arrPacketData[1]=mfReadScopeRecords){and(Result=meUnknownFunctionCode)}then begin
    //  јдрес”стройства,mfReadScopeRecords,ByteCount(=RegisterCount*2),word,...,word=1,1,1,2,...,2
    if Length(arrPacketData)<ndxReadByteCount+1then begin Result:=meElementReadByteCount; ndxError:=ndxReadByteCount; exit; end;
    arrPacketData[ndxReadByteCount]:=byte(arrPacketData[ndxReadByteCount])and$FE;
    i:=byte(arrPacketData[ndxReadByteCount])div 2;
    if Length(arrPacketData)<ndxReadByteCount+1+i then begin Result:=meElementReadValues; ndxError:=Length(arrPacketData)-1; exit; end;
    sResponse:=sResponse+IntToHex(arrPacketData[ndxReadByteCount],2);
    for i:=ndxReadByteCount+1to ndxReadByteCount+1+i-1do
      begin arrPacketData[i]:=word(arrPacketData[i]); sResponse:=sResponse+IntToHex(arrPacketData[i],4); end;
    sResponse:=MakePacket(sResponse); Result:=meSuccess;
  end else Result:=inherited MakeResponse(arrPacketData,sResponse,ndxError);
end;

initialization
  GetLocaleFormatSettings(SysLocale.DefaultLCID,gfs);
  RegisterClasses;

end.
