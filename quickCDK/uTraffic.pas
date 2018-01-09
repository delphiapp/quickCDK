unit uTraffic;

interface

uses Windows,Classes,Controls,VirtualTrees,Graphics,uSynchroObjects;

const ndxMax=60;

type
  PrTrafficDataInfo=^TrTrafficDataInfo;
  TrTrafficDataInfo=packed record         // информация по данным
    _lwLastTicks:longword;                // последние запомненные тики
    _iTotalData:Int64;                    // общее количество данных (байты, пакеты или ещё что-то)
    _lwAverageSpeed:longword;             // средняя скорость
    _lwCurrentSpeed:longword;             // текущая скорость
    _lwPeakSpeed:longword;                // пиковая скорость
  end;

  TTrafficInfo=class
  private
    fbActive:boolean;                     // активна статистика или нет
    fsDescription:AnsiString;             // описание трафика
    fstStarted:TSystemTime;               // время начала учёта трафика
    fmsec:Int64;                          // количество миллисекунд пройденных с начала учёта
    flwLastTicks:longword;                // последние запомненные тики

    rInBytesInfo:TrTrafficDataInfo;       // информация о входящих байтах
    rInPacketsInfo:TrTrafficDataInfo;     // информация о входящих пакетах
    rInErrorsInfo:TrTrafficDataInfo;      // информация о входящих ошибках
    rInTimeoutsInfo:TrTrafficDataInfo;    // информация о входящих таймаутах

    rOutBytesInfo:TrTrafficDataInfo;      // информация об исходящих байтах
    rOutPacketsInfo:TrTrafficDataInfo;    // информация об исходящих пакетах
    rOutErrorsInfo:TrTrafficDataInfo;     // информация об исходящих ошибках
    rOutTimeoutsInfo:TrTrafficDataInfo;   // информация об исходящих таймаутах

    rTotalBytesInfo:TrTrafficDataInfo;    // информация о всех байтах (входящие+исходящие)
    rTotalPacketsInfo:TrTrafficDataInfo;  // информация о всех пакетах
    rTotalErrorsInfo:TrTrafficDataInfo;   // информация о всех ошибках
    rTotalTimeoutsInfo:TrTrafficDataInfo; // информация о всех таймаутах

    fLock:TRTLCriticalSection;            // для запрещения одновременно работы с данными

    procedure SetActive(const b:boolean); virtual;
  protected
    fbRestarted:boolean; // после Run
    procedure AddDataInfo(ptdi:PrTrafficDataInfo; cntData:longword); virtual;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure Assign(TI:TTrafficInfo); virtual;

    procedure AddInBytes(cntBytes:longword); virtual;
    procedure AddInPackets(cntPackets:longword); virtual;
    procedure AddInErrors(cntErrors:longword); virtual;
    procedure AddInTimeouts(cntTimeouts:longword); virtual;
    procedure AddOutBytes(cntBytes:longword); virtual;
    procedure AddOutPackets(cntPackets:longword); virtual;
    procedure AddOutErrors(cntErrors:longword); virtual;
    procedure AddOutTimeouts(cntTimeouts:longword); virtual;

    procedure Lock; virtual;            // заблокировать работу
    function TryLock:boolean; virtual;  // попытка заблокировать работу
    procedure Unlock; virtual;          // разблокировать работу

    procedure Reset; virtual;           // сброс всего
    procedure Run; virtual;             // запуск статистики
    procedure Stop; virtual;            // останов статистики

    property Active:boolean read fbActive write SetActive;                      // активна статистика или нет
    property Description:AnsiString read fsDescription write fsDescription;     // описание трафика

    property StartedTime:TSystemTime read fstStarted;                           // время начала учёта трафика - полная дата-время
    property ActiveTime:Int64 read fmsec;                                       // активное время учёта трафика в мс

    property InBytesInfo:TrTrafficDataInfo read rInBytesInfo;                   // информация о входящих байтах
    property InPacketsInfo:TrTrafficDataInfo read rInPacketsInfo;               // информация о входящих пакетах
    property InErrorsInfo:TrTrafficDataInfo read rInErrorsInfo;                 // информация о входящих ошибках
    property InTimeoutsInfo:TrTrafficDataInfo read rInTimeoutsInfo;             // информация о входящих таймаутах

    property OutBytesInfo:TrTrafficDataInfo read rOutBytesInfo;                 // информация об исходящих байтах
    property OutPacketsInfo:TrTrafficDataInfo read rOutPacketsInfo;             // информация об исходящих пакетах
    property OutErrorsInfo:TrTrafficDataInfo read rOutErrorsInfo;               // информация об исходящих ошибках
    property OutTimeoutsInfo:TrTrafficDataInfo read rOutTimeoutsInfo;           // информация об исходящих таймаутах

    property TotalBytesInfo:TrTrafficDataInfo read rTotalBytesInfo;             // информация о всех байтах (входящие+исходящие)
    property TotalPacketsInfo:TrTrafficDataInfo read rTotalPacketsInfo;         // информация о всех пакетах
    property TotalErrorsInfo:TrTrafficDataInfo read rTotalErrorsInfo;           // информация о всех ошибках
    property TotalTimeoutsInfo:TrTrafficDataInfo read rTotalTimeoutsInfo;       // информация о всех таймаутах
  end;

  PTrafficDataArray=^TTrafficDataArray;
  TTrafficDataArray=array[0..ndxMax-1]of TrTrafficDataInfo;

  TTrafficView=class(TVirtualStringTree)
  private
    lti:TTrafficInfo; // локальная копия
    fti:TTrafficInfo; // оригинал
    cnt:integer;      // счётчик срабатывания таймера
    cntMax:integer;   // максимальный счётчик (сколько периодов таймера надо пропустить чтоб получить желаемую выдержку)
    arrInBytes,arrInPackets,arrInErrors,arrInTimeouts,
    arrOutBytes,arrOutPackets,arrOutErrors,arrOutTimeouts:TTrafficDataArray; ndx:integer; // текущий индекс в массиве
    inBytesMax,inPacketsMax,{inErrorsMax,inTimeoutsMax,}
    outBytesMax,outPacketsMax{,outErrorsMax,outTimeoutsMax}:longword; // максимальное значение в массиве
    procedure Init;
    procedure SetTI(const ti:TTrafficInfo);
  protected
    procedure DoAfterCellPaint(c:TCanvas; pNode:PVirtualNode; Column:TColumnIndex; CellRect:TRect); override;
    procedure DoGetText(pNode:PVirtualNode; Column:TColumnIndex; TextType:TVSTTextType; var Text:UnicodeString); override;

    procedure _OnAdvancedHeaderDraw(Sender:TVTHeader; var PaintInfo:THeaderPaintInfo; const Elements:THeaderPaintElements);
    procedure _OnHeaderDrawQueryElements(Sender:TVTHeader; var PaintInfo:THeaderPaintInfo; var Elements:THeaderPaintElements);
    procedure _OnTimer(Sender:TObject);
  public
    constructor Create(aOwner:TComponent); override;
    destructor Destroy; override;

    procedure UpdateInfo; virtual;

    property TrafficInfo:TTrafficInfo read fti write SetTI;
  end;

  function BitsSpeedToString(bits:longword):AnsiString;   // скорость в битах
  function BitsToString(bits:longword):AnsiString;        // биты
  function BytesSpeedToString(bytes:longword):AnsiString; // скорость в байтах
  function BytesToString(bytes:longword):AnsiString;      // байты
  function SecondsToString(secs:longword):AnsiString;     // секунды

