unit qCDKbrowser;

interface

uses Controls,sPanel,Classes,sLabel,VirtualTrees,Messages,sMemo,
  qCDKclasses,uEditors,uTrees;

type
  PrCommNodeData=^TrCommNodeData;
  TrCommNodeData=packed record
    _o:TObject;
    _sName,_sDescription:AnsiString;
  end;


  TCommunicationObjectsTree=class(TBaseStringTree)
  protected
    cs:TCommunicationSpace;
    procedure DoFreeNode(pn:PVirtualNode); override;
    procedure DoGetText(pn:PVirtualNode; Column:TColumnIndex; TextType:TVSTTextType; var Text:UnicodeString); override;
    procedure ValidateNodeDataSize(var i32Size:integer); override;
  public
    constructor Create(aOwner:TComponent); override;
    destructor Destroy; override;
    procedure Changed; virtual; // CommunicationSpace изменился или стал равным nil
  end;

  TCommunicationClassesTree=class(TBaseStringTree)
  protected
    cs:TCommunicationSpace;
    procedure DoFreeNode(pn:PVirtualNode); override;
    procedure DoGetText(pn:PVirtualNode; Column:TColumnIndex; TextType:TVSTTextType; var Text:UnicodeString); override;
    procedure ValidateNodeDataSize(var i32Size:integer); override;
  public
    constructor Create(aOwner:TComponent); override;
    destructor Destroy; override;
    procedure Changed; virtual; // CommunicationSpace изменился или стал равным nil
  end;

  TCommunicationBrowser=class(TsPanel)
  private
    fcs:TCommunicationSpace;

    pnl:TsPanel;
      lblCaption:TsLabel; lblCS:TsLabel;
    pnlObjects:TsPanel;
      lblObjects:TsLabel; tvObjects:TCommunicationObjectsTree;
    pnlClasses:TsPanel;
      lblClasses:TsLabel; tvClasses:TCommunicationClassesTree;
    pnlInfo:TsPanel;
      mmoInfo:TsMemo;
    procedure SetCommunicationSpace(const cs:TCommunicationSpace);
  protected
    procedure Resize; override;

    procedure ctrlMouseDown(Sender:TObject; btn:TMouseButton; setShift:TShiftState; x,y:integer);
    procedure _OnChanged(Sender:TObject); virtual;
    procedure _OnNodeChanged(tv:TBaseVirtualTree; pn:PVirtualNode);     
  public
    constructor Create(aOwner:TComponent); override;
    destructor Destroy; override;
//    procedure WndProc(var M:TMessage); override;    

    property CommunicationSpace:TCommunicationSpace read fcs write SetCommunicationSpace;
  end;

  procedure ShowCommunicationBrowser(cs:TCommunicationSpace=nil);

implementation

uses Windows,SysUtils,StdCtrls,Forms,ExtCtrls,
  uUtilsFunctions,uNamedSpace;

const WM_CDKObjectChanged=WM_USER+1;

var fm:TMovingForm;

  procedure ShowCommunicationBrowser(cs:TCommunicationSpace=nil); begin
    if cs=nil then cs:=CommunicationSpace;
    if fm=nil then begin
      fm:=TMovingForm.Create(nil); fm.Width:=640; fm.Height:=480; fm.Position:=poDesktopCenter; fm.ShowHint:=true;
      with TCommunicationBrowser.Create(fm)do begin Align:=alClient;
        CommunicationSpace:=cs;
      end;
    end;
    fm.Show;
  end;

  procedure _OnDoubleBuffered(c:TControl); stdcall;
  begin if c is TWinControl then TWinControl(c).DoubleBuffered:=true; end;

{ TCommunicationObjectsTree }

