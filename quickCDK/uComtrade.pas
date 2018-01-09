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
    _s:RawUTF8; // чтоб сгенерить TypeInfo
  end;

  TrHeader=packed record
    _sCell:RawUTF8;                   // ячейка
    _sConnection:RawUTF8;             // присоединение
    _sCorporation:RawUTF8;            // предприятие
    _sDevice:RawUTF8;                 // идентификатор устройства
    _sStation:RawUTF8;                // станция
    _sSubStation:RawUTF8;             // подстанция
    _sInfo:String;                    // вся другая информация
  end;

  TrAnalogChannelInfo=packed record
    _lwChannelNumber:cardinal;        // номер канала
    _sChannelID:RawUTF8;              // идентификатор канала
    _sPhase:RawUTF8;                  // идентификатор фазы
    _sCircuit:RawUTF8;                // цепь/компонент, который контролируется
    _sUnit:RawUTF8;                   // единица измерения в канале (kV, kA, и т.д.)
    _dA:Double;                       // вещественное число (см. ниже)
    _dB:Double;                       // вещественное число. Коэффициент преобразования к ЛА (т.е., записанная величина х соответствует (ах+b) в единицах, указанных выше)
    _dSkew:Double;                    // вещественное число. Сдвиг времени (в  с) в канале с начала отсчета
    _dMin:Double;                     // целое, равное минимальной величине (нижняя граница диапазона) для выборок этого канала
    _dMax:Double;                     // целое, равное максимальной величине (верхняя граница диапазона) для выборок этого канала
    _Units:array of RawUTF8;          // массив из 4х значений для единиц измерения: для относительных, первичных, вторичных величин и для величин в устройстве (в БЭМПе дискреты)
    _Coefficients:array of Double;    // массив из 4х значений для отображения величин: для относительных, первичных, вторичных и в устройстве
  end;

  TrDiscreteChannelInfo=packed record
    _lwChannelNumber:cardinal;        // номер канала
    _sChannelID:RawUTF8;              // идентификатор канала
    _bNormalValue:boolean;            // (0 или 1) нормальное состояние этого канала (относится только к дискретным каналам) (1 - инверсный канал)
  end;

  TrRateInfo=packed record
    _lwSamplingRate:cardinal;         // частота дискретизации в Гц
    _lwSampleOrgNumber:cardinal;      // номер начальной выборки для данной скорости
    _lwSampleEndNumber:cardinal;      // номер последней выборки для данной скорости
    _s:RawUTF8;                       // чтоб сгенерить TypeInfo
  end;

  TrConfiguration=packed record
    _sStationName:RawUTF8;                // уникальное название регистратора
    _sStationID:RawUTF8;                  // уникальный номер регистратора
    _lwAnalogsCount:cardinal;             // количество аналоговых каналов
    _lwDiscretesCount:cardinal;           // количество дискретных каналов
    _AnalogChannels:array of TrAnalogChannelInfo;     // массив описаний аналоговых каналов
    _DiscreteChannels:array of TrDiscreteChannelInfo; // массив описаний дискретных каналов
    _lwPowerFrequency:cardinal;           // частота сети в Гц (50 или 60)
    _lwRatesCount:cardinal;               // количество различных скоростей дискретизации в файле данных
    _Rates:array of TrRateInfo;           // массив описаний частот дискретизации
    _stFirstValueTimeStamp:TrSystemTime;  // метка времени для первого значения в файле данных
    _stLaunchTimeStamp:TrSystemTime;      // метка времени для момента пуска
  end;

  TrSampleInfo=packed record
    _lwSampleNumber:cardinal;         // номер выборки
    _lwSampleTime:cardinal;           // время в миллисекундах от начала записи
    _AnalogValues:array of Double;    // массив значений для аналоговых каналов
    _DiscreteValues:array of boolean; // массив значений для дискретных каналов
  end;

  TrComtradeData=packed record        // данные в Comtrade-формате
    _Header:TrHeader;                 // файл .hdr
    _Configuration:TrConfiguration;   // файл .cfg
    _Data:array of TrSampleInfo;      // файл .dat
  end;

  TrComtradeFile=packed record        // Comtrade-файл
    _ComtradeData:TrComtradeData;     // данные файла
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



  procedure SaveCJSN(const sFile:AnsiString; const cf:TrComtradeData); // ComtradeJSoN, расширение файла будет заменено на .cjsn

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
