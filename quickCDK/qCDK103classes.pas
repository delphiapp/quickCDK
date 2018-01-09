unit qCDK103classes;

interface

uses uCalcTypes,qCDKclasses,qCDK103types,uProgresses;

const
  MaxScopesListCount=10;

  ndxFCB=1000; ndxAsduAddress=1001; ndxLinkAddress=1002;
  ndxCompatibilityLevel=1003; ndxDeviceName=1004; ndxSoftwareID=1005;

  ndxClearReadnScope=1100; ndxFirstFCB=1101; ndxUseE5=1102;

  __TrTagInfo = 'Name String TypeID Byte FUN Byte INF Byte Channel Byte Scale Double';


type
  TrTagInfo=packed record // �������� ���� � ����� �����
    Name:String;        // �������� ����  
    TypeID:byte;        // ������������� ����, ���������� ��� ����
    FUN:byte;           // ��� �������, ������� ���� ������ ����
    INF:byte;           // ����� ����������, ������� ���� ������ ����
    Channel:byte;       // ����� ������ ��� ���������(TypeID ����� 3 ��� 9):
                        // 0 - �� ���������, ������ ��������� ����������� INF ���������������,
                        // �� 0 - ������ INF �� �������������, � Channel ��������� �� ���������������� ������ � ASDU ��� ���������
    Scale:double;       // ���������
  end;

  TrTagInfoArray=array of TrTagInfo; // ������ �������� �����

  TrTag1=packed record // ASDU1
    _BValue:boolean;              // �������� ����

    _DPI:tagDPI;                  // �������������� ����������
    _Time32:tagCP32Time2a;        // ����� �������
    _SIN:tagSIN;                  // �������������� ����������
  end;

  TrTag2=packed record // ASDU2
    _BValue:boolean;              // �������� ����  

    _DPI:tagDPI;                  // �������������� ����������
    _RET:tagRET;                  // ������������� �����, ��� ������ ������ �� �����������
    _FAN:tagFAN;                  // ����� �����������, ��� ������ ������ �� �����������
    _Time32:tagCP32Time2a;        // ����� �������
    _SIN:tagSIN;                  // �������������� ����������
  end;

  TrTag3=packed record // ASDU3
    _Scale:double;                // �����������
    _OV:boolean;                  // ������� ������������ MVAL
    _ER:boolean;                  // ������� ������������ MVAL
    _MVAL:double;                 // ��������
  end;

  TrTag4=packed record // ASDU4
    _SCL:tagSCL;                  // ���������� �� ����� ��������� ���������
    _RET:tagRET;                  // ������������� �����
    _FAN:tagFAN;                  // ����� �����������
    _Time32:tagCP32Time2a;        // ����� �������
  end;

  TrTag5=packed record // ASDU5
    _COL:tagCOL;                  // ������� �������������
    _Vendor:array[0..7]of tagASC; // �������������
    _SoftwareID:array[0..3]of byte; // ������������� ������������ �����������
  end;

  TrTag6=packed record // ASDU6
    _Time56:tagCP56Time2a;        // �����
  end;

  TrTag8=packed record // ASDU8
    _SCN:tagSCN;                  // ����� ������, ������ �� ������� ������������� GI
  end;

  TrTag9=packed record // ASDU9
    _Scale: double;               // �����������
    _OV:boolean;                  // ������� ������������ MVAL
    _ER:boolean;                  // ������� ������������ MVAL
    _MVAL:double;                 // ��������
  end;

  PIEC103Tag=^TIEC103Tag;
  TIEC103Tag=packed record
    _bValidValue:boolean;         // ���������� �� ��������
    _Name:AnsiString;             // ��� ����
    _TypeID:byte;                 // ������������� ���� Type Identification
    _ASDU:TASDU;                  // ��������� ����� - ����� ���� � ������� ��������
    _Address:longword;            // ������ ����� - ��� (_TypeID shl 24)+(_FUN shl 16)+(_INF shl 8)+_Channel
                  // _Channel=0 ��� ����, ����� _TypeID=3 � 9
                  // _TypeID=5, _INF: 2 ��� cot2ResetFCB, 3 ��� cot2ResetCommUnit, 4 ��� cot2StartRestart=5, 5 ��� cot2PowerOn
                  // _TypeID=6, - ��� (_TypeID shl 24)+(_FUN=0xFF shl 16)+(_INF=0x00 shl 8)+_Channel
                  // _TypeID=8, - ��� (_TypeID shl 24)+(_FUN=0xFF shl 16)+(_INF=0x00 shl 8)+_Channel
    case integer of
      1: (Tag1:TrTag1);
      2: (Tag2:TrTag2);
      3: (Tag3:TrTag3);
      4: (Tag4:TrTag4);
      5: (Tag5:TrTag5);
      6: (Tag6:TrTag6);
      8: (Tag8:TrTag8);
      9: (Tag9:TrTag9);
  end;

  TScopeState=(ssFaultsListWaiting,ssFaultSelect,ssFaultDataWaiting,ssFaultDataRequest,ssFaultTagsWaiting,ssFaultTagsRequest,
    ssFaultTagsTransmitting,ssFaultTagsAck,ssFaultChannelWaiting,ssFaultChannelRequest,ssFaultChannelTransmitting,ssFaultChannelAck,
    ssFaultDataAck);
  // ssFaultsListWaiting - �������� ������ ��������� ASDU23
  // ssFaultSelect - ����� ��������� ASDU24
  // ssFaultDataWaiting - �������� ���������� ������ � ���������� ASDU26
  // ssFaultDataRequest - ������ �������� ������ � ���������� ASDU24
  // ssFaultTagsWaiting - �������� ���������� ����� ASDU28
  // ssFaultTagsRequest - ������ �������� ����� ASDU 24
  // ssFaultTagsTransmitting - �������� ��������� ��������� ����� � �� ��������� ASDU29, ��������� �������� ����� ASDU31
  // ssFaultTagsAck - ������������� �������� ����� (������������� - ������� ��� �� ����) ASDU25
  // ssFaultChannelWaiting - �������� ���������� �������� ������ ASDU27, ��������� �������� ������ � ���������� ASDU31 (����� ��������� ������ ssFaultDataAck)
  // ssFaultChannelRequest - ������ �������� ������ ������ ASDU24
  // ssFaultChannelTransmitting - �������� ��������� �������� ������ ASDU30, ��������� �������� ������ ASDU31
  // ssFaultChannelAck - ������������� �������� ������ (������������� - ������� ��� �� ����) ASDU25
  // ssFaultDataAck - ������������� �������� ������ � ���������� ASDU25
  TrScopesListData=packed record // ���������� �� ������ ������������ (����� ���� ��������� � ����������)
    _FUN:byte;        // ��� �������
    _INF:byte;        // ����� ����������
    _Count:byte;      // ���������� ������������
    _FANs:array[0..255]of tagFAN; // ������ ������� ������������
    _OrgTagsCount:integer; // ���������� ����� � �������� ����������
  end;

  TrScopeTagInfo=packed record // ���������� � ����� (���������� �����)
    _FUN:byte;                // ��� �������
    _INF:byte;                // ����� ����������
    _DPIs:array of tagDPI;    // ������ ��������
  end;

  TrScopeChannelInfo=packed record // ���������� � ������ (���������� �����)
    _ACC:tagACC;              // ����� ������, ��� ��� ����� �������� �� _FUN,_INF � _ACC
    _RPV:tagRPV;              // ����������� ��������� �������� ������
    _RSV:tagRSV;              // ����������� ��������� �������� ������
    _RFA:tagRFA;              // ���������� ����������� ������
    _SDVs:array of tagSDV;     // ������ ��������
  end;

  PScopeTagsInfos=^TScopeTagsInfos;
  TScopeTagsInfos=array of TrScopeTagInfo;

  PScopeChannelsInfos=^TScopeChannelsInfos;
  TScopeChannelsInfos=array of TrScopeChannelInfo;

  TrReadingScopeData=packed record // ���������� �� ������� �������� �������������
    // ������������� ����� ��������������
    _FUN:byte;                // ��� �������
    _INF:byte;                // ����� ����������
    _Time56:tagCP56Time2a;    // ����� ����������� �������������
    // ��������� ������ �������������
    _ss:TScopeState;          // ��������� �������������
    _lwReadTicks:longword;    // ����, ����� ���� ������ �������������
    // ���������� �� �������������
    _FAN:tagFAN;              // ����� �������������
    _ACC:tagACC;              // ����� ������
    _RPV:tagRPV;              // ����������� ��������� �������� ������
    _RSV:tagRSV;              // ����������� ��������� �������� ������
    _RFA:tagRFA;              // ���������� ����������� ������

    _NOF:tagNOF;              // ����� ����������� ���� - ��������� ������������ ����� ���� � ���� �������
    _NOC:tagNOC;              // ����� �������
    _NOE:tagNOE;              // ����� ��������� ���������� � ������
    _INT:tagINT;              // �������� ����� ���������� ���������� � ���
    _Time32:tagCP32Time2a;    // ����� ������� ������ ������������������ ����������

    // �������� ������ �������������
    _lwStartedTicks,_lwCurrentProgress,_lwMaximalProgress:longword; // ��� ���������� ��� ������ ���������

    // ���������� �� ������
    _TagsInit:boolean;        // �������� ��������� ����� ��������
    _TagsCount:integer;       // ������� �������� ���������� �����
    _TagsCountMax:integer;    // ������������ �������� ����� � ������������� (�������� ���������)
    _TagsBaseInc:boolean;     // ��������� ������� ������� �����
    _TagsBasePos:integer;     // ������� ������� ����� (�� ������ 65536)
    _pTagsInfo:PScopeTagsInfos; // ������ ���� �����

    // ���������� �� �������
    _ChannelInit:boolean;     // �������� ��������� ������ ��������
    _ChannelBaseInc:boolean;  // ��������� ������� ������� ������
    _ChannelBasePos:integer;  // ������� ������� ������ (�� ������ 65536)
    _pChannelsInfo:PScopeChannelsInfos; // ������ ���� �������
  end;

  TrScopesData=packed record // ���������� �� ��������������
    _bSleep:boolean;          // ���� �������� ��������
    _ndxRequest:integer;      // ������ ������ ��� ������� (������� ����� ���� ���������)
    _ScopesListCount:integer; // ���������� ������� ������������ - �������� MaxScopesListCount
    _ScopesListDatas:array[0..MaxScopesListCount-1]of TrScopesListData; // ���������� �� ������� ������������ - ����� ���� ���������
    _ReadingScopeData:TrReadingScopeData;             // ���������� �� ������� �������� �������������
  end;

  TrScopesInfo=packed record    // ��
    _bInitialized:boolean;      // �������� �������������������
    _bAuto:boolean;             // �������������� ���������� �� ������� (��� 0-� ������� - �� ����� ������)
    _bProcessing:boolean;       // �������� �����������
    _lwOrgTicks:longword;       // ����� ������ ��������
    _lwLastTicks:longword;      // ����� � �� ��������� ��������
    _lwInterval:longword;       // �������� ���������� ��������
    _rScopesData:TrScopesData;  // �������������� ������ ��������
  end;

// ��� ����������� ��������� ����������� ������ ���� ������/�����

  TIEC103Protocol=class(TCommunicationProtocol)
  protected
    fbClearReadnScope,fbFirstFCB,fbUseE5:boolean;

    function DoGetAsText:AString; override;
    function DoGetStateInfo:AnsiString; override;
    procedure DoSetAsText(const s:AString); override;

    function DoGetBool(const ndx:integer):Bool64; override;               // ��� ��������� ��������

    procedure DoSetBool(const ndx:integer; const b:Bool64); override;     // ��� ��������� ��������
    procedure DoSetUInt(const ndx:integer; const ui:UInt64); override;    // ��� ����������� ����� ��������
  protected
    function IntToHex(i64:Int64; iDigits:integer):AnsiString; virtual;

    function MakePacket(const sHexBody:AnsiString):AnsiString; override;  // �������� ������ �� hex-���� ������ (������� ������ � �����, ����������� ����� � �.�.)
  public
    property ClearReadnScope:boolean index ndxClearReadnScope read GetB1 write SetB1;// ������� ��������� ������������� �� ����������
    property FirstFCB:boolean index ndxFirstFCB read GetB1 write SetB1;   // �������� ������� FCB ����� ������������� ����������
    property UseE5:boolean index ndxUseE5 read GetB1 write SetB1;         // ������������ ��������� ������ 0xE5
  public
    class function GetClassCaption:AString; override;       // �������� ������
    class function GetClassDescription:AString; override;   // ��������� �������� ������

    procedure SetDefault; override; // ��������� �� ���������
    function GetErrorAsText(ce:integer):AnsiString; override;                 // ������ � ���� ������

    // ������������ ����� �� ������ �������, ��������� ������� ������� ������ pDst, ���� �����
    // � ������ ���������� ��������� IEC103-���������� ���������� ����������
    function HandleResponse(sRequest,sResponse:AnsiString; pDst:pointer; iDstSize:integer):integer; override;

    function IsBroadcastRequest(const sRequest:AnsiString):boolean; override; // �������� �� ����������������� ������
    function IsResponseSuccess(const ce:integer):boolean; override;           // �������� ���� ������ ������ (HandleResponse) �� ������������ ������

    // ������ IEC103-������ �� ������ ������� �������� (���� ����������, ����� ����������, ���������)
    // � ������ ����������� ������������ IEC103-������� ���������� ����������
    function MakeRequest(arrPacketData:array of Int64):AnsiString; overload; override;
    // � ������ ����������� ������������ IEC103-������� ������������ ��� ������, � ������ ndxError � �������
    function MakeRequest(arrPacketData:array of Int64; out sRequest:AnsiString; out ndxError:integer):integer; overload; override;

    // ������ IEC103-����� �� ������ ������� �������� (����� ����������, �������, ���������)
    // � ������ ����������� ������������ ������ ���������� ����������
    function MakeResponse(arrPacketData:array of Int64):AnsiString; overload; override;
    // � ������ ����������� ������������ ������ ������������ ��� ������, � ������ ndxError � �������
    function MakeResponse(arrPacketData:array of Int64; out sResponse:AnsiString; out ndxError:integer):integer; overload; override;
  end;

////////// ������ �������� (������� ���� �������� ������ ������ � ������� �� ������ �������)
// LinkControlField,LinkAddress,TypeIdentification,VariableStructureQualifier,CauseOfTransmission,ASDUAddress,FunctionType,InformationNumber,InformationElements

// LinkControlField,LinkAddress,ti1TimeSynchronization,VSQ=0x81,COT=cot1TimeSynchronization,ASDUAddress,FT=0xFF,IN=0x00,Time56=1,1,1,1,1,1,1,1,[1,1,1,1,1,1,1]
// LinkControlField,LinkAddress,ti1GeneralInterrogation,VSQ=0x81,COT=cot1GeneralInterrogation,ASDUAddress,FT=0xFF,IN=0x00,SCN=1,1,1,1,1,1,1,1,1
// LinkControlField,LinkAddress,ti1GeneralCommand,VSQ=0x81,COT=cot1GeneralCommand,ASDUAddress,FT,IN,DCO,RII=1,1,1,1,1,1,1,1,1,1
// LinkControlField,LinkAddress,ti1FaultRequest,VSQ=0x81,COT=cot1FaultTransmission,ASDUAddress,FT,IN=0x00,TOO,TOV,FAN,ACC=1,1,1,1,1,1,1,1,1,1,2,1
// LinkControlField,LinkAddress,ti1FaultAcknowledge,VSQ=0x81,COT=cot1FaultTransmission,ASDUAddress,FT,IN=0x00,TOO,TOV,FAN,ACC=1,1,1,1,1,1,1,1,1,1,2,1

////////// ������ ������� (������� ���� �������� ������ ������ � ������� �� ������ �������)

