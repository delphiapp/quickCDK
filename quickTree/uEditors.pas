unit uEditors;

interface

uses Windows,Classes,ExtCtrls,Types,Controls,Messages,Buttons,Graphics,Forms,SysUtils,Dialogs,ComCtrls,
  VirtualTrees,
  sPanel,sLabel,sEdit,sButton,sGroupBox,sSpeedButton,sComboEdit,sCheckListBox,sListBox,sSpinEdit,
  sColorSelect,sTrackBar,sBitBtn;

type
  TMovingForm=class(TForm)
  protected
    procedure MouseDown(btn:TMouseButton; setShift:TShiftState; x,y:integer); override;
    procedure WndProc(var M:TMessage); override;
  public
  public
    constructor Create(aOwner:TComponent); override;
    procedure _OnMouseDown(Sender:TObject; btn:TMouseButton; setShift:TShiftState; x,y:integer); virtual;    
  end;

  TDeactivateForm=class(TMovingForm)
  protected
    procedure Deactivate; override;
    procedure KeyPress(var cKey:Char); override;
    procedure WndProc(var M:TMessage); override;
  public
    constructor Create(aOwner:TComponent); override;
  end;

////////// расширенные версии обычных контролов
  TsExCheckListBox=class(TsCheckListBox)
  private
    fOnChanged:TNotifyEvent;
  public
    procedure WndProc(var M:TMessage); override;

    property OnChanged:TNotifyEvent read fOnChanged write fOnChanged;
  end;

  TsColorListBox=class(TsListBox)
  protected
    procedure DrawItem(ndx:integer; r:TRect; setState:TOwnerDrawState); override;
  public
    constructor Create(aOwner:TComponent); override;
  end;

  TsFilteredListBox=class(TsListBox)
  private
    fsFilter:AnsiString;
    fsItems:TStringList;
    function GetItemsFiltered:TStrings;
    procedure SetFilter(const s:AnsiString);
    procedure SetItems(const sl:TStringList);
  protected
    procedure DrawItem(ndx:integer; r:TRect; setState:TOwnerDrawState); override;

    procedure _OnChanged(Sender:TObject); virtual;
  public
    constructor Create(aOwner:TComponent); override;
    destructor Destroy; override;

    property Filter:AnsiString read fsFilter write SetFilter;
    property Items:TStringList read fsItems write SetItems;
    property ItemsFiltered:TStrings read GetItemsFiltered;
  end;

  TsFilteredColorListBox=class(TsFilteredListBox)
  protected
    procedure DrawItem(ndx:integer; r:TRect; setState:TOwnerDrawState); override;
  end;


////////// панели редактирования (для редактирования значения свойства)
  TCommonEditPanel=class(TsPanel)
  private
    fOnChanged:TNotifyEvent;
    edtAvailableIndex:TsSpinEdit; // индекс возможного значения
    lbxAvailableValues:TsListBox; // список возможных значений
    fsValue:AnsiString;           // текущее значение
    fbUpdating:boolean;
    procedure SetValue(const s:AnsiString); // список возможных значений
  protected
    procedure _OnClick(Sender:TObject); virtual; // что-то изменилось или нажалось
  public
    constructor Create(aOwner:TComponent); override;
    procedure WndProc(var M:TMessage); override;

    property Value:AnsiString read fsValue write SetValue; // текстовое значение "значения" свойства

    property OnChanged:TNotifyEvent read fOnChanged write fOnChanged;   // при изменении значения будет вызвано
  end;

  TColorEditPanel=class(TCommonEditPanel)
  private
    function GetColorValue:integer;
    procedure SetColorValue(const c:integer);
    procedure SetColorText(const s:AnsiString);
  protected
    btnSelectColor:TsColorSelect; lbxColors:TsColorListBox;
    procedure DoGetColors; virtual;                     // создаётся список всех цветов

    procedure _OnClick(Sender:TObject); override;       // изменился индекс цвета, цвет в списке или цвет из диалога
    procedure _OnGetColorName(const s:string);          // перед заполнением списка цветов вызывается
    procedure _OnKeyPress(Sender:TObject; var c:char);  // при нажатии кнопки
  public
    constructor Create(aOwner:TComponent); override;

    {$WARNINGS OFF}
    property ColorText:AnsiString read fsValue write SetColorText;  // текстовое имя цвета
    {$WARNINGS ON}
    property ColorValue:integer read GetColorValue write SetColorValue; // RGB-значение, и для системных цветов
  end;

  TCheckListPanel=class(TCommonEditPanel)
  private
    clb:TsExCheckListBox; btnResetAll,btnSetAll:TsSpeedButton;
  protected
    procedure _OnClick(Sender:TObject); override;
  public
    constructor Create(aOwner:TComponent); override;
  end;

// сами редакторы с панелями редактирования
  TFilteredEdit=class(TsComboEdit)
  private
    bIgnoreDoFilter:boolean;
    fmFiltered:TDeactivateForm; lbxFiltered:TsFilteredListBox; // фильтрованный список - а также наследники этого же класса
  protected
    procedure Change; override;
    procedure KeyDown(var wKey:word; setShift:TShiftState); override;

    function DoCreateListBox:TsFilteredListBox; virtual; // здесь создаётся экземпляр списка наследников класса TsFilteredListBox
    procedure DoFilter; virtual;
    function GetFilterString:AnsiString; virtual; // строка для фильтрации в списке, в наследниках можно брать другое значение
    procedure _OnClick(Sender:TObject); virtual;
  public
    constructor Create(aOwner:TComponent); override;
    procedure CreateParams(var Params:TCreateParams); override;
    procedure WndProc(var M:TMessage); override;
  end;

  TFilteredPaneledEdit=class(TFilteredEdit)
  private
    fmEdit:TDeactivateForm; pnlEdit:TCommonEditPanel; // панель редактирования - а также наследники этого же класса
  protected
    function DoCreateEditPanel:TCommonEditPanel; virtual; // здесь создаётся экземпляр панели редактирования свойства (наследники класса TCommonEditPanel)

    procedure KeyDown(var wKey:word; setShift:TShiftState); override;
    procedure _OnClick(Sender:TObject); override;
  public
    constructor Create(aOwner:TComponent); override;

    procedure WndProc(var M:TMessage); override;
  end;

  TCheckListEdit=class(TFilteredPaneledEdit)
  private
    pnl:TCheckListPanel;
    fbCanAddNewItem,fbIgnoreChanged{,fbSaveSelection}:boolean;
    function GetCheckListBox:TsExCheckListBox;
  protected
    procedure DblClick; override;
    procedure DoEnter; override;
    procedure KeyDown(var wKey:word; setShift:TShiftState); override;
    procedure MouseDown(btn:TMouseButton; setShift:TShiftState; x,y:integer); override;

    function DoCreateEditPanel:TCommonEditPanel; override; // здесь создаётся экземпляр панели редактирования свойства (наследники класса TCommonEditPanel)
    function GetFilterString:AnsiString; override; // строка для фильтрации в списке, в наследниках можно брать другое значение
    procedure _OnClick(Sender:TObject); override;

    procedure DoRemoveUnusedItems; virtual; // убирает неиспользуемые значения (которые Disabled и Unchecked)
  public
    procedure WndProc(var M:TMessage); override;

    property CanAddNewItem:boolean read fbCanAddNewItem write fbCanAddNewItem; // когда меняется Self.Text, в список добавляются те, кто в нём не существовал
    property CheckListBox:TsExCheckListBox read GetCheckListBox;
  end;

  TColorEdit=class(TFilteredPaneledEdit)
  private
    pnl:TColorEditPanel; {fCanvas:TCanvas; }
    procedure WMPaint(var M:TWMPaint); message WM_PAINT;

    function GetColorValue:integer;
    procedure SetColorValue(const c:integer);
  protected
    procedure DblClick; override;

    function DoCreateEditPanel:TCommonEditPanel; override; // здесь создаётся экземпляр панели редактирования свойства (наследники класса TCommonEditPanel)
    function DoCreateListBox:TsFilteredListBox; override; // здесь создаётся экземпляр списка наследников класса TsFilteredListBox

    procedure _OnClick(Sender:TObject); override;
  public
    constructor Create(aOwner:TComponent); override;
    destructor Destroy; override;

    procedure WndProc(var M:TMessage); override;

    property ColorValue:integer read GetColorValue write SetColorValue; // RGB-значение, и для системных цветов
  end;

  PrAttrsNodeData=^TrAttrsNodeData;
  TrAttrsNodeData=packed record
    _sName,_sValue:AnsiString;
    _ctrl:TControl;
  end;

  TAttributesDisplayOption=(adoMeasureUnit,adoCategories,adoRangeMinMax,adoMinMax);
  TAttributesDisplayOptions=packed set of TAttributesDisplayOption;
  TNodeControlClickEvent=procedure(tv:TVirtualStringTree; n:PVirtualNode; ctrl:TControl)of object; 
  // показывать или нет один из следующих атрибутов
  // adoParamType - тип параметра
  // adoMeasureUnit - единица измерения
  // adoCategories - категории параметра
  // adoMinMax - минимальное и максимальное значение параметра
  // adoRangeMinMax - минимальное и максимальное значение диапазона типа параметра

