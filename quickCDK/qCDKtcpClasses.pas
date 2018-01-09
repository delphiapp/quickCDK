unit qCDKtcpClasses;

interface

uses Windows,SysUtils,IdTCPClient,IdTCPServer,
  uCalcTypes,qCDKclasses;

type
  TTCPClientSocket=class(TCommunicationSocket)
  protected
    fsServer:AnsiString; flwPort:longword;
    fTCPClient:TIdTCPClient;
    ct:TCommTimeouts;
  protected
    function DoGetUInt(const ndx:integer):UInt64; override;               // ��� ����������� ����� ��������

    function DoCreateHandle:THandle; override;         // ���������� ����� ������ ���������������� ������ �������
    procedure DoDestroyHandle; override;               // ���������� ����� ������ ����������� ��������� �������
  public
    class function GetClassCaption:AString; override;       // �������� ������
    class function GetClassDescription:AString; override;   // ��������� �������� ������

    constructor Create(sCommName:AnsiString; bOverlapped:boolean=false); override;
    class function GetObjectByName(sName:AnsiString):TCommunicationObject; override; // ����� ������� �� ����� - ��� ��������� �� �����
    procedure SetDefault; override;

    // �������� ��� ��������� ���������� �������� ��� ���������������� ��������, ���������� ���������� ������� ���������
    function _CancelIo:boolean; override;
    // ������� ��� ������ � ��������� ������ ���� ���������������� ������ � ��������� ���������������� ������
    function _FlushFileBuffers:boolean; override;
    // ���������� ������� ����� ������� ����������������� �������
    function _GetCommMask(var lwEventMask:longword):boolean; override;
    // ���������� ��������� ��������� ��� ���� �������� ������ � ������ ��� ���������� ����������������� �������
    function _GetCommTimeouts(var rCommTimeouts:TCommTimeouts):boolean; override;
    // ������ ���������� � ����������� ������ � ���������� �������� ���������� ����������� ��������
    function _GetOverlappedResult(const prOverlapped:POverlapped; var lwNumberOfBytesTransferred:longword; const bWait:boolean):boolean; override;
    // ����� �������� ����� �����, ����� ��������
    function _PurgeComm(const lwPurgeAction:longword):boolean; override;
    // ��������� ��������� �������� ���������� �������� (����) �� ���������� �������
    function _ReadFile(var Buffer; const lwNumberOfBytesToRead:longword; var lwNumberOfBytesRead:longword;
      const prOverlapped:POverlapped=nil):boolean; override;
    // ������������� ����� �������, ������� ����� ������������� ��� ������������ ����������������� �������;
    // ������������ ������� ����� ������� ������ ����� ������ ������� WaitCommEvent
    function _SetCommMask(const lwEventMask:longword):boolean; override;
    // ������������� �������� ��� ���� �������� ������ � ������ ��� ������������ ����������������� �������
    function _SetCommTimeouts(const rCommTimeouts:TCommTimeouts):boolean; override;
    // ������������� ������� ������� ����� � �������� ��� ����������������� �������
    function _SetupComm(const lwInputQueueSize,lwOutputQueueSize:longword):boolean; override;
    // ��� �������� ���������� ���������� � ��������� lwEventMask ����� �������, ������� ��������� � ���������������� �������
    function _WaitCommEvent(var lwEventMask:longword; const prOverlapped:POverlapped=nil):boolean; override;
    // ��������� �������� ��������� ���������� ���� � ���������������� ������
    function _WriteFile(const Buffer; const lwNumberOfBytesToWrite:longword; var lwNumberOfBytesWritten:longword;
      prOverlapped:POverlapped=nil):boolean; override;
  end;

  TTCPClientConnection=class(TCommunicationConnection)
  protected
    function GetTCPClientSocket:TTCPClientSocket; virtual;
  public
    class function GetClassCaption:AString; override;       // �������� ������
    class function GetClassDescription:AString; override;   // ��������� �������� ������

    constructor Create; override;
    procedure SetDefault; override;    

    property TCPClientSocket:TTCPClientSocket read GetTCPClientSocket;
  end;

  TTCPServerSocket=class(TCommunicationSocket)
  protected
    flwPort:longword;
    fTCPServer:TIdTCPServer;
    ct:TCommTimeouts;
  protected
    function DoGetUInt(const ndx:integer):UInt64; override;               // ��� ����������� ����� ��������

    function DoCreateHandle:THandle; override;         // ���������� ����� ������ ���������������� ������ �������
    procedure DoDestroyHandle; override;               // ���������� ����� ������ ����������� ��������� �������
  public
    constructor Create(sCommName:AnsiString; bOverlapped:boolean=false); override;
    class function GetObjectByName(sName:AnsiString):TCommunicationObject; override; // ����� ������� �� ����� - ��� ��������� �� �����
    procedure SetDefault; override;

    // �������� ��� ��������� ���������� �������� ��� ���������������� ��������, ���������� ���������� ������� ���������
    function _CancelIo:boolean; override;
    // ������� ��� ������ � ��������� ������ ���� ���������������� ������ � ��������� ���������������� ������
    function _FlushFileBuffers:boolean; override;
    // ���������� ������� ����� ������� ����������������� �������
    function _GetCommMask(var lwEventMask:longword):boolean; override;
    // ���������� ��������� ��������� ��� ���� �������� ������ � ������ ��� ���������� ����������������� �������
    function _GetCommTimeouts(var rCommTimeouts:TCommTimeouts):boolean; override;
    // ������ ���������� � ����������� ������ � ���������� �������� ���������� ����������� ��������
    function _GetOverlappedResult(const prOverlapped:POverlapped; var lwNumberOfBytesTransferred:longword; const bWait:boolean):boolean; override;
    // ����� �������� ����� �����, ����� ��������
    function _PurgeComm(const lwPurgeAction:longword):boolean; override;
    // ��������� ��������� �������� ���������� �������� (����) �� ���������� �������
    function _ReadFile(var Buffer; const lwNumberOfBytesToRead:longword; var lwNumberOfBytesRead:longword;
      const prOverlapped:POverlapped=nil):boolean; override;
    // ������������� ����� �������, ������� ����� ������������� ��� ������������ ����������������� �������;
    // ������������ ������� ����� ������� ������ ����� ������ ������� WaitCommEvent
    function _SetCommMask(const lwEventMask:longword):boolean; override;
    // ������������� �������� ��� ���� �������� ������ � ������ ��� ������������ ����������������� �������
    function _SetCommTimeouts(const rCommTimeouts:TCommTimeouts):boolean; override;
    // ������������� ������� ������� ����� � �������� ��� ����������������� �������
    function _SetupComm(const lwInputQueueSize,lwOutputQueueSize:longword):boolean; override;
    // ��� �������� ���������� ���������� � ��������� lwEventMask ����� �������, ������� ��������� � ���������������� �������
    function _WaitCommEvent(var lwEventMask:longword; const prOverlapped:POverlapped=nil):boolean; override;
    // ��������� �������� ��������� ���������� ���� � ���������������� ������
    function _WriteFile(const Buffer; const lwNumberOfBytesToWrite:longword; var lwNumberOfBytesWritten:longword;
      prOverlapped:POverlapped=nil):boolean; override;
  end;

  TTCPServerConnection=class(TCommunicationConnection)
  protected
    function GetTCPServerSocket:TTCPServerSocket; virtual;
  public
    constructor Create; override;

    property TCPClientSocket:TTCPServerSocket read GetTCPServerSocket;  
  end;

