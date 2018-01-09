unit uCmdServer;

interface

uses Classes,IdTCPServer;

const
  ndxHostName=-1; ndxHostIPAddress=-2; ndxHostIPPort=-3;

type
  TcmdServer=class(TIdTCPServer)
  private
    fsHostName,fsHostIPAddress,fsHostIPPort:AnsiString;
    function GetString(const ndx:integer):AnsiString;
  protected
//    function DoExecute(aThread:TIdPeerThread): boolean; override;
    procedure SetActive(b:boolean); override;
    procedure SetDefaultPort(const i32:integer); override;
  public
    constructor Create(aOwner:TComponent); override;
    destructor Destroy; override;

    property HostName:AnsiString      index ndxHostName       read GetString; // им€ компьютера
    property HostIPAddress:AnsiString index ndxHostIPAddress  read GetString; // IP-адрес
    property HostIPPort:AnsiString    index ndxHostIPPort     read GetString; // IP-порт
  end;

implementation

uses SysUtils,uUtilsFunctions;

{$BOOLEVAL OFF}
{$RANGECHECKS OFF}
{$OVERFLOWCHECKS OFF}

const wDefaultIPPort=12344;
  iMaxConnections=0; // максимальное количество одновременно соединЄнных клиентов
  sGreeting='';
  sMaxConnection='ошибка соединени€, максимальное количество клиентов на сервере';
  sUnknownCommand='неизвестна€ команда';

{ TcmdServer }

constructor TcmdServer.Create(aOwner:TComponent); begin inherited; DefaultPort:=wDefaultIPPort;
  fsHostName:=Net_GetHostName; fsHostIPAddress:=Net_GetLocalIPAddressStr; fsHostIPPort:=IntToStr(DefaultPort);
  Greeting.NumericCode:=200; Greeting.Text.Text:=''; ReplyExceptionCode:=500;
  MaxConnectionReply.NumericCode:=499; MaxConnectionReply.Text.Text:=sMaxConnection; MaxConnections:=iMaxConnections;
  ReplyUnknownCommand.NumericCode:=400; ReplyUnknownCommand.Text.Text:=sUnknownCommand;
end;

destructor TcmdServer.Destroy; begin Active:=false;

  inherited;
end;


function TcmdServer.GetString(const ndx:integer):AnsiString; begin Result:='';
  case ndx of
    ndxHostName:          Result:=fsHostName;
    ndxHostIPAddress:     Result:=fsHostIPAddress;
    ndxHostIPPort:        Result:=fsHostIPPort;
  end;
end;

procedure TcmdServer.SetActive(b:boolean); var i:integer; l:TList; begin
  if b<>fActive then begin
    if b then inherited SetActive(b)
    else try
      try l:=Threads.LockList;                      // закрываем все соединени€
        for i:=0to l.Count-1do try TIdPeerThread(l[i]).Connection.Disconnect; except end;
      finally Threads.UnlockList; end;
      try inherited SetActive(b); except end;       // деактивируем сервер
      try Bindings.Clear; except end;               // убираем все прив€зки (чтоб не было прив€зки к портам)
    except end;
  end;
end;

procedure TcmdServer.SetDefaultPort(const i32:integer); var b:boolean; begin
  if i32<>DefaultPort then begin b:=Active; Active:=false;
    inherited SetDefaultPort(i32); Active:=b;
    fsHostIPPort:=IntToStr(DefaultPort);
  end;
end;

end.