//LCF,LA,ti2TimeTag,VSQ=0x81,COT,ASDUAddress,FT,IN,DPI,CP32Time2a,SIN=1,1,1,1,1,1,1,1,1,4,1
//LCF,LA,ti2RelativeTimeTag,VSQ=0x81,COT,ASDUAddress,FT,IN,DPI,RET,FAN,CP32Time2a,SIN=1,1,1,1,1,1,1,1,1,2,2,4,1
//LCF,LA,ti2MeasuredValues1,VSQ=VSQ and 0x7F,COT,ASDUAddress,FT,IN,MEA[,MEA,...,MEA]=1,1,1,1,1,1,1,1,2,[2,...,2]
//LCF,LA,ti2MeasuredValues2,VSQ=VSQ and 0x7F,COT,ASDUAddress,FT,IN,MEA[,MEA,...,MEA]=1,1,1,1,1,1,1,1,2,[2,...,2]
//LCF,LA,ti2ShortCircuitLocation,VSQ=0x81,COT,ASDUAddress,FT,IN,SCL,RET,FAN,CP32Time2a=1,1,1,1,1,1,1,1,4,2,2,4
//LCF,LA,ti2IdentificationInfo,VSQ=0x81,COT,ASDUAddress,FT,IN,COL,ASC,ASC,ASC,ASC,ASC,ASC,ASC,ASC,byte,byte,byte,byte=1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
//LCF,LA,ti2TimeSynchronization,VSQ=0x81,COT=cot2TimeSynchronization,ASDUAddress,FT=0xFF,IN=0x00,CP56Time2a=1,1,1,1,1,1,1,1,7
//LCF,LA,ti2GeneralInterrogationTermination,VSQ=0x81,COT=cot2GeneralInterrogationTermination,ASDUAddress,FT=0xFF,IN=0x00,SCN=1,1,1,1,1,1,1,1,1
//LCF,LA,ti2FaultsList,VSQ=VSQ and 0x7F,COT,ASDUAddress,FT,IN,{FAN,SOF,CP56Time2a}[,{FAN,SOF,CP56Time2a},...,{FAN,SOF,CP56Time2a}]=1,1,1,1,1,1,1,1,{2,1,7}[,{2,1,7},...,{2,1,7}]
//LCF,LA,ti2FaultDataReady,VSQ=0x81,COT,ASDUAddress,FT,IN=0x00,0x00,TOV,FAN,NOF,NOC,NOE,INT,CP32Time2a=1,1,1,1,1,1,1,1,1,1,2,2,1,2,2,4
//LCF,LA,ti2FaultChannelReady,VSQ=0x81,COT,ASDUAddress,FT,IN=0x00,0x00,TOV,FAN,ACC,RPV,RSV,RFA=1,1,1,1,1,1,1,1,1,1,2,1,4,4,4
//LCF,LA,ti2FaultTagsReady,VSQ=0x81,COT,ASDUAddress,FT,IN=0x00,0x00,0x00,FAN=1,1,1,1,1,1,1,1,1,1,2
//LCF,LA,ti2FaultTagsTransimission,VSQ=0x81,COT,ASDUAddress,FT,IN=0x00,FAN,NOT,TAP,{FT,IN,DPI}[,{FT,IN,DPI},...,{FT,IN,DPI}]=1,1,1,1,1,1,1,1,2,1,2,{1,1,1}[,{1,1,1},...,{1,1,1}]
//LCF,LA,ti2FaultValuesTransmission,VSQ=0x81,COT,ASDUAddress,FT,IN=0x00,0x00,TOV,FAN,ACC,NDV,NFE,SDV[,SDV,...,SDV]=1,1,1,1,1,1,1,1,1,1,2,1,1,2,2[,2,..2]

  TIEC103Device=class(TCommunicationDevice)
  private
    fbFCB:boolean; fui8AsduAddress,fui8LinkAddress:byte;
    fui8CompatibilityLevel:byte; fsDeviceName:AnsiString;
    fui32SoftwareID:longword;
  protected
    function DoGetAString(const ndx:integer):AString; override;           // ��� ��������� ��������

    function DoGetBool(const ndx:integer):Bool64; override;               // ��� ��������� ��������
    function DoGetUInt(const ndx:integer):UInt64; override;               // ��� ����������� ����� ��������

    procedure DoSetBool(const ndx:integer; const b:Bool64); override;     // ��� ��������� ��������
    procedure DoSetUInt(const ndx:integer; const ui:UInt64); override;    // ��� ����������� ����� ��������
  public
    constructor Create; override;
    
    property AsduAddress:byte         index ndxAsduAddress          read GetUI8     write SetUI8;
    property FCB:boolean              index ndxFCB                  read GetB1      write SetB1;
    property LinkAddress:byte         index ndxLinkAddress          read GetUI8     write SetUI8;

    property CompatibilityLevel:byte  index ndxCompatibilityLevel   read GetUI8;      // ������� ������������� �� IEC103
    property DeviceName:AnsiString    index ndxDeviceName           read GetAString;  // ��� ����������, ���������� �� ��������� IEC103
    property SoftwareID:longword      index ndxSoftwareID           read GetUI32;     // ������������� ������������ ����������� ����������
  end;

  TProcessASDUEvent=procedure(Sender:TObject; asdu:TASDU)of object;

  TIEC103Thread=class(TCommunicationThread);

  TIEC103Master=class(TIEC103Device) // ���������� ���������� ��� ������� � ��������� 103slave ����������
  private
    LCF2:byte; {TLinkControlField ��������� ��������}
    fOnProcessASDU:TProcessASDUEvent;
  protected
    rClass1Info,rClass2Info:TrOperationInfo;
    rScopesInfo:TrScopesInfo;
    function DoAlive:integer; override;                 // ����� �������� �������� ����������

    function DoInitialize:integer; override;            // ����� �������� ������������� ����������
    function DoRefresh:integer; override;               // ����� �������� ������������� ������ ������
    function DoSynchronize:integer; override;           // ����� ����� ������� �������� �������������
    function DoSynchronizeBroadcast:integer; override;  // ����� ����� ������� �������� ����������������� �������������

    function DoGetRefreshID:longword; override;         // ������������� ������ ������

    procedure InitDevice; override;                     // ������������� ����� �����������

    function PerformTick:boolean; override;             // ������ ������ 1 ��� ������ 2, ��� ������ ������ ������������
  protected
    procedure DoComtrade; virtual;

    function FaultChannelAck:boolean; virtual;          // ������������� �������� ������
    function FaultChannelRequest:boolean; virtual;      // ������ �������� ������
    function FaultDataAbort:boolean; virtual;           // ��������������� ����������� �������� �������������
    function FaultDataAck:boolean; virtual;             // ������������� �������� �������������
    function FaultDataRequest:boolean; virtual;         // ������ �������� ������ � ����������
    function FaultTagsAck:boolean; virtual;             // ������������� �������� �����
    function FaultTagsRequest:boolean; virtual;         // ������ �������� �����

    function GetPTag(_TypeID,_FUN,_INF,_Channel:byte):PIEC103Tag; virtual;
    function GetTagAddress(_TypeID,_FUN,_INF,_Channel:byte):LongWord; virtual; // ����� ���103-����

    procedure ProcessASDU(asdu:TASDU); virtual;

    procedure ScopeProgressClose; virtual;              // ������� �������� �� �������������
    procedure ScopeProgressOpen; virtual;               // ������� �������� �� �������������
    procedure ScopeProgressUpdate(sWork:AnsiString; ps:TProgressState); virtual;  // �������� �������� ������ �������������    
  public
    class function GetClassCaption:AString; override;       // �������� ������
    class function GetClassDescription:AString; override;   // ��������� �������� ������

    procedure SetDefault; override;                     // ��������� �� ���������

    function Tick:boolean; override;                    // ���� ���� ������ ���������� (��� ��������� ���������� ������ ������ � �����������)


    function Class1:boolean; virtual;                                 // ������ ������ 1
    function Class2:boolean; virtual;                                 // ������ ������ 2

    function FaultSelect(FAN:tagFAN):boolean; virtual;                // ����� �������������    
    function FaultsListRequest:boolean; virtual;                      // ������ ������ ������������

    function ChannelState:boolean; virtual;                           // ��������� ������ �����
    function InitializeGI:boolean; virtual;                           // ������������� ������ ������
    function ResetCommUnit:boolean; virtual;                          // ����� ���� ������� ���������
    function ResetFCB:boolean; virtual;                               // ����� ��������� ������� ���������

    property OnProcessASDU:TProcessASDUEvent read fOnProcessASDU write fOnProcessASDU;
  end;

implementation

uses Windows,Classes,SysUtils,StrUtils,Math,SynCommons,IniFiles,
  uUtilsFunctions,uComtrade,qCDK103funcs,uNamedSpace;

{$BOOLEVAL OFF}
{$RANGECHECKS OFF}
{$OVERFLOWCHECKS OFF}

type TLTransactionData=class(TTransactionData);

var gfs:TFormatSettings;

const lwMaxPacketSize=255+6 {68 len len 68 ... lrc 16};

  type TLCommunicationObject=class(TCommunicationObject);

  procedure RegisterClasses; var co:TCommunicationObject; begin co:=nil;
    try co:=TCommunicationObject.Create;
      TLCommunicationObject(co).Owner.RegisterProtocolClass(TIEC103Protocol);
      TLCommunicationObject(co).Owner.RegisterDeviceClass(TIEC103Master);
    finally co.Free; end;
  end;

  function CreateTagsTable(sTags:AnsiString):THashedStringList; // ������ ������� �����
  var utf:RawUTF8; tagsInfo:TrTagInfoArray; i:integer; pTag:PIEC103Tag;
    b5,b6,b8:boolean; // ���� �� �������� ���� � _TypeID=5,6,8
    function GetTagAddress(_TypeID,_FUN,_INF,_Channel:byte):LongWord;
    begin Result:=(_TypeID shl 24)+(_FUN shl 16)+(_INF shl 8)+_Channel; end;
  begin Result:=nil;
    utf:=StringToUTF8(sTags); DynArrayLoadJSON(tagsInfo,@utf[1],TypeInfo(TrTagInfoArray));
    b5:=false; b6:=false; b8:=false;
    if Length(tagsInfo)<>0then begin Result:=THashedStringList.Create;
      for i:=0to High(tagsInfo)do begin
        pTag:=GetMemory(SizeOf(pTag^)); ZeroMemory(pTag,SizeOf(pTag^));
        with tagsInfo[i],pTag^do begin
          _TypeID:=TypeID; _Name:=Name; 
          case TypeID of
            ti2TimeTag:                           begin _Address:=GetTagAddress(TypeID,FUN,INF,0); end; // 1 - ��������� � ������ �������
            ti2RelativeTimeTag:                   begin _Address:=GetTagAddress(TypeID,FUN,INF,0); end; // 2 - ��������� � ������ �������������� �������
            ti2MeasuredValues1:                   begin _Address:=GetTagAddress(TypeID,FUN,INF,Channel); Tag3._Scale:=Scale; end; // 3 - ���������� ��������, ����� ���� 1
            ti2ShortCircuitLocation:              begin _Address:=GetTagAddress(TypeID,FUN,INF,0); _Name:=Name; end; // 4 - ����� ��������� ���������
            ti2IdentificationInfo:                begin _Address:=GetTagAddress(TypeID,FUN,INF,0); b5:=true; end; // 5 - ����������������� ����������
            ti2TimeSynchronization:               begin _Address:=GetTagAddress(TypeID,FUN,INF,0); b6:=true; end; // 6 - ������������� �������
            ti2GeneralInterrogationTermination:   begin _Address:=GetTagAddress(TypeID,FUN,INF,0); b8:=true; end; // 8 - ���������� ������ ������
            ti2MeasuredValues2:                   begin _Address:=GetTagAddress(TypeID,FUN,INF,Channel); Tag9._Scale:=Scale; end; // 9 - ���������� ��������, ����� ���� 2
          else FreeMemory(pTag); pTag:=nil; end; // ����� �� �� �����
        end;
        if pTag<>nil then Result.AddObject(IntToHex(pTag._Address,8),TObject(pTag));
      end;
      if Result.Count=0then FreeAndNil(Result); // ���-�� ������ �� ��������
    end;
    if not b5 then begin if Result=nil then Result:=THashedStringList.Create;
      pTag:=GetMemory(SizeOf(pTag^)); ZeroMemory(pTag,SizeOf(pTag^));
      pTag._TypeID:=5; pTag._Address:=GetTagAddress(pTag._TypeID,0,2,0); pTag._Name:='ASDU5 ����� FCB';
      Result.AddObject(IntToHex(pTag._Address,8),TObject(pTag));
      pTag:=GetMemory(SizeOf(pTag^)); ZeroMemory(pTag,SizeOf(pTag^));
      pTag._TypeID:=5; pTag._Address:=GetTagAddress(pTag._TypeID,0,3,0); pTag._Name:='ASDU5 ����� CU';
      Result.AddObject(IntToHex(pTag._Address,8),TObject(pTag));
      pTag:=GetMemory(SizeOf(pTag^)); ZeroMemory(pTag,SizeOf(pTag^));
      pTag._TypeID:=5; pTag._Address:=GetTagAddress(pTag._TypeID,0,4,0); pTag._Name:='ASDU5 �����/�������';
      Result.AddObject(IntToHex(pTag._Address,8),TObject(pTag));
      pTag:=GetMemory(SizeOf(pTag^)); ZeroMemory(pTag,SizeOf(pTag^));
      pTag._TypeID:=5; pTag._Address:=GetTagAddress(pTag._TypeID,0,5,0); pTag._Name:='ASDU5 ��������� �������';
      Result.AddObject(IntToHex(pTag._Address,8),TObject(pTag));
    end;
    if not b6 then begin if Result=nil then Result:=THashedStringList.Create;
      pTag:=GetMemory(SizeOf(pTag^)); ZeroMemory(pTag,SizeOf(pTag^));
      pTag._TypeID:=6; pTag._Address:=GetTagAddress(pTag._TypeID,$FF,$00,0); pTag._Name:='ASDU6 �������������';
      Result.AddObject(IntToHex(pTag._Address,8),TObject(pTag));
    end;
    if not b8 then begin if Result=nil then Result:=THashedStringList.Create;
      pTag:=GetMemory(SizeOf(pTag^)); ZeroMemory(pTag,SizeOf(pTag^));
      pTag._TypeID:=8; pTag._Address:=GetTagAddress(pTag._TypeID,$FF,$00,0); pTag._Name:='ASDU8 ����� ������ ������';
      Result.AddObject(IntToHex(pTag._Address,8),TObject(pTag));
    end;

  //  s2:=UTF8ToString(DynArraySaveJSON(DataTags,TypeInfo(trDataTags)));
  end;


{ TIEC103Protocol }

function TIEC103Protocol.DoGetAsText:AString; var v:variant; begin
  v:=_JsonFast(StringToUTF8(inherited DoGetAsText));
  v.ClearReadnScope:=fbClearReadnScope; v.FirstFCB:=fbFirstFCB; v.UseE5:=fbUseE5;
  Result:=v; if bJSONHumanReadable then Result:=JSONReformat(Result); // VariantSaveJSON(v)
  Result:=UTF8ToString(Result);
end;

function TIEC103Protocol.DoGetBool(const ndx:integer):Bool64; begin
  case ndx of
    ndxClearReadnScope: Result:=Bool64(fbClearReadnScope);
    ndxFirstFCB: Result:=Bool64(fbFirstFCB);       ndxUseE5: Result:=Bool64(fbUseE5);
  else Result:=inherited DoGetBool(ndx); end;
end;

function TIEC103Protocol.DoGetStateInfo:AnsiString;
begin Result:=Format('%s,ClearReadnScope=%s,FirstFCB=%s,UseE5=%s',[inherited DoGetStateInfo,sBoolsNumber[fbClearReadnScope],sBoolsNumber[fbFirstFCB],sBoolsNumber[fbUseE5]],gfs); end;

procedure TIEC103Protocol.DoSetAsText(const s: AString); var v:variant; begin
  try try BeginUpdate; v:=_JsonFast({StringToUTF8(}s{)});
    ClearReadnScope:=GetVariantProperty(v,'ClearReadnScope',fbClearReadnScope);
    FirstFCB:=GetVariantProperty(v,'FirstFCB',fbFirstFCB);
    UseE5:=GetVariantProperty(v,'UseE5',fbUseE5);    
    inherited DoSetAsText(s);
  finally EndUpdate; end; except end;
end;

procedure TIEC103Protocol.DoSetBool(const ndx:integer; const b:Bool64); begin
  case ndx of
    ndxClearReadnScope: if fbClearReadnScope<>Bool1(b)then begin fbClearReadnScope:=Bool1(b); Changed; end;
    ndxFirstFCB: if fbFirstFCB<>Bool1(b)then begin fbFirstFCB:=Bool1(b); Changed; end;
    ndxUseE5: if fbUseE5<>Bool1(b)then begin fbUseE5:=Bool1(b); Changed; end;
  else inherited DoSetBool(ndx,b); end;
end;

procedure TIEC103Protocol.DoSetUInt(const ndx:integer; const ui:UInt64); var lw:LongWord; begin
  case ndx of
    ndxAddressSize:         exit; // ������ ������ 1 ����
    ndxBroadcastAddress:    exit; // ����������������� ����� ������ 255
    ndxMaxPacketSize:       begin lw:=ui;
      if(lw=0)or(lw>lwMaxPacketSize)then lw:=lwMaxPacketSize;
      inherited DoSetUInt(ndx,lw);
    end;
  else inherited DoSetUInt(ndx,ui); end;
end;

class function TIEC103Protocol.GetClassCaption:AString;
begin Result:='�������� ���103 (TIEC103Protocol)'; end;

class function TIEC103Protocol.GetClassDescription:AString;
begin Result:='�������� ���60870-5-103 ������ TIEC103Protocol ��������� ����������� �������, ����� ��������� �����'; end;

function TIEC103Protocol.GetErrorAsText(ce:integer):AnsiString;
begin Result:=iec103GetErrorStr(ce); end;

function TIEC103Protocol.HandleResponse(sRequest,sResponse:AnsiString; pDst:pointer; iDstSize:integer):integer;
type TSetOfByte=set of byte;
  function GetFuncCodeResult(fc:byte; fcodes:TSetOfByte):integer; begin
    case fc of
      fc2ServiceUnavailable:      Result:=ieceServiceUnavailable;
      fc2ServiceUnimplemented:    Result:=ieceServiceUnimplemented;
    else
      Result:=ieceControlFunctionCode;
      if not(fc in fcodes)then Result:=ieceControlFunctionCode else case fc of
        fc2PosAck:                  Result:=iecePosAck;
        fc2NegAck:                  Result:=ieceNegAck;
        fc2UserData:                Result:=ieceUserData;
        fc2NoUserData:              Result:=ieceNoUserData;
        fc2ChannelState:            Result:=ieceChannelState;
      end;
    end;
  end;