procedure TCommunicationObjectsTree.Changed; var pn,pnChild,pnNext:PVirtualNode; var pnd:PrCommNodeData; l:TList;
  procedure UpdateChilds(pnParent:PVirtualNode; pndParent:PrCommNodeData); var pnChild,pnNext:PVirtualNode; l:TList; i:integer; begin l:=nil;
    try l:=TList.Create;
      if pndParent._o is TCommunicationConnection then with TCommunicationConnection(pndParent._o)do try Lock;
        l.Add(CommunicationMode); if CommunicationSocket<>nil then l.Add(CommunicationSocket);
        pnChild:=pnParent.FirstChild;
        while pnChild<>nil do begin pnd:=GetNodeData(pnChild); pnNext:=pnChild.NextSibling;
          i:=l.IndexOf(pnd._o); if i=-1then begin pnd._o:=nil; DeleteNode(pnChild); end else begin l.Delete(i); pnd._sName:=TCommunicationObject(pnd._o).Name; pnd._sDescription:=TCommunicationObject(pnd._o).ClassName; end;
          pnChild:=pnNext;
        end;
        for i:=0to l.Count-1do begin pnChild:=AddChild(pnParent,nil); pnd:=GetNodeData(pnChild); pnd._o:=l[i]; pnd._sName:=TCommunicationObject(pnd._o).Name;
          pnd._sDescription:=TCommunicationObject(pnd._o).ClassName;
        end;
      finally Unlock; end else if pndParent._o is TCommunicationDevice then;
    finally l.Free; end;
  end;
  procedure UpdateNodes(pnParent:PVirtualNode; cos:TCommunicationObjects; bUpdateChilds:boolean=false); var i:integer; begin
    pnd._o:=cos; pnChild:=pnParent.FirstChild; for i:=0to cos.ObjectsCount-1do l.Add(cos.Objects[i]);
    if(l.Count=0)then DeleteChildren(pnParent,true)
    else begin
      while pnChild<>nil do begin pnd:=GetNodeData(pnChild); pnNext:=pnChild.NextSibling;
        i:=l.IndexOf(pnd._o); if i=-1then DeleteNode(pnChild)else begin l.Delete(i); pnd._sName:=TCommunicationObject(pnd._o).Name; pnd._sDescription:=TCommunicationObject(pnd._o).ClassName; if bUpdateChilds then UpdateChilds(pnChild,pnd); end;
        pnChild:=pnNext;
      end;
      for i:=0to l.Count-1do begin pnChild:=AddChild(pnParent,nil); pnd:=GetNodeData(pnChild); pnd._o:=l[i]; pnd._sName:=TCommunicationObject(pnd._o).Name;
        pnd._sDescription:=TCommunicationObject(pnd._o).ClassName; if bUpdateChilds then UpdateChilds(pnChild,pnd);
      end;
    end;
  end;
begin l:=nil;
  try l:=TList.Create; pn:=RootNode.FirstChild;
    if cs=nil then while pn<>nil do begin pnd:=GetNodeData(pn); pnd._o:=nil; DeleteChildren(pn,true); pn:=pn.NextSibling; end
    else while pn<>nil do begin pnd:=GetNodeData(pn); l.Clear;
      case pn.Index of
        0: UpdateNodes(pn,cs.Modes);
        1: UpdateNodes(pn,cs.Sockets);
        2: UpdateNodes(pn,cs.Connections,true);
        3: UpdateNodes(pn,cs.Protocols);
        4: UpdateNodes(pn,cs.Devices,true);
      end;
      pn:=pn.NextSibling;
    end;
  finally l.Free; end;
  Repaint;
end;

constructor TCommunicationObjectsTree.Create(aOwner:TComponent); begin inherited ;
  with Self do begin if aOwner is TWinControl then Parent:=TWinControl(aOwner); DoubleBuffered:=true;
    Header.Options:=[{hoAutoResize,}hoColumnResize,hoDblClickResize,hoDrag,hoShowSortGlyphs,hoVisible];
    Header.Style:=hsPlates; Header.SortColumn:=-1;
    IncrementalSearch:=isAll; IncrementalSearchStart:=ssAlwaysStartOver;
    TreeOptions.MiscOptions:=TreeOptions.MiscOptions+[toEditable,toEditOnDblClick,toReportMode]-[toCheckSupport];
    TreeOptions.PaintOptions:=TreeOptions.PaintOptions+[toShowHorzGridLines,toShowVertGridLines,toFullVertGridLines,toHideFocusRect,toGhostedIfUnfocused]{-[toShowButtons]};
    TreeOptions.SelectionOptions:=TreeOptions.SelectionOptions+[toExtendedFocus,toFullRowSelect];
    with Header.Columns.Add do begin
      Width:=200; Text:='Объекты'; Options:=Options-[coAllowFocus]; {Color:=clRed;}
//      Indent:=0; Margin:=0;
    end;
    with Header.Columns.Add do begin Width:=35; Text:='Класс'; Options:=Options-[coAllowFocus]; {Color:=$FFE0E0;} end;
    Header.MainColumn:=0; HintMode:=hmTooltip; Header.AutoSizeIndex:=1; Header.Options:=Header.Options+[hoAutoResize];
    {FocusedColumn:=6;} LineMode:=lmBands;
    AddChild(nil); AddChild(nil); AddChild(nil); AddChild(nil); AddChild(nil); AddChild(nil);
  end;