implementation

{$BOOLEVAL OFF}
{$RANGECHECKS OFF}
{$OVERFLOWCHECKS OFF}

uses SysUtils,Math,uUtilsFunctions, Types;

var gfs:TFormatSettings;

  const
    OneKBit=1000; OneMBit=OneKBit*1000; OneGBit=OneMBit*1000;
    OneKByte=1024; OneMByte=OneKByte*1024; OneGByte=OneMByte*1024;

  function BitsSpeedToString(bits:longword):AnsiString;
  begin Result:=BitsToString(bits)+'/с'; end;

  function BitsToString(bits:longword):AnsiString; begin
    if bits<OneKBit then Result:=FormatFloat('#,##0 бит',bits)
    else if bits<OneMBit then Result:=FormatFloat('#,##0.00 Кбит',bits/OneKBit)
      else if bits<OneGBit then Result:=FormatFloat('#,##0.00 Мбит',bits/OneMBit)
        else Result:=FormatFloat('#,##0.00 Гбит',bits/OneGBit);
  end;

  function BytesSpeedToString(bytes:longword):AnsiString;
  begin Result:=BytesToString(bytes)+'/с'; end;

  function BytesToString(bytes:longword):AnsiString; begin
    if bytes<OneKByte then Result:=FormatFloat('#,##0 Б',bytes)
    else if bytes<OneMByte then Result:=FormatFloat('#,##0.00 КБ',bytes/OneKByte)
      else if bytes<OneGByte then Result:=FormatFloat('#,##0.00 МБ',bytes/OneMByte)
        else Result:=FormatFloat('#,##0.00 ГБ',bytes/OneGByte);
  end;

  function SecondsToString(secs:longword):AnsiString; var h,m:longword; begin
    h:=secs div 3600; secs:=secs-3600*h; m:=secs div 60; secs:=secs-60*m;
    Result:=Format('%.2d:%.2d:%.2d',[h,m,secs]);
  end;

{ TTrafficInfo }

procedure TTrafficInfo.AddDataInfo(ptdi:PrTrafficDataInfo; cntData:longword); var lw:longword;
  procedure MakeTotal(ptdiTotal,ptdiIn,ptdiOut:PrTrafficDataInfo); begin
    with ptdiTotal^do begin _lwLastTicks:=ptdi^._lwLastTicks;
      _iTotalData:=ptdiIn^._iTotalData+ptdiOut^._iTotalData;
      _lwCurrentSpeed:=ptdiIn^._lwCurrentSpeed+ptdiOut^._lwCurrentSpeed;
      _lwAverageSpeed:=ptdiIn^._lwAverageSpeed+ptdiOut^._lwAverageSpeed;
      if _lwCurrentSpeed>_lwPeakSpeed then _lwPeakSpeed:=_lwCurrentSpeed;
//      _lwPeakSpeed:=ptdiIn^._lwPeakSpeed+ptdiOut^._lwPeakSpeed;
    end;
  end;
begin if not fbActive then exit;
  try Lock; if ptdi^._lwLastTicks=0then begin inc(ptdi^._iTotalData,cntData); ptdi^._lwLastTicks:=GetTickCount; exit; end;
    lw:=GetTickCount; fmsec:=fmsec+(lw-flwLastTicks); flwLastTicks:=lw;
    with ptdi^do begin
      inc(_iTotalData,cntData); lw:=flwLastTicks-_lwLastTicks;
      if lw=0then _lwCurrentSpeed:=cntData else _lwCurrentSpeed:=cntData*1000div lw; _lwLastTicks:=flwLastTicks;
      if _lwCurrentSpeed>_lwPeakSpeed then _lwPeakSpeed:=_lwCurrentSpeed;
      if fmsec=0then _lwAverageSpeed:=0 else _lwAverageSpeed:=_iTotalData*1000 div fmsec;
    end;
    case IndexOfPointer(ptdi,[@rInBytesInfo,@rOutBytesInfo,@rInPacketsInfo,@rOutPacketsInfo,
      @rInErrorsInfo,@rOutErrorsInfo,@rInTimeoutsInfo,@rOutTimeoutsInfo])of
      0..1: MakeTotal(@rTotalBytesInfo,@rInBytesInfo,@rOutBytesInfo);
      2..3: MakeTotal(@rTotalPacketsInfo,@rInPacketsInfo,@rOutPacketsInfo);
      4..5: MakeTotal(@rTotalErrorsInfo,@rInErrorsInfo,@rOutErrorsInfo);
      6..7: MakeTotal(@rTotalTimeoutsInfo,@rInTimeoutsInfo,@rOutTimeoutsInfo);
    end;
  finally Unlock; end;