implementation

uses StrUtils,IdTCPConnection,IdIOHandlerSocket;

var gfs:TFormatSettings;

{$BOOLEVAL OFF}
{$RANGECHECKS OFF}
{$OVERFLOWCHECKS OFF}

const excOverlappedUnavailable='����������� ����� ����������';
  excNoTCPPort='�� ����� TCP-����'; excInvalidTCPPort='������������ TCP-���� <%s>';


type TLIdTCPClient=class(TIdTCPClient); 

  procedure RegisterClasses; begin 
    CommunicationSpace.RegisterSocketClass(TTCPClientSocket);
    CommunicationSpace.RegisterConnectionClass(TTCPClientConnection);
  end;


{ TTCPClientSocket }

constructor TTCPClientSocket.Create(sCommName:AnsiString; bOverlapped:boolean); var ndx:integer; i64:Int64; sPort:AnsiString; begin
  if bOverlapped then raise EqCDKexception.Create(ClassName+': '+excOverlappedUnavailable);
  sCommName:=AnsiUpperCase(sCommName); ndx:=Pos(':',AnsiReverseString(sCommName));
  if ndx=0then raise EqCDKexception.Create(ClassName+': '+excNoTCPPort); // ��� TCP-����� ������ ������� �������
  fsServer:=sCommName; SetLength(fsServer,Length(sCommName)-ndx); sPort:=AnsiRightStr(sCommName,ndx-1);
  if TryStrToInt64(sPort,i64)and(i64>=Low(flwPort))and(i64<=High(flwPort))then flwPort:=i64
  else raise EqCDKexception.Create(Format(ClassName+': '+excInvalidTCPPort,[sPort],gfs));
  inherited Create(sCommName);