end;

destructor TCommunicationObjectsTree.Destroy;
begin cs:=nil; Changed; inherited; end;

procedure TCommunicationObjectsTree.DoFreeNode(pn:PVirtualNode); var pnd:PrCommNodeData; begin
  if pn<>nil then begin pnd:=GetNodeData(pn); pnd._sName:=''; pnd._sDescription:=''; end;
  inherited;
end;

procedure TCommunicationObjectsTree.DoGetText(pn:PVirtualNode; Column:TColumnIndex; TextType:TVSTTextType; var Text:UnicodeString); var pnd:PrCommNodeData; begin
  Text:='';
  case Column of
    0: if pn.Parent=RootNode then case pn.Index of
      0: Text:='Режимы';  1: Text:='Сокеты';  2: Text:='Соединения';  3: Text:='Протоколы'; 4: Text:='Устройства';  5: Text:='Потоки';
    end else begin pnd:=GetNodeData(pn); Text:=pnd._sName; end;
    1: if pn.Parent<>RootNode then begin pnd:=GetNodeData(pn); Text:=pnd._sDescription; end;
  end;
end;

procedure TCommunicationObjectsTree.ValidateNodeDataSize(var i32Size:integer);
begin i32Size:=SizeOf(TrCommNodeData); end;

{ TCommunicationClassesTree }

procedure TCommunicationClassesTree.Changed; var pn,pnChild,pnNext:PVirtualNode; var pnd:PrCommNodeData; l:TList; 
  procedure UpdateNodes(pnParent:PVirtualNode; cos:TCommunicationObjectClasses); var i:integer; begin
    pnd._o:=cos; pnChild:=pnParent.FirstChild; for i:=0to cos.ClassesCount-1do l.Add(cos.Classes[i]);
    if(l.Count=0)then DeleteChildren(pnParent,true)
    else begin
      while pnChild<>nil do begin pnd:=GetNodeData(pnChild); pnNext:=pnChild.NextSibling;
        i:=l.IndexOf(pnd._o); if i=-1then DeleteNode(pnChild)else begin l.Delete(i); pnd._sName:=TCommunicationObjectClass(pnd._o).ClassName; pnd._sDescription:=TCommunicationObjectClass(pnd._o).GetClassCaption; end;
        pnChild:=pnNext;
      end;
      for i:=0to l.Count-1do begin pnChild:=AddChild(pnParent,nil); pnd:=GetNodeData(pnChild); pnd._o:=l[i]; pnd._sName:=TCommunicationObjectClass(pnd._o).ClassName;
        pnd._sDescription:=TCommunicationObjectClass(pnd._o).GetClassCaption; end;
    end;
  end;
begin l:=nil;
  try l:=TList.Create; pn:=RootNode.FirstChild;
    if cs=nil then while pn<>nil do begin pnd:=GetNodeData(pn); pnd._o:=nil; DeleteChildren(pn,true); pn:=pn.NextSibling; end
    else while pn<>nil do begin pnd:=GetNodeData(pn); l.Clear;
      case pn.Index of
        0: UpdateNodes(pn,cs.ModeClasses);
        1: UpdateNodes(pn,cs.SocketClasses);
        2: UpdateNodes(pn,cs.ConnectionClasses); 
        3: UpdateNodes(pn,cs.ProtocolClasses); 
        4: UpdateNodes(pn,cs.DeviceClasses);
      end;
      pn:=pn.NextSibling;
    end;
  finally l.Free; end;
  Invalidate;
end;

constructor TCommunicationClassesTree.Create(aOwner:TComponent); begin inherited;
  with Self do begin if aOwner is TWinControl then Parent:=TWinControl(aOwner); DoubleBuffered:=true;
    Header.Options:=[{hoAutoResize,}hoColumnResize,hoDblClickResize,hoDrag,hoShowSortGlyphs,hoVisible];
    Header.Style:=hsPlates; Header.SortColumn:=-1;
    IncrementalSearch:=isAll; IncrementalSearchStart:=ssAlwaysStartOver;
    TreeOptions.MiscOptions:=TreeOptions.MiscOptions+[toEditable,toEditOnDblClick,toReportMode]-[toCheckSupport];
    TreeOptions.PaintOptions:=TreeOptions.PaintOptions+[toShowHorzGridLines,toShowVertGridLines,toFullVertGridLines,toHideFocusRect,toGhostedIfUnfocused]{-[toShowButtons]};
    TreeOptions.SelectionOptions:=TreeOptions.SelectionOptions+[toExtendedFocus,toFullRowSelect];
    with Header.Columns.Add do begin Width:=200; Text:='Классы'; Options:=Options-[coAllowFocus]; {Color:=clRed;}