end;

procedure TTrafficInfo.AddInBytes(cntBytes:longword);
begin AddDataInfo(@rInBytesInfo,cntBytes); end;

procedure TTrafficInfo.AddInErrors(cntErrors:longword);
begin AddDataInfo(@rInErrorsInfo,cntErrors); end;

procedure TTrafficInfo.AddInPackets(cntPackets:longword);
begin AddDataInfo(@rInPacketsInfo,cntPackets); end;

procedure TTrafficInfo.AddInTimeouts(cntTimeouts:longword);
begin AddDataInfo(@rInTimeoutsInfo,cntTimeouts); end;

procedure TTrafficInfo.AddOutBytes(cntBytes:longword);
begin AddDataInfo(@rOutBytesInfo,cntBytes); end;

procedure TTrafficInfo.AddOutErrors(cntErrors:longword);
begin AddDataInfo(@rOutErrorsInfo,cntErrors); end;

procedure TTrafficInfo.AddOutPackets(cntPackets:longword);
begin AddDataInfo(@rOutPacketsInfo,cntPackets); end;

procedure TTrafficInfo.AddOutTimeouts(cntTimeouts:longword);
begin AddDataInfo(@rOutTimeoutsInfo,cntTimeouts); end;

procedure TTrafficInfo.Assign(TI:TTrafficInfo); begin
  if TI=nil then begin Active:=false; Reset; end
  else begin fbActive:=TI.fbActive; fsDescription:=TI.fsDescription;
    fstStarted:=TI.fstStarted; fmsec:=TI.fmsec; flwLastTicks:=TI.flwLastTicks;

    rInBytesInfo:=TI.rInBytesInfo; rInPacketsInfo:=TI.rInPacketsInfo;
    rInErrorsInfo:=TI.rInErrorsInfo; rInTimeoutsInfo:=TI.rInTimeoutsInfo;

    rOutBytesInfo:=TI.rOutBytesInfo; rOutPacketsInfo:=TI.rOutPacketsInfo;
    rOutErrorsInfo:=TI.rOutErrorsInfo; rOutTimeoutsInfo:=TI.rOutTimeoutsInfo;

    rTotalBytesInfo:=TI.rTotalBytesInfo; rTotalPacketsInfo:=TI.rTotalPacketsInfo;
    rTotalErrorsInfo:=TI.rTotalErrorsInfo; rTotalTimeoutsInfo:=TI.rTotalTimeoutsInfo;
  end;
end;

constructor TTrafficInfo.Create;
begin InitializeCriticalSection(fLock); Reset; end;

destructor TTrafficInfo.Destroy;
begin DeleteCriticalSection(fLock); inherited; end;

procedure TTrafficInfo.Lock;
begin EnterCriticalSection(fLock); end;

procedure TTrafficInfo.Reset; begin
  GetLocalTime(fstStarted); fmsec:=0; flwLastTicks:=GetTickCount-5000; {при запуске отодвигаемся на 1 секунду назад}

  ZeroMemory(@rInBytesInfo,SizeOf(rInBytesInfo));         //rInBytesInfo._lwLastTicks:=flwLastTicks;
  ZeroMemory(@rInPacketsInfo,SizeOf(rInPacketsInfo));     //rInPacketsInfo._lwLastTicks:=flwLastTicks;
  ZeroMemory(@rInErrorsInfo,SizeOf(rInErrorsInfo));       //rInErrorsInfo._lwLastTicks:=flwLastTicks;
  ZeroMemory(@rInTimeoutsInfo,SizeOf(rInTimeoutsInfo));   //rInTimeoutsInfo._lwLastTicks:=flwLastTicks;

  ZeroMemory(@rOutBytesInfo,SizeOf(rOutBytesInfo));       //rOutBytesInfo._lwLastTicks:=flwLastTicks;
  ZeroMemory(@rOutPacketsInfo,SizeOf(rOutPacketsInfo));   //rOutPacketsInfo._lwLastTicks:=flwLastTicks;
  ZeroMemory(@rOutErrorsInfo,SizeOf(rOutErrorsInfo));     //rOutErrorsInfo._lwLastTicks:=flwLastTicks;
  ZeroMemory(@rOutTimeoutsInfo,SizeOf(rOutTimeoutsInfo)); //rOutTimeoutsInfo._lwLastTicks:=flwLastTicks;

  ZeroMemory(@rTotalBytesInfo,SizeOf(rTotalBytesInfo));
  ZeroMemory(@rTotalPacketsInfo,SizeOf(rTotalPacketsInfo));
  ZeroMemory(@rTotalErrorsInfo,SizeOf(rTotalErrorsInfo));
  ZeroMemory(@rTotalTimeoutsInfo,SizeOf(rTotalTimeoutsInfo));   
end;

procedure TTrafficInfo.Run;
begin Active:=true; end;