begin
  try Result:=ceUnknownError;
    if Length(sRequest)<5then begin Result:=ceFrameLength; exit; end;
    if Length(sResponse)<1then begin Result:=ceFrameLength; exit; end;
    case sResponse[1]of
      #$E5: SetLength(sResponse,1);
      #$10: begin if Length(sResponse)<5then begin Result:=ceFrameLength; exit; end; SetLength(sResponse,5);
        if sResponse[5]<>#$16then begin Result:=ceCorruptedResponse; exit; end;
        if byte(CheckSum_CalculateLRC(sResponse[2]+sResponse[3]))<>byte(sResponse[4])then begin Result:=ceFrameCRC; exit; end;
      end;
      #$68: begin if(sResponse[2]<>sResponse[3])then begin Result:=ceFrameLength; exit; end;
        if Length(sResponse)<byte(sResponse[2])+6then begin Result:=ceFrameLength; exit; end; // ����� ����� ������
        SetLength(sResponse,byte(sResponse[2])+6); // ������� ������ �����, ���� ����
        if Length(sResponse)<12then begin Result:=ceFrameLength; exit; end; // ����� LCF,LA,TypeID,VSQ,COT,ASDUaddress
        if sResponse[Length(sResponse)]<>#$16then begin Result:=ceCorruptedResponse; exit; end;
          if byte(CheckSum_CalculateLRC(Copy(sResponse,5,Length(sResponse)-6)))<>byte(sResponse[Length(sResponse)-1])
            then begin Result:=ceFrameCRC; exit; end;
      end;
    else Result:=ceCorruptedResponse; exit; end;
    case sRequest[1]of
      #$68: begin if(sRequest[2]<>sRequest[3])then begin Result:=ceFrameLength; exit; end;
        if Length(sRequest)<>byte(sRequest[2])+6then begin Result:=ceFrameLength; exit; end; // ����� ����� ������
        if Length(sRequest)<12then begin Result:=ceFrameLength; exit; end; // ����� LCF,LA,TypeID,VSQ,COT,ASDUaddress
        case byte(sRequest[5])and$0Fof
          fc1UserSend: if sResponse[1]=#$E5then begin Result:=iecePosAck; exit; end
            else if sResponse[1]<>#$10then begin Result:=ceIncorrectResponse; exit; end
            else begin Result:=GetFuncCodeResult(byte(sResponse[2])and$0F,[fc2PosAck,fc2NegAck]); exit; end;
          fc1UserBroadcast: begin Result:=ieceBroadCast; exit; end;
        else Result:=ieceControlFunctionCode; exit; end; // ������ �������������� ���� �� ������ ��� ����
      end;
      #$10: case byte(sRequest[2])and$0Fof
        fc1ResetCommUnit: if sResponse[1]=#$E5then begin Result:=iecePosAck; exit; end
          else if sResponse[1]<>#$10then begin Result:=ceIncorrectResponse; exit; end
          else begin Result:=GetFuncCodeResult(byte(sResponse[2])and$0F,[fc2PosAck,fc2NegAck]); exit; end;
        fc1ResetFCB: if sResponse[1]=#$E5then begin Result:=iecePosAck; exit; end
          else if sResponse[1]<>#$10then begin Result:=ceIncorrectResponse; exit; end
          else begin Result:=GetFuncCodeResult(byte(sResponse[2])and$0F,[fc2PosAck,fc2NegAck]); exit; end;
        fc1ChannelState: if sResponse[1]=#$E5then begin Result:=iecePosAck; exit; end
          else if sResponse[1]<>#$10then begin Result:=ceIncorrectResponse; exit; end
          else begin Result:=GetFuncCodeResult(byte(sResponse[2])and$0F,[fc2ChannelState]); exit; end;
        fc1Class1: case sResponse[1]of
          #$E5: begin Result:=ieceNoUserData; exit; end;
          #$10: begin Result:=GetFuncCodeResult(byte(sResponse[2])and$0F,[fc2NoUserData]); exit; end;
          #$68: begin Result:=GetFuncCodeResult(byte(sResponse[5])and$0F,[fc2UserData]);
            if Result<>ieceUserData then exit;
            if(pDst<>nil)and(iDstSize<SizeOf(TLDU))then begin Result:=ceBufferSize; exit; end;
            CopyMemory(pDst,@sResponse[5],Length(sResponse)-6);
          end;
        end;
        fc1Class2: case sResponse[1]of
          #$E5: begin Result:=ieceNoUserData; exit; end;
          #$10: begin Result:=GetFuncCodeResult(byte(sResponse[2])and$0F,[fc2NoUserData]); exit; end;
          #$68: begin Result:=GetFuncCodeResult(byte(sResponse[5])and$0F,[fc2UserData]);
            if Result<>ieceUserData then exit;
            if(pDst<>nil)and(iDstSize<SizeOf(TLDU))then begin Result:=ceBufferSize; exit; end;
            CopyMemory(pDst,@sResponse[5],Length(sResponse)-6);
          end;
        end;
      else Result:=ieceControlFunctionCode; exit; end; // ������ �������������� ���� �� ������ ��� ����
    else Result:=ceIncorrectRequest; exit; end;
  except Result:=ceSysException; end;
end;

function TIEC103Protocol.IntToHex(i64:Int64; iDigits:integer):AnsiString; var i,iHigh:integer; b:byte; begin
  iHigh:=iDigits div 2-1;
  for i:=0to(iHigh+1)div 2-1do begin b:=pbyte(integer(@i64)+i)^; pbyte(integer(@i64)+i)^:=pbyte(integer(@i64)+iHigh-i)^; pbyte(integer(@i64)+iHigh-i)^:=b; end;
  Result:=SysUtils.IntToHex(i64,iDigits);
end;