end;

function TTCPClientSocket.DoCreateHandle:THandle; begin Result:=inherited DoCreateHandle;
  try fTCPClient:=TIdTCPClient.Create(nil); fTCPClient.Host:=fsServer; fTCPClient.Port:=flwPort;
    fTCPClient.Connect; fbConnected:=fTCPClient.Connected; Result:=fTCPClient.Socket.Binding.Handle;
  except FreeAndNil(fTCPClient); end;
end;

procedure TTCPClientSocket.DoDestroyHandle; begin
  try FreeAndNil(fTCPClient); except end;
  fhCommHandle:=INVALID_HANDLE_VALUE;
  inherited DoDestroyHandle;
end;

function TTCPClientSocket.DoGetUInt(const ndx:integer):UInt64; begin Result:=0; 
  case ndx of
    ndxBytesForRead,ndxBytesForWrite,ndxCommInputQueueSize,ndxCommOutputQueueSize:
      if not Connected then begin SetLastError(ceInvalidHandle); exit; end
      else case ndx of
        ndxBytesForRead:        Result:=fTCPClient.InputBuffer.Size;
        ndxBytesForWrite:       with TLIdTCPClient(fTCPClient)do if FWriteBuffer<>nil then Result:=FWriteBuffer.Size;
        ndxCommInputQueueSize:  Result:=fTCPClient.RecvBufferSize;
        ndxCommOutputQueueSize: Result:=fTCPClient.SendBufferSize;
      else Result:=0; end;
  else Result:=inherited DoGetUInt(ndx); end;
end;

class function TTCPClientSocket.GetClassCaption:AString;
begin Result:='������� ����� TCP-������ (TTCPClientSocket)'; end;

class function TTCPClientSocket.GetClassDescription:AString;
begin Result:='����� TTCPClientSocket ��������� ����� �� ������ TCP-�������'; end;

class function TTCPClientSocket.GetObjectByName(sName:AnsiString):TCommunicationObject;
begin Result:=nil; end;

procedure TTCPClientSocket.SetDefault; begin
  try Lock; BeginUpdate; inherited SetDefault;
    fsCaption:=CommName; fsName:=fsCaption; fsDescription:=GetClassDescription;
  finally EndUpdate; Unlock; end;
end;

function TTCPClientSocket._CancelIo:boolean;
begin Result:=false; SetLastError(ceInvalidFunction); end; // �������� �������

function TTCPClientSocket._FlushFileBuffers:boolean; begin Result:=false;
  try Lock; if not Connected then begin SetLastError(ceInvalidHandle);  exit; end;
    try fTCPClient.FlushWriteBuffer; Result:=true; except end;
  finally Unlock; end;
end;

function TTCPClientSocket._GetCommMask(var lwEventMask:longword):boolean;
begin Result:=false; SetLastError(ceInvalidFunction); end; // �������� �������

function TTCPClientSocket._GetCommTimeouts(var rCommTimeouts:TCommTimeouts):boolean;
begin try Lock; rCommTimeouts:=ct; Result:=true; finally Unlock; end; end;