procedure TTrafficInfo.SetActive(const b:boolean); var lw:longword; begin
  if b<>fbActive then begin fbActive:=b; fbRestarted:=fbActive;
    if fbActive then begin Reset; lw:=flwLastTicks;
      rInBytesInfo._lwLastTicks:=lw; rInPacketsInfo._lwLastTicks:=lw;
      rInErrorsInfo._lwLastTicks:=lw; rInTimeoutsInfo._lwLastTicks:=lw;
      rOutBytesInfo._lwLastTicks:=lw; rOutPacketsInfo._lwLastTicks:=lw;
      rOutErrorsInfo._lwLastTicks:=lw; rOutTimeoutsInfo._lwLastTicks:=lw;
      rTotalBytesInfo._lwLastTicks:=lw; rTotalPacketsInfo._lwLastTicks:=lw;
      rTotalErrorsInfo._lwLastTicks:=lw; rTotalTimeoutsInfo._lwLastTicks:=lw;
    end else begin
      rInBytesInfo._lwCurrentSpeed:=0; rInPacketsInfo._lwCurrentSpeed:=0;
      rInErrorsInfo._lwCurrentSpeed:=0; rInTimeoutsInfo._lwCurrentSpeed:=0;
      rOutBytesInfo._lwCurrentSpeed:=0; rOutPacketsInfo._lwCurrentSpeed:=0;
      rOutErrorsInfo._lwCurrentSpeed:=0; rOutTimeoutsInfo._lwCurrentSpeed:=0;
      rTotalBytesInfo._lwCurrentSpeed:=0; rTotalPacketsInfo._lwCurrentSpeed:=0;
      rTotalErrorsInfo._lwCurrentSpeed:=0; rTotalTimeoutsInfo._lwCurrentSpeed:=0;
    end;
  end;
end;

procedure TTrafficInfo.Stop;
begin Active:=false; end;

function TTrafficInfo.TryLock:boolean;
begin Result:=TryEnterCriticalSection(fLock); end;

procedure TTrafficInfo.Unlock;
begin LeaveCriticalSection(fLock); end;

{ TTrafficView }

constructor TTrafficView.Create(aOwner:TComponent); begin inherited; 
  lti:=TTrafficInfo.Create; Init;
  with Self do begin if aOwner is TWinControl then Parent:=TWinControl(aOwner); DoubleBuffered:=true;
    Header.Options:=[{hoAutoResize,}hoColumnResize,hoDblClickResize,hoDrag,hoShowSortGlyphs,hoVisible,hoOwnerDraw{,hoAutoSpring}];
    Header.Style:=hsPlates; Header.SortColumn:=-1;
    IncrementalSearch:=isAll; IncrementalSearchStart:=ssAlwaysStartOver;
    TreeOptions.MiscOptions:=TreeOptions.MiscOptions+[toCheckSupport,toEditable,toEditOnDblClick,toReportMode{,toVariableNodeHeight,toNodeHeightResize}];
    TreeOptions.PaintOptions:=TreeOptions.PaintOptions+[toShowHorzGridLines,toShowVertGridLines,toFullVertGridLines,toHideFocusRect]-[toShowButtons];
    TreeOptions.SelectionOptions:=TreeOptions.SelectionOptions+[toExtendedFocus,toFullRowSelect];
//    Header.Columns.DefaultWidth:=100;
    with Header.Columns.Add do begin Width:=75; Text:='Трафик'; Options:=Options-[coAllowFocus,coDraggable,coAllowClick]; Style:=vsOwnerDraw; {CheckBox:=false; Margin:=0; Spacing:=0;} end;
    with Header.Columns.Add do begin Width:=70; Text:='Байт всего'; Options:=Options-[coAllowFocus,coDraggable,coAllowClick]; Style:=vsOwnerDraw; end;
    with Header.Columns.Add do begin Width:=80; Text:='Байт тек'; Options:=Options-[coAllowFocus,coDraggable,coAllowClick]; Style:=vsOwnerDraw; end;
    with Header.Columns.Add do begin Width:=80; Text:='Байт сред'; Options:=Options-[coAllowFocus,coDraggable,coAllowClick]; Style:=vsOwnerDraw; end;
    with Header.Columns.Add do begin Width:=80; Text:='Байт пик'; Options:=Options-[coAllowFocus,coDraggable,coAllowClick]; Style:=vsOwnerDraw; end;
    with Header.Columns.Add do begin Width:=70; Text:='Пакетов всего'; Options:=Options-[coAllowFocus,coDraggable,coAllowClick]; Style:=vsOwnerDraw; end;
    with Header.Columns.Add do begin Width:=80; Text:='Пакетов тек'; Options:=Options-[coAllowFocus,coDraggable,coAllowClick]; Style:=vsOwnerDraw; end;
    with Header.Columns.Add do begin Width:=80; Text:='Пакетов сред'; Options:=Options-[coAllowFocus,coDraggable,coAllowClick]; Style:=vsOwnerDraw; end;
    with Header.Columns.Add do begin Width:=80; Text:='Пакетов пик'; Options:=Options-[coAllowFocus,coDraggable,coAllowClick]; Style:=vsOwnerDraw; end;
    with Header.Columns.Add do begin Width:=80; Text:='Тренды'; Options:=Options-[coAllowFocus,coDraggable,coAllowClick]; Style:=vsOwnerDraw; end;
    Indent:=0; // убрать у основной колонки отступ
    Header.AutoSizeIndex:=9; Header.Options:=Header.Options+[hoAutoResize];
    Header.MainColumn:=-2; HintMode:=hmTooltip;
    {FocusedColumn:=6;} LineMode:=lmBands;
    AddChild(nil); AddChild(nil); AddChild(nil); AddChild(nil); AddChild(nil);
    NodeHeight[AddChild(nil)]:=DefaultNodeHeight*3div 2;
    OnAdvancedHeaderDraw:=_OnAdvancedHeaderDraw; OnHeaderDrawQueryElements:=_OnHeaderDrawQueryElements;
  end;
  GetTimerNotifier.AddNotifyEvent(Self,_OnTimer); cntMax:=4*250div GetTimerNotifier.TimerInterval; if cntMax=0then cntMax:=1;
