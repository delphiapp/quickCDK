unit uComtrade;

interface

uses Classes,SynCommons;

type
//{$M+}
  TrSystemTime= record
    _wYear:word;
    _wMonth:word;
    _wDayOfWeek:word;
    _wDay:word;
    _wHour:word;
    _wMinute:word;
    _wSecond:word;
    _wMilliseconds:word;
    _s:RawUTF8; // ���� ��������� TypeInfo
  end;

  TrHeader=packed record
    _sCell:RawUTF8;                   // ������
    _sConnection:RawUTF8;             // �������������
    _sCorporation:RawUTF8;            // �����������
    _sDevice:RawUTF8;                 // ������������� ����������
    _sStation:RawUTF8;                // �������
    _sSubStation:RawUTF8;             // ����������
    _sInfo:String;                    // ��� ������ ����������
  end;

  TrAnalogChannelInfo=packed record
    _lwChannelNumber:cardinal;        // ����� ������
    _sChannelID:RawUTF8;              // ������������� ������
    _sPhase:RawUTF8;                  // ������������� ����
    _sCircuit:RawUTF8;                // ����/���������, ������� ��������������
    _sUnit:RawUTF8;                   // ������� ��������� � ������ (kV, kA, � �.�.)
    _dA:Double;                       // ������������ ����� (��. ����)
    _dB:Double;                       // ������������ �����. ����������� �������������� � �� (�.�., ���������� �������� � ������������� (��+b) � ��������, ��������� ����)
    _dSkew:Double;                    // ������������ �����. ����� ������� (�  �) � ������ � ������ �������
    _dMin:Double;                     // �����, ������ ����������� �������� (������ ������� ���������) ��� ������� ����� ������
    _dMax:Double;                     // �����, ������ ������������ �������� (������� ������� ���������) ��� ������� ����� ������
    _Units:array of RawUTF8;          // ������ �� 4� �������� ��� ������ ���������: ��� �������������, ���������, ��������� ������� � ��� ������� � ���������� (� ����� ��������)
    _Coefficients:array of Double;    // ������ �� 4� �������� ��� ����������� �������: ��� �������������, ���������, ��������� � � ����������
  end;

  TrDiscreteChannelInfo=packed record
    _lwChannelNumber:cardinal;        // ����� ������
    _sChannelID:RawUTF8;              // ������������� ������
    _bNormalValue:boolean;            // (0 ��� 1) ���������� ��������� ����� ������ (��������� ������ � ���������� �������) (1 - ��������� �����)
  end;

  TrRateInfo=packed record
    _lwSamplingRate:cardinal;         // ������� ������������� � ��
    _lwSampleOrgNumber:cardinal;      // ����� ��������� ������� ��� ������ ��������
    _lwSampleEndNumber:cardinal;      // ����� ��������� ������� ��� ������ ��������
    _s:RawUTF8;                       // ���� ��������� TypeInfo
  end;

  TrConfiguration=packed record
    _sStationName:RawUTF8;                // ���������� �������� ������������
    _sStationID:RawUTF8;                  // ���������� ����� ������������
    _lwAnalogsCount:cardinal;             // ���������� ���������� �������
    _lwDiscretesCount:cardinal;           // ���������� ���������� �������
    _AnalogChannels:array of TrAnalogChannelInfo;     // ������ �������� ���������� �������
    _DiscreteChannels:array of TrDiscreteChannelInfo; // ������ �������� ���������� �������
    _lwPowerFrequency:cardinal;           // ������� ���� � �� (50 ��� 60)
    _lwRatesCount:cardinal;               // ���������� ��������� ��������� ������������� � ����� ������
    _Rates:array of TrRateInfo;           // ������ �������� ������ �������������
    _stFirstValueTimeStamp:TrSystemTime;  // ����� ������� ��� ������� �������� � ����� ������
    _stLaunchTimeStamp:TrSystemTime;      // ����� ������� ��� ������� �����
  end;

  TrSampleInfo=packed record
    _lwSampleNumber:cardinal;         // ����� �������
    _lwSampleTime:cardinal;           // ����� � ������������� �� ������ ������
    _AnalogValues:array of Double;    // ������ �������� ��� ���������� �������
    _DiscreteValues:array of boolean; // ������ �������� ��� ���������� �������
  end;

  TrComtradeData=packed record        // ������ � Comtrade-�������
    _Header:TrHeader;                 // ���� .hdr
    _Configuration:TrConfiguration;   // ���� .cfg
    _Data:array of TrSampleInfo;      // ���� .dat
  end;

  TrComtradeFile=packed record        // Comtrade-����
    _ComtradeData:TrComtradeData;     // ������ �����
  end;

  const
    __TrSystemTime='Year word Month word DayOfWeek word Day word Hour word Minute word Second word Milliseconds word _s RawUTF8';
    __TrHeader='Cell String Connection String Corporation String Device String Station String SubStation String Info String';
    __TrAnalogChannelInfo='ChannelNumber cardinal ChannelID RawUTF8 Phase RawUTF8 Circuit RawUTF8 Unit RawUTF8 A Double B Double Skew Double Min Double Max Double Units array of RawUTF8 Coefficients array of Double';
    __TrDiscreteChannelInfo='ChannelNumber cardinal ChannelID RawUTF8 NormalValue boolean';
    __TrRateInfo='SamplingRate cardinal SampleOrgNumber cardinal SampleEndNumber cardinal _s RawUTF8';
    __TrConfiguration='StationName RawUTF8 StationID RawUTF8 AnalogsCount cardinal DiscretesCount cardinal AnalogChannels array of TrAnalogChannelInfo DiscreteChannels array of TrDiscreteChannelInfo PowerFrequency cardinal'+' RatesCount cardinal Rates array of TrRateInfo FirstValueTimeStamp TrSystemTime LaunchTimeStamp TrSystemTime';
    __TrSampleInfo='SampleNumber cardinal SampleTime cardinal AnalogValues array of Double DiscreteValues array of boolean';
    __TrComtradeData='Header TrHeader Configuration TrConfiguration Data array of TrSampleInfo';
    __TrComtradeFile='ComtradeData TrComtradeData';



  procedure SaveCJSN(const sFile:AnsiString; const cf:TrComtradeData); // ComtradeJSoN, ���������� ����� ����� �������� �� .cjsn

  procedure LoadCJSN(const sFile:AnsiString; var cf:TrComtradeData); // ComtradeJSoN