function TIEC103Protocol.IsBroadcastRequest(const sRequest:AnsiString):boolean;
begin Result:=(Length(sRequest)=4){(sRequest<>'')}and(sRequest[1]=#$10)and(byte(sRequest[2])and$0F=fc1UserBroadcast); end;

function TIEC103Protocol.IsResponseSuccess(const ce:integer):boolean; begin
  Result:=ce in[iecePosAck,ieceNegAck,ieceBroadCast,ieceUserData,ieceNoUserData,ieceChannelState,
    ieceServiceUnavailable,ieceServiceUnimplemented];
end;

function TIEC103Protocol.MakePacket(const sHexBody:AnsiString):AnsiString; var cs:AnsiString; len:integer;
const sFormat='����� ���� (%d) ����� ���������� ����� ��������� ������������ ������ (%d)'; begin
  len:=Length(sHexBody)div 2; if len=1then begin Result:=inherited MakePacket(sHexBody); exit; end; // ��������� ������
  cs:=IntToHex(byte(CheckSum_CalculateLRC(Text_Hex2String(sHexBody))),2);
  if len=2then Result:='10'+sHexBody+cs+'16' // ���� ������������� �����
  else if len>integer(flwMaxPacketSize-6)then raise EqCDKexception.Create(Format(sFormat,[len,flwMaxPacketSize],gfs))
    else Result:='68'+IntToHex(len,2)+IntToHex(len,2)+'68'+sHexBody+cs+'16';
  Result:=Text_Hex2String(Result);
end;

function TIEC103Protocol.MakeRequest(arrPacketData:array of Int64):AnsiString; var iece,ndx:integer;
const sFormat='������ ������������ ������� � ������� %d: %s';
begin iece:=MakeRequest(arrPacketData,Result,ndx);
  if iece<>ceSuccess then raise EqCDKexception.Create(Format(sFormat,[ndx,GetErrorAsText(iece)],gfs));
end;

// LinkControlField,LinkAddress,TypeIdentification,VariableStructureQualifier,CauseOfTransmission,ASDUAddress,FunctionType,InformationNumber,InformationElements
function TIEC103Protocol.MakeRequest(arrPacketData:array of Int64; out sRequest:AnsiString; out ndxError:integer):integer;
  const ndxLinkControlField=0; ndxLinkAddress=1;
    ndxTypeIdentification=2; ndxVariableStructureQualifier=3; ndxCauseOfTransmission=4;
    ndxASDUAddress=5; ndxFunctionType=6; ndxInformationNumber=7;
    ndxCP56Time2a=8;
    ndxSCN=8;
    ndxDCO=8; ndxRII=9;
    ndxTOO=8; ndxTOV=9; ndxFAN=10; ndxACC=11;
  procedure MakeASDU; var i:integer; begin Result:=ceSuccess;
    if Length(arrPacketData)<ndxTypeIdentification+1then begin Result:=ieceTypeIdentification; ndxError:=ndxTypeIdentification; exit; end;
    if Length(arrPacketData)<ndxVariableStructureQualifier+1then begin Result:=ieceVariableStructureQualifier; ndxError:=ndxVariableStructureQualifier; exit; end;
    if Length(arrPacketData)<ndxCauseOfTransmission+1then begin Result:=ieceCauseOfTransmission; ndxError:=ndxCauseOfTransmission; exit; end;
    if Length(arrPacketData)<ndxASDUAddress+1then begin Result:=ieceASDUAddress; ndxError:=ndxASDUAddress; exit; end;
    if Length(arrPacketData)<ndxFunctionType+1then begin Result:=ieceFunctionType; ndxError:=ndxFunctionType; exit; end;
    if Length(arrPacketData)<ndxInformationNumber+1then begin Result:=ieceInformationNumber; ndxError:=ndxInformationNumber; exit; end;
    arrPacketData[ndxTypeIdentification]:=byte(arrPacketData[ndxTypeIdentification]);
    arrPacketData[ndxVariableStructureQualifier]:=byte(arrPacketData[ndxVariableStructureQualifier]);
    arrPacketData[ndxCauseOfTransmission]:=byte(arrPacketData[ndxCauseOfTransmission]);
    arrPacketData[ndxASDUAddress]:=byte(arrPacketData[ndxASDUAddress]);
    arrPacketData[ndxFunctionType]:=byte(arrPacketData[ndxFunctionType]);
    arrPacketData[ndxInformationNumber]:=byte(arrPacketData[ndxInformationNumber]);
    case arrPacketData[ndxTypeIdentification]of
      // LinkControlField,LinkAddress,ti1TimeSynchronization,VSQ=0x81,COT=cot1TimeSynchronization,ASDUAddress,FT=0xFF,IN=0x00,CP56Time2a=1,1,1,1,1,1,1,1,7
      ti1TimeSynchronization: begin // ������������� �������
        if Length(arrPacketData)<ndxCP56Time2a+1then begin Result:=ieceCP56Time2a; ndxError:=ndxCP56Time2a; exit; end;
        arrPacketData[ndxVariableStructureQualifier]:=$81; arrPacketData[ndxCauseOfTransmission]:=cot1TimeSynchronization;
        arrPacketData[ndxFunctionType]:=$FF; arrPacketData[ndxInformationNumber]:=$00;
        arrPacketData[ndxCP56Time2a]:=arrPacketData[ndxCP56Time2a]and$0FFFFFFFFFFFFFFF;
        for i:=ndxTypeIdentification to ndxInformationNumber do sRequest:=sRequest+IntToHex(arrPacketData[i],2);
        sRequest:=sRequest+IntToHex(arrPacketData[ndxCP56Time2a],14);
      end;
      // LinkControlField,LinkAddress,ti1GeneralInterrogation,VSQ=0x81,COT=cot1GeneralInterrogation,ASDUAddress,FT=0xFF,IN=0x00,SCN=1,1,1,1,1,1,1,1,1
      ti1GeneralInterrogation: begin // ����� �����
        if Length(arrPacketData)<ndxSCN+1then begin Result:=ieceSCN; ndxError:=ndxSCN; exit; end;
        arrPacketData[ndxVariableStructureQualifier]:=$81; arrPacketData[ndxCauseOfTransmission]:=cot1GeneralInterrogation;
        arrPacketData[ndxFunctionType]:=$FF; arrPacketData[ndxInformationNumber]:=$00;
        arrPacketData[ndxSCN]:=byte(arrPacketData[ndxSCN]);
        for i:=ndxTypeIdentification to ndxSCN do sRequest:=sRequest+IntToHex(arrPacketData[i],2);
      end;

//      ti1GenericInfo=10;                    // ��������� ����������

      // LinkControlField,LinkAddress,ti1GeneralCommand,VSQ=0x81,COT=cot1GeneralCommand,ASDUAddress,FT,IN,DCO,RII=1,1,1,1,1,1,1,1,1,1
      ti1GeneralCommand: begin // ����� �������
        if Length(arrPacketData)<ndxDCO+1then begin Result:=ieceDCO; ndxError:=ndxDCO; exit; end;
        arrPacketData[ndxDCO]:=arrPacketData[ndxDCO]and$03;
//        if(arrPacketData[ndxDCO]<>1)and(arrPacketData[ndxDCO]<>2)then begin Result:=ieceDCOinvalid; ndxError:=ndxDCO; exit; end;
        if Length(arrPacketData)<ndxRII+1then begin Result:=ieceRII; ndxError:=ndxRII; exit; end;
        arrPacketData[ndxVariableStructureQualifier]:=$81; arrPacketData[ndxCauseOfTransmission]:=cot1GeneralCommand;
        arrPacketData[ndxRII]:=byte(arrPacketData[ndxRII]);
        for i:=ndxTypeIdentification to ndxRII do sRequest:=sRequest+IntToHex(arrPacketData[i],2);
      end;

//      ti1GenericCommand=21;                 // ��������� �������

      // LinkControlField,LinkAddress,ti1FaultRequest,VSQ=0x81,COT=cot1FaultTransmission,ASDUAddress,FT,IN=0x00,TOO,TOV,FAN,ACC=1,1,1,1,1,1,1,1,1,1,2,1
      // LinkControlField,LinkAddress,ti1FaultAcknowledge,VSQ=0x81,COT=cot1FaultTransmission,ASDUAddress,FT,IN=0x00,TOO,TOV,FAN,ACC=1,1,1,1,1,1,1,1,1,1,2,1
      ti1FaultOrder,ti1FaultAcknowledge: begin // TOO 0..31 - FaultRequest, 64..95 - ��� FaultAcknowledge
        if Length(arrPacketData)<ndxTOO+1then begin Result:=ieceTOO; ndxError:=ndxTOO; exit; end;
        if Length(arrPacketData)<ndxTOV+1then begin Result:=ieceTOV; ndxError:=ndxTOV; exit; end;
        if Length(arrPacketData)<ndxFAN+1then begin Result:=ieceFAN; ndxError:=ndxFAN; exit; end;
        if Length(arrPacketData)<ndxACC+1then begin Result:=ieceACC; ndxError:=ndxACC; exit; end;
        arrPacketData[ndxTOO]:=byte(arrPacketData[ndxTOO]); arrPacketData[ndxTOV]:=byte(arrPacketData[ndxTOV]);
        arrPacketData[ndxFAN]:=word(arrPacketData[ndxFAN]); arrPacketData[ndxACC]:=byte(arrPacketData[ndxACC]);
        for i:=ndxTypeIdentification to ndxTOV do sRequest:=sRequest+IntToHex(arrPacketData[i],2);
        sRequest:=sRequest+IntToHex(arrPacketData[ndxFAN],4)+IntToHex(arrPacketData[ndxACC],2);
      end;
    else Result:=ieceTypeIdentificationUnknown; ndxError:=ndxTypeIdentification; exit; end;    
  end;
begin sRequest:='';
  if(Length(arrPacketData)=0)then begin Result:=ieceLinkControlField; ndxError:=ndxLinkControlField; exit; end;
  try arrPacketData[ndxLinkControlField]:=LinkControlField1(byte(arrPacketData[ndxLinkControlField]));
  except Result:=ieceLinkControlField; ndxError:=ndxLinkControlField; exit; end;
  if Length(arrPacketData)<ndxLinkAddress+1then begin Result:=ieceLinkAddress; ndxError:=ndxLinkAddress; exit; end;
  arrPacketData[ndxLinkAddress]:=byte(arrPacketData[ndxLinkAddress]);
  sRequest:=IntToHex(arrPacketData[ndxLinkControlField],2)+IntToHex(arrPacketData[ndxLinkAddress],2);
  case arrPacketData[ndxLinkControlField]and$0F of
    fc1ResetCommUnit:;              // ������������� ����
    fc1UserSend:      begin MakeASDU; if Result<>ceSuccess then exit; end;
    fc1UserBroadcast: begin MakeASDU; if Result<>ceSuccess then exit; end;
    fc1ResetFCB:;                   // ������������� ����
    fc1ChannelState:;               // ������������� ����
    fc1Class1:;                     // ������������� ����
    fc1Class2:;                     // ������������� ����
  else Result:=ieceControlFunctionCode; exit; end;
  if Length(sRequest)div 2>integer(flwMaxPacketSize)then begin Result:=ceFrameLength; exit; end;
  sRequest:=MakePacket(sRequest); Result:=ceSuccess;
end;

function TIEC103Protocol.MakeResponse(arrPacketData:array of Int64):AnsiString; var iece,ndx:integer;
const sFormat='������ ������������ ������ � ������� %d: %s';
begin iece:=MakeResponse(arrPacketData,Result,ndx);
  if iece<>ceSuccess then raise EqCDKexception.Create(Format(sFormat,[ndx,GetErrorAsText(iece)],gfs));
end;

function TIEC103Protocol.MakeResponse(arrPacketData:array of Int64; out sResponse:AnsiString; out ndxError:integer):integer;
  const ndxLinkControlField=0; ndxLinkAddress=1;
    ndxTypeIdentification=2; ndxVariableStructureQualifier=3; ndxCauseOfTransmission=4;
    ndxASDUAddress=5; ndxFunctionType=6; ndxInformationNumber=7;
    ndxDPI1=8; ndxCP32Time2a1=9; ndxSIN1=10;
    ndxDPI2=8; ndxRET2=9; ndxFAN2=10; ndxCP32Time2a2=11; ndxSIN2=12;
    ndxSCL4=8; ndxRET4=9; ndxFAN4=10; ndxCP32Time2a4=11;
    ndxCOL=8;
    ndxCP56Time2a6=8;
    ndxSCN=8;
    ndxNullByte26=8; ndxTOV26=9; ndxFAN26=10; ndxNOF26=11; ndxNOC26=12; ndxNOE26=13; ndxINT26=14; ndxCP32Time2a26=15;
    ndxNullByte27=8; ndxTOV27=9; ndxFAN27=10; ndxACC27=11; ndxRPV=12; ndxRSV=13; ndxRFA=14;
    ndxNullByte28_1=8; ndxNullByte28_2=9; ndxFAN28=10;
    ndxFAN29=8; ndxNOT29=9; ndxTAP29=10;
    ndxNullByte30=8; ndxTOV30=9; ndxFAN30=10; ndxACC30=11; ndxNDV30=12; ndxNFE30=13;
    ndxTOO31=8; ndxTOV31=9; ndxFAN31=10; ndxACC31=11;
  procedure MakeASDU; var i:integer; begin Result:=ceSuccess;
    if Length(arrPacketData)<ndxTypeIdentification+1then begin Result:=ieceTypeIdentification; ndxError:=ndxTypeIdentification; exit; end;
    if Length(arrPacketData)<ndxVariableStructureQualifier+1then begin Result:=ieceVariableStructureQualifier; ndxError:=ndxVariableStructureQualifier; exit; end;
    if Length(arrPacketData)<ndxCauseOfTransmission+1then begin Result:=ieceCauseOfTransmission; ndxError:=ndxCauseOfTransmission; exit; end;
    if Length(arrPacketData)<ndxASDUAddress+1then begin Result:=ieceASDUAddress; ndxError:=ndxASDUAddress; exit; end;
    if Length(arrPacketData)<ndxFunctionType+1then begin Result:=ieceFunctionType; ndxError:=ndxFunctionType; exit; end;
    if Length(arrPacketData)<ndxInformationNumber+1then begin Result:=ieceInformationNumber; ndxError:=ndxInformationNumber; exit; end;
    arrPacketData[ndxTypeIdentification]:=byte(arrPacketData[ndxTypeIdentification]);
    arrPacketData[ndxVariableStructureQualifier]:=byte(arrPacketData[ndxVariableStructureQualifier]);
    arrPacketData[ndxCauseOfTransmission]:=byte(arrPacketData[ndxCauseOfTransmission]);
    arrPacketData[ndxASDUAddress]:=byte(arrPacketData[ndxASDUAddress]);
    arrPacketData[ndxFunctionType]:=byte(arrPacketData[ndxFunctionType]);
    arrPacketData[ndxInformationNumber]:=byte(arrPacketData[ndxInformationNumber]);
    case arrPacketData[ndxTypeIdentification]of
      //LCF,LA,ti2TimeTag,VSQ=0x81,COT,ASDUAddress,FT,IN,DPI,CP32Time2a,SIN=1,1,1,1,1,1,1,1,1,4,1
      ti2TimeTag: begin
        arrPacketData[ndxVariableStructureQualifier]:=$81;
        if Length(arrPacketData)<ndxDPI1+1then begin Result:=ieceDPI; ndxError:=ndxDPI1; exit; end;
        if Length(arrPacketData)<ndxCP32Time2a1+1then begin Result:=ieceCP32Time2a; ndxError:=ndxCP32Time2a1; exit; end;
        if Length(arrPacketData)<ndxSIN1+1then begin Result:=ieceSIN; ndxError:=ndxSIN1; exit; end;
        arrPacketData[ndxDPI1]:=arrPacketData[ndxDPI1]and$03; arrPacketData[ndxCP32Time2a1]:=LongWord(arrPacketData[ndxCP32Time2a1]);
        arrPacketData[ndxSIN1]:=byte(arrPacketData[ndxSIN1]);
        for i:=ndxTypeIdentification to ndxDPI1 do sResponse:=sResponse+IntToHex(arrPacketData[i],2);
        sResponse:=sResponse+IntToHex(arrPacketData[ndxCP32Time2a1],8)+IntToHex(arrPacketData[ndxSIN1],2);
      end;
      //LCF,LA,ti2RelativeTimeTag,VSQ=0x81,COT,ASDUAddress,FT,IN,DPI,RET,FAN,CP32Time2a,SIN=1,1,1,1,1,1,1,1,1,2,2,4,1
      ti2RelativeTimeTag: begin
        arrPacketData[ndxVariableStructureQualifier]:=$81;
        if Length(arrPacketData)<ndxDPI2+1then begin Result:=ieceDPI; ndxError:=ndxDPI2; exit; end;
        if Length(arrPacketData)<ndxRET2+1then begin Result:=ieceRET; ndxError:=ndxRET2; exit; end;
        if Length(arrPacketData)<ndxFAN2+1then begin Result:=ieceFAN; ndxError:=ndxFAN2; exit; end;
        if Length(arrPacketData)<ndxCP32Time2a2+1then begin Result:=ieceCP32Time2a; ndxError:=ndxCP32Time2a2; exit; end;
        if Length(arrPacketData)<ndxSIN2+1then begin Result:=ieceSIN; ndxError:=ndxSIN2; exit; end;
        arrPacketData[ndxDPI2]:=arrPacketData[ndxDPI2]and$03; arrPacketData[ndxRET2]:=word(arrPacketData[ndxRET2]);
        arrPacketData[ndxFAN2]:=word(arrPacketData[ndxFAN2]); arrPacketData[ndxCP32Time2a2]:=LongWord(arrPacketData[ndxCP32Time2a2]);
        arrPacketData[ndxSIN2]:=byte(arrPacketData[ndxSIN2]);
        for i:=ndxTypeIdentification to ndxDPI2 do sResponse:=sResponse+IntToHex(arrPacketData[i],2);
        sResponse:=sResponse+IntToHex(arrPacketData[ndxRET2],4)+IntToHex(arrPacketData[ndxFAN2],4)+
          IntToHex(arrPacketData[ndxCP32Time2a2],8)+IntToHex(arrPacketData[ndxSIN2],2);
      end;
      //LCF,LA,ti2MeasuredValues1,VSQ=VSQ and 0x7F,COT,ASDUAddress,FT,IN,MEA[,MEA,...,MEA]=1,1,1,1,1,1,1,1,2,[2,...,2]
      //LCF,LA,ti2MeasuredValues2,VSQ=VSQ and 0x7F,COT,ASDUAddress,FT,IN,MEA[,MEA,...,MEA]=1,1,1,1,1,1,1,1,2,[2,...,2]
      ti2MeasuredValues1,ti2MeasuredValues2: begin
        arrPacketData[ndxVariableStructureQualifier]:=arrPacketData[ndxVariableStructureQualifier]and$7F;
        i:=arrPacketData[ndxVariableStructureQualifier]; // ����� ���������� �������
        if Length(arrPacketData)<ndxInformationNumber+i+1then begin Result:=ieceMEA; ndxError:=Length(arrPacketData); exit; end;
        for i:=ndxTypeIdentification to ndxInformationNumber do sResponse:=sResponse+IntToHex(arrPacketData[i],2);
        for i:=ndxInformationNumber+1to ndxInformationNumber+arrPacketData[ndxVariableStructureQualifier]do
          sResponse:=sResponse+IntToHex(arrPacketData[i],4);
      end;
      //LCF,LA,ti2ShortCircuitLocation,VSQ=0x81,COT,ASDUAddress,FT,IN,SCL,RET,FAN,CP32Time2a=1,1,1,1,1,1,1,1,4,2,2,4
      ti2ShortCircuitLocation: begin
        arrPacketData[ndxVariableStructureQualifier]:=$81;
        if Length(arrPacketData)<ndxSCL4+1then begin Result:=ieceSCL; ndxError:=ndxSCL4; exit; end;
        if Length(arrPacketData)<ndxRET4+1then begin Result:=ieceRET; ndxError:=ndxRET4; exit; end;
        if Length(arrPacketData)<ndxFAN4+1then begin Result:=ieceFAN; ndxError:=ndxFAN4; exit; end;
        if Length(arrPacketData)<ndxCP32Time2a4+1then begin Result:=ieceCP32Time2a; ndxError:=ndxCP32Time2a4; exit; end;
        arrPacketData[ndxSCL4]:=LongWord(arrPacketData[ndxSCL4]); arrPacketData[ndxRET4]:=word(arrPacketData[ndxRET4]);
        arrPacketData[ndxFAN4]:=word(arrPacketData[ndxFAN4]); arrPacketData[ndxCP32Time2a4]:=LongWord(arrPacketData[ndxCP32Time2a4]);
        for i:=ndxTypeIdentification to ndxInformationNumber do sResponse:=sResponse+IntToHex(arrPacketData[i],2);
        sResponse:=sResponse+IntToHex(arrPacketData[ndxSCL4],8)+IntToHex(arrPacketData[ndxRET4],4)+IntToHex(arrPacketData[ndxFAN4],4)+
          IntToHex(arrPacketData[ndxCP32Time2a2],8);
      end;
      //LCF,LA,ti2IdentificationInfo,VSQ=0x81,COT,ASDUAddress,FT,IN,COL,ASC,ASC,ASC,ASC,ASC,ASC,ASC,ASC,byte,byte,byte,byte=1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
      ti2IdentificationInfo: begin
        arrPacketData[ndxVariableStructureQualifier]:=$81;
        case arrPacketData[ndxCauseOfTransmission]of
          cot2ResetFCB:         arrPacketData[ndxInformationNumber]:=cot2ResetFCB-1;
          cot2ResetCommUnit:    arrPacketData[ndxInformationNumber]:=cot2ResetCommUnit-1;
          cot2StartRestart:     arrPacketData[ndxInformationNumber]:=cot2StartRestart-1;
          cot2PowerOn:          arrPacketData[ndxInformationNumber]:=cot2PowerOn-1;
        end;
        if Length(arrPacketData)<ndxCOL+1then begin Result:=ieceCOL; ndxError:=ndxCOL; exit; end;
        if Length(arrPacketData)<ndxCOL+8+1then begin Result:=ieceASC; ndxError:=Length(arrPacketData); exit; end;
        if Length(arrPacketData)<ndxCOL+8+4+1then begin Result:=ieceSoftwareID; ndxError:=Length(arrPacketData); exit; end;
        for i:=ndxTypeIdentification to ndxCol+12do arrPacketData[i]:=byte(arrPacketData[i]);
        for i:=ndxTypeIdentification to ndxCol+12do sResponse:=sResponse+IntToHex(arrPacketData[i],2);
      end;
      //LCF,LA,ti2TimeSynchronization,VSQ=0x81,COT=cot2TimeSynchronization,ASDUAddress,FT=0xFF,IN=0x00,CP56Time2a=1,1,1,1,1,1,1,1,7
      ti2TimeSynchronization: begin
        if Length(arrPacketData)<ndxCP56Time2a6+1then begin Result:=ieceCP56Time2a; ndxError:=ndxCP56Time2a6; exit; end;
        arrPacketData[ndxVariableStructureQualifier]:=$81; arrPacketData[ndxCauseOfTransmission]:=cot2TimeSynchronization;
        arrPacketData[ndxFunctionType]:=$FF; arrPacketData[ndxInformationNumber]:=$00;
        arrPacketData[ndxCP56Time2a6]:=arrPacketData[ndxCP56Time2a6]and$0FFFFFFFFFFFFFFF;
        for i:=ndxTypeIdentification to ndxInformationNumber do sResponse:=sResponse+IntToHex(arrPacketData[i],2);
        sResponse:=sResponse+IntToHex(arrPacketData[ndxCP56Time2a6],14);
      end;
      //LCF,LA,ti2GeneralInterrogationTermination,VSQ=0x81,COT=cot2GeneralInterrogationTermination,ASDUAddress,FT=0xFF,IN=0x00,SCN=1,1,1,1,1,1,1,1,1
      ti2GeneralInterrogationTermination: begin
        if Length(arrPacketData)<ndxSCN+1then begin Result:=ieceSCN; ndxError:=ndxSCN; exit; end;
        arrPacketData[ndxVariableStructureQualifier]:=$81; arrPacketData[ndxCauseOfTransmission]:=cot2GeneralInterrogationTermination;
        arrPacketData[ndxFunctionType]:=$FF; arrPacketData[ndxInformationNumber]:=$00;
        arrPacketData[ndxSCN]:=byte(arrPacketData[ndxSCN]);
        for i:=ndxTypeIdentification to ndxSCN do sResponse:=sResponse+IntToHex(arrPacketData[i],2);
      end;

      // ti2GenericInfo=10;                    // ��������� ����������

      // ti2GenericIdentifier=11;              // ��������� �������������

      //LCF,LA,ti2FaultsList,VSQ=VSQ and 0x7F,COT,ASDUAddress,FT,IN=0x00,{FAN,SOF,CP56Time2a}[,{FAN,SOF,CP56Time2a},...,{FAN,SOF,CP56Time2a}]=1,1,1,1,1,1,1,1,{2,1,7}[,{2,1,7},...,{2,1,7}]
      ti2FaultsList: begin // IN �� ���������� � 0 - ����� ������������ ����������
        arrPacketData[ndxVariableStructureQualifier]:=arrPacketData[ndxVariableStructureQualifier]and$7F;
        for i:=ndxTypeIdentification to ndxInformationNumber do sResponse:=sResponse+IntToHex(arrPacketData[i],2);
        i:=arrPacketData[ndxVariableStructureQualifier]; // ����� ������������
        for i:=ndxInformationNumber+1to ndxInformationNumber+i*3do begin
          case(i-ndxInformationNumber-1)mod 3of
            0: if Length(arrPacketData)<i+1then begin Result:=ieceFAN; ndxError:=i; exit; end
            else begin arrPacketData[i]:=word(arrPacketData[i]); sResponse:=sResponse+IntToHex(arrPacketData[i],4); end;
            1: if Length(arrPacketData)<i+1then begin Result:=ieceSOF; ndxError:=i; exit; end
            else begin arrPacketData[i]:=byte(arrPacketData[i]); sResponse:=sResponse+IntToHex(arrPacketData[i],2); end;
            2: if Length(arrPacketData)<i+1then begin Result:=ieceCP56Time2a; ndxError:=i; exit; end
            else begin arrPacketData[i]:=arrPacketData[i]and$0FFFFFFFFFFFFFFF; sResponse:=sResponse+IntToHex(arrPacketData[i],14); end;
          end;
        end;
      end;
      //LCF,LA,ti2FaultDataReady,VSQ=0x81,COT,ASDUAddress,FT,IN=0x00,0x00,TOV,FAN,NOF,NOC,NOE,INT,CP32Time2a=1,1,1,1,1,1,1,1,1,1,2,2,1,2,2,4
      ti2FaultDataReady: begin // IN �� ���������� � 0 - ����� ������������ ����������
        if Length(arrPacketData)<ndxNullByte26+1then begin Result:=ieceNullByte; ndxError:=ndxNullByte26; exit; end;
        if Length(arrPacketData)<ndxTOV26+1then begin Result:=ieceTOV; ndxError:=ndxTOV26; exit; end;
        if Length(arrPacketData)<ndxFAN26+1then begin Result:=ieceFAN; ndxError:=ndxFAN26; exit; end;
        if Length(arrPacketData)<ndxNOF26+1then begin Result:=ieceNOF; ndxError:=ndxNOF26; exit; end;
        if Length(arrPacketData)<ndxNOC26+1then begin Result:=ieceNOC; ndxError:=ndxNOC26; exit; end;
        if Length(arrPacketData)<ndxNOE26+1then begin Result:=ieceNOE; ndxError:=ndxNOE26; exit; end;
        if Length(arrPacketData)<ndxINT26+1then begin Result:=ieceINT; ndxError:=ndxINT26; exit; end;
        if Length(arrPacketData)<ndxCP32Time2a26+1then begin Result:=ieceCP32Time2a; ndxError:=ndxCP32Time2a26; exit; end;
        arrPacketData[ndxVariableStructureQualifier]:=$81;
        arrPacketData[ndxNullByte26]:=$00; arrPacketData[ndxTOV26]:=byte(arrPacketData[ndxTOV26]);
        arrPacketData[ndxFAN26]:=word(arrPacketData[ndxFAN26]); arrPacketData[ndxNOF26]:=word(arrPacketData[ndxNOF26]);
        arrPacketData[ndxNOC26]:=byte(arrPacketData[ndxNOC26]); arrPacketData[ndxNOE26]:=word(arrPacketData[ndxNOE26]);
        arrPacketData[ndxINT26]:=word(arrPacketData[ndxINT26]); arrPacketData[ndxCP32Time2a26]:=longword(arrPacketData[ndxCP32Time2a26]);
        for i:=ndxTypeIdentification to ndxTOV26 do sResponse:=sResponse+IntToHex(arrPacketData[i],2);
        sResponse:=sResponse+IntToHex(arrPacketData[ndxFAN26],4)+IntToHex(arrPacketData[ndxNOF26],4)
          +IntToHex(arrPacketData[ndxNOC26],2)+IntToHex(arrPacketData[ndxNOE26],4)+IntToHex(arrPacketData[ndxINT26],4)
          +IntToHex(arrPacketData[ndxCP32Time2a26],8);
      end;
      //LCF,LA,ti2FaultChannelReady,VSQ=0x81,COT,ASDUAddress,FT,IN=0x00,0x00,TOV,FAN,ACC,RPV,RSV,RFA=1,1,1,1,1,1,1,1,1,1,2,1,4,4,4
      ti2FaultChannelReady: begin // IN �� ���������� � 0 - ����� ������������ ����������
        if Length(arrPacketData)<ndxNullByte27+1then begin Result:=ieceNullByte; ndxError:=ndxNullByte27; exit; end;
        if Length(arrPacketData)<ndxTOV27+1then begin Result:=ieceTOV; ndxError:=ndxTOV27; exit; end;
        if Length(arrPacketData)<ndxFAN27+1then begin Result:=ieceFAN; ndxError:=ndxFAN27; exit; end;
        if Length(arrPacketData)<ndxACC27+1then begin Result:=ieceACC; ndxError:=ndxACC27; exit; end;
        if Length(arrPacketData)<ndxRPV+1then begin Result:=ieceRPV; ndxError:=ndxRPV; exit; end;
        if Length(arrPacketData)<ndxRSV+1then begin Result:=ieceRSV; ndxError:=ndxRSV; exit; end;
        if Length(arrPacketData)<ndxRFA+1then begin Result:=ieceRFA; ndxError:=ndxRFA; exit; end;
        arrPacketData[ndxVariableStructureQualifier]:=$81;
        arrPacketData[ndxNullByte27]:=$00; arrPacketData[ndxTOV27]:=byte(arrPacketData[ndxTOV27]);
        arrPacketData[ndxFAN27]:=word(arrPacketData[ndxFAN27]); arrPacketData[ndxACC27]:=byte(arrPacketData[ndxACC27]);
        arrPacketData[ndxRPV]:=word(arrPacketData[ndxRPV]); arrPacketData[ndxRSV]:=word(arrPacketData[ndxRSV]);
        arrPacketData[ndxRFA]:=word(arrPacketData[ndxRFA]);
        for i:=ndxTypeIdentification to ndxTOV27 do sResponse:=sResponse+IntToHex(arrPacketData[i],2);
        sResponse:=sResponse+IntToHex(arrPacketData[ndxFAN27],4)+IntToHex(arrPacketData[ndxACC27],2)
          +IntToHex(arrPacketData[ndxRPV],4)+IntToHex(arrPacketData[ndxRSV],4)+IntToHex(arrPacketData[ndxRFA],4);
      end;
      //LCF,LA,ti2FaultTagsReady,VSQ=0x81,COT,ASDUAddress,FT,IN=0x00,0x00,0x00,FAN=1,1,1,1,1,1,1,1,1,1,2
      ti2FaultTagsReady: begin // IN �� ���������� � 0 - ����� ������������ ����������
        if Length(arrPacketData)<ndxNullByte28_1+1then begin Result:=ieceNullByte; ndxError:=ndxNullByte28_1; exit; end;
        if Length(arrPacketData)<ndxNullByte28_2+1then begin Result:=ieceNullByte; ndxError:=ndxNullByte28_2; exit; end;
        if Length(arrPacketData)<ndxFAN28+1then begin Result:=ieceFAN; ndxError:=ndxFAN28; exit; end;
        arrPacketData[ndxVariableStructureQualifier]:=$81;
        arrPacketData[ndxNullByte28_1]:=$00; arrPacketData[ndxNullByte28_2]:=$00;
        arrPacketData[ndxFAN28]:=word(arrPacketData[ndxFAN28]);
        for i:=ndxTypeIdentification to ndxNullByte28_2 do sResponse:=sResponse+IntToHex(arrPacketData[i],2);
        sResponse:=sResponse+IntToHex(arrPacketData[ndxFAN28],4);
      end;
      //LCF,LA,ti2FaultTagsTransimission,VSQ=0x81,COT,ASDUAddress,FT,IN=0x00,FAN,NOT,TAP,{FT,IN,DPI}[,{FT,IN,DPI},...,{FT,IN,DPI}]=1,1,1,1,1,1,1,1,2,1,2,{1,1,1}[,{1,1,1},...,{1,1,1}]
      ti2FaultTagsTransmission: begin // IN �� ���������� � 0 - ����� ������������ ����������
        if Length(arrPacketData)<ndxFAN29+1then begin Result:=ieceFAN; ndxError:=ndxFAN29; exit; end;
        if Length(arrPacketData)<ndxNOT29+1then begin Result:=ieceNOT; ndxError:=ndxNOT29; exit; end;
        if Length(arrPacketData)<ndxTAP29+1then begin Result:=ieceTAP; ndxError:=ndxTAP29; exit; end;
        arrPacketData[ndxVariableStructureQualifier]:=$81;
        arrPacketData[ndxFAN29]:=word(arrPacketData[ndxFAN29]); arrPacketData[ndxNOT29]:=byte(arrPacketData[ndxNOT29]);
        arrPacketData[ndxTAP29]:=word(arrPacketData[ndxTAP29]);
        for i:=ndxTypeIdentification to ndxInformationNumber do sResponse:=sResponse+IntToHex(arrPacketData[i],2);
        i:=arrPacketData[ndxNOT29]; // ����� �����
        for i:=ndxTAP29+1to ndxTAP29+i*3do begin
          case(i-ndxInformationNumber-1)mod 3of
            0: if Length(arrPacketData)<i+1then begin Result:=ieceFunctionType; ndxError:=i; exit; end
            else begin arrPacketData[i]:=word(arrPacketData[i]); sResponse:=sResponse+IntToHex(arrPacketData[i],2); end;
            1: if Length(arrPacketData)<i+1then begin Result:=ieceInformationNumber; ndxError:=i; exit; end
            else begin arrPacketData[i]:=byte(arrPacketData[i]); sResponse:=sResponse+IntToHex(arrPacketData[i],2); end;
            2: if Length(arrPacketData)<i+1then begin Result:=ieceDPI; ndxError:=i; exit; end
            else begin arrPacketData[i]:=arrPacketData[i]and$03; sResponse:=sResponse+IntToHex(arrPacketData[i],2); end;
          end;
        end;
      end;
      //LCF,LA,ti2FaultValuesTransmission,VSQ=0x81,COT,ASDUAddress,FT,IN=0x00,0x00,TOV,FAN,ACC,NDV,NFE,SDV[,SDV,...,SDV]=1,1,1,1,1,1,1,1,1,1,2,1,1,2,2[,2,..2]
      ti2FaultValuesTransmission: begin // IN �� ���������� � 0 - ����� ������������ ����������
        if Length(arrPacketData)<ndxNullByte30+1then begin Result:=ieceNullByte; ndxError:=ndxNullByte30; exit; end;
        if Length(arrPacketData)<ndxTOV30+1then begin Result:=ieceTOV; ndxError:=ndxTOV30; exit; end;
        if Length(arrPacketData)<ndxFAN30+1then begin Result:=ieceFAN; ndxError:=ndxFAN30; exit; end;
        if Length(arrPacketData)<ndxACC30+1then begin Result:=ieceACC; ndxError:=ndxACC30; exit; end;
        if Length(arrPacketData)<ndxNDV30+1then begin Result:=ieceNDV; ndxError:=ndxNDV30; exit; end;
        if Length(arrPacketData)<ndxNFE30+1then begin Result:=ieceNFE; ndxError:=ndxNFE30; exit; end;
        arrPacketData[ndxVariableStructureQualifier]:=$81; arrPacketData[ndxNullByte30]:=$00;
        arrPacketData[ndxTOV30]:=byte(arrPacketData[ndxTOV30]); arrPacketData[ndxFAN30]:=word(arrPacketData[ndxFAN30]);
        arrPacketData[ndxACC30]:=byte(arrPacketData[ndxACC30]); arrPacketData[ndxNDV30]:=byte(arrPacketData[ndxNDV30]);
        arrPacketData[ndxNFE30]:=word(arrPacketData[ndxNFE30]);
        i:=arrPacketData[ndxNDV30]; // ����� ��������� ��������
        if Length(arrPacketData)<ndxNFE30+i+1then begin Result:=ieceSDV; ndxError:=Length(arrPacketData); exit; end;
        for i:=ndxTypeIdentification to ndxTOV30 do sResponse:=sResponse+IntToHex(arrPacketData[i],2);
        sResponse:=sResponse+IntToHex(arrPacketData[ndxFAN30],4)+IntToHex(arrPacketData[ndxACC30],2)
          +IntToHex(arrPacketData[ndxNDV30],2)+IntToHex(arrPacketData[ndxNFE30],4);
        for i:=ndxNFE30+1to ndxNFE30+arrPacketData[ndxNDV30]do sResponse:=sResponse+IntToHex(arrPacketData[i],4);
      end;
      //LCF,LA,ti2FaultTransmissionTermination,VSQ=0x81,COT,ASDUAddress,FT,IN=0x00,TOO,TOV,FAN,ACC=1,1,1,1,1,1,1,1,1,1,2,1
      ti2FaultTransmissionTermination: begin // IN �� ���������� � 0 - ����� ������������ ����������
      // TOO 32..64 - ������� �����������
        if Length(arrPacketData)<ndxTOO31+1then begin Result:=ieceTOO; ndxError:=ndxTOO31; exit; end;
        if Length(arrPacketData)<ndxTOV31+1then begin Result:=ieceTOV; ndxError:=ndxTOV31; exit; end;
        if Length(arrPacketData)<ndxFAN31+1then begin Result:=ieceFAN; ndxError:=ndxFAN31; exit; end;
        if Length(arrPacketData)<ndxACC31+1then begin Result:=ieceACC; ndxError:=ndxACC31; exit; end;
        arrPacketData[ndxVariableStructureQualifier]:=$81;
        arrPacketData[ndxTOO31]:=byte(arrPacketData[ndxTOO31]); arrPacketData[ndxTOV31]:=byte(arrPacketData[ndxTOV31]);
        arrPacketData[ndxFAN31]:=word(arrPacketData[ndxFAN31]); arrPacketData[ndxACC31]:=byte(arrPacketData[ndxACC31]);
        for i:=ndxTypeIdentification to ndxTOV31 do sResponse:=sResponse+IntToHex(arrPacketData[i],2);
        sResponse:=sResponse+IntToHex(arrPacketData[ndxFAN31],4)+IntToHex(arrPacketData[ndxACC31],2);
      end;
    else Result:=ieceTypeIdentificationUnknown; ndxError:=ndxTypeIdentification; exit; end;
  end;
begin sResponse:='';
  if(Length(arrPacketData)=0)then begin Result:=ieceLinkControlField; ndxError:=ndxLinkControlField; exit; end;
  if arrPacketData[ndxLinkControlField]=$E5then // ��������� ������
    begin sResponse:=IntToHex(arrPacketData[ndxLinkControlField],2); Result:=ceSuccess; exit; end;
  try arrPacketData[ndxLinkControlField]:=LinkControlField2(byte(arrPacketData[ndxLinkControlField]));
  except Result:=ieceLinkControlField; ndxError:=ndxLinkControlField; exit; end;
  if Length(arrPacketData)<ndxLinkAddress+1then begin Result:=ieceLinkAddress; ndxError:=ndxLinkAddress; exit; end;
  arrPacketData[ndxLinkAddress]:=byte(arrPacketData[ndxLinkAddress]);
  sResponse:=IntToHex(arrPacketData[ndxLinkControlField],2)+IntToHex(arrPacketData[ndxLinkAddress],2);
  case arrPacketData[ndxLinkControlField]and$0F of
    fc2PosAck:;                     // ������������� ����
    fc2NegAck:;                     // ������������� ����
    fc2UserData:    begin MakeASDU; if Result<>ceSuccess then exit; end;
    fc2NoUserData:;                 // ������������� ����
    fc2ChannelState:;               // ������������� ����
    fc2ServiceUnavailable:;         // ������������� ����
    fc2ServiceUnimplemented:;       // ������������� ����
  else Result:=ieceControlFunctionCode; exit; end;
  if Length(sResponse)div 2>integer(flwMaxPacketSize)then begin Result:=ceFrameLength; exit; end;
  sResponse:=MakePacket(sResponse); Result:=ceSuccess;
end;

procedure TIEC103Protocol.SetDefault; begin
  try Lock; BeginUpdate;
    inherited SetDefault; // ������ �������� ��� ��������
    fsCaption:='IEC103Protocol_0x'+IntToHex(fhID,8); fsName:=fsCaption; fsDescription:=GetClassCaption;
    flwAddressSize:=1; flwBroadcastAddress:=255; flwMaxPacketSize:=lwMaxPacketSize; fbClearReadnScope:=false; fbFirstFCB:=false; fbUseE5:=false;
  finally EndUpdate; Unlock; end;
end;

{ TIEC103Device }

constructor TIEC103Device.Create; begin
  fCommunicationProtocolClass:=TIEC103Protocol; fCommunicationThreadClass:=TIEC103Thread;
  inherited Create;
end;

function TIEC103Device.DoGetAString(const ndx:integer):AString; begin
  case ndx of
    ndxDeviceName:  Result:=fsDeviceName;
  else Result:=inherited DoGetAString(ndx); end;
end;

function TIEC103Device.DoGetBool(const ndx:integer):Bool64; begin
  case ndx of
    ndxFCB: Result:=Bool64(fbFCB);
  else Result:=inherited DoGetBool(ndx); end;
end;

function TIEC103Device.DoGetUInt(const ndx:integer):UInt64; begin
  case ndx of
    ndxAsduAddress:         Result:=fui8AsduAddress;
    ndxLinkAddress:         Result:=fui8LinkAddress;
    ndxCompatibilityLevel:  Result:=fui8CompatibilityLevel;
    ndxSoftwareID:          Result:=fui32SoftwareID;
  else Result:=inherited DoGetUInt(ndx); end;
end;

procedure TIEC103Device.DoSetBool(const ndx:integer; const b:Bool64); begin
  case ndx of
    ndxFCB: if fbFCB<>Bool1(b)then begin fbFCB:=Bool1(b); Changed; end;
  else inherited DoSetBool(ndx,b); end;
end;

procedure TIEC103Device.DoSetUInt(const ndx:integer; const ui:UInt64); begin
  case ndx of
    ndxAsduAddress: if fui8AsduAddress<>ui then begin fui8AsduAddress:=ui; Changed; end;
    ndxLinkAddress: if fui8LinkAddress<>ui then begin
      if fui8AsduAddress=fui8LinkAddress then fui8AsduAddress:=ui;
      fui8LinkAddress:=ui; Changed;
    end;
  else inherited DoSetUInt(ndx,ui); end;
end;

{ TIEC103Master }

function TIEC103Master.ChannelState:boolean;
begin Result:=Alive; end;

function TIEC103Master.Class1:boolean; var ldu:TLDU; begin Result:=false;
  try Lock; if(cc=nil)or(cp=nil)then exit; // ��� ���������� - ������ ������� �� ������
    fbFCB:=not fbFCB; Result:=iec103Class1(Self,@ldu)=ceSuccess;
    if Result then with rClass1Info do begin LCF2:=ldu._LCF; ProcessASDU(ldu._asdu);
      _bInitialized:=true; _lwLastTicks:=GetTickCount; _lwOrgTicks:=_lwLastTicks;
    end;
  finally Unlock; end;
end;

function TIEC103Master.Class2:boolean; var ldu:TLDU; begin Result:=false;
  try Lock; if(cc=nil)or(cp=nil)then exit; // ��� ���������� - ������ ������� �� ������
    fbFCB:=not fbFCB; Result:=iec103Class2(Self,@ldu)=ceSuccess;
    if Result then with rClass2Info do begin LCF2:=ldu._LCF; ProcessASDU(ldu._asdu);
      _bInitialized:=true; _lwLastTicks:=GetTickCount; _lwOrgTicks:=_lwLastTicks;
    end;
  finally Unlock; end;
end;

function TIEC103Master.DoAlive:integer;
begin Result:=iec103ChannelState(Self); end;

procedure TIEC103Master.DoComtrade; var s,sFile:AnsiString; sl,sl1:TStringList; i,j,dc,ac:integer; e:extended; dpi:tagDPI; cf:TrComtradeFile;
begin sl:=nil; sl1:=nil;
  try Lock;
    with rScopesInfo._rScopesData._ReadingScopeData do try sl:=TStringList.Create; sl1:=TStringList.Create;
      s:=CP32Time2aToStr(_Time32); s:=AnsiReplaceText(s,'.',''); s:=AnsiReplaceText(s,':','');
      s:=Format('FUN_%.2x INF_%.2x FAN_%.5d %s',[_FUN,_INF,_FAN,s],gfs);
      sFile:=s;
      s:=Format('����������: %s, �����:%d, ����������� �����������: 0x%.8x, ��������: ��� 60870-5-103, ������� �������������: %d, ����� ����������� ����: %d',
        [DeviceName,LinkAddress,SoftwareID,CompatibilityLevel,_NOF],gfs);
      sl.Add(s); cf._ComtradeData._Header._sDevice:=DeviceName; cf._ComtradeData._Header._sInfo:=s;
      dc:=Length(_pTagsInfo^); ac:=Length(_pChannelsInfo^);
      sl.Add(Format('%d,%dA,%dD',[dc+ac,ac,dc],gfs));
      with cf._ComtradeData._Configuration do begin _sStationName:=DeviceName; _sStationID:='IEC 60870-5-103';
        _lwAnalogsCount:=ac; _lwDiscretesCount:=dc; SetLength(_AnalogChannels,_lwAnalogsCount); SetLength(_DiscreteChannels,_lwDiscretesCount);
      end;
      for i:=0to ac-1do begin sl.Add(Format('%d,%s,,,%s,%d,%d,0,0,0',[i+1,IntToStr(_pChannelsInfo^[i]._ACC),'',1,0],gfs));
        with cf._ComtradeData._Configuration._AnalogChannels[i]do begin _lwChannelNumber:=i+1; _sChannelID:=IntToStr(_pChannelsInfo^[i]._ACC);
          _sPhase:=''; _sCircuit:=''; _sUnit:=''; _dA:=1; _dB:=0; _dSkew:=0; _dMin:=0; _dMax:=0;
        end;
      end;
      for i:=ac to ac+dc-1do begin sl.Add(Format('%d,%.2x%.2x,0',[i+1,_pTagsInfo^[i-ac]._FUN,_pTagsInfo^[i-ac]._INF],gfs));
        with cf._ComtradeData._Configuration._DiscreteChannels[i-ac]do begin
          _lwChannelNumber:=i+1; _sChannelID:=Format('0x%.2x%.2x',[_pTagsInfo^[i-ac]._FUN,_pTagsInfo^[i-ac]._INF],gfs);
          _bNormalValue:=false;
        end;
      end;
      sl.Add(IntToStr(50)); cf._ComtradeData._Configuration._lwPowerFrequency:=50;
      sl.Add('1'); cf._ComtradeData._Configuration._lwRatesCount:=1;
      sl.Add(IntToStr(Round(1000000/_INT{800}))+','+IntToStr(_NOE));
      with cf._ComtradeData do begin SetLength(_Configuration._Rates,1); _Configuration._Rates[0]._lwSamplingRate:=Round(1000000/_INT);
        _Configuration._Rates[0]._lwSampleOrgNumber:=1; _Configuration._Rates[0]._lwSampleEndNumber:=_NOE;
      end;
  //    sl.Add(Format('dd/mm/yy,hh:nn:ss.zz',[],gfs));
      TCP32Time2a(@_Time32).IV:=0; TCP32Time2a(@_Time32).SU:=0;
      sl.Add(Format('07/05/15,%s',[CP32Time2aToStr(_Time32)],gfs)); // ����� �����
      sl.Add(Format('07/05/15,%s',[CP32Time2aToStr(_Time32)],gfs));
      sl.Add('ASCII');
      sl.SaveToFile(sFile+'.cfg');

      sl.Clear; DecimalSeparator:='.';
      for i:=0to 3do begin s:='';
        for j:=0to High(_pChannelsInfo^)do with _pChannelsInfo^[j]do begin e:=2.4;
          case i of
            0: if(not IsNan(e))and(e<>0)then s:=s+FloatToStrF(e,ffGeneral,15,5)+','
              else s:=s+FloatToStrF(1,ffGeneral,15,5)+',';
            1: s:=s+FloatToStrF((_RPV)/($8000*_RFA*_RSV),ffGeneral,15,5)+',';
            2: s:=s+FloatToStrF(1/($8000*_RFA),ffGeneral,15,5)+',';
            3: s:=s+FloatToStrF(1,ffGeneral,15,5)+',';
          end;
        end;
        SetLength(s,Length(s)-1); sl.Add(s);
      end;
      SetLength(s,Length(s)-1); s:='coefficients='+sl.CommaText; sl1.Add(s);

      sl.Clear;
      for i:=0to 3do begin s:='';
        for j:=0to High(_pChannelsInfo^)do with _pChannelsInfo^[j]do begin
          case i of
            0: s:=s+'_�,';
            1: s:=s+IntToStr(_ACC)+'_1,';
            2: s:=s+IntToStr(_ACC)+'_2,';
            3: s:=s+'��������,';
          end;
        end;
        SetLength(s,Length(s)-1); sl.Add(s);
      end;
      SetLength(s,Length(s)-1); s:='units="'+sl.CommaText+'"'; sl1.Add(s);
      sl1.SaveToFile(sFile+'.hdr');

      sl.Clear; //DecimalSeparator:='';
      SetLength(cf._ComtradeData._Data,_NOE);
      for i:=0to _NOE-1do begin s:=IntToStr(i)+','+IntToStr(_INT*i);
        cf._ComtradeData._Data[i]._lwSampleNumber:=i+1; cf._ComtradeData._Data[i]._lwSampleTime:=_INT*i;
        SetLength(cf._ComtradeData._Data[i]._AnalogValues,ac);
        for j:=0to ac-1do begin s:=s+','+FloatToStr(_pChannelsInfo^[j]._SDVs[i]{/$8000});
          cf._ComtradeData._Data[i]._AnalogValues[j]:=_pChannelsInfo^[j]._SDVs[i];
        end;
        SetLength(cf._ComtradeData._Data[i]._DiscreteValues,dc);
        for j:=ac to ac+dc-1do with _pTagsInfo^[j-ac]do begin
          if i<Length(_DPIs)then dpi:=_DPIs[i]else dpi:=_DPIs[High(_DPIs)];
          s:=s+','+IntToStr(ord(dpi=2));
          cf._ComtradeData._Data[i]._DiscreteValues[j-ac]:=dpi=2;
  //        if ti._FUN<>0then;
        end;
        sl.Add(s);
      end;
      sl.SaveToFile(sFile+'.dat');

      s:=UTF8ToString(RecordSaveJSON(cf,TypeInfo(TrComtradeFile)));
  //    Dispose(@cf);
  //    ZeroMemory(@cf,SizeOf(cf));
      RecordLoadJSON(cf,PUTF8Char(StringToUTF8(s)),TypeInfo(TrComtradeFile));
      sl.Text:=s; sl.SaveToFile(sFile+'.json');
{      for i:=0to _NOE-1do begin
        SetLength(cd._Data[i]._AnalogValues,0);
        SetLength(cd._Data[i]._DiscreteValues,0);
      end;
      SetLength(cd._Data,0); SetLength(cd._Configuration._AnalogChannels,0);
      SetLength(cd._Configuration._DiscreteChannels,0); SetLength(cd._Configuration._Rates,0);}
    finally sl.Free; sl1.Free; end;
  finally Unlock; end;
//    ShellExecute(0,'open',pchar(ExtractFilePath(Application.ExeName)+'BSV.exe'),pchar('"'+fOscFileName+'_'+IntToStr(fReadOscRec.orFAN)+'.dat"'),nil,SW_SHOW);
end;

function TIEC103Master.DoGetRefreshID:longword;
begin Result:=byte(inherited DoGetRefreshID); end;

function TIEC103Master.DoInitialize:integer; var bFirst:boolean; begin
  try Lock; bFirst:=false; if CommunicationProtocol is TIEC103Protocol then bFirst:=TIEC103Protocol(CommunicationProtocol).FirstFCB;
    Result:=iec103ResetCommUnit(Self); if Result=ceSuccess then fbFCB:=bFirst;
  finally Unlock; end;
end;

function TIEC103Master.DoRefresh:integer; var scn:byte; cnt:integer; begin
  try Lock; with PrRefreshInfo(rRefreshInfo._pData)^do begin scn:=byte(_ID); cnt:=_cnt; end;
    fbFCB:=not fbFCB; Result:=iec103InitializeGI(Self,scn);
  finally Unlock; end;
  if Result=ceSuccess then begin rRefreshInfo._bProcessing:=true;
    DoProgress(ti1GeneralInterrogation,0,0,cnt,0,'����� ����� ��� ������� '+IntToStr(scn),psOpened);
  end;
end;

function TIEC103Master.DoSynchronize:integer;
begin fbFCB:=not fbFCB; Result:=iec103Synchronization(Self); end;

function TIEC103Master.DoSynchronizeBroadcast:integer;
begin Result:=iec103SynchronizationBroadcast(Self); end;

function TIEC103Master.FaultChannelAck:boolean; var ldu:TLDU; iece:integer; begin Result:=false;
  try Lock; if(cc=nil)or(cp=nil)then exit; // ��� ���������� - ������ ������� �� ������
    with rScopesInfo._rScopesData._ReadingScopeData do begin
      if _ss<>ssFaultChannelAck then begin Result:=false; exit; end; // ������ �� ����� ������������� � ��������� ������
      fbFCB:=not fbFCB; iece:=iec103FaultAcknowledge(Self,_FUN,_INF,too1FaultChannelSucces,_FAN,_ACC,@ldu);
      Result:=(iece=ceSuccess);
      if iece=ieceUserData then begin Result:=true; LCF2:=ldu._LCF; ProcessASDU(ldu._asdu); end;
      if not Result then ScopeProgressClose
      else begin _ss:=ssFaultChannelWaiting; _lwReadTicks:=GetTickCount; end; // �������� ����� ������ ������ ������������� - ���� �� ����� ��������
    end;
  finally Unlock; end;
end;

function TIEC103Master.FaultChannelRequest:boolean; var ldu:TLDU; iece:integer; begin Result:=false;
  try Lock; if(cc=nil)or(cp=nil)then exit; // ��� ���������� - ������ ������� �� ������
    with rScopesInfo._rScopesData._ReadingScopeData do begin
      if _ss<>ssFaultChannelRequest then begin Result:=false; exit; end;
      fbFCB:=not fbFCB; iece:=iec103FaultOrder(Self,_FUN,_INF,too1FaultChannelRequest,_FAN,_ACC,@ldu);
      Result:=(iece=ceSuccess);
      if iece=ieceUserData then begin Result:=true; LCF2:=ldu._LCF; ProcessASDU(ldu._asdu); end;
      if not Result then ScopeProgressClose
      else begin _ss:=ssFaultChannelTransmitting; _lwReadTicks:=GetTickCount; end; // �������� ����� ������ ������ ������������� - ���� �� ����� ��������
    end;
  finally Unlock; end;
end;

function TIEC103Master.FaultDataAbort:boolean; var ldu:TLDU; iece:integer; begin Result:=false;
  try Lock; if(cc=nil)or(cp=nil)then exit; // ��� ���������� - ������ ������� �� ������
    with rScopesInfo._rScopesData._ReadingScopeData do begin
      fbFCB:=not fbFCB; iece:=iec103FaultOrder(Self,_FUN,_INF,too1FaultDataAbort,_FAN,_ACC,@ldu);
      Result:=(iece=ceSuccess);
      if iece=ieceUserData then begin Result:=true; LCF2:=ldu._LCF; ProcessASDU(ldu._asdu); end;
    end;
  finally Unlock; end;
end;

function TIEC103Master.FaultDataAck:boolean; var iece,i,j:integer; ldu:TLDU; begin Result:=false;
  try Lock; if(cc=nil)or(cp=nil)then exit; // ��� ���������� - ������ ������� �� ������
    with rScopesInfo._rScopesData._ReadingScopeData do begin
      if _ss<>ssFaultDataAck then begin Result:=false; exit; end;
      if(CommunicationProtocol is TIEC103Protocol)and(TIEC103Protocol(CommunicationProtocol)).ClearReadnScope then begin // ������������, ��� ������� ������������� � ��� ����� ����� � ����������
        fbFCB:=not fbFCB; iece:=iec103FaultAcknowledge(Self,_FUN,_INF,too1FaultDataSuccess,_FAN,_ACC,@ldu); // ������� ������������� � ����������
        Result:=(iece=ceSuccess);
        if iece=ieceUserData then begin Result:=true; LCF2:=ldu._LCF; ProcessASDU(ldu._asdu); end;
      end;
      Result:=true; ScopeProgressClose;
      if Result then with rScopesInfo._rScopesData do begin _ss:=ssFaultsListWaiting; // ����������� � ���, ��� ������������� �������
        LogMessage(Format('������� ������������� %d (FUN=%d, INF=%d)',[_FAN,_FUN,_INF],gfs));
        for i:=0to _ScopesListCount-1do if(_ScopesListDatas[i]._FUN=_FUN)and(_ScopesListDatas[i]._INF=_INF)then with _ScopesListDatas[i]do begin
          for j:=0to _Count-1do if _FANs[j]=_FAN then begin // �������� ������� ��, ��� �� ������ � ������
            if j<>_Count-1then CopyMemory(@_FANs[j],@_FANs[j+1],(_Count-1-j)*SizeOf(_FANs[0]));
            dec(_Count); _OrgTagsCount:=_TagsCountMax;
            if _Count<>0then begin _ss:=ssFaultSelect; _FAN:=_FANs[0]; end; // � ���� ������ ��� �������� �������������
            break;
          end;
          break;
        end;
  {      for i:=_ScopesListCount-1downto 0do if _ScopesListDatas[i]._Count=0then begin // ����� ������ ������
          if i<>MaxScopesListCount-1then CopyMemory(@_ScopesListDatas[i],@_ScopesListDatas[i+1],(MaxScopesListCount-1-i)*SizeOf(_ScopesListDatas[0]));
          dec(_ScopesListCount);
        end;}
        if _ss=ssFaultsListWaiting then for i:=0to _ScopesListCount-1do if(_ScopesListDatas[i]._Count<>0)then begin
          _ss:=ssFaultSelect; _FAN:=_ScopesListDatas[i]._FANs[0]; _FUN:=_ScopesListDatas[i]._FUN; _INF:=_ScopesListDatas[i]._INF; break;
        end;
      end;
    end;
  finally Unlock; end;
end;

function TIEC103Master.FaultDataRequest:boolean; var ldu:TLDU; iece:integer; begin Result:=false;
  try Lock; if(cc=nil)or(cp=nil)then exit; // ��� ���������� - ������ ������� �� ������
    with rScopesInfo._rScopesData._ReadingScopeData do begin
      if _ss<>ssFaultDataRequest then begin Result:=false; exit; end;
      fbFCB:=not fbFCB; iece:=iec103FaultOrder(Self,_FUN,_INF,too1FaultDataRequest,_FAN,_ACC,@ldu);
      Result:=(iece=ceSuccess);
      if iece=ieceUserData then begin Result:=true; LCF2:=ldu._LCF; ProcessASDU(ldu._asdu); end;
      if not Result then ScopeProgressClose
      else begin _ss:=ssFaultTagsWaiting; _lwReadTicks:=GetTickCount; end; // �������� ����� ������ ������ ������������� - ���� �� ����� ��������
    end;
  finally Unlock; end;
end;

function TIEC103Master.FaultSelect(FAN:tagFAN):boolean; var ldu:TLDU; iece:integer; begin Result:=false;
  try Lock; if(cc=nil)or(cp=nil)then exit; // ��� ���������� - ������ ������� �� ������
    with rScopesInfo._rScopesData._ReadingScopeData do begin
      if(_ss<>ssFaultsListWaiting)and(_ss<>ssFaultSelect)then ScopeProgressClose;
      _FAN:=FAN; _ACC:=0;
      fbFCB:=not fbFCB; iece:=iec103FaultOrder(Self,_FUN,_INF,too1FaultSelect,_FAN,_ACC,@ldu);
      Result:=(iece=ceSuccess);
      if iece=ieceUserData then begin Result:=true; LCF2:=ldu._LCF; ProcessASDU(ldu._asdu); end;
      if Result then begin _lwReadTicks:=GetTickCount; // �������� ����� ������ ������ ������������� - ���� �� ����� ��������
        _lwStartedTicks:=GetTickCount; _lwCurrentProgress:=0; _lwMaximalProgress:=0;
        _ss:=ssFaultDataWaiting; ScopeProgressOpen;
      end;
    end;
  finally Unlock; end;
end;

function TIEC103Master.FaultsListRequest:boolean; var s:AnsiString; ldu:TLDU; iece:integer; FUN,INF:byte; begin Result:=false;
  try Lock; if(cc=nil)or(cp=nil)then exit; // ��� ���������� - ������ ������� �� ������
    with rScopesInfo do begin _bInitialized:=true; _lwLastTicks:=GetTickCount; _lwOrgTicks:=_lwLastTicks; end;
    with rScopesInfo._rScopesData do begin
      if _ndxRequest>_ScopesListCount then _ndxRequest:=0; // ������ ������ ��� �������
      if _ScopesListCount=0then begin // ���� ������� ��� �� ��������
        FUN:=rScopesInfo._rScopesData._ReadingScopeData._FUN; INF:=rScopesInfo._rScopesData._ReadingScopeData._INF;
      end else begin FUN:=_ScopesListDatas[_ndxRequest]._FUN; INF:=_ScopesListDatas[_ndxRequest]._INF; inc(_ndxRequest); end; // ���� �� ������
    end;
    fbFCB:=not fbFCB; iece:=iec103FaultsList(Self,FUN,INF,@ldu);
    Result:=(iece=ceSuccess)or(iece=ieceUserData); rScopesInfo._lwLastTicks:=GetTickCount;
    if iece=ieceUserData then begin Result:=true; LCF2:=ldu._LCF; ProcessASDU(ldu._asdu); end;
    if Result then s:=Format('<�������� ������ ������������ (FUN=%d, INF=%d)',[FUN,INF],gfs)
    else s:='!������ ������� ������ ������������: '+GetErrorAsText(iece);
    LogMessage(s);
    if rScopesInfo._bAuto then LogMessage('��������� ������ ������ ������������ ����� �������� ����� '+IntToStr(rScopesInfo._lwInterval div 1000)+' �');
    if Result then rScopesInfo._bProcessing:=true;
  finally Unlock; end;
end;

function TIEC103Master.FaultTagsAck:boolean; var ldu:TLDU; iece:integer; begin Result:=false;
  try Lock; if(cc=nil)or(cp=nil)then exit; // ��� ���������� - ������ ������� �� ������
    with rScopesInfo._rScopesData._ReadingScopeData do begin
      if _ss<>ssFaultTagsAck then begin Result:=false; exit; end;
      fbFCB:=not fbFCB; iece:=iec103FaultAcknowledge(Self,_FUN,_INF,too1FaultTagsSuccess,_FAN,_ACC,@ldu);
      Result:=(iece=ceSuccess);
      if iece=ieceUserData then begin Result:=true; LCF2:=ldu._LCF; ProcessASDU(ldu._asdu); end;
      if not Result then ScopeProgressClose
      else begin _ss:=ssFaultChannelWaiting; _lwReadTicks:=GetTickCount; end; // �������� ����� ������ ������ ������������� - ���� �� ����� ��������
    end;
  finally Unlock; end;
end;

function TIEC103Master.FaultTagsRequest:boolean; var ldu:TLDU; iece:integer; begin Result:=false;
  try Lock; if(cc=nil)or(cp=nil)then exit; // ��� ���������� - ������ ������� �� ������
    with rScopesInfo._rScopesData._ReadingScopeData do begin
      if _ss<>ssFaultTagsRequest then begin Result:=false; exit; end;
      fbFCB:=not fbFCB; iece:=iec103FaultOrder(Self,_FUN,_INF,too1FaultTagsRequest,_FAN,_ACC,@ldu);
      Result:=(iece=ceSuccess);
      if iece=ieceUserData then begin Result:=true; LCF2:=ldu._LCF; ProcessASDU(ldu._asdu); end;
      if not Result then ScopeProgressClose
      else begin _ss:=ssFaultTagsTransmitting; _lwReadTicks:=GetTickCount; end; // �������� ����� ������ ������ ������������� - ���� �� ����� ��������
    end;
  finally Unlock; end;
end;

class function TIEC103Master.GetClassCaption:AString;
begin Result:='������� ���������� �� ���103 (TIEC103Master)'; end;

class function TIEC103Master.GetClassDescription:AString;
begin Result:='������� ���������� �� ��� 60870-5-103 ������ TIEC103Master ��������� ������ � ���103-��������'; end;

function TIEC103Master.GetPTag(_TypeID,_FUN,_INF,_Channel:byte):PIEC103Tag;
begin Result:=nil;

end;

function TIEC103Master.GetTagAddress(_TypeID,_FUN,_INF,_Channel:byte):LongWord;
begin Result:=(_TypeID shl 24)+(_FUN shl 16)+(_INF shl 8)+_Channel; end;

procedure TIEC103Master.InitDevice; begin
  try Lock; inherited InitDevice;

    with rScopesInfo._rScopesData._ReadingScopeData do begin
      if _pTagsInfo<>nil then Dispose(_pTagsInfo);          // ������ ��� �����
      if _pChannelsInfo<>nil then Dispose(_pChannelsInfo);  // ������ ��� ������
      _pTagsInfo:=nil; _pChannelsInfo:=nil;
    end;

    ZeroMemory(@rClass1Info,SizeOf(rClass1Info)); ZeroMemory(@rClass2Info,SizeOf(rClass2Info));
    ZeroMemory(@rScopesInfo,SizeOf(rScopesInfo));

    rClass1Info._bAuto:=true; rClass1Info._lwInterval:=10;                // ��� � 10 ��
    rClass1Info._bAuto:=true; rClass2Info._lwInterval:=250;               // ��� � 250 ��
    rScopesInfo._bAuto:=true; rScopesInfo._lwInterval:=90000;             // ��� � 1.5 ������ ����� ������������
    rScopesInfo._rScopesData._ReadingScopeData._ss:=ssFaultsListWaiting;  // � �������� ������ ������������
  finally Unlock; end;
end;

function TIEC103Master.InitializeGI:boolean;
begin Result:=Refresh; end;

function TIEC103Master.PerformTick:boolean; var delta1,delta2:longword; b1,b2:boolean; begin
  try Lock; Result:=inherited PerformTick;
    with rClass1Info do if not _bInitialized then begin Class1; Result:=true; exit; end
    {else if(TLinkControlField2(@rLCF2._LCF2).ACD=1)then begin // ���� ���������� �� ������ ������ ������ 1
      _lwLastTicks:=GetTickCount; Class1; exit;
    end }else begin delta1:=GetTickCount-_lwLastTicks;
      b1:=delta1>_lwInterval; delta1:=delta1-_lwInterval; // ������ ������� ��� ������
    end;
    with rClass2Info do if not _bInitialized then begin Class2; Result:=true; exit; end
    else begin delta2:=GetTickCount-_lwLastTicks;
      b2:=delta2>_lwInterval; delta2:=delta2-_lwInterval; // ������ ������� ��� ������
    end;
    with rScopesInfo._rScopesData do begin _bSleep:=not _bSleep;
      if not _bSleep then with _ReadingScopeData do case _ss of
        ssFaultsListWaiting:;                                                     // �������� ������ ��������� ASDU23
        ssFaultSelect:              begin FaultSelect(_FAN); exit; end;           // ����� �������������
        ssFaultDataWaiting:;                                                      // �������� ���������� ������ � ���������� ASDU26
        ssFaultDataRequest:         begin FaultDataRequest; exit; end;            // ������ �������� ������ � ����������
        ssFaultTagsWaiting:;                                                      // �������� ���������� ����� ASDU28
        ssFaultTagsRequest:         begin FaultTagsRequest; exit; end;            // ������ �������� �����
        ssFaultTagsTransmitting:;                                                 // �������� ��������� ��������� ����� � �� ��������� ASDU29, ��������� �������� ����� ASDU31
        ssFaultTagsAck:             begin FaultTagsAck; exit; end;                // ������������� �������� �����
        ssFaultChannelWaiting:;                                                   // �������� ���������� ������
        ssFaultChannelRequest:      begin FaultChannelRequest; exit; end;         // ������ �������� ������
        ssFaultChannelTransmitting:;                                              // �������� ������ ������
        ssFaultChannelAck:          begin FaultChannelAck; exit; end;             // ������������� �������� ������
        ssFaultDataAck:             begin DoComtrade; FaultDataAck; exit; end;    // ����������� �������� �������������
      end;
    end;
    if b1 and b2 then begin b1:=delta1>delta2; b2:=not b1; end; // ��� �� ������ ���� ��� (����� 1 ��� ����� 2?)
    if b1 then begin Class1; rClass1Info._lwLastTicks:=GetTickCount; end // � ������� ����������
    else if b2 then begin Class2; rClass2Info._lwLastTicks:=GetTickCount; end;
  finally Unlock; end;
end;

procedure TIEC103Master.ProcessASDU(asdu:TASDU); var pTag:PIEC103Tag; bFound,bIncChannel:boolean;
  i,j,iNum,ndx:integer; s:AnsiString; sld:TrScopesListData; dpi:tagDPI; sdv:tagSDV;
begin
  try Lock;
    if@fOnProcessASDU<>nil then fOnProcessASDU(Self,asdu);
    case asdu.DUI._COT of
      cot2GeneralInterrogation: with rRefreshInfo,PrRefreshInfo(_pData)^do if _bProcessing then begin
        _lwLastTicks:=GetTickCount; // ��������, ��� ����� �� �����
        inc(_ndx); // ����������� ������� �����
        {if rGIinfo._CountMax<>0then }
          DoProgress(ti1GeneralInterrogation,0,_ndx,_cnt,GetTickCount-_lwOrgTicks,Format('����� ����� ��� ������� %d (ASDU=%d, FUN=%d, INF=%d)',
            [byte(_ID),asdu.DUI._TypeID,asdu.IO1._FunctionType,asdu.IO1._InformationNumber],gfs),psWorking);
      end;
      // cot2GeneralInterrogationTermination: if rGIinfo._bProcessing then begin rGIinfo._bProcessing:=false; LogMessage('���������� ������ ������ ��� ������� '+IntToStr(asdu.IO8._SCN)); end;
    end;
    case asdu.DUI._TypeID of
      ti2TimeTag: begin
        pTag:=GetPTag(asdu.DUI._TypeID,asdu.IO1._FunctionType,asdu.IO1._InformationNumber,0);
        if pTag<>nil then if pTag._TypeID<>ti2TimeTag then pTag:=nil; // ����� ��� ����, �� �� ���� ����
        if pTag<>nil then begin
          pTag._ASDU:=asdu; pTag._bValidValue:=true;
          pTag.Tag1._DPI:=asdu.IO1._DPI; pTag.Tag1._Time32:=asdu.IO1._Time32; pTag.Tag1._SIN:=asdu.IO1._SIN;
          case pTag.Tag1._DPI of
            1: pTag.Tag1._BValue:=false;        2: pTag.Tag1._BValue:=true;
          else pTag._bValidValue:=false; end;
        end;
      end;
      ti2RelativeTimeTag: begin
//        pTag:=GetPTag(1,asdu.IO2._FunctionType,asdu.IO2._InformationNumber,0);  // ��� ��������
        pTag:=GetPTag(asdu.DUI._TypeID,asdu.IO2._FunctionType,asdu.IO2._InformationNumber,0);
        if pTag<>nil then if pTag._TypeID<>ti2RelativeTimeTag then pTag:=nil; // ����� ��� ����, �� �� ���� ����
        if pTag<>nil then begin
{          pTag._ASDU:=asdu; pTag._bValidValue:=true; // ��� ��������
          pTag.Tag1._DPI:=asdu.IO2._DPI; pTag.Tag1._Time32:=asdu.IO2._Time32; pTag.Tag2._SIN:=asdu.IO2._SIN;
          case pTag.Tag1._DPI of
            1: pTag.Tag1._BValue:=false;        2: pTag.Tag1._BValue:=true;
          else pTag._bValidValue:=false; end;}
          pTag.Tag2._DPI:=asdu.IO2._DPI; pTag.Tag2._RET:=asdu.IO2._RET;
          pTag.Tag2._FAN:=asdu.IO2._FAN; pTag.Tag2._Time32:=asdu.IO2._Time32; pTag.Tag2._SIN:=asdu.IO2._SIN;
          case pTag.Tag2._DPI of
            1: pTag.Tag2._BValue:=false;        2: pTag.Tag2._BValue:=true;
          else pTag._bValidValue:=false; end;
        end;
      end;
  //    ti2MeasuredValues1=3;                 // ���������� ��������, ����� ���� 1
  //    ti2ShortCircuitLocation=4;            // ����� ��������� ���������
      ti2IdentificationInfo: begin
        case asdu.DUI._COT of
          cot2ResetFCB:         LogMessage('>���������� ������������� ������ ���� ������');
          cot2ResetCommUnit:    if rInitializeInfo._bProcessing then begin rInitializeInfo._bProcessing:=false; LogMessage('>���������� ������������� ����������'{������ �����}); end;
          cot2StartRestart:     LogMessage('�����/������� ����������');
          cot2PowerOn:          LogMessage('��������� ����������');
        else LogMessage('!������ � ASDU5 (������������� ����������): ������� �������� '+IntToStr(asdu.DUI._COT)+' ������ 3..6'); end;
        LogMessage('����������: "'+asdu.IO5._Vendor+'", ���������: 0x'+IntToHex(PLongWord(@asdu.IO5._SoftwareID)^,8)+', �������������: '+IntToStr(asdu.IO5._COL));
        fui8CompatibilityLevel:=asdu.IO5._COL; fsDeviceName:=asdu.IO5._Vendor; fui32SoftwareID:=asdu.IO5._SoftwareID;
      end;
      ti2TimeSynchronization: begin
        if asdu.DUI._COT<>cot2TimeSynchronization then LogMessage('!������ � ASDU6 (���������� �������������): ������� �������� '+IntToStr(asdu.DUI._COT)+' ������ '+IntToStr(cot2TimeSynchronization));
        if rSynchronizeInfo._bProcessing then begin rSynchronizeInfo._bProcessing:=false; LogMessage('>���������� ������������� ����������'); end;
      end;
      ti2GeneralInterrogationTermination: begin
        if asdu.DUI._COT<>cot2GeneralInterrogationTermination then LogMessage('!������ � ASDU8 (���������� ������ ������): ������� �������� '+IntToStr(asdu.DUI._COT)+' ������ '+IntToStr(cot2GeneralInterrogationTermination));
        with rRefreshInfo,PrRefreshInfo(_pData)^do if _bProcessing then
          if byte(_ID)<>asdu.IO8._SCN then LogMessage('!��������� ������������ ������ ������ ��� ������� '+IntToStr(asdu.IO8._SCN))
          else begin _bProcessing:=false; LogMessage('>���������� ������ ������ ��� ������� '+IntToStr(asdu.IO8._SCN));
            DoProgress(ti1GeneralInterrogation,0,_ndx,_cnt,GetTickCount-_lwOrgTicks,'����� ����� ��� ������� '+IntToStr(asdu.IO8._SCN),psClosed);
            _cnt:=_ndx; // ������ ������� ����� ��������� � ����� ������
          end
        else LogMessage('!��������� ������������ ������ ������ ��� ������� '+IntToStr(asdu.IO8._SCN));
      end;
      ti2MeasuredValues2: begin
        pTag:=GetPTag(asdu.DUI._TypeID,asdu.IO9._FunctionType,asdu.IO9._InformationNumber,0); // ������� ��� ������ ������
        if pTag<>nil then if pTag._TypeID<>ti2MeasuredValues2 then pTag:=nil; // ����� ��� ����, �� �� ���� ����
        iNum:=asdu.DUI._VSQ and$7F; // ���������� ��������� � ������
        bIncChannel:=pTag=nil; // ����� ����������� Channel, � �� INF - ��������� ������ ����� �����
        for i:=1to iNum do begin
          if bIncChannel then pTag:=GetPTag(asdu.DUI._TypeID,asdu.IO9._FunctionType,asdu.IO9._InformationNumber,i)
          else pTag:=GetPTag(asdu.DUI._TypeID,asdu.IO9._FunctionType,asdu.IO9._InformationNumber+i-1,0);
          if pTag=nil then Continue;
          pTag._ASDU:=asdu; pTag._bValidValue:=true;
          pTag.Tag9._OV:=TMEA(@asdu.IO9._MEA[i-1]).OV=1;
          pTag.Tag9._ER:=TMEA(@asdu.IO9._MEA[i-1]).ER=1;
          pTag.Tag9._MVAL:=TMEA(@asdu.IO9._MEA[i-1]).MVAL*pTag.Tag9._Scale;
//          if pTag.Tag9._MVAL<>0then;
        end;
      end;
      ti2FaultsList: with rScopesInfo,_rScopesData do begin
        sld._FUN:=asdu.IO23._FunctionType; sld._INF:=asdu.IO23._InformationNumber;
        sld._Count:=asdu.DUI._VSQ and$7F; sld._OrgTagsCount:=0;
        s:=''; for i:=1to sld._Count do begin
          sld._FANs[i-1]:=asdu.IO23._FanInfo[i-1]._FAN; s:=s+','+IntToStr(asdu.IO23._FanInfo[i-1]._FAN);
        end;
        if s<>''then Delete(s,1,1); s:=Format('������� ������ ������������ (FUN=%d, INF=%d): %s',[sld._FUN,sld._INF,s],gfs);
        if rScopesInfo._bProcessing then s:='>'+s; LogMessage(s);
        _bInitialized:=true; _bProcessing:=false; _lwLastTicks:=GetTickCount;
        bFound:=false; // ���� ����� ��������� ������� ������������ (����� �� MaxScopesListCount)
        for i:=0to _ScopesListCount-1do
          if(_ScopesListDatas[i]._FUN=sld._FUN)and(_ScopesListDatas[i]._INF=sld._INF)then
            begin bFound:=true; sld._OrgTagsCount:=_ScopesListDatas[i]._OrgTagsCount; _ScopesListDatas[i]:=sld; break; end; // ����� � ��������
        if not bFound then
          if _ScopesListCount=MaxScopesListCount then LogMessage('!������ ������������ ��������������, ��������� ���������� ���������� - �������� '+IntToStr(MaxScopesListCount))
          else begin _ScopesListDatas[_ScopesListCount]:=sld; inc(_ScopesListCount); bFound:=true; end; // �������� ����� ������
        if bFound then begin // ���� ������ �� ��������������� � ����� ������, �� ����� ���������� � ���
          if(sld._Count=0)and(_ReadingScopeData._ss<>ssFaultsListWaiting)and // ������� ��������� ������ - ������������ � ���������� ��� �� ��������
            (_ReadingScopeData._FUN=sld._FUN)and(_ReadingScopeData._INF=sld._INF)then ScopeProgressClose
          else if _ReadingScopeData._ss<>ssFaultsListWaiting then begin bFound:=false;
            for i:=1to sld._Count do if _ReadingScopeData._FAN=sld._FANs[i-1]then begin bFound:=true; break; end;
            if not bFound then ScopeProgressClose // ����� ������������� ��� ��� - �� ����� � ����������
            else if GetTickCount-_ReadingScopeData._lwReadTicks>_lwInterval then // ��������� ������ ������ ������������� ���� ����� �����
              ScopeProgressClose; // ������� ������� ��������� ������
          end;
          if(_ReadingScopeData._ss=ssFaultsListWaiting)and(sld._Count<>0)then begin // ���� ��� �� ������, �� �����
            _ReadingScopeData._FUN:=sld._FUN; _ReadingScopeData._INF:=sld._INF; _ReadingScopeData._TagsCountMax:=sld._OrgTagsCount;
            _ReadingScopeData._FAN:=sld._FANs[0]; _ReadingScopeData._ACC:=0; _ReadingScopeData._ss:=ssFaultSelect; // ���� ����� ������� �������������
          end;
        end;
      end;
      ti2FaultDataReady: with rScopesInfo._rScopesData._ReadingScopeData do // ��������, ��� ��� ���� ������������� � �� ��� ���������� ������
        if(_ss=ssFaultDataWaiting)and(_FAN=asdu.IO26._FAN)and(_FUN=asdu.IO26._FunctionType)and(_INF=asdu.IO26._InformationNumber)then begin
          _lwReadTicks:=GetTickCount; // � �������� ������ ������������� ������ ����� ��������� ���� - ����� �� ��������� � ���������
          _NOF:=asdu.IO26._NOF; _NOC:=asdu.IO26._NOC; _NOE:=asdu.IO26._NOE; _INT:=asdu.IO26._INT; _Time32:=asdu.IO26._Time32;
          _lwMaximalProgress:=_NOC*_NOE{+_TagsCountMax};
          _ss:=ssFaultDataRequest; // ���� ����� ��������� ������
          if _pTagsInfo=nil then New(_pTagsInfo); { ������ ��� �����}
          if _pChannelsInfo=nil then New(_pChannelsInfo); { ������ ��� ������}
          SetLength(_pTagsInfo^,0); SetLength(_pChannelsInfo^,0);
        end;
      ti2FaultChannelReady: with rScopesInfo._rScopesData._ReadingScopeData do // ��������, ��� ��� ���� ������������� � �� ��� ���������� ������
        if(_ss=ssFaultChannelWaiting)and(_FAN=asdu.IO27._FAN)and(_FUN=asdu.IO27._FunctionType)and(_INF=asdu.IO27._InformationNumber)then begin
          _lwReadTicks:=GetTickCount; // � �������� ������ ������������� ������ ����� ��������� ���� - ����� �� ��������� � ���������
          _ACC:=asdu.IO27._ACC; _RPV:=asdu.IO27._RPV; _RSV:=asdu.IO27._RSV;  _RFA:=asdu.IO27._RFA;
          _ChannelInit:=false; _ChannelBasePos:=0; _ChannelBaseInc:=true; 
          _ss:=ssFaultChannelRequest; // ���� ����� ��������� �����
        end;
      ti2FaultTagsReady: with rScopesInfo._rScopesData._ReadingScopeData do // ��������, ��� ��� ���� ������������� � �� ��� ���������� �����
        if(_ss=ssFaultTagsWaiting)and(_FAN=asdu.IO28._FAN)and(_FUN=asdu.IO28._FunctionType)and(_INF=asdu.IO28._InformationNumber)then begin
          _lwReadTicks:=GetTickCount; // � �������� ������ ������������� ������ ����� ��������� ���� - ����� �� ��������� � ���������
          _TagsInit:=false; _TagsBasePos:=0; _TagsBaseInc:=true; _TagsCount:=0; // ����� ������� �����
          _ss:=ssFaultTagsRequest; // ���� ����� ��������� �����
        end;
      ti2FaultTagsTransmission: with rScopesInfo._rScopesData._ReadingScopeData do // ��������, ��� ��� ���� ������������� � �� ��� ��������� �����
        if(_ss=ssFaultTagsTransmitting)and(_FAN=asdu.IO29._FAN)and(_FUN=asdu.IO29._FunctionType)and(_INF=asdu.IO29._InformationNumber)then begin
          _lwReadTicks:=GetTickCount; // � �������� ������ ������������� ������ ����� ��������� ���� - ����� �� ��������� � ���������
          if(asdu.IO29._TAP=0)then // ���� ��������� �������� ����� ����� 0 - ���� �������� ���������, ���� ������������ �� ������ 65536
            if not(_TagsInit)then begin i:=_TagsCount; inc(_TagsCount,asdu.IO29._NOT); // ������� ����� (������ � �������� ����������)
              SetLength(_pTagsInfo^,_TagsCount);
              for i:=i to _TagsCount-1do begin
                _pTagsInfo^[i]._FUN:=asdu.IO29._Tags[i]._FunctionType;
                _pTagsInfo^[i]._INF:=asdu.IO29._Tags[i]._InformationNumber;
                SetLength(_pTagsInfo^[i]._DPIs,1); _pTagsInfo^[i]._DPIs[0]:=asdu.IO29._Tags[i]._DPI;
              end;
            end else if _TagsBaseInc then begin inc(_TagsBasePos,65536); _TagsBaseInc:=false; end; // ���� ��� �������� �������
          if asdu.IO29._TAP<>0then begin _TagsInit:=true; _TagsBaseInc:=true; end; // ��������� _TAP ����� ���� ����������� �� ������ 65536, ������� ������ ������� �� �����
          ndx:=asdu.IO29._TAP+_TagsBasePos;
          if(ndx>0)and(ndx<_NOE)then begin // ���� ������ ��� ������ �� ������ - �� ������ ������ (���������� �� ������ 65536 ������-�� �� �������)
            for i:=0to asdu.IO29._NOT-1do begin
              for j:=0to High(_pTagsInfo^)do
                if((_pTagsInfo^[j]._FUN)=asdu.IO29._Tags[i]._FunctionType)and((_pTagsInfo^[j]._INF)=asdu.IO29._Tags[i]._InformationNumber)
                  then begin // ����� ����� �����
                    dpi:=_pTagsInfo^[j]._DPIs[High(_pTagsInfo^[j]._DPIs)]; // ���������� ��������� ���������
                    iNum:=Length(_pTagsInfo^[j]._DPIs);
                    SetLength(_pTagsInfo^[j]._DPIs,ndx+1);
                    FillMemory(@_pTagsInfo^[j]._DPIs[iNum],(ndx-iNum)*SizeOf(dpi),dpi);
                    _pTagsInfo^[j]._DPIs[ndx]:=asdu.IO29._Tags[i]._DPI; break;
//                    if rScopesInfo._ScopesData._ReadingScopeData._pTagsInfo^[0]._DPIs[0]<>1then;
                  end;
              // ���� ����� ����� �� ����� - ������ ���������� �
            end;
          end;
          _lwCurrentProgress:=_TagsCount; ScopeProgressUpdate('������ �����',psWorking);
        end;
      ti2FaultValuesTransmission: with rScopesInfo._rScopesData._ReadingScopeData do // ��������, ��� ��� ���� ������������� � �� ��� �������� ������ � ����� ���
        if(_ss=ssFaultChannelTransmitting)and(_ACC=asdu.IO30._ACC)and(_FAN=asdu.IO30._FAN)and(_FUN=asdu.IO30._FunctionType)and(_INF=asdu.IO30._InformationNumber)then begin
          _lwReadTicks:=GetTickCount; // � �������� ������ ������������� ������ ����� ��������� ���� - ����� �� ��������� � ���������
          if(asdu.IO30._NFE=0)then // ���� ��������� �������� ������ ����� 0 - ���� �������� ���������, ���� ������������ �� ������ 65536
            if not(_ChannelInit)then begin i:=Length(_pChannelsInfo^);
              SetLength(_pChannelsInfo^,i+1);
              _pChannelsInfo^[i]._ACC:=asdu.IO30._ACC;
              _pChannelsInfo^[i]._RPV:=_RPV; _pChannelsInfo^[i]._RSV:=_RSV; _pChannelsInfo^[i]._RFA:=_RFA;
              iNum:=asdu.IO30._NDV; SetLength(_pChannelsInfo^[i]._SDVs,iNum);
              for j:=0to iNum-1do _pChannelsInfo^[i]._SDVs[j]:=asdu.IO30._SDVs[j];
            end else if _ChannelBaseInc then begin inc(_ChannelBasePos,65536); _ChannelBaseInc:=false; end; // ���� ��� �������� �������
          if asdu.IO30._NFE<>0then begin _ChannelInit:=true; _ChannelBaseInc:=true; end; // ��������� _NFE ����� ���� ����������� �� ������ 65536, ������� ������ ������� �� �����
          ndx:=asdu.IO30._NFE+_ChannelBasePos;
          if(ndx>0)and(ndx<_NOE)then begin // ���� ������ ��� ������ �� ������ - �� ������ ������ (���������� �� ������ 65536 ������-�� �� �������)
            for j:=0to High(_pChannelsInfo^)do
              if((_pChannelsInfo^[j]._ACC)=asdu.IO30._ACC)
                then begin // ����� ���������� �����
                  sdv:=_pChannelsInfo^[j]._SDVs[High(_pChannelsInfo^[j]._SDVs)]; // ���������� ��������� ���������
//                  iNum:=Length(_pChannelsInfo^[j]._SDVs);                  
                  SetLength(_pChannelsInfo^[j]._SDVs,ndx+asdu.IO30._NDV);
//                  FillMemory(@_pChannelsInfo^[j]._SDVs[iNum],(ndx+asdu.IO30._NDV-iNum)*SizeOf(sdv),sdv);
                  for i:=0to asdu.IO30._NDV-1do _pChannelsInfo^[j]._SDVs[ndx+i]:=asdu.IO30._SDVs[i];
                  if rScopesInfo._rScopesData._ReadingScopeData._pChannelsInfo^[0]._SDVs[0]<>1then;
                  break;
                end;
              // ���� ������ ������ �� ����� - ������ ���������� ���
          end;
          inc(_lwCurrentProgress,asdu.IO30._NDV); ScopeProgressUpdate('������ ������ ������ '+IntToStr(_ACC),psWorking);
        end;
      ti2FaultTransmissionTermination: with rScopesInfo._rScopesData._ReadingScopeData do // ��������, ��� ��� ���� �������������
        if(_FAN=asdu.IO31._FAN)and(_FUN=asdu.IO31._FunctionType)and(_INF=asdu.IO31._InformationNumber)then begin
          _lwReadTicks:=GetTickCount; // � �������� ������ ������������� ������ ����� ��������� ���� - ����� �� ��������� � ���������
          case asdu.IO31._TOO of
            // ��������� �������� ������ � ���������� ��� ���������������� �����������
            too2FaultDataEnd: if(_ss=ssFaultChannelWaiting)then begin                                                 
              _ss:=ssFaultDataAck; // ���� �����������, ��� ��������� ��� �������������
            end else ScopeProgressClose; // ���� ������ ����� ����
            // ��������� �������� ������ � ���������� � ��������������� ������������ �������� ����������
            too2FaultDataSystemAbort,
            // ��������� �������� ������ � ���������� � ��������������� ������������ ����������� ������
            too2FaultDataDeviceAbort: ScopeProgressClose; // �������� ������ �������������
            // ��������� �������� ������ ��� ���������������� �����������
            too2FaultChannelEnd: if _ss=ssFaultChannelTransmitting then begin // ���� �� �� ��� �������� ������, �� ���� ������ �� ���
              _ss:=ssFaultChannelAck; // ���� �����������, ��� ������� �����
            end;
            // ��������� �������� ������ � ��������������� ������������ �������� ����������
            too2FaultChannelSystemAbort:;
            // ��������� �������� ������ � ��������������� ������������ ����������� ������
            too2FaultChannelDeviceAbort:;
            // ��������� �������� ����� ��� ���������������� �����������
            too2FaultTagsEnd: if _ss=ssFaultTagsTransmitting then begin // ���� �� �� ��� �������� �����, �� ���� ������ �� ���
              if _TagsCountMax=0then _TagsCountMax:=_TagsCount;
              _ss:=ssFaultTagsAck; // ���� �����������, ��� ��� ����� �������
              _lwMaximalProgress:=_NOC*_NOE+_TagsCountMax;              
            end;
            // ��������� �������� ����� � ��������������� ������������ �������� ����������
            too2FaultTagsSystemAbort, // �� �� ���������� - �������� ����������, ���� ���������
            // ��������� �������� ����� � ��������������� ������������ ����������� ������
            too2FaultTagsDeviceAbort: // ���������� ������-�� �� ������ �������� ����� - ���� ���������
              if _ss=ssFaultTagsTransmitting then // ���� �� �� ��� �������� �����, �� ���� ������ �� ���
                {_ss:=ssFaultTagsRequest}ScopeProgressClose; // �������������� ����������� - ��������
          end;
        end;
    end;
    with rInitializeInfo do if _bProcessing and((GetTickCount-_lwLastTicks)>600000) // ������ ������� � ������ ������������� ���������� ����� 10 �����,
    then _bProcessing:=false; // ������ ���-�� ���� �� ��� - ������� ����, ����� ������ ������ ����������
    with rSynchronizeInfo do if _bProcessing and((GetTickCount-_lwLastTicks)>_lwInterval) // ������ ������� � ������ ������������� ������,
    then _bProcessing:=false; // ��� ��� ��������� ����� �������������, ������ ���-�� ���� �� ��� - ������� ����, ��������� ������
    with rRefreshInfo do if _bProcessing and((GetTickCount-_lwOrgTicks)>_lwInterval) // ������ ������� � ������ ������������� GI ������,
    then with rRefreshInfo,PrRefreshInfo(_pData)^do begin _bProcessing:=false; // ��� ��� ��������� ����� �����, ������ ���-�� ���� �� ��� - ������� ����, ����� ��-���� �����
      DoProgress(ti1GeneralInterrogation,0,_ndx,_cnt,GetTickCount-_lwOrgTicks,'����� ����� ��� ������� '+IntToStr(byte(_ID)),psClosed);
    end;
    with rScopesInfo do if _bProcessing and((GetTickCount-_lwOrgTicks)>_lwInterval) // ������ ������� � ������ ������� ������ ������������ ������,
    then _bProcessing:=false; // ��� ��� ��������� ����� ������, ������ ���-�� ���� �� ��� - ������� ����, ������ ��-���� ����� ��� ���������
  finally Unlock; end;
end;

function TIEC103Master.ResetCommUnit:boolean;
begin Result:=Initialize; end;

function TIEC103Master.ResetFCB:boolean; var s:AnsiString; begin Result:=false;
  try Lock; if(cc=nil)or(cp=nil)then exit; // ��� ���������� - ������ ������� �� ������
    Result:=iec103ResetFCB(Self)=ceSuccess; if Result then fbFCB:=false ;
  finally Unlock; end;
  if Result then s:='<�������� ������������� ������ ���� ������'else s:='!������ ������������� ������ ���� ������';
  LogMessage(s);
end;

procedure TIEC103Master.ScopeProgressClose; begin
  try Lock;
    with rScopesInfo._rScopesData._ReadingScopeData do begin
      if _ss<>ssFaultsListWaiting then begin _ss:=ssFaultsListWaiting;
        LogMessage(Format('!��������������� ����������� ������ ������������� %d (FUN=%d, INF=%d)',[_FAN,_FUN,_INF],gfs));
      end;
      FaultDataAbort; // ��� �� ��� ������ ����?
    end;
    ScopeProgressUpdate('',psClosed);
  finally Unlock; end;
end;

procedure TIEC103Master.ScopeProgressOpen;
begin ScopeProgressUpdate('',psOpened); end;

procedure TIEC103Master.ScopeProgressUpdate(sWork:AnsiString; ps:TProgressState); begin
  try Lock;
    with rScopesInfo._rScopesData._ReadingScopeData do begin
      if sWork<>''then sWork:=': '+sWork; sWork:=Format('������ ������������� %d (FUN=%d, INF=%d)%s',[_FAN,_FUN,_INF,sWork],gfs);
      DoProgress(ti1FaultOrder,0,_lwCurrentProgress,_lwMaximalProgress,GetTickCount-_lwStartedTicks,sWork,ps);
    end;
  finally Unlock; end;
end;

procedure TIEC103Master.SetDefault; begin
  try Lock; BeginUpdate;
    inherited SetDefault; // ������ �������� ��� ��������
    fsCaption:='IEC103Master_0x'+IntToHex(fhID,8); fsName:=fsCaption; fsDescription:=GetClassCaption;
  finally EndUpdate; Unlock; end;
end;

function TIEC103Master.Tick:boolean; begin
  try Lock;
    if(TLinkControlField2(@LCF2).DFC=1)and not rBusyInfo._bProcessing then rBusyInfo._bInitialized:=true; // ���� ���������� ��������, ��� ������ - �� ����� ��� ����������
    Result:=inherited Tick; if Result then exit;
    with rScopesInfo do if _bAuto then // ����� ������������
      if not _bInitialized or((GetTickCount-_lwOrgTicks)>_lwInterval)then begin FaultsListRequest; Result:=true; exit; end // ������������� �����������
      else if _bProcessing then begin Result:=PerformTick; exit; end; // ������� ������ ������������
    if not Result then Result:=PerformTick; // ���� ������ �� ���� ���������, �������� �� ���������
  finally Unlock; end;
end;

initialization
  GetLocaleFormatSettings(SysLocale.DefaultLCID,gfs);
  TTextWriter.RegisterCustomJSONSerializerFromText(TypeInfo(TrTagInfo),__TrTagInfo).Options:=[soReadIgnoreUnknownFields,soWriteHumanReadable];
  RegisterClasses;


end.