end;

destructor TTrafficView.Destroy;
begin TrafficInfo:=nil; GetTimerNotifier.RemoveNotifyEvent(Self,_OnTimer); FreeAndNil(lti); inherited; end;

procedure TTrafficView.DoAfterCellPaint(c:TCanvas; pNode:PVirtualNode; Column:TColumnIndex; CellRect:TRect);
var r,rIn,rOut:TRect; ws:WideString; i,w,h:integer; dw:double; imax:integer; {ptInLast,ptOutLast:TPoint;} arr:array of TPoint;
  arrTotalBytes:TTrafficDataArray;
  procedure DrawTrend(pa:PTrafficDataArray; imax:integer; cl:integer); var i:integer; lr:TRect; begin
    GetTextInfo(pNode,Column,c.Font,r,ws); OffsetRect(r,0,CellRect.Top-r.Top+2);
    r.Bottom:=r.Bottom+((CellRect.Bottom-CellRect.Top)-(r.Bottom-r.Top));
    Header.Columns.GetColumnBounds(Column,r.Left,r.Right);
    OffsetRect(r,-OffsetX,-OffsetY); c.Brush.Color:=$A0FFFF; c.FillRect(r);
    h:=r.Bottom-r.Top+1; w:=r.Right-r.Left+1; lr:=r;
    if(w<>0)and(ndx<>0)then begin dw:=w/ndx/2; SetLength(arr,ndx+2);
      arr[0].X:=r.Left; arr[0].Y:=r.Bottom;
      for i:=0to ndx-1do begin
        if imax=0then lr.Top:=r.Bottom
        else lr.Top:=r.Bottom-Round((pa^[i]._lwCurrentSpeed/imax)*h);
        lr.Left:=r.Left+Round((2*i)*dw); // lr.Right:=r.Left+Round((2*i+1)*dw);
        arr[i+1].X:=lr.Left; arr[i+1].Y:=lr.Top;
      end;
      arr[ndx+1].X:=arr[ndx].X; arr[ndx+1].Y:=r.Bottom;
      c.Brush.Color:=cl; c.Pen.Color:=c.Brush.Color; c.Polygon(arr);
    end;
  end;
begin inherited;
  case pNode.Index of
    5: case Column of
      2..4: begin
        GetTextInfo(pNode,Column,c.Font,r,ws); OffsetRect(r,0,CellRect.Top-r.Top+2);
        r.Bottom:=r.Bottom+((CellRect.Bottom-CellRect.Top)-(r.Bottom-r.Top));
        Header.Columns.GetColumnBounds(2,r.Left,i); Header.Columns.GetColumnBounds(4,i,r.Right);
        OffsetRect(r,-OffsetX,-OffsetY); c.Brush.Color:=$A0FFFF; c.FillRect(r);
        h:=r.Bottom-r.Top+1; w:=r.Right-r.Left+1; rIn:=r; rOut:=r;
        if(w<>0)and(ndx<>0)then begin dw:=w/ndx/2; imax:=max(inBytesMax,outBytesMax);
          for i:=0to ndx-1do begin
            if outBytesMax=0then rOut.Top:=r.Bottom
            else rOut.Top:=r.Bottom-Round((arrOutBytes[i]._lwCurrentSpeed/imax)*h);
            rOut.Left:=r.Left+Round((2*i)*dw); rOut.Right:=r.Left+Round((2*i+1)*dw);
            c.Brush.Color:=$A0A0FF; c.FillRect(rOut);
{            if i<>0then begin c.Pen.Color:=c.Brush.Color; c.MoveTo(ptOutLast.X,ptOutLast.Y); c.LineTo(rOut.Left,rOut.Top); end;
            ptOutLast:=Point(rOut.Right,rOut.Top);}
            if inBytesMax=0then rIn.Top:=r.Bottom
            else rIn.Top:=r.Bottom-Round((arrInBytes[i]._lwCurrentSpeed/imax)*h);
            rIn.Left:=r.Left+Round((2*i+1)*dw); rIn.Right:=r.Left+Round((2*i+2)*dw);
            c.Brush.Color:=$FFA0A0; c.FillRect(rIn);
{            if i<>0then begin c.Pen.Color:=c.Brush.Color; c.MoveTo(ptInLast.X,ptInLast.Y); c.LineTo(rIn.Left,rIn.Top); end;
            ptInLast:=Point(rIn.Right,rIn.Top);}
          end;
        end;
      end;
      6..8: begin
        GetTextInfo(pNode,Column,c.Font,r,ws); OffsetRect(r,0,CellRect.Top-r.Top+2);
        r.Bottom:=r.Bottom+((CellRect.Bottom-CellRect.Top)-(r.Bottom-r.Top));
        Header.Columns.GetColumnBounds(6,r.Left,i); Header.Columns.GetColumnBounds(8,i,r.Right);
        OffsetRect(r,-OffsetX,-OffsetY); c.Brush.Color:=$A0FFFF; c.FillRect(r);
        h:=r.Bottom-r.Top+1; w:=r.Right-r.Left+1; rIn:=r; rOut:=r;
        if(w<>0)and(ndx<>0)then begin dw:=w/ndx/2; imax:=max(inPacketsMax,outPacketsMax);
          for i:=0to ndx-1do begin
            if outPacketsMax=0then rOut.Top:=r.Bottom
            else rOut.Top:=r.Bottom-Round((arrOutPackets[i]._lwCurrentSpeed/imax)*h);
            rOut.Left:=r.Left+Round((2*i)*dw); rOut.Right:=r.Left+Round((2*i+1)*dw);
            c.Brush.Color:=$A0A0FF; c.FillRect(rOut);
{            if i<>0then begin c.Pen.Color:=c.Brush.Color; c.MoveTo(ptOutLast.X,ptOutLast.Y); c.LineTo(rOut.Left,rOut.Top); end;
            ptOutLast:=Point(rOut.Right,rOut.Top);}
            if inPacketsMax=0then rIn.Top:=r.Bottom
            else rIn.Top:=r.Bottom-Round((arrInPackets[i]._lwCurrentSpeed/imax)*h);
            rIn.Left:=r.Left+Round((2*i+1)*dw); rIn.Right:=r.Left+Round((2*i+2)*dw);
            c.Brush.Color:=$FFA0A0; c.FillRect(rIn);
{            if i<>0then begin c.Pen.Color:=c.Brush.Color; c.MoveTo(ptInLast.X,ptInLast.Y); c.LineTo(rIn.Left,rIn.Top); end;
            ptInLast:=Point(rIn.Right,rIn.Top);}
          end;
        end;
      end;
    end;
  end;
  if Column=9then case pNode.Index of
    1: DrawTrend(@arrOutBytes,outBytesMax,$A0A0FF);
    2: DrawTrend(@arrInBytes,inBytesMax,$FFA0A0);
    3: begin arrTotalBytes:=arrOutBytes;
      for i:=0to ndxMax-1do arrTotalBytes[i]._lwCurrentSpeed:=arrTotalBytes[i]._lwCurrentSpeed+arrInBytes[i]._lwCurrentSpeed;
      try lti.Lock; i:=lti.rTotalBytesInfo._lwPeakSpeed; finally lti.Unlock; end;
      DrawTrend(@arrTotalBytes,i,clRed);
    end;
  end;