//      Indent:=0; Margin:=0;
    end;
    with Header.Columns.Add do begin Width:=35; Text:='Описание'; Options:=Options-[coAllowFocus]; {Color:=$FFE0E0;} end;
    Header.MainColumn:=0; HintMode:=hmTooltip; Header.AutoSizeIndex:=1; Header.Options:=Header.Options+[hoAutoResize];
    {FocusedColumn:=6;} LineMode:=lmBands;
    AddChild(nil); AddChild(nil); AddChild(nil); AddChild(nil); AddChild(nil);
  end;
end;

destructor TCommunicationClassesTree.Destroy;
begin cs:=nil; Changed; inherited; end;

procedure TCommunicationClassesTree.DoFreeNode(pn:PVirtualNode); var pnd:PrCommNodeData; begin
  if pn<>nil then begin pnd:=GetNodeData(pn); pnd._sName:=''; pnd._sDescription:=''; end;
  inherited;
end;

procedure TCommunicationClassesTree.DoGetText(pn:PVirtualNode; Column:TColumnIndex; TextType:TVSTTextType; var Text:UnicodeString); var pnd:PrCommNodeData; begin
  Text:='';
  case Column of
    0: if pn.Parent=RootNode then case pn.Index of
      0: Text:='Режимы';  1: Text:='Сокеты';  2: Text:='Соединения';  3: Text:='Протоколы'; 4: Text:='Устройства';
    end else begin pnd:=GetNodeData(pn); Text:=pnd._sName; end;
    1: if pn.Parent<>RootNode then begin pnd:=GetNodeData(pn); Text:=pnd._sDescription; end;
  end;
end;

procedure TCommunicationClassesTree.ValidateNodeDataSize(var i32Size:integer);
begin i32Size:=SizeOf(TrCommNodeData); end;

{ TCommunicationBrowser }

constructor TCommunicationBrowser.Create(aOwner:TComponent); begin inherited;
  if aOwner is TWinControl then Parent:=TWinControl(aOwner); OnMouseDown:=ctrlMouseDown;
  pnl:=TsPanel.Create(Self); with pnl do begin Parent:=Self; Align:=alTop; OnMouseDown:=ctrlMouseDown; end;
  lblCaption:=TsLabel.Create(pnl); with lblCaption do begin Parent:=pnl; OnMouseDown:=ctrlMouseDown;
    Align:=alTop; Alignment:=taCenter; Layout:=tlCenter; Caption:='Браузер коммуникационного пространства'; Height:=Height+4;
  end;
  lblCS:=TsLabel.Create(pnl); with lblCS do begin Parent:=pnl; OnMouseDown:=ctrlMouseDown;
    Align:=alTop; Alignment:=taCenter; Layout:=tlCenter; Height:=Height+4;
  end;
  pnlObjects:=TsPanel.Create(Self); with pnlObjects do begin Parent:=Self; OnMouseDown:=ctrlMouseDown; end;
  lblObjects:=TsLabel.Create(pnlObjects); with lblObjects do begin Parent:=pnlObjects; OnMouseDown:=ctrlMouseDown;
    Align:=alTop; Alignment:=taCenter; Layout:=tlCenter; Caption:='Рабочие объекты'; Height:=Height+4;
  end;
  tvObjects:=TCommunicationObjectsTree.Create(pnlObjects); with tvObjects do begin Parent:=pnlObjects; Align:=alClient; OnChange:=_OnNodeChanged; end;
  pnlClasses:=TsPanel.Create(Self); with pnlClasses do begin Parent:=Self; OnMouseDown:=ctrlMouseDown; end;
  lblClasses:=TsLabel.Create(pnlClasses); with lblClasses do begin Parent:=pnlClasses; OnMouseDown:=ctrlMouseDown;
    Align:=alTop; Alignment:=taCenter; Layout:=tlTop; Caption:='Доступные классы'; Height:=Height+4;
  end;
  tvClasses:=TCommunicationClassesTree.Create(pnlClasses); with tvClasses do begin Parent:=pnlClasses; Align:=alClient; OnChange:=_OnNodeChanged; end;
  pnlInfo:=TsPanel.Create(Self); with pnlInfo do begin Parent:=Self; Align:=alBottom; OnMouseDown:=ctrlMouseDown; Height:=120; end;
  mmoInfo:=TsMemo.Create(pnlInfo); with mmoInfo do begin Parent:=pnlInfo; Align:=alClient; ReadOnly:=true; ScrollBars:=ssBoth; WordWrap:=false; end;
  EnumControls(Self,_OnDoubleBuffered);