function TTCPClientSocket._GetOverlappedResult(const prOverlapped:POverlapped;var lwNumberOfBytesTransferred:longword; const bWait:boolean):boolean;
begin Result:=false; SetLastError(ceInvalidFunction); end; // �������� �������

function TTCPClientSocket._PurgeComm(const lwPurgeAction:longword):boolean; begin Result:=false;
  try Lock; if not Connected then begin SetLastError(ceInvalidHandle);  exit; end;
    if lwPurgeAction and PURGE_RXCLEAR<>0then try fTCPClient.InputBuffer.Clear; except end;
    if lwPurgeAction and PURGE_TXCLEAR<>0then try fTCPClient.ClearWriteBuffer; except end;
    Result:=true;
  finally Unlock; end;
end; 

function TTCPClientSocket._ReadFile(var Buffer; const lwNumberOfBytesToRead:longword; var lwNumberOfBytesRead:longword;
  const prOverlapped:POverlapped):boolean;
var lwTotalTicks,lwTicks,lw:longword; s,s0:AnsiString;
begin Result:=false; lwNumberOfBytesRead:=0;
  try Lock; if not Connected then begin SetLastError(ceInvalidHandle); exit; end;
    if fTCPClient.Connected then try
      if(ct.ReadTotalTimeoutConstant=0)or(ct.ReadTotalTimeoutMultiplier=0)then lwTotalTicks:=ct.ReadIntervalTimeout else lwTotalTicks:=0;
      if lwNumberOfBytesToRead>0then inc(lwTotalTicks,ct.ReadTotalTimeoutMultiplier*lwNumberOfBytesToRead);
      inc(lwTotalTicks,ct.ReadTotalTimeoutConstant); lwTotalTicks:=GetTickCount+lwTotalTicks;
      repeat // ����������� ����� ������� ������
        lw:=ct.ReadIntervalTimeout; if(lw=0)and(CommBytesForRead<>0)then lw:=1;
        fTCPClient.ReadTimeout:=lw; lwTicks:=GetTickCount+lw; s:='';
        repeat // �������� ������ � ������� �������������� ��������
          Result:=fTCPClient.ReadFromStack(true,lw,false)>0;
          if Result then begin lwNumberOfBytesRead:=fTCPClient.InputBuffer.Size;
            s0:=fTCPClient.ReadString(lwNumberOfBytesRead); s:=s+s0;
            lwTicks:=GetTickCount+lw; // ����������� ������������� �������
          end;
        until integer(longword(GetTickCount-lwTicks))>0;
        Result:=s<>'';
        if Result then begin lwNumberOfBytesRead:=Length(s); CopyMemory(@Buffer,@s[1],lwNumberOfBytesRead); break; end;
      until integer(longword(GetTickCount-lwTotalTicks))>0;
    except Connected:=fTCPClient.Connected; end;
  finally Unlock; end;
end;

function TTCPClientSocket._SetCommMask(const lwEventMask:longword):boolean;
begin Result:=false; SetLastError(ceInvalidFunction); end; // �������� �������

function TTCPClientSocket._SetCommTimeouts(const rCommTimeouts:TCommTimeouts):boolean;
begin try Lock; ct:=rCommTimeouts; Result:=true; finally Unlock; end; end;

function TTCPClientSocket._SetupComm(const lwInputQueueSize,lwOutputQueueSize:longword):boolean; begin Result:=false;
  try Lock; if not Connected then begin SetLastError(ceInvalidHandle);  exit; end;
    try fTCPClient.RecvBufferSize:=lwInputQueueSize; fTCPClient.SendBufferSize:=lwOutputQueueSize; except end;
  finally Unlock; end;
end;

function TTCPClientSocket._WaitCommEvent(var lwEventMask:longword; const prOverlapped:POverlapped):boolean;
begin Result:=false; SetLastError(ceInvalidFunction); end; // �������� �������

function TTCPClientSocket._WriteFile(const Buffer; const lwNumberOfBytesToWrite:longword; var lwNumberOfBytesWritten:longword;
  prOverlapped:POverlapped):boolean;