end;

procedure TTrafficView.DoGetText(pNode:PVirtualNode; Column:TColumnIndex; TextType:TVSTTextType; var Text:UnicodeString); begin Text:='';
  with lti do try Lock;
    case Column of
      0: case pNode.Index of
        0: Text:='Скорость';
        1: Text:='Исходящие';
        2: Text:='Входящие';
        3: Text:='Всего';
        4: Text:='Начато';
      end;
      1: case pNode.Index of
        1: Text:=BytesToString(rOutBytesInfo._iTotalData);
        2: Text:=BytesToString(rInBytesInfo._iTotalData);
        3: Text:=BytesToString(rOutBytesInfo._iTotalData+rInBytesInfo._iTotalData);
        4: with lti.fstStarted do Text:=Format('%.4d.%.2d.%.2d',[wYear,wMonth,wDay],gfs);
      end;
      2: case pNode.Index of
        0: Text:='Текущая';
        1: Text:=BitsSpeedToString(rOutBytesInfo._lwCurrentSpeed*8);
        2: Text:=BitsSpeedToString(rInBytesInfo._lwCurrentSpeed*8);
        3: Text:=BitsSpeedToString((rTotalBytesInfo._lwCurrentSpeed)*8);
        4: with lti.fstStarted do Text:=Format('%.2d:%.2d:%.2d.%.3d',[wHour,wMinute,wSecond,wMilliseconds],gfs);
      end;
      3: case pNode.Index of
        0: Text:='Средняя';
        1: Text:=BitsSpeedToString(rOutBytesInfo._lwAverageSpeed*8);
        2: Text:=BitsSpeedToString(rInBytesInfo._lwAverageSpeed*8);
        3: Text:=BitsSpeedToString((rTotalBytesInfo._lwAverageSpeed)*8);
        4: Text:='Время';

      end;
      4: case pNode.Index of
        0: Text:='Пиковая';
        1: Text:=BitsSpeedToString(rOutBytesInfo._lwPeakSpeed*8);
        2: Text:=BitsSpeedToString(rInBytesInfo._lwPeakSpeed*8);
        3: Text:=BitsSpeedToString(rTotalBytesInfo._lwPeakSpeed*8);
        4: Text:=SecondsToString(fmsec div 1000);
      end;
      5: case pNode.Index of
        1: Text:=IntToStr(rOutPacketsInfo._iTotalData);
        2: Text:=IntToStr(rInPacketsInfo._iTotalData);
        3: Text:=IntToStr(rOutPacketsInfo._iTotalData+rInPacketsInfo._iTotalData);
        4: Text:='Ошибки';
      end;
      6: case pNode.Index of
        0: Text:='Текущая';
        1: Text:=IntToStr(rOutPacketsInfo._lwCurrentSpeed)+' пак/с';
        2: Text:=IntToStr(rInPacketsInfo._lwCurrentSpeed)+' пак/с';
        3: Text:=IntToStr(rTotalPacketsInfo._lwCurrentSpeed)+' пак/с';
        4: Text:=IntToStr(rOutErrorsInfo._iTotalData)+' исх/'+IntToStr(rInErrorsInfo._iTotalData)+' вх';
      end;
      7: case pNode.Index of
        0: Text:='Средняя';
        1: Text:=IntToStr(rOutPacketsInfo._lwAverageSpeed)+' пак/с';
        2: Text:=IntToStr(rInPacketsInfo._lwAverageSpeed)+' пак/с';
        3: Text:=IntToStr(rTotalPacketsInfo._lwAverageSpeed)+' пак/с';
        4: Text:='Таймауты';
      end;
      8: case pNode.Index of
        0: Text:='Пиковая';
        1: Text:=IntToStr(rOutPacketsInfo._lwPeakSpeed)+' пак/с';
        2: Text:=IntToStr(rInPacketsInfo._lwPeakSpeed)+' пак/с';
        3: Text:=IntToStr(rTotalPacketsInfo._lwPeakSpeed)+' пак/с';
        4: Text:=IntToStr(rOutTimeoutsInfo._iTotalData)+' исх/'+IntToStr(rInTimeoutsInfo._iTotalData)+' вх';
      end;
    end;
  finally Unlock; end;