end;

procedure TCommunicationBrowser.ctrlMouseDown(Sender:TObject; btn:TMouseButton; setShift:TShiftState; x,y:integer); var fm:TCustomForm; begin
  fm:=GetParentForm(TControl(Sender)); if fm=nil then exit;
  with fm do if WindowState<>wsMaximized then begin ReleaseCapture; Perform(WM_SYSCOMMAND,$F012,0); end;
end;

destructor TCommunicationBrowser.Destroy;
begin CommunicationSpace:=nil; inherited; end;

procedure TCommunicationBrowser.Resize; begin inherited;
  if(pnlObjects=nil)or(pnlClasses=nil)then exit;
  //Perform(WM_SETREDRAW,0,0);
  pnlObjects.Align:=alLeft; pnlObjects.Align:=alNone;
  pnlClasses.Align:=alRight; pnlClasses.Align:=alNone;
  pnlObjects.Width:=ClientWidth div 2; pnlClasses.Left:=pnlObjects.Left+pnlObjects.Width+1; pnlClasses.Width:=ClientWidth-pnlClasses.Left-pnlObjects.Left;
  //Perform(WM_SETREDRAW,1,0); Invalidate;
end;

procedure TCommunicationBrowser.SetCommunicationSpace(const cs:TCommunicationSpace); begin
  try
    if cs<>fcs then begin if fcs<>nil then fcs.RemoveOnChange(Self,fcs,_OnChanged);
      fcs:=cs; if fcs<>nil then fcs.AddOnChange(Self,fcs,_OnChanged);
      tvObjects.cs:=fcs; tvClasses.cs:=fcs;
    end;
    if fcs=nil then lblCS.Caption:=''else lblCS.Caption:=fcs.Name+' ('+fcs.ClassName+')';
    _OnChanged(Self); tvObjects.FullExpand; tvClasses.FullExpand;
//    if not(csDestroying in ComponentState)then _OnChanged(Self)else begin tvObjects.Changed; tvClasses.Changed; end;
  except end;
end;

//procedure TCommunicationBrowser.WndProc(var M:TMessage); var msg:tagMSG; begin
//  if M.Msg=WM_CDKObjectChanged then begin
//    while PeekMessageA(msg,Handle,WM_CDKObjectChanged,WM_CDKObjectChanged,PM_REMOVE)do;
//    tvObjects.Changed; tvClasses.Changed;
//  end;
//  inherited;
//end;

procedure TCommunicationBrowser._OnChanged(Sender:TObject);
  begin try tvObjects.Changed; tvClasses.Changed; {PostMessageA(Handle,WM_CDKObjectChanged,0,0);} except raise Exception.Create('nennnfka;э'); end; end;

procedure TCommunicationBrowser._OnNodeChanged(tv:TBaseVirtualTree; pn:PVirtualNode); var pnd:PrCommNodeData; begin if csDestroying in ComponentState then exit;
  if(fcs=nil)or(tv=nil)or(pn=nil)then begin mmoInfo.Clear; exit; end;
  pnd:=tv.GetNodeData(pn);
  if tv=tvObjects then
    if pnd._o is TNamedObjects then mmoInfo.Text:=TNamedObjects(pnd._o).AsText
    else if pnd._o is TNamedObject then mmoInfo.Text:=TNamedObject(pnd._o).AsText else mmoInfo.Clear
  else if tv=tvClasses then
    if pn.Parent=tvClasses.RootNode then if pnd._o is TNamedObjectClasses then mmoInfo.Text:=TNamedObjectClasses(pnd._o).AsText else mmoInfo.Clear
    else mmoInfo.Text:=TCommunicationObjectClass(pnd._o).GetClassAsText;
end;

initialization
finalization
  FreeAndNil(fm);

end.
