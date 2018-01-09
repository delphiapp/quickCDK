unit uUSBNotifier;

interface

uses Windows,Messages,Classes,DBT;

type
  TUSBNotifyEvent=procedure(Sender:TObject; dwEvent:longword; sUSBName:AnsiString)of object;

const
  GUID_DEVINTERFACE_COMPORT:TGUID='{86E0D1E0-8089-11D0-9CE4-08003E301F73}'; //'{4d36e978-e325-11ce-bfc1-08002be10318}';
  GUID_DEVINTERFACE_USB_DEVICE:TGUID='{A5DCBF10-6530-11D2-901F-00C04FB951ED}';

type

  TUSBnotifier=class(TComponent)
  private
    hWindow:HWND; hNotify:HDEVNOTIFY; fOnUSBNotify:TUSBNotifyEvent;
    procedure SetOnUSBNotify(const ne:TUSBNotifyEvent);
    procedure USBRegister;
    procedure USBUnregister;
  protected
    procedure WMDeviceChange(var M:TMessage); virtual;
    procedure WndProc(var M:TMessage); virtual;
  public
    constructor Create(aOwner:TComponent); override;
    destructor Destroy; override;
  published
    property OnUSBNotify:TUSBNotifyEvent read FOnUSBNotify write SetOnUSBNotify;
  end;

  function GetComPortName(sUSBInfo:AnsiString):AnsiString;

implementation

uses Registry;

{$BOOLEVAL OFF}
{$RANGECHECKS OFF}
{$OVERFLOWCHECKS OFF}

  function GetComPortName(sUSBInfo:AnsiString):AnsiString; var r:TRegistry; s:AnsiString; ndx:integer; begin r:=nil;
    try try r:=TRegistry.Create; r.RootKey:=HKEY_LOCAL_MACHINE;
      s:=sUSBInfo; ndx:=Pos('USB',s); if ndx<>0then Delete(s,1,ndx+2);
      if r.OpenKeyReadOnly('System\ControlSet001\Enum\USB')then begin ndx:=Pos('#',s);
        if ndx<>0then begin Delete(s,1,ndx); ndx:=Pos('#',s);
          if ndx<>0then begin
            if r.OpenKeyReadOnly(Copy(s,1,ndx-1))then begin Delete(s,1,ndx); ndx:=Pos('#',s);
              if ndx<>0then begin r.OpenKeyReadOnly(Copy(s,1,ndx-1));
                // if r.ValueExists('FriendlyName')then s:=r.ReadString('FriendlyName'); // FriendlyName - дополнительная информация по порту
                if r.OpenKeyReadOnly('Device Parameters')then if r.ValueExists('PortName')then
                  begin s:=r.ReadString('SymbolicName'); sUSBInfo:=r.ReadString('PortName'); end;
              end;
            end;
          end;
        end;
      end;
    finally r.Free; end; except end;
    Result:=sUSBInfo;
  end;

{ TUSBnotifier }

constructor TUSBnotifier.Create(aOwner:TComponent);
begin inherited Create(aOwner); hWindow:=AllocateHWnd(WndProc); USBRegister; end;

destructor TUSBnotifier.Destroy;
begin USBUnregister; DeallocateHWnd(hWindow); inherited Destroy; end;

procedure TUSBnotifier.SetOnUSBNotify(const ne:TUSBNotifyEvent);
begin fOnUSBNotify:=ne; end;

procedure TUSBnotifier.USBregister; var dbi:DEV_BROADCAST_DEVICEINTERFACE_A; begin
  ZeroMemory(@dbi,SizeOf(dbi));
  dbi.dbcc_size:=SizeOf(dbi); dbi.dbcc_devicetype:=DBT_DEVTYP_DEVICEINTERFACE; dbi.dbcc_reserved:=0;
  dbi.dbcc_classguid:=GUID_DEVINTERFACE_USB_DEVICE;
  hNotify:=RegisterDeviceNotification(hWindow,@dbi,DEVICE_NOTIFY_WINDOW_HANDLE);
end;

procedure TUSBnotifier.USBunregister;
begin UnregisterDeviceNotification(hNotify); end;

procedure TUSBnotifier.WMDeviceChange(var M:TMessage); var lpdb:PDevBroadcastHdr; Device:PDevBroadcastDeviceInterface; sName:AnsiString; i:integer; begin
  if(M.WParam=DBT_DEVICEARRIVAL)or(M.WParam=DBT_DEVICEREMOVECOMPLETE)
    or(M.WParam=DBT_DEVICEREMOVEPENDING)or(M.WParam=DBT_DEVICEQUERYREMOVE)or(M.WParam=DBT_DEVICEQUERYREMOVEFAILED)then begin
    lpdb:=PDevBroadcastHdr(M.LParam); if lpdb.dbch_devicetype<>DBT_DEVTYP_DEVICEINTERFACE then exit;
    Device:=PDevBroadcastDeviceInterface(M.LParam); i:=lpdb.dbch_size-SizeOf(lpdb^)+1;
    SetLength(sName,i); CopyMemory(@sName[1],@Device^.dbcc_name[0],i);
    if@fOnUSBNotify<>nil then fOnUSBNotify(Self,M.WParam,sName);
  end;
end;

procedure TUSBnotifier.WndProc(var M:TMessage);
begin if(M.Msg=WM_DEVICECHANGE)then WMDeviceChange(M)else M.Result:=DefWindowProc(hWindow,M.Msg,M.WParam,M.LParam); end;

end.