end;

procedure TTrafficView.Init; begin ndx:=0;
  ZeroMemory(@arrInBytes,SizeOf(arrInBytes)); ZeroMemory(@arrInPackets,SizeOf(arrInPackets));
  ZeroMemory(@arrInErrors,SizeOf(arrInErrors)); ZeroMemory(@arrInTimeouts,SizeOf(arrInTimeouts));
  ZeroMemory(@arrOutBytes,SizeOf(arrOutBytes)); ZeroMemory(@arrOutPackets,SizeOf(arrOutPackets));
  ZeroMemory(@arrOutErrors,SizeOf(arrOutErrors)); ZeroMemory(@arrOutTimeouts,SizeOf(arrOutTimeouts));
end;

procedure TTrafficView.SetTI(const ti:TTrafficInfo);
begin if ti<>fti then begin fti:=ti; Init; UpdateInfo; end; end;

procedure TTrafficView.UpdateInfo; var iSize:integer; {bRestarted:boolean;}
  function MaxValue(arr:TTrafficDataArray):longword; var i:integer;
  begin Result:=0; for i:=0to High(arr)do if arr[i]._lwCurrentSpeed>Result then Result:=arr[i]._lwCurrentSpeed; end;
begin
  try lti.Lock; {bRestarted:=false;}
    if fti=nil then lti.Assign(fti)
    else try fti.Lock; lti.Assign(fti); {bRestarted:=fti.fbRestarted;} fti.fbRestarted:=false; finally fti.Unlock; end;
    if ndx=ndxMax then begin iSize:=(ndxMax-1)*SizeOf(TrTrafficDataInfo);
      CopyMemory(@arrInBytes[0],@arrInBytes[1],iSize); CopyMemory(@arrInPackets[0],@arrInPackets[1],iSize);
      CopyMemory(@arrInErrors[0],@arrInErrors[1],iSize); CopyMemory(@arrInTimeouts[0],@arrInTimeouts[1],iSize);
      CopyMemory(@arrOutBytes[0],@arrOutBytes[1],iSize); CopyMemory(@arrOutPackets[0],@arrOutPackets[1],iSize);
      CopyMemory(@arrOutErrors[0],@arrOutErrors[1],iSize); CopyMemory(@arrOutTimeouts[0],@arrOutTimeouts[1],iSize);
      dec(ndx);
    end;
    arrInBytes[ndx]:=lti.InBytesInfo; arrInPackets[ndx]:=lti.InPacketsInfo;
    arrInErrors[ndx]:=lti.InErrorsInfo; arrInTimeouts[ndx]:=lti.InTimeoutsInfo;
    arrOutBytes[ndx]:=lti.OutBytesInfo; arrOutPackets[ndx]:=lti.OutPacketsInfo;
    arrOutErrors[ndx]:=lti.OutErrorsInfo; arrOutTimeouts[ndx]:=lti.OutTimeoutsInfo;
{    if(ndx<>0)and(not bRestarted)then begin
      lw:=lti.InBytesInfo._lwLastTicks-arrInBytes[ndx-1]._lwLastTicks;
      if lw<>0then arrInBytes[ndx]._lwCurrentSpeed:=Round((lti.InBytesInfo._iTotalData-arrInBytes[ndx-1]._iTotalData)*1000/lw);
      lw:=lti.InPacketsInfo._lwLastTicks-arrInPackets[ndx-1]._lwLastTicks;
      if lw<>0then arrInPackets[ndx]._lwCurrentSpeed:=Round((lti.InPacketsInfo._iTotalData-arrInPackets[ndx-1]._iTotalData)*1000/lw);
      lw:=lti.InErrorsInfo._lwLastTicks-arrInErrors[ndx-1]._lwLastTicks;
      if lw<>0then arrInErrors[ndx]._lwCurrentSpeed:=Round((lti.InErrorsInfo._iTotalData-arrInErrors[ndx-1]._iTotalData)*1000/lw);
      lw:=lti.InTimeoutsInfo._lwLastTicks-arrInTimeouts[ndx-1]._lwLastTicks;
      if lw<>0then arrInTimeouts[ndx]._lwCurrentSpeed:=Round((lti.InTimeoutsInfo._iTotalData-arrInTimeouts[ndx-1]._iTotalData)*1000/lw);
      lw:=lti.OutBytesInfo._lwLastTicks-arrOutBytes[ndx-1]._lwLastTicks;
      if lw<>0then arrOutBytes[ndx]._lwCurrentSpeed:=Round((lti.OutBytesInfo._iTotalData-arrOutBytes[ndx-1]._iTotalData)*1000/lw);
      lw:=lti.OutPacketsInfo._lwLastTicks-arrOutPackets[ndx-1]._lwLastTicks;
      if lw<>0then arrOutPackets[ndx]._lwCurrentSpeed:=Round((lti.OutPacketsInfo._iTotalData-arrOutPackets[ndx-1]._iTotalData)*1000/lw);
      lw:=lti.OutErrorsInfo._lwLastTicks-arrOutErrors[ndx-1]._lwLastTicks;
      if lw<>0then arrOutErrors[ndx]._lwCurrentSpeed:=Round((lti.OutErrorsInfo._iTotalData-arrOutErrors[ndx-1]._iTotalData)*1000/lw);
      lw:=lti.OutTimeoutsInfo._lwLastTicks-arrOutTimeouts[ndx-1]._lwLastTicks;
      if lw<>0then arrOutTimeouts[ndx]._lwCurrentSpeed:=Round((lti.OutTimeoutsInfo._iTotalData-arrOutTimeouts[ndx-1]._iTotalData)*1000/lw);

      if(arrInBytes[ndx]._lwPeakSpeed<>arrInBytes[ndx-1]._lwPeakSpeed)then
        if(arrInBytes[ndx]._lwCurrentSpeed<arrInBytes[ndx]._lwPeakSpeed)then arrInBytes[ndx]._lwPeakSpeed:=arrInBytes[ndx-1]._lwPeakSpeed;
      if(arrInPackets[ndx]._lwPeakSpeed<>arrInPackets[ndx-1]._lwPeakSpeed)then
        if(arrInPackets[ndx]._lwCurrentSpeed<arrInPackets[ndx]._lwPeakSpeed)then arrInPackets[ndx]._lwPeakSpeed:=arrInPackets[ndx-1]._lwPeakSpeed;
      if(arrOutBytes[ndx]._lwPeakSpeed<>arrOutBytes[ndx-1]._lwPeakSpeed)then
        if(arrOutBytes[ndx]._lwCurrentSpeed<arrOutBytes[ndx]._lwPeakSpeed)then arrOutBytes[ndx]._lwPeakSpeed:=arrOutBytes[ndx-1]._lwPeakSpeed;
      if(arrOutPackets[ndx]._lwPeakSpeed<>arrOutPackets[ndx-1]._lwPeakSpeed)then
        if(arrOutPackets[ndx]._lwCurrentSpeed<arrOutPackets[ndx]._lwPeakSpeed)then arrOutPackets[ndx]._lwPeakSpeed:=arrOutPackets[ndx-1]._lwPeakSpeed;
    end;}
    {lti.rInBytesInfo:=arrInBytes[ndx]; lti.rInPacketsInfo:=arrInPackets[ndx];
    lti.rInErrorsInfo:=arrInErrors[ndx]; lti.rInTimeoutsInfo:=arrInTimeouts[ndx];
    lti.rOutBytesInfo:=arrOutBytes[ndx]; lti.rOutPacketsInfo:=arrOutPackets[ndx];
    lti.rOutErrorsInfo:=arrOutErrors[ndx]; lti.rOutTimeoutsInfo:=arrOutTimeouts[ndx];}
  finally lti.Unlock; end;
  inBytesMax:=MaxValue(arrInBytes); inPacketsMax:=MaxValue(arrInPackets);
  //inErrorsMax:=MaxValue(arrInErrors); inTimeoutsMax:=MaxValue(arrInTimeouts);
  outBytesMax:=MaxValue(arrOutBytes); outPacketsMax:=MaxValue(arrOutPackets);
  //outErrorsMax:=MaxValue(arrOutErrors); outTimeoutsMax:=MaxValue(arrOutTimeouts);
  if ndx<>ndxMax then inc(ndx);
  Invalidate;