implementation

uses SysUtils;

  procedure SaveCJSN(const sFile:AnsiString; const cf:TrComtradeData); var s:AnsiString; sl:TStringList; begin sl:=nil;
    try sl:=TStringList.Create;
      s:=UTF8ToString(RecordSaveJSON(cf,TypeInfo(TrComtradeFile)));
      sl.Text:=s; sl.SaveToFile(ChangeFileExt(sFile,'.cjsn'));
    finally sl.Free; end;
  end;

  procedure LoadCJSN(const sFile:AnsiString; var cf:TrComtradeData); var s:AnsiString; sl:TStringList; begin sl:=nil;
    try sl:=TStringList.Create; sl.LoadFromFile(sFile); s:=sl.Text;
      RecordLoadJSON(cf,PUTF8Char(StringToUTF8(s)),TypeInfo(TrComtradeFile));
    finally sl.Free; end;
  end;

{$RANGECHECKS OFF}
{$OVERFLOWCHECKS OFF}
{$BOOLEVAL OFF}

initialization
  TTextWriter.RegisterCustomJSONSerializerFromText(TypeInfo(TrSystemTime),__TrSystemTime);
  TTextWriter.RegisterCustomJSONSerializerFromText(TypeInfo(TrHeader),__TrHeader).Options:=[soReadIgnoreUnknownFields,soWriteHumanReadable];
  TTextWriter.RegisterCustomJSONSerializerFromText(TypeInfo(TrAnalogChannelInfo),__TrAnalogChannelInfo).Options:=[soReadIgnoreUnknownFields,soWriteHumanReadable];;
  TTextWriter.RegisterCustomJSONSerializerFromText(TypeInfo(TrDiscreteChannelInfo),__TrDiscreteChannelInfo).Options:=[soReadIgnoreUnknownFields,soWriteHumanReadable];;
  TTextWriter.RegisterCustomJSONSerializerFromText(TypeInfo(TrRateInfo),__TrRateInfo).Options:=[soReadIgnoreUnknownFields,soWriteHumanReadable];;
  TTextWriter.RegisterCustomJSONSerializerFromText(TypeInfo(TrConfiguration),__TrConfiguration).Options:=[soReadIgnoreUnknownFields,soWriteHumanReadable];;
  TTextWriter.RegisterCustomJSONSerializerFromText(TypeInfo(TrSampleInfo),__TrSampleInfo).Options:=[soReadIgnoreUnknownFields,soWriteHumanReadable];
  TTextWriter.RegisterCustomJSONSerializerFromText(TypeInfo(TrComtradeData),__TrComtradeData).Options:=[soReadIgnoreUnknownFields,soWriteHumanReadable];
  TTextWriter.RegisterCustomJSONSerializerFromText(TypeInfo(TrComtradeFile),__TrComtradeFile).Options:=[soReadIgnoreUnknownFields,soWriteHumanReadable];

end.