{    _bValidValue:boolean;           // параметр определён или проинициализирован true - значение известно, false - неизвестно
    _setPAR:TParamAccessRights;     // права доступа
    _pExtraData:pointer;            // указатель на дополнительные данные, можно использовать по своему усмотрению
    _eRangeMin,_eRangeMax:extended; // минимальное и максимальное значения данного типа параметра
    _eMin,_eMax:extended;           // минимум и максимум параметра
    _wDisplayRadix:word;            // основание вывода значений при переводе в строку, 0 - перевод по умолчанию
    _wIntDigits:word;               // количество целых цифр, 0 - сколько есть (без добавления нулей) - только для 10й системы (или 0й)
    _wFracDigits:word;              // количество дробных цифр (после точки), 0 - сколько есть (без добавления нулей) - только для 10й системы (или 0й)
    _wByteCount:word;               // размер данных в памяти в байтах
    _wBitCount:word;                // размер данных в памяти в битах - могут быть нецелые байты, лишние впереди нули не нужны _wByteCount=(_wBitCount+7)div 8;
    _sMeasureUnit:AnsiString;       // единица измерения
    _sCategories:AnsiString;        // список строк категорий параметра, например "измерения,токи,фаза А,угол"
    _slAvailableValues:THashedStringList; // список допустимых значений - не для массивов
    _slTypeValues:THashedStringList;    // список значений - для enum, set и bool (чётные - значения false, нечётные - значения true)

//    _bNan,_bInf,_bNegInf:boolean; // для вещественных типов значения NaN, Inf, NegInf существуют, а вот для целочисленных - нет
}

  TAttributesView=class(TVirtualStringTree)
  private
    fOnNodeControlClick:TNodeControlClickEvent;
    fsetDisplayOptions:TAttributesDisplayOptions;
    procedure SetDisplayOptions(const ado:TAttributesDisplayOptions);
  protected
    procedure DoAfterCellPaint(c:TCanvas; pn:PVirtualNode; Column:TColumnIndex; CellRect:TRect); override;
    procedure DoCanEdit(pn:PVirtualNode; Column:TColumnIndex; var bAllowed:boolean); override;
    procedure DoFocusChange(pn:PVirtualNode; Column:TColumnIndex); override;
    procedure DoFreeNode(pn:PVirtualNode); override;
    procedure DoGetText(pn:PVirtualNode; Column:TColumnIndex; TextType:TVSTTextType; var Text:UnicodeString); override;

    procedure CreateNodes; virtual; // здесь будут свойства тега
    function GetAttributeNode(const ndx:integer):PVirtualNode; virtual; // получаем свойство тега по индексу
{    function GetAttributeNode(sName:AnsiString):PVirtualNode; virtual; // получаем узел по имени тега}

    procedure _OnClick(Sender:TObject); virtual;
  public
    constructor Create(aOwner:TComponent); override;

    property DisplayOptions:TAttributesDisplayOptions read fsetDisplayOptions write SetDisplayOptions;
    property OnNodeControlClick:TNodeControlClickEvent read fOnNodeControlClick write fOnNodeControlClick;
  end;

////////// полноценные редакторы свойств
  TCommonEditor=class(TsPanel)
  private
    lblTagName:TsHTMLLabel; lblTagPath:TsHTMLLabel;
    tvAttr:TAttributesView;
    pnlNewValue:TsPanel;
    btnApply,btnCancel:TsButton;
    fiModalResult:TModalResult;
  protected
    ctrlNewValue:TControl; // здесь будет объект, отвечающий за непосредственный ввод нового значения
    function DoCreateNewValueEdit:TControl; virtual; // здесь нужно создавать любые контролы, которые необходимы для ввода нового значения, возвращается сам контрол, где вводится новое значение
    function DoGetValue(ndx:integer):AnsiString; virtual; // получить строковое значение свойства тега по индексу
    procedure DoSetNewValue(ndx:integer); virtual; // установить новое значение в соответствии с индексом (мин,макс,текущее)
    procedure DoUpdateControls; virtual; // обновить контролы

    function DoGetNewValue:OleVariant; virtual;    

    procedure MouseDown(btn:TMouseButton; setShift:TShiftState; x,y:integer); override;

    procedure _OnClick(Sender:TObject); virtual;
    procedure _OnNodeControlClick(tv:TVirtualStringTree; n:PVirtualNode; ctrl:TControl); virtual;
    procedure _OnMouseDown(Sender:TObject; btn:TMouseButton; setShift:TShiftState; x,y:integer); virtual;
    procedure _OnResize(Sender:TObject); virtual;
  public
    constructor Create(aOwner:TComponent); override;
    property ModalResult:TModalResult read fiModalResult;
    property NewValue:OleVariant read DoGetNewValue;
  end;

  TBooleanEditor=class(TCommonEditor)
  private
    fbMin,fbMax,fbCurrent:boolean; fsFalse,fsTrue:AnsiString;
    lblNewValue:TsLabel; btnNewValue:TsBitBtn;
    procedure _OnPaintText(Sender:TBaseVirtualTree; const TargetCanvas:TCanvas; n:PVirtualNode; Column:TColumnIndex; TextType:TVSTTextType);
    function GetValue(b:boolean):AnsiString; virtual;
  protected
    function DoCreateNewValueEdit:TControl; override;
    function DoGetValue(ndx:integer):AnsiString; override;
    procedure DoSetNewValue(ndx:integer); override;
    procedure DoUpdateControls; override;
    function DoGetNewValue:OleVariant; override;
    procedure _OnClick(Sender:TObject); override;
  public
  end;

  TSimpleEditor=class(TCommonEditor)
  private
    edtNewValue:TsEdit;
  protected
    function DoCreateNewValueEdit:TControl; override;
  end;

  TSimpleAvailableValuesEditor=class(TCommonEditor)
  private
    edtIndex:TsSpinEdit;
    lbxAvailableValues:TsListBox;
  public
    constructor Create(aOwner:TComponent); override;
  end;

  TFloatEditor=class(TSimpleAvailableValuesEditor)
  private
    edtNewValue:TsDecimalSpinEdit; tbr:TsTrackBar;
  protected
    function DoCreateNewValueEdit:TControl; override;
  end;

  TIntegerEditor=class(TFloatEditor)
  protected
    function DoCreateNewValueEdit:TControl; override;
  end;

  function GetFormState(fm:TForm):AnsiString;
  procedure SetFormState(fm:TForm; sState:AnsiString);

implementation

uses StdCtrls,StrUtils,
  SynCommons,
  sConst,
  uUtilsFunctions,uColors;

{$BOOLEVAL OFF}
{$RANGECHECKS OFF}
{$OVERFLOWCHECKS OFF}

var gfs:TFormatSettings;
  hCallWndProc:HHook=0;
  fmLast:TDeactivateForm=nil; ctrlLast:TWinControl=nil;

const iOffs=4; WM_DoFilter=WM_USER+$33; WM_UpdateFormPosition=WM_USER+$34; // WM_UpdateList=WM_USER+$35;

  ndxTagType=0; ndxMeasureUnit=1; ndxCategories=2; ndxRangeMin=3; ndxRangeMax=4; ndxMin=5; ndxMax=6; ndxCurrent=7; ndxNew=8;

  sColorEditHint=
    'сделайте DoubleClick для выбора следующего цвета, Shift+DoubleClick для выбора предыдущего, '#13#10
      +'ArrowUp или ArrowDown для выбора в отфильтрованном списке, Alt + ArrowDown для вызова редактора, '#13#10
      +'Esc - для закрытия списка или редактора';

  sDownArrow='424DF6000000000000007600000028000000100000001000000001000400000000008000000000000000000000000000000000000000000000000000800000800000008080008000000080008000808000008080'+
    '8000C0C0C0000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF008888888888888888888888888888888888888888888888888888888808888888888888808088888888888808880888888888'+
    '808888808888888888888888888888888880808888888888888080888888888888808088888888888880808888888888888080888888888888888888888888888888888888888888888888888888';
  sChecked='424DF6000000000000007600000028000000100000001000000001000400000000008000000000000000000000000000000000000000000000000000800000800000008080008000000080008000808000008080'+
    '8000C0C0C0000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF888888888888FFFF8FFFFFFFFFF8FFFF8FFFF0FFFFF8FFFF8FF000FFFFF8FFFF8F'+
    '00000FFFF8FFFF8F00F00FFFF8FFFF8FFFFF00FFF8FFFF8FFFFFF00FF8FFFF8FFFFFFF00F8FFFF8FFFFFFFFFF8FFFF8FFFFFFFFFF8FFFF888888888888FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF';
  sUnchecked='424DF6000000000000007600000028000000100000001000000001000400000000008000000000000000000000000000000000000000000000000000800000800000008080008000000080008000808000008080'+
    '8000C0C0C0000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF888888888888FFFF8FFFFFFFFFF8FFFF8FFFFFFFFFF8FFFF8FFFFFFFFFF8FFFF8F'+
    'FFFFFFFFF8FFFF8FFFFFFFFFF8FFFF8FFFFFFFFFF8FFFF8FFFFFFFFFF8FFFF8FFFFFFFFFF8FFFF8FFFFFFFFFF8FFFF8FFFFFFFFFF8FFFF888888888888FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF';

  function CallWndProcHook(nCode:integer; wParam:WPARAM; lParam:LPARAM):LRESULT; stdcall;
  var cwp:PCWPStruct; begin 
    Result:=CallNextHookEx(hCallWndProc,nCode,wParam,lParam); if nCode<0then exit;
    cwp:=PCWPStruct(lParam);
    if(cwp.message=WM_MOVING)and(ctrlLast<>nil)and(fmLast<>nil)and(fmLast.Visible)then
      PostMessage(ctrlLast.Handle,WM_UpdateFormPosition,0,0);
  end;

  procedure ValidateFormPosition(fm:TForm; rForm:TRect; w,h:integer); var w0,h0:integer; begin
    w0:=rForm.Right-rForm.Left; h0:=rForm.Bottom-rForm.Top;
    if rForm.Left+w0>Screen.Width then // выходим за правый край
      if w0>Screen.Width div 4 then begin                                // ширина больше 1/4 ширины экрана
        w0:=Screen.Width div 4; if rForm.Left+w0>Screen.Width then rForm.Left:=Screen.Width-w0;
      end else rForm.Left:=Screen.Width-w0; // по ширине от правого края, если ширина не больше 1/4 ширины экрана
    if rForm.Top+h0>Screen.Height then // выходим за нижний край
      if h0>Screen.Height div 4 then h0:=Screen.Height div 4; // больше 1/4 высоты экрана
    if rForm.Top+h0>Screen.Height then rForm.Top:=rForm.Top-h0-h-4; // по высоте от нижнего края целевого прямоуголника минус высота
    if rForm.Top+h0>Screen.Height then rForm.Top:=Screen.Height-h0; // если всё же ниже экрана, то поднимем
    if rForm.Left<0then rForm.Left:=0; if rForm.Top<0then rForm.Top:=0;
    rForm.Right:=rForm.Left+w0; rForm.Bottom:=rForm.Top+h0; fm.BoundsRect:=rForm;
    if not fm.Visible then fm.Tag:=integer(Screen.ActiveForm);
  end;

  function GetFormState(fm:TForm):AnsiString; var ws:TWindowState; b1,b2:boolean; b8:byte;  begin
    with fm do begin b1:=Visible; b2:=AlphaBlend;
      b8:=AlphaBlendValue; AlphaBlendValue:=0; AlphaBlend:=false; AlphaBlend:=true; Show;
      ws:=WindowState; if ws<>wsNormal then WindowState:=wsNormal;
      Result:=JSONEncode(['Left',Left,'Top',Top,'Width',Width,'Height',Height,'WindowState',
        {TypInfo.GetEnumName(TypeInfo(TWindowState),}integer(ws){)}]);
      Visible:=b1; AlphaBlend:=b2; AlphaBlendValue:=b8; 
    end;
  end;

  function GetProperty(v:variant; sName:AnsiString; vDefault:variant):variant;
  begin Result:=vDefault; if v.Exists(sName)then try Result:=TDocVariantData(v).Value[sName]; except end; end;

  procedure SetFormState(fm:TForm; sState:AnsiString); var v:variant; begin
    if sState<>''then with fm do try v:=_JsonFast(sState);
      Left:=GetProperty(v,'Left',Left); Top:=GetProperty(v,'Top',Top);
      Width:=GetProperty(v,'Width',Width); Height:=GetProperty(v,'Height',Height);
      WindowState:=GetProperty(v,'WindowState',WindowState);
    except end;
  end;


{ TMovingForm }

constructor TMovingForm.Create(aOwner:TComponent); begin 
  GlobalNameSpace.BeginWrite;
  try CreateNew(aOwner); if OldCreateOrder then DoCreate;
  finally GlobalNameSpace.EndWrite; end;
  Scaled:=false; Font.Name:='Microsoft Sans Serif'; BorderIcons:=BorderIcons-[biMinimize];
  KeyPreview:=true; Caption:=''; Width:=320; Height:=240;
  Constraints.MinHeight:=240; Constraints.MinWidth:=Width; {BorderStyle:=bsSizeToolWin;}
  Left:=(Screen.Width-Width)div 2; Top:=(Screen.Height-Height)div 2;
  Position:=poDesigned; Visible:=false; DoubleBuffered:=true;
  AlphaBlendValue:=235; AlphaBlend:=true; SnapBuffer:=0; 
end;

procedure TMovingForm.MouseDown(btn:TMouseButton; setShift:TShiftState; x,y:integer);
begin inherited; _OnMouseDown(Self,btn,setShift,x,y); end;

procedure TMovingForm.WndProc(var M:TMessage); begin inherited;
  case M.Msg of
    WM_ENTERSIZEMOVE: Screen.Cursor:=crSizeAll;
    WM_EXITSIZEMOVE: Screen.Cursor:=crDefault;
    CM_SHOWINGCHANGED: if not(csDestroying in ComponentState)then begin
      AlphaBlend:=false; AlphaBlend:=true;
      if(Self<>fmLast)and(fmLast<>nil)then fmLast.Hide;
    end;
  end;
end;

procedure TMovingForm._OnMouseDown(Sender:TObject; btn:TMouseButton; setShift:TShiftState; x,y:integer); var fm:TCustomForm; begin
  fm:=GetParentForm(TControl(Sender)); if fm=nil then exit;
  with fm do if WindowState<>wsMaximized then begin ReleaseCapture; Perform(WM_SYSCOMMAND,$F012,0); end;
end;

{ TDeactivateForm }

constructor TDeactivateForm.Create(aOwner:TComponent);
begin inherited Create(aOwner); FormStyle:=fsStayOnTop; end;

procedure TDeactivateForm.Deactivate; begin 
  if Self.SnapBuffer=0then begin Hide;
    if(Tag<>0)and(not(csDestroying in ComponentState))then
      try if(TObject(Tag)is TForm)then with TForm(Tag)do if Visible then SetFocus; except end;
  end;
  inherited;
end;

procedure TDeactivateForm.KeyPress(var cKey:Char); var i:integer;
begin inherited; if cKey=#27then begin i:=SnapBuffer; SnapBuffer:=0; Deactivate; SnapBuffer:=i; end; end;

procedure TDeactivateForm.WndProc(var M:TMessage); begin inherited;
  if M.Msg=CM_VISIBLECHANGED then begin
    if Visible then fmLast:=Self
    else if fmLast=Self then fmLast:=nil;
  end;
end;

{ TsExCheckListBox }

procedure TsExCheckListBox.WndProc(var M:TMessage); begin
  case M.Msg of
    LB_ADDSTRING,LB_INSERTSTRING,LB_DELETESTRING: Changed;
    CM_CHANGED: if@fOnChanged<>nil then fOnChanged(Self);
  end;
  inherited;
end;

{ TsColorListBox }

constructor TsColorListBox.Create(aOwner:TComponent);
begin inherited; if aOwner is TWinControl then Parent:=TWinControl(aOwner); DoubleBuffered:=true; end;

procedure TsColorListBox.DrawItem(ndx:integer; r:TRect; setState:TOwnerDrawState); var r0:TRect; s:AnsiString; Flags:integer; begin
  Canvas.Brush.Color:=Color; Canvas.FillRect(r); r0:=r;
  r.Left:=r.Left+32; inherited;
  r.Left:=r.Left-32; r.Right:=r.Left+32;

  r.Right:=r.Left+16; Canvas.Brush.Color:=clBlack; Canvas.FillRect(r);
  OffsetRect(r,16,0); Canvas.Brush.Color:=clWhite; Canvas.FillRect(r);
  Canvas.Brush.Color:=integer(Items.Objects[ndx]);
  InflateRect(r,-2,-2); Canvas.FillRect(r);
  OffsetRect(r,-16,0); Canvas.FillRect(r);

  Canvas.Font.Name:='Lucida Console'; Canvas.Font.Color:=Font.Color;
  r:=r0; s:='0x'+IntToHex(integer(Items.Objects[ndx]),8)+Format(' (%.3d)',[ndx],gfs);
  r0.Left:=r0.Right-Canvas.TextWidth('0xDDDDDDDD (999)')-iOffs;
  Canvas.Brush.Style:=bsClear;
  Flags:=DrawTextBiDiModeFlags(DT_SINGLELINE or DT_VCENTER or DT_NOPREFIX);
  DrawTextA(Canvas.Handle,PAnsiChar(s),Length(s),r0,Flags);
end;

{ TsFilteredListBox }

constructor TsFilteredListBox.Create(aOwner:TComponent); begin
  inherited; if aOwner is TWinControl then Parent:=TWinControl(aOwner); DoubleBuffered:=true;
  fsItems:=TStringList.Create; fsItems.OnChange:=_OnChanged;
end;

destructor TsFilteredListBox.Destroy;
begin FreeAndNil(fsItems); inherited; end;

procedure TsFilteredListBox.DrawItem(ndx:integer; r:TRect; setState:TOwnerDrawState); var iLeft,iPos:integer; s,sSource:AnsiString; begin
  inherited;
  if ndx>=0then with Canvas do begin {TextOut(r.Left+2,r.Top,ItemsFiltered[ndx]);}
    Font:=Self.Font; Font.Color:=$0000FF; iLeft:=r.Left+1; r.Top:=r.Top+1;
    iPos:=1; s:=AnsiLowerCase(fsFilter); sSource:=ItemsFiltered[ndx];
    Brush.Color:=clYellow; // Brush.Style:=bsClear;
    while PosEx(s,AnsiLowerCase(sSource),iPos)<>0do begin iPos:=PosEx(s,AnsiLowerCase(sSource),iPos);
      TextOut(iLeft+TextWidth(Copy(sSource,1,iPos-1)),r.Top,Copy(sSource,iPos,Length(s))); iPos:=iPos+Length(s);
    end;
  end;
end;

function TsFilteredListBox.GetItemsFiltered:TStrings;
begin Result:=inherited Items; end;

procedure TsFilteredListBox.SetFilter(const s:AnsiString);
begin if s<>fsFilter then begin fsFilter:=s; _OnChanged(fsItems); end; end;

procedure TsFilteredListBox.SetItems(const sl:TStringList); var i:integer; begin
  try fsItems.BeginUpdate; fsItems.Clear;
    if sl<>nil then for i:=0to sl.Count-1do fsItems.AddObject(sl[i],sl.Objects[i]);
  finally fsItems.EndUpdate; end;
end;

procedure TsFilteredListBox._OnChanged(Sender:TObject); var i:integer; begin
  try inherited Items.BeginUpdate; inherited Items.Clear;
    for i:=0to fsItems.Count-1do if(fsFilter='')or(AnsiPos(AnsiLowerCase(fsFilter),AnsiLowerCase(fsItems[i]))<>0)then
      inherited Items.AddObject(fsItems[i],fsItems.Objects[i]);
  finally inherited Items.EndUpdate; end;
end;

{ TsFilteredColorListBox }

procedure TsFilteredColorListBox.DrawItem(ndx:integer; r:TRect; setState:TOwnerDrawState); var r0:TRect; s:AnsiString; Flags:integer; begin
  Canvas.Brush.Color:=Color; Canvas.FillRect(r); r0:=r;
  r.Left:=r.Left+32; inherited;
  r.Left:=r.Left-32; r.Right:=r.Left+32;

  if ndx=-1then exit;

  r.Right:=r.Left+16; Canvas.Brush.Color:=clBlack; Canvas.FillRect(r);
  OffsetRect(r,16,0); Canvas.Brush.Color:=clWhite; Canvas.FillRect(r);
  Canvas.Brush.Color:=integer(ItemsFiltered.Objects[ndx]);
  InflateRect(r,-2,-2); Canvas.FillRect(r);
  OffsetRect(r,-16,0); Canvas.FillRect(r);

  Canvas.Font.Name:='Lucida Console'; Canvas.Font.Color:=Font.Color;
  r:=r0; s:='0x'+IntToHex(integer(ItemsFiltered.Objects[ndx]),8)+Format(' (%.3d)',[ndx],gfs);
  r0.Left:=r0.Right-Canvas.TextWidth('0xDDDDDDDD (999)')-iOffs;
  Canvas.Brush.Style:=bsClear;
  Flags:=DrawTextBiDiModeFlags(DT_SINGLELINE or DT_VCENTER or DT_NOPREFIX);
  DrawTextA(Canvas.Handle,PAnsiChar(s),Length(s),r0,Flags);
end;

{ TCommonEditPanel }

constructor TCommonEditPanel.Create(aOwner:TComponent); begin
  inherited; Width:=320; Height:=240;
  if aOwner is TWinControl then Parent:=TWinControl(aOwner); DoubleBuffered:=true;
  edtAvailableIndex:=TsSpinEdit.Create(Self);
  with edtAvailableIndex do begin Parent:=Self; OnChange:=Self._OnClick; AllowNegative:=false;
    BoundLabel.Caption:='Индекс:'; BoundLabel.Active:=true; BoundLabel.FTheLabel.AutoSize:=true;
    Left:=iOffs+BoundLabel.FTheLabel.Width+iOffs; Top:=iOffs;
    Width:=80; Anchors:=[akLeft,akRight,akTop]; //Hint:='индекс возможного значения';
  end;
  lbxAvailableValues:=TsListBox.Create(Self);
  with lbxAvailableValues do begin Parent:=Self; OnClick:=Self._OnClick; Align:=alTop; Align:=alNone;
    Width:=Width-1; Anchors:=[akLeft,akRight,akTop]; Top:=edtAvailableIndex.Top+edtAvailableIndex.Height+iOffs;
    Height:=Self.ClientHeight-Top-1; //ClientHeight:=ItemHeight*10;
  end;
end;

procedure TCommonEditPanel.SetValue(const s:AnsiString); var ndx:integer; begin if fbUpdating then exit;
  try fbUpdating:=true; if lbxAvailableValues.Items.Count=0then exit;
    ndx:=lbxAvailableValues.Items.IndexOf(s); if ndx=-1then exit;
    lbxAvailableValues.ItemIndex:=ndx; edtAvailableIndex.Value:=ndx; fsValue:=s;
  finally fbUpdating:=false; end;
  Changed;
end;

procedure TCommonEditPanel.WndProc(var M:TMessage); begin inherited;
  case M.Msg of
    CM_CHANGED: if@fOnChanged<>nil then fOnChanged(Self);
  end;
end;

procedure TCommonEditPanel._OnClick(Sender:TObject); begin if fbUpdating then exit;
  case IndexOfObject(Sender,[edtAvailableIndex,lbxAvailableValues])of
    0: try Value:=lbxAvailableValues.Items[edtAvailableIndex.Value]; except Value:=Value; end;
    1: edtAvailableIndex.Value:=lbxAvailableValues.ItemIndex;
  end;
end;

{ TColorEditPanel }

constructor TColorEditPanel.Create(aOwner:TComponent); begin inherited;
  with edtAvailableIndex do begin OnClick:=Self._OnClick;
    Left:=iOffs+BoundLabel.FTheLabel.Width+iOffs; Top:=iOffs; Width:=80;
    Anchors:=[akLeft,akRight,akTop]; Hint:='индекс цвета';
  end;
  btnSelectColor:=TsColorSelect.Create(Self);
  with btnSelectColor do begin Parent:=Self; OnChange:=Self._OnClick;
    Left:=edtAvailableIndex.Left+edtAvailableIndex.Width+iOffs; Top:=edtAvailableIndex.Top;
    Width:=Self.ClientWidth-Left-iOffs; Anchors:=[akLeft,akRight,akTop];
    Caption:='Выбрать "мой цвет"...'; Height:=edtAvailableIndex.Height;
    Hint:='выбранный пользователем цвет (индекс: 0, имя: "мой цвет")';
  end;
  lbxColors:=TsColorListBox.Create(Self);
  with lbxColors do begin Parent:=Self; OnClick:=Self._OnClick; Align:=alTop; Align:=alNone;
    Width:=Width-1; Anchors:=[akLeft,akRight,akTop]; Top:=edtAvailableIndex.Top+edtAvailableIndex.Height+iOffs;
    Items.Add('мой цвет'); Height:=Self.ClientHeight-Top-1; //ClientHeight:=ItemHeight*10;
    OnKeyPress:=_OnKeyPress;
  end;
  lbxAvailableValues.Free; lbxAvailableValues:=lbxColors;
  DoGetColors; ColorValue:=btnSelectColor.ColorValue;
end;

procedure TColorEditPanel.DoGetColors; var i:integer; begin
  try lbxColors.Items.BeginUpdate; GetColorValues(_OnGetColorName);
    for i:=Low(WebColors)to High(WebColors)do
      lbxColors.Items.AddObject(WebColors[i].Name,TObject(WebColors[i].Value));
  finally lbxColors.Items.EndUpdate; end;
  with edtAvailableIndex do begin MaxValue:=lbxColors.Items.Count-1; Hint:='индекс цвета 0..'+IntToStr(MaxValue); end;
end;

function TColorEditPanel.GetColorValue:integer;
begin Result:=btnSelectColor.ColorValue; end;

procedure TColorEditPanel.SetColorText(const s:AnsiString); var ndx:integer; begin
  if fsValue<>s then begin ndx:=lbxColors.Items.IndexOf(s); if ndx=-1then exit;
    edtAvailableIndex.Value:=ndx;
  end;
end;

procedure TColorEditPanel.SetColorValue(const c:integer); var ndx:integer; begin if fbUpdating then exit;
  try fbUpdating:=true;
    btnSelectColor.ColorValue:=c;
    if(edtAvailableIndex.Value>=0)and(edtAvailableIndex.Value<=lbxColors.Items.Count-1)
      and(integer(lbxColors.Items.Objects[edtAvailableIndex.Value])=c)
      then lbxColors.ItemIndex:=edtAvailableIndex.Value
      else begin ndx:=lbxColors.Items.IndexOfObject(TObject(c));
        if ndx<>-1then begin lbxColors.ItemIndex:=ndx; edtAvailableIndex.Value:=ndx; end
        else begin lbxColors.Items.Objects[0]:=TObject(c); lbxColors.ItemIndex:=0; edtAvailableIndex.Value:=0; lbxColors.Invalidate; end;
      end;
    if lbxColors.ItemIndex<>0then lbxColors.Hint:=''else
      lbxColors.Hint:='нажмите клавишу Enter, чтобы вызвать диалог для выбора "мой цвет"';
    fsValue:=lbxColors.Items[edtAvailableIndex.Value];
  finally fbUpdating:=false; end;
  Changed;
end;

procedure TColorEditPanel._OnClick(Sender:TObject); begin if fbUpdating then exit;
  case IndexOfObject(Sender,[edtAvailableIndex,btnSelectColor,lbxColors])of
    0: try ColorValue:=integer(lbxColors.Items.Objects[edtAvailableIndex.Value]); except ColorValue:=ColorValue; end;
    1: ColorValue:=btnSelectColor.ColorValue;
    2: edtAvailableIndex.Value:=lbxColors.ItemIndex;
  end;
end;

procedure TColorEditPanel._OnGetColorName(const s:string); var c:integer;
begin IdentToColor(s,c); lbxColors.Items.AddObject(s,TObject({ColorToRGB(}c{)})); end;

procedure TColorEditPanel._OnKeyPress(Sender:TObject; var c:char); begin
  if Sender=lbxColors then case c of
    {#32,}#13,#10: if lbxColors.ItemIndex=0then btnSelectColor.Click;
  end;
end;

{ TCheckListPanel }

constructor TCheckListPanel.Create(aOwner:TComponent); var bmp:TBitmap; begin
  inherited; if aOwner is TWinControl then Parent:=TWinControl(aOwner); DoubleBuffered:=true;
  clb:=TsExCheckListBox.Create(Self);
  with clb do begin Parent:=Self; Align:=alClient; Align:=alNone; OnChanged:=Self._OnClick;
    OnClickCheck:=Self._OnClick; Width:=Width-1;
  end;
  btnResetAll:=TsSpeedButton.Create(Self);
  Self.Height:=Self.Height+iOffs*2+btnResetAll.Height; clb.Anchors:=[akLeft,akRight,akTop,akBottom];
  with btnResetAll do begin Parent:=Self; Width:=100; Left:=iOffs; Top:=Self.ClientHeight-iOffs-Height; Enabled:=false;
    Anchors:=[akLeft,akBottom]; Caption:='Сбросить'; OnClick:=Self._OnClick; Hint:='сбросить всё как невыбранное';
    bmp:=Graphics_CreateBitmap(sUnchecked); Glyph:=bmp; bmp.Free;
  end;
  btnSetAll:=TsSpeedButton.Create(Self);
  with btnSetAll do begin Parent:=Self; Width:=100; Left:=Self.ClientWidth-iOffs-Width; Top:=btnResetAll.Top; Enabled:=false;
    Anchors:=[akRight,akBottom]; Caption:='Установить'; OnClick:=Self._OnClick; Hint:='установить всё как выбранное';
    bmp:=Graphics_CreateBitmap(sChecked); Glyph:=bmp; bmp.Free;
  end;
  edtAvailableIndex.Top:=btnSetAll.Top+btnSetAll.Height+2*iOffs;
  lbxAvailableValues.Top:=edtAvailableIndex.Top+edtAvailableIndex.Height+iOffs;
end;

procedure TCheckListPanel._OnClick(Sender:TObject); var sl:TStringList; i:integer; begin
  case IndexOfObject(Sender,[clb,btnResetAll,btnSetAll])of
    0: begin btnResetAll.Enabled:=clb.Items.Count<>0; btnSetAll.Enabled:=btnResetAll.Enabled; sl:=nil;
      try sl:=TStringList.Create;
        for i:=0to clb.Count-1do if clb.Checked[i]then sl.Add(clb.Items[i]);
        clb.Text:=sl.CommaText; Changed;
      finally sl.Free; end;
    end;
    1: begin for i:=0to clb.Items.Count-1do if clb.ItemEnabled[i]then clb.Checked[i]:=false; clb.Changed; end;
    2: begin for i:=0to clb.Items.Count-1do if clb.ItemEnabled[i]then clb.Checked[i]:=true; clb.Changed; end;  
  end;
end;

{ TFilteredEdit }

procedure TFilteredEdit.Change; begin inherited; if not bIgnoreDoFilter then PostMessage(Handle,WM_DoFilter,0,0); end;

constructor TFilteredEdit.Create(aOwner:TComponent); var aLeft:integer; begin inherited;
  if aOwner is TWinControl then Parent:=TWinControl(aOwner); DoubleBuffered:=true;
  AutoSelect:=false; GlyphMode.Grayed:=false; OnButtonClick:=Self._OnClick;
  fmFiltered:=TDeactivateForm.Create(Self); fmFiltered.BorderStyle:=bsNone; fmFiltered.ShowHint:=true;
  aLeft:=fmFiltered.Left; fmFiltered.Left:=-fmFiltered.Width-10; fmFiltered.Show;
  lbxFiltered:=DoCreateListBox;
  with lbxFiltered do begin Parent:=fmFiltered; Align:=alClient; OnClick:=Self._OnClick; end;
  fmFiltered.Hide; fmFiltered.Left:=aLeft; fmFiltered.FormStyle:=fsStayOnTop; 
end;

procedure TFilteredEdit.CreateParams(var Params:TCreateParams);
const Alignments:array[TAlignment]of Cardinal=(ES_LEFT,ES_RIGHT,ES_CENTER);
begin inherited CreateParams(Params);
  Params.Style:=Params.Style or ES_MULTILINE or WS_CLIPCHILDREN or Alignments[Alignment];
  Params.ExStyle:=Params.ExStyle or WS_EX_NOACTIVATE;
end;

function TFilteredEdit.DoCreateListBox:TsFilteredListBox;
begin Result:=TsFilteredListBox.Create(Self); end;

procedure TFilteredEdit.DoFilter; var fm:TCustomForm; begin if csDestroying in ComponentState then exit;
  lbxFiltered.Filter:=GetFilterString;
  with Self.ClientToScreen(Point(-2,Height))do ValidateFormPosition(fmFiltered,Rect(X,Y,X+fmFiltered.Width,Y+fmFiltered.Height),Width,Height);
  if Visible and not fmFiltered.Visible and Self.Focused {and(lbxFiltered.ItemsFiltered.Count<>0)}then begin
    fmFiltered.SnapBuffer:=1; fmFiltered.Show;
    fm:=GetParentForm(Self);
    if(Screen.ActiveForm<>fm)and(fm.Visible)then fm.SetFocus;
  end;
end;

function TFilteredEdit.GetFilterString:AnsiString;
begin Result:=Self.Text; end;

procedure TFilteredEdit.KeyDown(var wKey:word; setShift:TShiftState); var ndx:integer; begin
  inherited KeyDown(wKey,setShift);
  case wKey of
    VK_ESCAPE: fmFiltered.Hide;
    VK_RETURN: begin fmFiltered.Hide; bIgnoreDoFilter:=true; lbxFiltered.Click; bIgnoreDoFilter:=false; end;
    VK_UP: begin
      ndx:=lbxFiltered.ItemIndex; if ndx<=0then ndx:=lbxFiltered.ItemsFiltered.Count-1 else dec(ndx);
      lbxFiltered.ItemIndex:=ndx; if not fmFiltered.Visible then PostMessage(Handle,WM_DoFilter,0,0);
    end;
    VK_DOWN: begin
      ndx:=lbxFiltered.ItemIndex; if ndx<lbxFiltered.ItemsFiltered.Count-1then inc(ndx)else ndx:=0;
      if ndx>lbxFiltered.ItemsFiltered.Count-1then ndx:=lbxFiltered.ItemsFiltered.Count-1;
      lbxFiltered.ItemIndex:=ndx; if not fmFiltered.Visible then PostMessage(Handle,WM_DoFilter,0,0);
    end;
    VK_PRIOR: begin 
      ndx:=lbxFiltered.ItemIndex;
      if ndx<=0then ndx:=lbxFiltered.ItemsFiltered.Count-1 else begin
        dec(ndx,lbxFiltered.ClientHeight div lbxFiltered.ItemHeight); if ndx<0then ndx:=0;
      end;
      lbxFiltered.ItemIndex:=ndx; if not fmFiltered.Visible then PostMessage(Handle,WM_DoFilter,0,0);
    end;
    VK_NEXT: begin
      ndx:=lbxFiltered.ItemIndex;
      if ndx>=lbxFiltered.ItemsFiltered.Count-1then ndx:=0 else
        inc(ndx,lbxFiltered.ClientHeight div lbxFiltered.ItemHeight);
      if ndx>lbxFiltered.ItemsFiltered.Count-1then ndx:=lbxFiltered.ItemsFiltered.Count-1;
      lbxFiltered.ItemIndex:=ndx; if not fmFiltered.Visible then PostMessage(Handle,WM_DoFilter,0,0);
    end;
{    VK_HOME: begin
      ndx:=lbxFiltered.ItemsFiltered.Count; if ndx=0then ndx:=-1 else ndx:=0;
      lbxFiltered.ItemIndex:=ndx; if not fmFiltered.Visible then PostMessage(Handle,WM_DoFilter,0,0);
    end;
    VK_END: begin
      ndx:=lbxFiltered.ItemsFiltered.Count-1;
      lbxFiltered.ItemIndex:=ndx; if not fmFiltered.Visible then PostMessage(Handle,WM_DoFilter,0,0);
    end;}
  end;
end;

procedure TFilteredEdit.WndProc(var M:TMessage); begin inherited;
  case M.Msg of
    WM_DoFilter,WM_UpdateFormPosition: DoFilter;
    CM_ENTER: if not(csDestroying in ComponentState)then begin SelectAll; PostMessage(Handle,WM_DoFilter,0,0);
      Invalidate; ctrlLast:=Self;
    end;
    CM_EXIT: if not(csDestroying in ComponentState)then begin SelectAll;
      if Screen.ActiveForm<>fmFiltered then fmFiltered.Hide;
      if ctrlLast=Self then ctrlLast:=nil;
    end;
    WM_SETFOCUS: ctrlLast:=Self;
    WM_KILLFOCUS: if ctrlLast=Self then ctrlLast:=nil;
    CM_CHANGED: if@OnChange<>nil then OnChange(Self);
  end;
end;

procedure TFilteredEdit._OnClick(Sender:TObject); begin
  if Sender=lbxFiltered then begin bIgnoreDoFilter:=true;
    if(lbxFiltered.ItemIndex<>-1)and(lbxFiltered.ItemsFiltered.Count<>0)then
      Self.Text:=lbxFiltered.ItemsFiltered[lbxFiltered.ItemIndex];
    bIgnoreDoFilter:=false; fmFiltered.Hide;
  end;
end;

{ TFilteredPaneledEdit }

constructor TFilteredPaneledEdit.Create(aOwner:TComponent); var aLeft:integer; begin inherited;
  fmEdit:=TDeactivateForm.Create(Self); fmEdit.BorderStyle:=bsNone; fmEdit.ShowHint:=true;
  aLeft:=fmEdit.Left; fmEdit.Left:=-fmEdit.Width-10; fmEdit.Show;
  pnlEdit:=DoCreateEditPanel;
  with pnlEdit do begin Parent:=fmEdit; Align:=alClient; OnChanged:=Self._OnClick; end;
  fmFiltered.Hide; fmFiltered.Left:=aLeft;
end;

function TFilteredPaneledEdit.DoCreateEditPanel:TCommonEditPanel;
begin Result:=TCommonEditPanel.Create(Self); end;

procedure TFilteredPaneledEdit.KeyDown(var wKey:word; setShift:TShiftState);
begin inherited KeyDown(wKey,setShift); if wKey in[VK_ESCAPE,VK_RETURN]then fmEdit.Hide; end;

procedure TFilteredPaneledEdit.WndProc(var M:TMessage); begin inherited;
  case M.Msg of
    CM_ENTER: Hint:='';
    CM_EXIT: if Screen.ActiveForm<>fmEdit then fmEdit.Hide;
  end;
end;

procedure TFilteredPaneledEdit._OnClick(Sender:TObject); var b:boolean; begin
  case IndexOfObject(Sender,[Self,pnlEdit,lbxFiltered])of
    0: begin with Self.ClientToScreen(Point(-2,Height))do ValidateFormPosition(fmEdit,Rect(X,Y,X+fmEdit.Width,Y+fmEdit.Height),Width,Height);
      pnlEdit.edtAvailableIndex.MaxValue:=pnlEdit.lbxAvailableValues.Items.Count-1;
      pnlEdit.edtAvailableIndex.Hint:='индекс значение 0..'+IntToStr(pnlEdit.edtAvailableIndex.MaxValue);
      SelectAll; fmFiltered.Hide; fmEdit.Show;
    end;
    1: begin b:=Self.Text<>pnlEdit.Value; if b then Self.Text:=pnlEdit.Value else Changed; SelectAll; end;
    2: if(lbxFiltered.ItemIndex<>-1)and(lbxFiltered.ItemsFiltered.Count<>0)then begin
{      pnl.lbxColors.ItemIndex:=pnl.lbxColors.Items.IndexOf(lbxFiltered.ItemsFiltered[lbxFiltered.ItemIndex]);
      bIgnoreDoFilter:=true; pnl.lbxColors.Click; _OnClick(pnl); fmFiltered.Hide; bIgnoreDoFilter:=false;}
    end;
  end;
end;

{ TCheckListEdit }

procedure TCheckListEdit.DblClick;
begin inherited; DoEnter; end;

function TCheckListEdit.DoCreateEditPanel:TCommonEditPanel;
 begin pnl:=TCheckListPanel.Create(Self); Result:=pnl; end;

procedure TCheckListEdit.DoEnter;
begin _OnClick(Self); end;

procedure TCheckListEdit.DoRemoveUnusedItems; var i,ndx:integer; sl:TStringList; b:boolean; begin sl:=nil;
  try sl:=TStringList.Create; sl.CommaText:=Self.Text; pnl.Perform(WM_SETREDRAW,0,0);
    for i:=pnl.clb.Items.Count-1downto 0do if not pnl.clb.ItemEnabled[i]then pnl.clb.DeleteString(i);
    for i:=0to pnl.clb.Items.Count-1do pnl.clb.Checked[i]:=false;
    if sl.Count<>0then begin b:=false;
      for i:=0to sl.Count-1do begin ndx:=pnl.clb.Items.IndexOf(sl[i]);
        if(ndx=-1)and fbCanAddNewItem then begin ndx:=pnl.clb.Items.Add(sl[i]); pnl.clb.ItemEnabled[ndx]:=false; b:=true; end;
        if ndx<>-1then pnl.clb.Checked[ndx]:=true;
      end;
      if b then pnl.clb.Changed;
    end;
    lbxFiltered.Items.Clear;
    for i:=0to pnl.clb.Items.Count-1do if pnl.clb.ItemEnabled[i]then lbxFiltered.Items.AddObject(pnl.clb.Items[i],pnl.clb.Items.Objects[i]);
  finally sl.Free; pnl.Perform(WM_SETREDRAW,1,0); pnl.Invalidate; end;
end;

function TCheckListEdit.GetCheckListBox:TsExCheckListBox;
begin Result:=pnl.clb; end;

function TCheckListEdit.GetFilterString:AnsiString; var sl:TStringList; s:AnsiString; ndx:integer; begin Result:=''; sl:=nil; 
  try sl:=TStringList.Create; s:=''; ndx:=0;
    if SelStart<>0then s:=Copy(Text,1,SelStart);
    if s<>''then begin sl.CommaText:=s; ndx:=sl.Count-1; if ndx=-1then ndx:=0; end;
    sl.CommaText:=Self.Text; if ndx<=sl.Count-1then Result:=sl[ndx];
  finally sl.Free; end;
end;

procedure TCheckListEdit.KeyDown(var wKey:word; setShift:TShiftState);
begin inherited; if(wKey<>VK_ESCAPE)and(wKey<>VK_RETURN)then PostMessage(Handle,WM_DoFilter,0,0); end;

procedure TCheckListEdit.MouseDown(btn:TMouseButton; setShift:TShiftState; x,y:integer);
begin inherited; PostMessage(Handle,WM_DoFilter,0,0); end;

procedure TCheckListEdit.WndProc(var M:TMessage); var s:AnsiString; iStart:integer; begin
  if M.Msg=CM_CHANGED then begin if fbIgnoreChanged then exit;
    SendMessage(Handle,WM_DoFilter,0,0);
    try fbIgnoreChanged:=true;
      s:=Self.Text; iStart:=SelStart;
      if s<>''then begin DoRemoveUnusedItems; pnl.clb.Changed; end;
      Self.Text:=s; SelStart:=iStart; 
    finally fbIgnoreChanged:=false; end;
  end;
  inherited;
end;

procedure TCheckListEdit._OnClick(Sender:TObject); var b:boolean; s:AnsiString; begin
  case IndexOfObject(Sender,[Self,pnl,lbxFiltered])of
    0: begin DoRemoveUnusedItems;
      with Self.ClientToScreen(Point(-2,Height))do ValidateFormPosition(fmEdit,Rect(X,Y,X+fmEdit.Width,Y+fmEdit.Height),Width,Height);
      fmFiltered.Hide; fmEdit.Show;
    end;
    1: begin b:=Self.Text<>pnl.clb.Text; if b then Self.Text:=pnl.clb.Text else Changed; end;
    2: with lbxFiltered do begin bIgnoreDoFilter:=true;
      if(ItemIndex<>-1)and(ItemsFiltered.Count<>0)then begin s:=ItemsFiltered[ItemIndex];
        pnl.clb.Checked[Items.IndexOf(s)]:=true; pnl._OnClick(pnl.clb);
//        pnl.clb.Changed;
        SelStart:=AnsiPos(s,Self.Text)+Length(s);
      end;
      bIgnoreDoFilter:=false; fmFiltered.Hide;
    end;
  end;
end;

{ TColorEdit }

constructor TColorEdit.Create(aOwner:TComponent);begin inherited;
  lbxFiltered.Items.Assign(pnl.lbxColors.Items);
{  fCanvas:=TControlCanvas.Create; TControlCanvas(fCanvas).Control:=Self;}
  Hint:=sColorEditHint;
end;

procedure TColorEdit.DblClick; var ndx:integer; begin
  inherited; ndx:=pnl.lbxColors.ItemIndex;
  if GetKeyState(VK_SHIFT)<0then begin dec(ndx); if ndx<0then ndx:=pnl.lbxColors.Count-1; end
  else begin inc(ndx); if ndx>pnl.lbxColors.Count-1then ndx:=0; end;
  pnl.lbxColors.ItemIndex:=ndx; pnl._OnClick(pnl.lbxColors);
end;

destructor TColorEdit.Destroy;
begin {FreeAndNil(fCanvas); }inherited; end;

function TColorEdit.DoCreateEditPanel:TCommonEditPanel;
begin pnl:=TColorEditPanel.Create(Self); Result:=pnl; end;

function TColorEdit.DoCreateListBox:TsFilteredListBox;
begin Result:=TsFilteredColorListBox.Create(Self); end;

function TColorEdit.GetColorValue:integer;
begin Result:=pnl.ColorValue; end;

procedure TColorEdit.SetColorValue(const c:integer);
begin pnl.ColorValue:=c; Self.Text:=pnl.lbxColors.Items[pnl.lbxColors.ItemIndex]; SelectAll; end;

procedure TColorEdit.WMPaint(var M:TWMPaint); {var r:TRect; w:integer; }begin inherited;
{  r:=ClientRect; InflateRect(r,-1,-1); w:=r.Bottom-r.Top;
  r.Right:=r.Left+w; fCanvas.Brush.Color:=clBlack; fCanvas.FillRect(r);
  OffsetRect(r,w,0); fCanvas.Brush.Color:=clWhite; fCanvas.FillRect(r);
  fCanvas.Brush.Color:=ColorValue;
  InflateRect(r,-2,-2); fCanvas.FillRect(r);
  OffsetRect(r,-w,0); fCanvas.FillRect(r);}
end;

procedure TColorEdit.WndProc(var M:TMessage); {var r:TRect; }begin
//  case M.Msg of
//    EM_SETRECT,EM_SETRECTNP: begin r:=PRect(M.LParam)^; r.Left:=r.Left+32; PRect(M.LParam)^:=r; M.Msg:=EM_SETRECT;
//      Perform(EM_SETMARGINS,EC_LEFTMARGIN+EC_RIGHTMARGIN,r.Left+r.Right shl 16);
//    end;
//  end;
  inherited; if M.Msg=CM_EXIT then Hint:=sColorEditHint;
end;

procedure TColorEdit._OnClick(Sender:TObject); var b:boolean; begin if csDestroying in ComponentState then exit;
  case IndexOfObject(Sender,[Self,pnl,lbxFiltered])of
    0: begin pnl.edtAvailableIndex.Hint:='индекс цвета 0..'+IntToStr(pnl.edtAvailableIndex.MaxValue); inherited; end;
    1: begin b:=Self.Text<>pnl.Value; if b then Self.Text:=pnl.Value else Changed; SelectAll; end;
    2: if(lbxFiltered.ItemIndex<>-1)and(lbxFiltered.ItemsFiltered.Count<>0)then begin
      pnl.lbxColors.ItemIndex:=pnl.lbxColors.Items.IndexOf(lbxFiltered.ItemsFiltered[lbxFiltered.ItemIndex]);
      bIgnoreDoFilter:=true; pnl.lbxColors.Click; _OnClick(pnl); fmFiltered.Hide; bIgnoreDoFilter:=false;
    end;
  end;
end;

{ TAttributesView }

constructor TAttributesView.Create(aOwner:TComponent); const clBtnShadow=$A19D9D; clBtnFace=$E3DFE0; clHighlight=$BFB4B2; clWindowText=$0; clHighlightText=$0; begin
  inherited;
  with Colors do begin // серая гамма - не зависит от системных цветов, т.к. заданы в RGB
    DisabledColor:=clBtnShadow; {index 0}
    DropMarkColor:=clHighlight; {index 1}
    DropTargetColor:=clHighLight; {index 2}
    FocusedSelectionColor:=clHighLight; {index 3}
    GridLineColor:=clBtnFace; {index 4}
    TreeLineColor:=clBtnShadow; {index 5}
    UnfocusedSelectionColor:=clBtnFace; {index 6}
    BorderColor:=clBtnFace; {index 7}
    HotColor:=clWindowText; {index 8}
    FocusedSelectionBorderColor:=clHighLight; {index 9}
    UnfocusedSelectionBorderColor:=clBtnFace; {index 10}
    DropTargetBorderColor:=clHighlight; {index 11}
    SelectionRectangleBlendColor:=clHighlight; {index 12}
    SelectionRectangleBorderColor:=clHighlight; {index 13}
    HeaderHotColor:=clBtnShadow; {index 14}
    SelectionTextColor:=clBlue; {clHighlightText}; {index 15}
    UnfocusedColor:=clBtnFace; {index 16}
  end;
  with Self do begin if aOwner is TWinControl then Parent:=TWinControl(aOwner); DoubleBuffered:=true;
    Header.Options:=[hoAutoResize,hoColumnResize,hoDblClickResize,hoDrag,hoShowSortGlyphs,hoVisible];
    Header.Style:=hsPlates; Header.SortColumn:=-1; Header.AutoSizeIndex:=0;
    IncrementalSearch:=isAll; IncrementalSearchStart:=ssAlwaysStartOver;
    TreeOptions.MiscOptions:=TreeOptions.MiscOptions+[toCheckSupport{,toEditable,toEditOnDblClick}];
    TreeOptions.PaintOptions:=TreeOptions.PaintOptions+[toShowHorzGridLines,toShowVertGridLines,toFullVertGridLines,toHideFocusRect];
    TreeOptions.SelectionOptions:=TreeOptions.SelectionOptions+[toExtendedFocus,toFullRowSelect];
    {FocusedColumn:=lwColumnValue; }LineMode:=lmBands; IncrementalSearch:=isNone;
    HintMode:=hmTooltip; CheckImageKind:=ckXP; TextMargin:=2;
  end;
  NodeDataSize:=SizeOf(TrAttrsNodeData);
  with Header.Columns.Add do begin Width:=50; Text:='Свойство'; Options:=Options-[coAllowFocus]; {Color:=$E0FFFF;} end;
  with Header.Columns.Add do begin Width:=130; Text:='Значение'; Options:=Options-[coAllowFocus]; {Color:=$D0FFE0;} end;
  with Header.Columns.Add do begin Width:=65; Text:='Действие'; Options:=Options-[coAllowFocus]; {Color:=$E3DFE0;} {Color:=$FFE0E0;} end;
  Indent:=0; CreateNodes;
end;

procedure TAttributesView.CreateNodes; var p:PVirtualNode; pnd:PrAttrsNodeData; begin
  p:=AddChild(nil); pnd:=GetNodeData(p);
  pnd._sName:='Тип'; pnd._sValue:=''; pnd._ctrl:=nil;
  p:=AddChild(nil); pnd:=GetNodeData(p);
  pnd._sName:='Единица'; pnd._sValue:=''; pnd._ctrl:=nil;
  p:=AddChild(nil); pnd:=GetNodeData(p);
  pnd._sName:='Категории'; pnd._sValue:=''; pnd._ctrl:=nil;
  p:=AddChild(nil); pnd:=GetNodeData(p);
  pnd._sName:='Минимум типа'; pnd._sValue:=''; pnd._ctrl:=nil;
  p:=AddChild(nil); pnd:=GetNodeData(p);
  pnd._sName:='Максимум типа'; pnd._sValue:=''; pnd._ctrl:=nil;
  p:=AddChild(nil); pnd:=GetNodeData(p);
  pnd._sName:='Минимум'; pnd._sValue:=''; pnd._ctrl:=TsSpeedButton.Create(Self);
  with TsSpeedButton(pnd._ctrl)do begin Parent:=Self; Caption:='=> новое'; OnClick:=_OnClick;
    Tag:=integer(p); Hint:='сделать минимальное значение параметра новым';
  end;
  p:=AddChild(nil); pnd:=GetNodeData(p);
  pnd._sName:='Максимум'; pnd._sValue:=''; pnd._ctrl:=TsSpeedButton.Create(Self);
  with TsSpeedButton(pnd._ctrl)do begin Parent:=Self; Caption:='=> новое'; OnClick:=_OnClick;
    Tag:=integer(p); Hint:='сделать максимальное значение параметра новым';
  end;
  p:=AddChild(nil); pnd:=GetNodeData(p);
  pnd._sName:='Текущее'; pnd._sValue:=''; pnd._ctrl:=TsSpeedButton.Create(Self);
  with TsSpeedButton(pnd._ctrl)do begin Parent:=Self; Caption:='=> новое'; OnClick:=_OnClick;
    Tag:=integer(p); Hint:='сделать текущее значение параметра новым';
  end;
  Height:=DefaultNodeHeight*(RootNodeCount+1)+8;
  fsetDisplayOptions:=[adoMeasureUnit,adoCategories,adoRangeMinMax,adoMinMax];
end;

procedure TAttributesView.DoAfterCellPaint(c:TCanvas; pn:PVirtualNode; Column:TColumnIndex; CellRect:TRect);
var pnd:PrAttrsNodeData; ws:WideString; r:TRect; begin
  inherited;
  if Column=2then begin pnd:=GetNodeData(pn);
    if pnd._ctrl<>nil then begin
      DoGetText(pn,Column,ttNormal,ws);
      GetTextInfo(pn,Column,c.Font,r,ws); OffsetRect(CellRect,r.Left-CellRect.Left,r.Top-CellRect.Top);
      CellRect.Bottom:=r.Bottom; CellRect.Right:=CellRect.Right-4*TextMargin;
      InflateRect(CellRect,2*TextMargin,TextMargin); pnd._ctrl.BoundsRect:=CellRect;
      //InvalidateColumn(1); InvalidateColumn(2);
    end;
  end;
end;

procedure TAttributesView.DoCanEdit(pn:PVirtualNode; Column:TColumnIndex; var bAllowed:boolean);
begin bAllowed:=false; end;

procedure TAttributesView.DoFocusChange(pn:PVirtualNode; Column:TColumnIndex);
begin inherited DoFocusChange(pn,Column); DoChange(pn); end;

procedure TAttributesView.DoFreeNode(pn:PVirtualNode); var pnd:PrAttrsNodeData; begin
  pnd:=GetNodeData(pn); pnd._sName:=''; pnd._sValue:=''; pnd._ctrl.Free;
  inherited;
end;

procedure TAttributesView.DoGetText(pn:PVirtualNode; Column:TColumnIndex; TextType:TVSTTextType; var Text:UnicodeString);
var pnd:PrAttrsNodeData; begin
  if TextType=ttNormal then begin pnd:=GetNodeData(pn);
    case Column of
      0: Text:=pnd._sName;    1: Text:=pnd._sValue;   2: Text:='';
    else inherited; end;
  end else inherited;
end;

function TAttributesView.GetAttributeNode(const ndx:integer):PVirtualNode; begin Result:=RootNode.FirstChild;
  while Result<>nil do if Result.Index=longword(ndx)then break else Result:=Result.NextSibling;
end;

{function TAttributesView.GetAttributeNode(sName:AnsiString):PVirtualNode; var pnd:PrAttrsNodeData; begin Result:=RootNode.FirstChild;
  while Result<>nil do begin pnd:=GetNodeData(Result);
    if AnsiSameText(pnd._sName,sName)then exit else Result:=GetNext(Result);
  end;
end;}

procedure TAttributesView.SetDisplayOptions(const ado:TAttributesDisplayOptions); var pn:PVirtualNode; cnt:integer; begin
  if fsetDisplayOptions<>ado then begin fsetDisplayOptions:=ado; pn:=RootNode.FirstChild; cnt:=0;
    while pn<>nil do begin
      if(pn.Index=ndxMeasureUnit)then IsVisible[pn]:=adoMeasureUnit in ado;
      if(pn.Index=ndxCategories)then IsVisible[pn]:=adoCategories in ado;
      if(pn.Index=ndxRangeMin)or(pn.Index=ndxRangeMax)then IsVisible[pn]:=adoRangeMinMax in ado;
      if(pn.Index=ndxMin)or(pn.Index=ndxMax)then IsVisible[pn]:=adoMinMax in ado;
      if IsVisible[pn]then inc(cnt);
      pn:=pn.NextSibling;
    end;
    Height:=integer(DefaultNodeHeight)*(cnt{VisibleCount}+1)+8;
    Changed;
  end;
end;

procedure TAttributesView._OnClick(Sender:TObject);
begin if@fOnNodeControlClick<>nil then fOnNodeControlClick(Self,PVirtualNode(TControl(Sender).Tag),TControl(Sender)); end;

{ TCommonEditor }

constructor TCommonEditor.Create(aOwner:TComponent); {var bmp:TBitmap; }begin
  inherited; if aOwner is TWinControl then Parent:=TWinControl(aOwner); fiModalResult:=mrNone;
  Font.Name:='Microsoft Sans Serif'; DoubleBuffered:=true; Width:=300; Height:=300;
  lblTagName:=TsHTMLLabel.Create(Self);
  with lblTagName do begin Parent:=Self; Top:=iOffs; Left:=Top; Caption:='Параметр: <b>[Неизвестный параметр]</b>'; OnMouseDown:=_OnMouseDown; end;
  lblTagPath:=TsHTMLLabel.Create(Self);
  with lblTagPath do begin Parent:=Self; Top:=lblTagName.Top+lblTagName.Height+iOffs; Left:=iOffs; Caption:='Путь: <b>[Путь к параметру]</b>'; OnMouseDown:=_OnMouseDown; end;
  tvAttr:=TAttributesView.Create(Self);
  with tvAttr do begin Parent:=Self; Top:=lblTagPath.Top+lblTagPath.Height+iOffs+2; DoubleBuffered:=true;
    Left:=iOffs; Width:=Self.ClientWidth-Left-iOffs; Anchors:=[akLeft,akRight,akTop]; OnNodeControlClick:=_OnNodeControlClick;
  end;
  pnlNewValue:=TsPanel.Create(Self);
  with pnlNewValue do begin Parent:=Self;
    Anchors:=[akLeft,akRight,akTop{,akBottom}]; Top:=tvAttr.Top+tvAttr.Height+iOffs;
    Left:=iOffs; Width:=Self.ClientWidth-Left-iOffs; OnResize:=_OnResize; OnMouseDown:=_OnMouseDown;
  end;
  btnApply:=TsButton.Create(Self);
  with btnApply do begin Parent:=Self; Left:=iOffs*2; Top:=Self.ClientHeight-Height-Left; ModalResult:=mrOk;
    Anchors:=[akLeft,akBottom]; Caption:='Подтвердить'; Default:=true; Width:=85; OnClick:=_OnClick; Enabled:=false;
  end;
  btnCancel:=TsButton.Create(Self);
  with btnCancel do begin Parent:=Self; Width:=85; Left:=Self.ClientWidth-Width-2*iOffs; Top:=btnApply.Top; ModalResult:=mrCancel;
    Anchors:=[akRight,akBottom]; Caption:='Отменить'; Cancel:=true; OnClick:=_OnClick;
  end;
  ctrlNewValue:=DoCreateNewValueEdit;
  if ctrlNewValue=nil then pnlNewValue.ClientHeight:=lblTagName.Top+lblTagName.Height+iOffs
  else pnlNewValue.ClientHeight:=ctrlNewValue.Top+ctrlNewValue.Height+iOffs;
  DoUpdateControls;
  Constraints.MinWidth:=Width; Constraints.MinHeight:=Height;
end;

function TCommonEditor.DoCreateNewValueEdit:TControl;
begin Result:=nil; end;

function TCommonEditor.DoGetNewValue:OleVariant;
begin

end;

function TCommonEditor.DoGetValue(ndx:integer):AnsiString;
begin

end;

procedure TCommonEditor.DoSetNewValue(ndx:integer);
begin

end;

procedure TCommonEditor.DoUpdateControls; var pnd:PrAttrsNodeData; begin
  pnd:=tvAttr.GetNodeData(tvAttr.GetAttributeNode(ndxRangeMin)); pnd._sValue:=DoGetValue(ndxRangeMin);
  pnd:=tvAttr.GetNodeData(tvAttr.GetAttributeNode(ndxRangeMax)); pnd._sValue:=DoGetValue(ndxRangeMax);
  pnd:=tvAttr.GetNodeData(tvAttr.GetAttributeNode(ndxMin)); pnd._sValue:=DoGetValue(ndxMin);
  pnd:=tvAttr.GetNodeData(tvAttr.GetAttributeNode(ndxMax)); pnd._sValue:=DoGetValue(ndxMax);
  pnd:=tvAttr.GetNodeData(tvAttr.GetAttributeNode(ndxCurrent)); pnd._sValue:=DoGetValue(ndxCurrent);
  if tvAttr<>nil then pnlNewValue.Top:=tvAttr.Top+tvAttr.Height+iOffs;
  if(btnApply<>nil)and(Align<>alClient)then ClientHeight:=pnlNewValue.Top+pnlNewValue.Height+2*iOffs+btnApply.Height+btnApply.Left;
end;

procedure TCommonEditor.MouseDown(btn:TMouseButton; setShift:TShiftState; x,y:integer);
begin inherited; _OnMouseDown(Self,btn,setShift,x,y); end;

procedure TCommonEditor._OnClick(Sender:TObject); var fm:TCustomForm; begin
  if(Sender is TsSpeedButton)and(TsSpeedButton(Sender).Parent=tvAttr)then DoSetNewValue(PVirtualNode(TsSpeedButton(Sender).Tag).Index)
  else case IndexOfObject(Sender,[btnApply,btnCancel])of
    0: begin fiModalResult:=btnApply.ModalResult; fm:=GetParentForm(Self); if fm<>nil then fm.ModalResult:=fiModalResult; end;
    1: begin fiModalResult:=btnCancel.ModalResult; fm:=GetParentForm(Self); if fm<>nil then fm.ModalResult:=fiModalResult; end;
  end;
end;

procedure TCommonEditor._OnMouseDown(Sender:TObject; btn:TMouseButton; setShift:TShiftState; x,y:integer); var fm:TCustomForm; begin
  inherited; fm:=GetParentForm(TControl(Sender)); if fm=nil then exit;
  with fm do if WindowState<>wsMaximized then begin ReleaseCapture; Perform(WM_SYSCOMMAND,$F012,0); end;
end;

procedure TCommonEditor._OnNodeControlClick(tv:TVirtualStringTree; n:PVirtualNode; ctrl:TControl);
begin _OnClick(ctrl); end;

procedure TCommonEditor._OnResize(Sender:TObject);
begin DoUpdateControls; end;

{ TSimpleEditor }

function TSimpleEditor.DoCreateNewValueEdit:TControl; begin inherited DoCreateNewValueEdit;
  edtNewValue:=TsEdit.Create(Self);
  with edtNewValue do begin Parent:=pnlNewValue; Top:=iOffs;
    BoundLabel.Active:=true; BoundLabel.FTheLabel.AutoSize:=true; BoundLabel.Caption:='Новое: '; BoundLabel.FTheLabel.OnMouseDown:=_OnMouseDown;
    Left:=iOffs+BoundLabel.FTheLabel.Width+iOffs; Width:=pnlNewValue.ClientWidth-Left-iOffs; Anchors:=[akLeft,akRight,akTop];
  end;
  pnlNewValue.ClientHeight:=edtNewValue.Top+edtNewValue.Height+iOffs;
  Result:=edtNewValue;
end;

{ TSimpleAvailableValuesEditor }

constructor TSimpleAvailableValuesEditor.Create(aOwner:TComponent); begin inherited;
  edtIndex:=TsSpinEdit.Create(Self);
  with edtIndex do begin Parent:=pnlNewValue; {OnChange:=_OnClick;} AllowNegative:=false;
    BoundLabel.Caption:='Индекс:'; BoundLabel.Active:=true; BoundLabel.FTheLabel.AutoSize:=true; BoundLabel.FTheLabel.OnMouseDown:=_OnMouseDown;
    Width:=80; Left:=pnlNewValue.ClientWidth-Width-iOffs;
    Top:=iOffs; if ctrlNewValue<>nil then Top:=ctrlNewValue.Top+ctrlNewValue.Height+iOffs+7;
    Anchors:=[akRight,akTop]; Hint:='индекс значения';
  end;
  lbxAvailableValues:=TsListBox.Create(Self);
  with lbxAvailableValues do begin Parent:=pnlNewValue;
    BoundLabel.Caption:='Возможные значения:'{#13#10'      '}; BoundLabel.Active:=true; BoundLabel.FTheLabel.AutoSize:=true;
    BoundLabel.Layout:=sclTopLeft; BoundLabel.FTheLabel.OnMouseDown:=_OnMouseDown;
    Left:=iOffs; Width:=pnlNewValue.ClientWidth-Left-iOffs;
    Top:=edtIndex.Top+edtIndex.Height+2; Height:=ItemHeight*5;
    Color:=2;
  end;

  pnlNewValue.ClientHeight:=lbxAvailableValues.Top+lbxAvailableValues.Height+iOffs;
  lbxAvailableValues.Anchors:=[akLeft,akRight,akTop,akBottom];
end;

{ TFloatEditor }

function TFloatEditor.DoCreateNewValueEdit:TControl; begin
  edtNewValue:=TsDecimalSpinEdit.Create(Self);
  with edtNewValue do begin Parent:=pnlNewValue; Top:=iOffs;
    BoundLabel.Active:=true; BoundLabel.FTheLabel.AutoSize:=true; BoundLabel.Caption:='Новое: '; BoundLabel.FTheLabel.OnMouseDown:=_OnMouseDown;
    Left:=iOffs+BoundLabel.FTheLabel.Width+iOffs; Width:=pnlNewValue.ClientWidth-Left-iOffs; Anchors:=[akLeft,akRight,akTop];
    FlatSpinButtons:=true;
  end;
  tbr:=TsTrackBar.Create(Self);
  with tbr do begin Parent:=pnlNewValue; Top:=edtNewValue.Top-3; Anchors:=[akTop,akRight]; Width:=100;
    Left:=pnlNewValue.ClientWidth-Width-2; Height:=35;
  end;

  edtNewValue.Width:=tbr.Left-edtNewValue.Left-iOffs; Result:=edtNewValue;
end;

{ TIntegerEditor }

function TIntegerEditor.DoCreateNewValueEdit:TControl;
begin Result:=inherited DoCreateNewValueEdit; edtNewValue.HideExcessZeros:=true; end;

{ TBooleanEditor }

function TBooleanEditor.DoCreateNewValueEdit:TControl; var pnd:PrAttrsNodeData; begin inherited DoCreateNewValueEdit;
  fbMin:=false; fbMax:=true; fbCurrent:=false; fsFalse:='отключено'; fsTrue:='включено';
  tvAttr.DisplayOptions:=tvAttr.DisplayOptions-[adoRangeMinMax]; _OnResize(Self);
  tvAttr.OnPaintText:=_OnPaintText;
  pnd:=tvAttr.GetNodeData(tvAttr.GetAttributeNode(ndxTagType)); pnd._sValue:='bool';
  lblNewValue:=TsLabel.Create(Self);
  with lblNewValue do begin Parent:=pnlNewValue; Top:=iOffs; Left:=Top; Caption:='Новое:'; OnMouseDown:=_OnMouseDown; end;
  btnNewValue:=TsBitBtn.Create(Self); Result:=btnNewValue;
  with btnNewValue do begin Parent:=pnlNewValue; Top:=lblNewValue.Top; Left:=lblNewValue.Left+lblNewValue.Width+iOffs;
    Width:=pnlNewValue.ClientWidth-Left-iOffs; Anchors:=[akTop,akLeft,akRight]; Down:=true; Font.Style:=[fsBold]; OnClick:=_OnClick; 
    lblNewValue.Top:=Top+Height div 2-lblNewValue.Height div 2-1; OnClick(btnNewValue);
  end;
end;

function TBooleanEditor.DoGetNewValue:OleVariant;
begin Result:=btnNewValue.Down; end;

function TBooleanEditor.DoGetValue(ndx:integer):AnsiString; var b:boolean; begin b:=false;
  case ndx of
    ndxRangeMin: b:=false;                ndxRangeMax: b:=true;
    ndxMin: b:=fbMin;                     ndxMax: b:=fbMax;
    ndxCurrent: b:=fbCurrent;             ndxNew: b:=btnNewValue.Down;
  end;
  Result:=GetValue(b);
end;

procedure TBooleanEditor.DoSetNewValue(ndx:integer); begin
  case ndx of
    ndxMin: btnNewValue.Down:=fbMin;
    ndxMax: btnNewValue.Down:=fbMax;
    ndxCurrent: btnNewValue.Down:=fbCurrent;
  end;
//  DoUpdateControls;
end;

procedure TBooleanEditor.DoUpdateControls; begin inherited;
  if btnNewValue<>nil then begin
    btnNewValue.Caption:=DoGetValue(ndxNew); 
    if btnNewValue.Down then btnNewValue.Font.Style:=[fsBold]else btnNewValue.Font.Style:=[];
    btnApply.Enabled:=btnNewValue.Down<>fbCurrent;
  end;
end;

function TBooleanEditor.GetValue(b:boolean):AnsiString;
begin if not b then Result:=fsFalse else Result:=fsTrue; end;

procedure TBooleanEditor._OnClick(Sender:TObject); begin inherited;
  if Sender=btnNewValue then begin
    if(fbMin<>fbMax)then btnNewValue.Down:=not btnNewValue.Down else btnNewValue.Down:=fbMin;
  end;
  DoUpdateControls;
end;

procedure TBooleanEditor._OnPaintText(Sender:TBaseVirtualTree; const TargetCanvas:TCanvas; n:PVirtualNode; Column:TColumnIndex; TextType:TVSTTextType); var b:boolean; begin
  if(Column=1)then begin b:=false;
    case n.Index of
      ndxRangeMin:;                       ndxRangeMax: b:=true;
      ndxMin: b:=fbMin;                   ndxMax: b:=fbMax;
      ndxCurrent: b:=fbCurrent;
    end;
    if b then TargetCanvas.Font.Style:=[fsBold];
  end;
end;

initialization
  GetLocaleFormatSettings(SysLocale.DefaultLCID,gfs);
//  hCallWndProc:=SetWindowsHookExW(WH_CALLWNDPROC,@CallWndProcHook,0{hInstance},GetCurrentThreadId); {ставим локальную ловушку и только на наш процесс!, глобальная только через длл'ки однако}
//  if hCallWndProc=0then ShowMessage(SysErrorMessage(GetLastError));
finalization
  if hCallWndProc<>0then UnhookWindowsHookEx(hCallWndProc); hCallWndProc:=0;

end.