end;

procedure TTrafficView._OnAdvancedHeaderDraw(Sender:TVTHeader; var PaintInfo:THeaderPaintInfo; const Elements:THeaderPaintElements);
var c:TCanvas; r:TRect; i:integer; s:AnsiString;
begin if PaintInfo.Column=nil then exit; c:=PaintInfo.TargetCanvas;
  case PaintInfo.Column.Index of
    0: begin
      c.Brush.Color:=clWhite; c.FillRect(PaintInfo.PaintRectangle);
      r:=PaintInfo.TextRectangle; s:=PaintInfo.Column.Text; //if PaintInfo.IsDownIndex then OffsetRect(r,1,1);
      Sender.Columns.GetColumnBounds(0,r.Left,r.Right);
      c.TextRect(r,r.Left+((r.Right-r.Left)-c.TextWidth(s))div 2,r.Top,s);
    end;
    1..4: begin
//      r:=PaintInfo.PaintRectangle; inc(r.Top);
//      Sender.Columns.GetColumnBounds(1,r.Left,i); Sender.Columns.GetColumnBounds(4,i,r.Right);
      c.Brush.Color:=$B0FFB0; c.FillRect(PaintInfo.PaintRectangle);
      r:=PaintInfo.TextRectangle;
      Sender.Columns.GetColumnBounds(1,r.Left,i); Sender.Columns.GetColumnBounds(4,i,r.Right);
      c.Font.Color:=clBlack; s:='Байты'; // c.Brush.Style:=bsClear;
      c.TextRect(r,r.Left+((r.Right-r.Left)-c.TextWidth(s))div 2,r.Top,s);
    end;
    5..8: begin
      c.Brush.Color:=$BFFFF0; c.FillRect(PaintInfo.PaintRectangle);
      r:=PaintInfo.TextRectangle;
      Sender.Columns.GetColumnBounds(5,r.Left,i); Sender.Columns.GetColumnBounds(8,i,r.Right);
      c.Font.Color:=clBlack; s:='Пакеты';
      c.TextRect(r,r.Left+((r.Right-r.Left)-c.TextWidth(s))div 2,r.Top,s);
    end;
    9: begin
      c.Brush.Color:=clWhite; c.FillRect(PaintInfo.PaintRectangle);
      r:=PaintInfo.TextRectangle;
      Sender.Columns.GetColumnBounds(9,r.Left,r.Right);
      c.Font.Color:=clBlack; s:='Тренды';
      c.TextRect(r,r.Left+((r.Right-r.Left)-c.TextWidth(s))div 2,r.Top,s);
    end;
  end;
end;

procedure TTrafficView._OnHeaderDrawQueryElements(Sender:TVTHeader; var PaintInfo:THeaderPaintInfo; var Elements:THeaderPaintElements);
begin Elements:=[hpeBackground,hpeText]; end;

procedure TTrafficView._OnTimer(Sender:TObject);
begin inc(cnt); if cnt=cntMax then begin cnt:=0; UpdateInfo; end; end;

initialization
  GetLocaleFormatSettings(SysLocale.DefaultLCID,gfs);

end.