begin Result:=false; lwNumberOfBytesWritten:=0;
  try Lock; if not Connected then begin SetLastError(ceInvalidHandle); exit; end;
    if fTCPClient.Connected then try
      fTCPClient.WriteBuffer(Buffer,lwNumberOfBytesToWrite); lwNumberOfBytesWritten:=lwNumberOfBytesToWrite;
      Result:=true;
    except Connected:=fTCPClient.Connected; end;
  finally Unlock; end;
end;

{ TTCPClientConnection }

constructor TTCPClientConnection.Create;
begin fCommunicationSocketClass:=TTCPClientSocket; inherited; end;

class function TTCPClientConnection.GetClassCaption:AString;
begin Result:='������� ���������� TCP-������ (TTCPClientConnection)'; end;

class function TTCPClientConnection.GetClassDescription: AString;
begin Result:='������� ���������� TTCPClientConnection ��������� ������� ����� ������ TTCPClientSocket �� ������ ����������� TCommunicationMode'; end;

function TTCPClientConnection.GetTCPClientSocket:TTCPClientSocket;
begin Result:=TTCPClientSocket(CommunicationSocket); end;

procedure TTCPClientConnection.SetDefault; begin
  try Lock; BeginUpdate;
    inherited SetDefault; // ������ �������� ��� ��������
    fsCaption:='TCPClientConnection_0x'+IntToHex(fhID,8); fsName:=fsCaption; fsDescription:=GetClassCaption;
  finally EndUpdate; Unlock; end;
end;


{ TTCPServerSocket }

constructor TTCPServerSocket.Create(sCommName: AnsiString;
  bOverlapped: boolean);
begin
  inherited;

end;

function TTCPServerSocket.DoCreateHandle: THandle;
begin

end;

procedure TTCPServerSocket.DoDestroyHandle;
begin
  inherited;

end;

function TTCPServerSocket.DoGetUInt(const ndx: integer): UInt64;
begin

end;

class function TTCPServerSocket.GetObjectByName(
  sName: AnsiString): TCommunicationObject;
begin

end;

procedure TTCPServerSocket.SetDefault;
begin
  inherited;

end;

function TTCPServerSocket._CancelIo: boolean;
begin

end;

function TTCPServerSocket._FlushFileBuffers: boolean;
begin

end;

function TTCPServerSocket._GetCommMask(var lwEventMask: longword): boolean;
begin

end;

function TTCPServerSocket._GetCommTimeouts(
  var rCommTimeouts: TCommTimeouts): boolean;
begin

end;

function TTCPServerSocket._GetOverlappedResult(
  const prOverlapped: POverlapped;
  var lwNumberOfBytesTransferred: longword; const bWait: boolean): boolean;
begin

end;

function TTCPServerSocket._PurgeComm(
  const lwPurgeAction: longword): boolean;
begin

end;

function TTCPServerSocket._ReadFile(var Buffer;
  const lwNumberOfBytesToRead: longword; var lwNumberOfBytesRead: longword;
  const prOverlapped: POverlapped): boolean;
begin

end;

function TTCPServerSocket._SetCommMask(
  const lwEventMask: longword): boolean;
begin

end;

function TTCPServerSocket._SetCommTimeouts(
  const rCommTimeouts: TCommTimeouts): boolean;
begin

end;

function TTCPServerSocket._SetupComm(const lwInputQueueSize,
  lwOutputQueueSize: longword): boolean;
begin

end;

function TTCPServerSocket._WaitCommEvent(var lwEventMask: longword;
  const prOverlapped: POverlapped): boolean;
begin

end;

function TTCPServerSocket._WriteFile(const Buffer;
  const lwNumberOfBytesToWrite: longword;
  var lwNumberOfBytesWritten: longword;
  prOverlapped: POverlapped): boolean;
begin

end;

{ TTCPServerConnection }

constructor TTCPServerConnection.Create;
begin fCommunicationSocketClass:=TTCPServerSocket; inherited; end;

function TTCPServerConnection.GetTCPServerSocket:TTCPServerSocket;
begin Result:=TTCPServerSocket(CommunicationSocket); end;

initialization
  GetLocaleFormatSettings(SysLocale.DefaultLCID,gfs);
  RegisterClasses;

end.
