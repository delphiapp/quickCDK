unit qCDKclasses;
// (C) Witcher,2014.03
interface

uses Windows,Classes,IniFiles,SysUtils,Messages,
  uUSBNotifier,uSynchroObjects,uExtClasses,uTraffic,uProgresses,uNamedSpace,uCalcTypes;

const
////////// константы ошибок (communication errors)
  ceSuccess=0;                          // нет ошибки
// коды для пакета qCDK
  ceNoCommunicationSocket=-1;           // нет коммуникационного сокета
  ceNoCommunicationProtocol=-2;         // нет коммуникационного протокола (или он не того класса чем ожидается)
  ceSysException=-3;                    // системная ошибка, что-то случилось во время выполнения функции
  ceNoTransactionData=-4;               // не получилось создать "данные для транзакции", может параметры неверные
  ceBroadCast=-5;                       // широковещательный запрос, ответ возвращён не будет
  ceTimeout=-6;                         // таймаут ожидания
  ceCallbackWait=-7;                    // функция в режиме ожидания на вызов функции обратного вызова
  ceAbortOperation=-8;                  // операция была прервана
  ceQueueOverflow=-9;                   // количество запросов в очереди превышает максимальное, операция не выполнена
  ceWriteError=-10;                     // ошибка записи, не удалось передать запрос
  ceBufferSize=-11;                     // недостаточный размер буфера данных

  ceUnknownError=-13;                   // неизвестная ошибка (неизвестно что случилось)
  ceFrameCRC=-14;                       // ошибка контрольной суммы фрейма (пакета)
  ceFrameLength=-15;                    // ошибка длины фрейма (неверная длина пакета)
  ceCorruptedRequest=-16;               // неверный запрос (содержимое пакета не соответствует спецификации протокола)
  ceCorruptedResponse=-17;              // неверный ответ (содержимое пакета не соответствует спецификации протокола)
  ceIncorrectRequest=-18;               // в запросе есть некорректные данные (не то, что ожидается)
  ceIncorrectResponse=-19;              // в ответе есть некорректные данные (не то, что ожидается)
  ceNoCommunicationConnection=-20;      // нет коммуникационного соединения
  ceNoCommunicationDevice=-21;          // нет коммуникационного устройства
  ceNoCommunicationThread=-22;          // нет коммуникационного потока для обработки транзакции
  ceIncorrectTransmissionMode=-23;      // неверный тип передачи данных

  ceDataSize=-24;                       // неверный размер данных (размер входных данных, размер выходного буфера и т.д.)
  ceDataFormat=-25;                     // неверный формат данных (файла, рисунка и т.д.)

// системные коды
  ceInvalidFunction=$01;                // неверная функция
  ceInvalidHandle=$06;                  // неверный дескриптор
  ceDataCRC=$17;                        // ошибка в данных (CRC)

  CommunicationErrorsCount=25;
  CommunicationErrorsInfos:array[0..CommunicationErrorsCount-1]of TIdentMapEntry=(
    (Value:ceSuccess;                           Name:'0 - нет ошибки'),
    (Value:ceNoCommunicationSocket;             Name:'-1 - неизвестная ошибка (неизвестно что случилось)'),
    (Value:ceNoCommunicationProtocol;           Name:'-2 - нет коммуникационного протокола (или он не того класса чем ожидается)'),
    (Value:ceSysException;                      Name:'-3 - системная ошибка, что-то случилось во время выполнения функции'),
    (Value:ceNoTransactionData;                 Name:'-4 - не получилось создать "данные для транзакции", может параметры неверные'),
    (Value:ceBroadCast;                         Name:'-5 - широковещательный запрос, ответ возвращён не будет'),
    (Value:ceTimeout;                           Name:'-6 - таймаут ожидания'),
    (Value:ceCallbackWait;                      Name:'-7 - функция в режиме ожидания на вызов функции обратного вызова'),
    (Value:ceAbortOperation;                    Name:'-8 - операция была прервана'),
    (Value:ceQueueOverflow;                     Name:'-9 - количество запросов в очереди превышает максимальное, операция не выполнена'),
    (Value:ceWriteError;                        Name:'-10 - ошибка записи, не удалось передать запрос'),
    (Value:ceBufferSize;                        Name:'-11 - недостаточный размер буфера данных'),

    (Value:ceUnknownError;                      Name:'-13 - неизвестная ошибка (неизвестно что случилось)'),
    (Value:ceFrameCRC;                          Name:'-14 - ошибка контрольной суммы фрейма (пакета)'),
    (Value:ceFrameLength;                       Name:'-15 - ошибка длины фрейма (неверная длина пакета)'),
    (Value:ceCorruptedRequest;                  Name:'-16 - неверный запрос (содержимое пакета не соответствует спецификации протокола)'),
    (Value:ceCorruptedResponse;                 Name:'-17 - неверный ответ (содержимое пакета не соответствует спецификации протокола)'),
    (Value:ceIncorrectRequest;                  Name:'-18 - в запросе есть некорректные данные (не то, что ожидается)'),
    (Value:ceIncorrectResponse;                 Name:'-19 - в ответе есть некорректные данные (не то, что ожидается)'),
    (Value:ceNoCommunicationConnection;         Name:'-20 - нет коммуникационного соединения'),
    (Value:ceNoCommunicationDevice;             Name:'-21 - нет коммуникационного устройства'),
    (Value:ceNoCommunicationThread;             Name:'-22 - нет коммуникационного потока для обработки транзакции'),
    (Value:ceIncorrectTransmissionMode;         Name:'-23 - тип представления данных при передаче неизвестен'),

    (Value:ceDataSize;                          Name:'-24 - неверный размер данных (размер входных данных, размер выходного буфера и т.д.)'),
    (Value:ceDataFormat;                        Name:'-25 - неверный формат данных (файла, рисунка и т.д.)')
  );

// константы свойств объектов - используются только в этом модуле
  ndxActiveNotifyEnabled=188;

  ndxAutoAuthorize=201; ndxAutoAuthorizePeriod=202; ndxAuthorized=203;
  ndxAutoAlive=204; ndxAutoAlivePeriod=205;
  ndxAutoConnect=206; ndxAutoConnectPeriod=207; ndxConnected=208;
  ndxAutoInitialize=209; ndxInitialized=210;
  ndxAutoRefresh=211; ndxAutoRefreshPeriod=212;
  ndxAutoSynchronize=213; ndxAutoSynchronizePeriod=214; ndxSynchronized=215;
  ndxAutoTick=216; ndxAutoTickPeriod=217; ndxAutoUpdate=218; ndxAutoUpdatePeriod=219;

  ndxUpdating=220;
  ndxTagsCount=222;

  ndxBytesForRead=230; ndxBytesForWrite=231; ndxCommHandle=232; ndxCommMask=233; ndxCommName=234;

  ndxOverlapped=250;

  ndxCommInputQueueSize=259; ndxCommOutputQueueSize=260; ndxLogDetailed=261; ndxLogFile=262; ndxLogging=263;
  ndxLogMaxSize=264; ndxLogRecreate=265; ndxRetries=266;

  ndxPurgeActionsBeforeRead=280; ndxPurgeActionsBeforeWrite=281;
  ndxTimeoutReadInterChar=282; ndxTimeoutReadTotal=283; ndxTimeoutWriteTotal=284;

  ndxAddressSize=300; ndxBroadcastAddress=301; ndxDefaultAddress=302; ndxMaxPacketSize=303; ndxTransmissionMode=304;

type
  EqCDKexception=class(Exception);
///!!! использование критической секции должно быть вне объекта, например не как здесь:
/// поток1                        поток2
/// ---                           fCommObject.Free;
/// fCommObject.Lock;             --- (Free ещё не завершён, поток1 ожидает освобождение критической секции)
/// ---                           fCommObject уничтожен вместе с критической секцией, поток1 в непонятном состоянии
/// лучше использовать критическую секцию объекта более верхнего уровня (Owner'а), например TCommunicationSpace

  TCommunicationSpace=class;
  TCommunicationConnection=class;
////////// объект коммуникации - общий класс, сделаем сразу с критической секцией - пригодится для многопоточности
  TCommunicationObject=class(TNamedObject)
  private
    function GetOwner:TCommunicationSpace;
    procedure SetOwner(const cs:TCommunicationSpace);
  protected
    fbActiveNotifyEnabled,fbActive,fbConnected:boolean;

    function DoGetAsText:AString; override;
    function DoGetStateInfo:AnsiString; override;
    procedure DoSetAsText(const s:AString); override;

    function DoGetBool(const ndx:integer):Bool64; override;               // все булевские свойства
    procedure DoSetBool(const ndx:integer; const b:Bool64); override;     // все булевские свойства
  protected
    procedure DoActive; virtual;
  protected
    property ActiveNotifyEnabled:boolean    index ndxActiveNotifyEnabled    read GetB1 write SetB1; // разрешение на уведомление об изменении свойства Active - очень часто меняется, иногда не нужно это
    property Owner:TCommunicationSpace read GetOwner write SetOwner;              // владелец объектов
  public
    class function GetObjectByName(sName:AnsiString):TCommunicationObject; virtual; // поиск объекта по имени

    constructor Create; override;
    class function NewInstance:TObject; override; // здесь объявим fOwner'а, чтобы в конструкторе он уже был

    procedure Lock; override;               // блокировка критической секцией
    function TryLock:boolean; override;     // попытка блокировки критической секцией
    procedure Unlock; override;             // разблокировка критической секцией

    procedure SetDefault; override;         // параметры по умолчанию
 public
    property Active:boolean                 read fbActive;                                          // объект активен (в данный момент используется - например, идёт чтение из сокета)
    property Connected:boolean              index ndxConnected              read GetB1 write SetB1; // объект имеет соединение (например, сокет подцеплён к физическому сокету)
  end;

////////// список объектов коммуникации
  TCommunicationObjects=class(TNamedObjects)
  protected
    function GetObject(ndx:integer):TCommunicationObject; reintroduce; virtual;
  public
    constructor Create; override;

    function CreateObject:TCommunicationObject; reintroduce; virtual;
    function AddObject(co:TCommunicationObject):boolean; reintroduce; virtual;
    function RemoveObject(co:TCommunicationObject):boolean; reintroduce; virtual;
    function IndexOf(co:TCommunicationObject):integer; reintroduce; virtual;
  public
    property Objects[ndx:integer]:TCommunicationObject read GetObject; default;
  end;

////////// список классов объектов коммуникации
  TCommunicationObjectClass=class of TCommunicationObject;

  TCommunicationObjectClasses=class(TNamedObjectClasses)
  protected
    function GetClass(ndx:integer):TCommunicationObjectClass; reintroduce; virtual;
  public
    constructor Create; override;
    function AddClass(coclass:TCommunicationObjectClass):boolean; reintroduce; virtual;
    function RemoveClass(coclass:TCommunicationObjectClass):boolean; reintroduce; virtual;
    function IndexOf(coclass:TCommunicationObjectClass):integer; reintroduce; virtual;
  public
    property Classes[ndx:integer]:TCommunicationObjectClass read GetClass; default;
  end;

////////// коммуникационный режим
  TCommunicationMode=class(TCommunicationObject)
  private
  protected
    frCommTimeouts:TCOMMTIMEOUTS;
    flwCommMask,flwCommInputQueueSize,flwCommOutputQueueSize:longword; fsCommName:AnsiString;
    fbLogDetailed,fbLogging,fbLogRecreate:boolean; flwLogMaxSize:longword; fsLogFile:AnsiString;
    fiRetries:integer;

    function DoGetAsText:AString; override;
    function DoGetStateInfo:AnsiString; override;
    procedure DoSetAsText(const s:AString); override;

    function DoGetAString(const ndx:integer):AString; override;           // все строковые свойства
    function DoGetBool(const ndx:integer):Bool64; override;               // все булевские свойства
    function DoGetInt(const ndx:integer):Int64; override;                 // все знаковые целые свойства
    function DoGetUInt(const ndx:integer):UInt64; override;               // все беззнаковые целые свойства

    procedure DoSetAString(const ndx:integer; const s:AString); override; // все строковые свойства
    procedure DoSetBool(const ndx:integer; const b:Bool64); override;     // все булевские свойства
    procedure DoSetInt(const ndx:integer; const i:Int64); override;       // все знаковые целые свойства
    procedure DoSetUInt(const ndx:integer; const ui:UInt64); override;    // все беззнаковые целые свойства
  protected
    function GetCommTimeouts:TCOMMTIMEOUTS; virtual;
    procedure SetCommTimeouts(const ct:TCOMMTIMEOUTS); virtual;
  public
    procedure SetDefault; override; // параметры по умолчанию
  public
    class function GetClassCaption:AString; override;       // описание класса
    class function GetClassDescription:AString; override;   // подробное описание класса

    // коммуникационная маска - используется своим классом
    property CommMask:longword index ndxCommMask read GetUI32 write SetUI32;
    // идентификационное имя коммуникационного порта
    property CommName:AnsiString index ndxCommName read GetAString write SetAString;
    // таймауты в стиле последовательного порта
    property CommTimeouts:TCOMMTIMEOUTS read GetCommTimeouts write SetCommTimeouts;
    // размер входного буфера (для чтения)
    property CommInputQueueSize:longword index ndxCommInputQueueSize read GetUI32 write SetUI32;
    // размер выходного буфера (для записи)
    property CommOutputQueueSize:longword index ndxCommOutputQueueSize read GetUI32 write SetUI32;
    // детальное протоколирование - при Loggging=true записываются и детали работы
    property LogDetailed:boolean index ndxLogDetailed read GetB1 write SetB1;
    // имя файла для протоколирования
    property LogFile:AnsiString index ndxLogFile read GetAString write SetAString;
    // используется протоколирование или нет - важные события
    property Logging:boolean index ndxLogging read GetB1 write SetB1;
    // максимальный размер лога
    property LogMaxSize:longword index ndxLogMaxSize read GetUI32 write SetUI32;
    // создать лог заново
    property LogRecreate:boolean index ndxLogRecreate read GetB1 write SetB1;
    // количество попыток
    property Retries:integer index ndxRetries read GetI32 write SetI32;
  end;

  TCommunicationModeClass=class of TCommunicationMode;

////////// список режимов
  TCommunicationModes=class(TCommunicationObjects)
  protected
    function GetObject(ndx:integer):TCommunicationMode; reintroduce; virtual;
  public
    constructor Create; override;

    function CreateObject:TCommunicationMode; reintroduce; virtual;
    function AddObject(cm:TCommunicationMode):boolean; reintroduce; virtual;
    function RemoveObject(cm:TCommunicationMode):boolean; reintroduce;  virtual;
    function IndexOf(cm:TCommunicationMode):integer; reintroduce; virtual;
  public
    property Objects[ndx:integer]:TCommunicationMode read GetObject; default;
  end;

////////// список классов режимов
  TCommunicationModeClasses=class(TCommunicationObjectClasses)
  protected
    function GetClass(ndx:integer):TCommunicationModeClass; reintroduce; virtual;
  public
    function AddClass(cmclass:TCommunicationModeClass):boolean; reintroduce; virtual;
    function RemoveClass(cmclass:TCommunicationModeClass):boolean; reintroduce; virtual;
    function IndexOf(cmclass:TCommunicationModeClass):integer; reintroduce; virtual;
  public
    property Classes[ndx:integer]:TCommunicationModeClass read GetClass ; default;
  end;

////////// коммуникационный сокет - через него реальные данные идут
  TCommunicationSocket=class(TCommunicationObject)
  private
  protected
    fhCommHandle:THandle;                           // хендл коммуникационного ресурса-сокета
    fsCommName:AnsiString;                          // имя коммуникационного ресурса-сокета

    flwRefCount:longword;                           // счётчик ссылок на порт - лучше реализовать через DuplicateHandle

    fbOverlapped:boolean; // асинхронный сокет

    function DoGetAsText:AString; override;
    function DoGetStateInfo:AnsiString; override;
    procedure DoSetAsText(const s:AString); override;

    function DoGetAString(const ndx:integer):AString; override;           // все строковые свойства
    function DoGetBool(const ndx:integer):Bool64; override;               // все булевские свойства
    function DoGetUInt(const ndx:integer):UInt64; override;               // все беззнаковые целые свойства

    procedure DoSetBool(const ndx:integer; const b:Bool64); override;     // все булевские свойства
    procedure DoSetUInt(const ndx:integer; const ui:UInt64); override;    // все беззнаковые целые свойства
  protected
    fLastConnection:TCommunicationConnection;       // последний TCommunicationConnection, который обращался к сокету
    function GetCommTimeouts:TCOMMTIMEOUTS; virtual;
    procedure SetCommTimeouts(const ct:TCOMMTIMEOUTS); virtual;

    function DoCreateHandle:THandle; virtual;         // создание подключения к коммукационному ресурсу
    procedure DoDestroyHandle; virtual;               // освобождение подключения к коммукационному ресурсу
//    procedure DoRealCreate; virtual;                  // наследники здесь должны инициализировать данные объекта - вызывается один раз для первого синглтона
//    procedure DoRealDestroy; virtual;                 // наследники здесь должны освобождать созданные ресурсы - вызывается один раз для первого синглтона
  public
    class function GetClassCaption:AString; override;       // описание класса
    class function GetClassDescription:AString; override;   // подробное описание класса

    // конструктор нужен с именем для сокета - будем синглтоны реализовывать,
    // т.е. один объект на один именнованный сокет (физический ком.порт и др.)
    constructor Create(sCommName:AnsiString; bOverlapped:boolean=false); reintroduce; virtual;
    destructor Destroy; override;
    procedure SetDefault; override; // параметры по умолчанию

    class function GetObjectByName(sName:AnsiString):TCommunicationObject; override; // поиск объекта по имени
//    class function NewInstance:TObject; override; // это для синглтонов, вызывается в Create на самом первом begin, параметры конструктора для классовой функции неизвестны
    procedure FreeInstance; override;             // это для синглтонов, вызывается в Destroy на последнем end
  public
    // количество байт в буфере, готовых на чтение
    property CommBytesForRead:longword      index ndxBytesForRead           read GetUI32;
    // количество байт в буфере, готовых на запись
    property CommBytesForWrite:longword     index ndxBytesForWrite          read GetUI32;
    // идентификатор сокета
    property CommHandle:THandle             index ndxCommHandle             read GetUI32;
    // коммуникационная маска - используется своим классом (маска событий, например)
    property CommMask:longword              index ndxCommMask               read GetUI32    write SetUI32;
    // идентификационное имя сокета - только для чтения, по этому имени будет создан только один экземпляр объекта для доступа к сокету
    property CommName:AnsiString            index ndxCommName               read GetAString;
    // таймауты в стиле последовательного порта
    property CommTimeouts:TCOMMTIMEOUTS read GetCommTimeouts write SetCommTimeouts;
    // размер входного буфера (для чтения)
    property CommInputQueueSize:longword index ndxCommInputQueueSize read GetUI32 write SetUI32;
    // размер выходного буфера (для записи)
    property CommOutputQueueSize:longword index ndxCommOutputQueueSize read GetUI32 write SetUI32;
  public
  //======== все функции, реализующие обращение к одноименным Windows-функциям (без знака подчёркивания), POverlapped для асинхронных операций
  // в принципе блокировать функции не надо, т.к. они реализованы в Windows, хендл сокета - синхронизирующий для них объект (Windows или их драйвер сам синхронизирует работу с хендлом)
    // отменяет все ожидающие завершения операции над коммуникационным ресурсом, запущенные вызывающим потоком программы
    function _CancelIo:boolean; virtual;
    // очищает все буферы и форсирует запись всех буферизированных данных в выбранный коммуникационный ресурс
    function _FlushFileBuffers:boolean; virtual;
    // возвращает текущую маску событий коммуникационного ресурса
    function _GetCommMask(var lwEventMask:longword):boolean; virtual;
    // возвращает настройки таймаутов для всех операций чтения и записи для выбранного коммуникационного ресурса
    function _GetCommTimeouts(var rCommTimeouts:TCommTimeouts):boolean; virtual;
    // всегда вызывается в асинхронном режиме и производит проверку выполнения асинхронной операции
    function _GetOverlappedResult(const prOverlapped:POverlapped; var lwNumberOfBytesTransferred:longword; const bWait:boolean):boolean; virtual;
    // может очистить буфер приёма, буфер передачи, а также прервать выполнение операций чтения и записи выбранного коммуникационного ресурса
    function _PurgeComm(const lwPurgeAction:longword):boolean; virtual;
    // позволяет прочитать заданное количество символов (байт) из выбранного ресурса
    function _ReadFile(var Buffer; const lwNumberOfBytesToRead:longword; var lwNumberOfBytesRead:longword;
      const prOverlapped:POverlapped=nil):boolean; virtual;
    // устанавливает маску событий, которые будут отслеживаться для определённого коммуникационного ресурса;
    // отслеживание событий будет вестись только после вызова функции WaitCommEvent
    function _SetCommMask(const lwEventMask:longword):boolean; virtual;
    // устанавливает таймауты для всех операций чтения и записи для определённого коммуникационного ресурса
    function _SetCommTimeouts(const rCommTimeouts:TCommTimeouts):boolean; virtual;
    // устанавливает размеры буферов приёма и передачи для коммуникационного ресурса
    function _SetupComm(const lwInputQueueSize,lwOutputQueueSize:longword):boolean; virtual;
    // при успешном выполнении возвращает в параметре lwEventMask набор событий, которые произошли в коммуникационном ресурсе
    function _WaitCommEvent(var lwEventMask:longword; const prOverlapped:POverlapped=nil):boolean; virtual;
    // позволяет записать выбранное количество байт в коммуникационный ресурс
    function _WriteFile(const Buffer; const lwNumberOfBytesToWrite:longword; var lwNumberOfBytesWritten:longword;
      prOverlapped:POverlapped=nil):boolean; virtual;
  public
    function AllocateOverlapped:POverlapped; virtual;       // возвращает структуру для асинхронного сокета (нельзя для разных потоков одну и ту же использовать)
    procedure FreeOverlapped(const p:POverlapped); virtual; // уничтожает структуру для асинхронного сокета 

    property Overlapped:boolean index ndxOverlapped read GetB1{ write SetBoolean}; // в асинхронном сокете нужно использовать POverlapped
  end;

  TCommunicationSocketClass=class of TCommunicationSocket;

////////// список сокетов
  TCommunicationSockets=class(TCommunicationObjects)
  protected
    function GetObject(ndx:integer):TCommunicationSocket; reintroduce; virtual;
  public
    constructor Create; override;
    destructor Destroy; override;

    function CreateObject:TCommunicationSocket; reintroduce; virtual;
    function AddObject(cs:TCommunicationSocket):boolean; reintroduce; virtual;
    function RemoveObject(cs:TCommunicationSocket):boolean; reintroduce;  virtual;
    function IndexOf(cs:TCommunicationSocket):integer; reintroduce; virtual;
  public
    property Objects[ndx:integer]:TCommunicationSocket read GetObject; default;
  end;

////////// список классов сокетов
  TCommunicationSocketClasses=class(TCommunicationObjectClasses)
  protected
    function GetClass(ndx:integer):TCommunicationSocketClass; reintroduce; virtual;
  public
    function AddClass(csclass:TCommunicationSocketClass):boolean; reintroduce; virtual;
    function RemoveClass(csclass:TCommunicationSocketClass):boolean; reintroduce; virtual;
    function IndexOf(csclass:TCommunicationSocketClass):integer; reintroduce; virtual;
  public
    property Classes[ndx:integer]:TCommunicationSocketClass read GetClass; default;
  end;

////////// коммуникационное соединение
  TCommunicationConnection=class(TCommunicationObject)
  private
  protected
    flwPurgeActionsBeforeRead,flwPurgeActionsBeforeWrite:longword;
    fTrafficInfo:TTrafficInfo;

    fCommunicationMode:TCommunicationMode; fCommunicationModeClass:TCommunicationModeClass;
    fCommunicationSocket:TCommunicationSocket; fCommunicationSocketClass:TCommunicationSocketClass;
    fpBuffer:PAnsiChar; fiBufferCnt:integer; // буфер для работы внутри класса, сюда копируются считанные данные, и размер данных

    function DoGetAsText:AString; override;
    function DoGetStateInfo:AnsiString; override;
    procedure DoSetAsText(const s:AString); override;

    function DoGetUInt(const ndx:integer):UInt64; override;               // все беззнаковые целые свойства
    procedure DoSetBool(const ndx:integer; const b:Bool64); override;     // все булевские свойства
    procedure DoSetUInt(const ndx:integer; const ui:UInt64); override;    // все беззнаковые целые свойства

    function GetSelfTimeStamp(st:TSystemTime):AnsiString; override;
    procedure LogMessage(s:AnsiString); override;
  protected
    function GetCommunicationMode:TCommunicationMode; virtual;
    function GetCommunicationSocket:TCommunicationSocket; virtual;
    function GetTrafficInfo:TTrafficInfo; virtual;

    procedure SetCommunicationMode(const cm:TCommunicationMode); virtual;

    // чтение буфера драйвера коммуникационного сокета в строку длиной iBytesToRead (если длина равна -1, то в течение таймаута ожидаем символы)
    function ReadDriverBuffer(const iBytesToRead:integer=-1):AnsiString; virtual;
    procedure _OnChanged(Sender:TObject); virtual; // что-то изменилось (fCommunicationMode)
  public
    property Connected; // свойство, устанавливающее состояние соединения с коммуникационным сокетом

    // свойства коммуникационного сокета, внутренний объект класса
    // если уже соединены, то имя порта изменить нельзя
    property CommunicationMode:TCommunicationMode read GetCommunicationMode write SetCommunicationMode;
    // коммуникационный ресурс, объект создаётся классом при вызове Connect и уничтожается при вызове Disconnect
    property CommunicationSocket:TCommunicationSocket read GetCommunicationSocket; // полученная ссылка может быть неверна, т.к. сокет создаётся и уничтожается!!!
    // информация о трафике
    property TrafficInfo:TTrafficInfo read GetTrafficInfo;

    // операции (комбинация флагов), выполняемые перед любой операцией чтения Readxxx и записи Writexxx
    // PURGE_TXABORT=1 - прерывает все ожидающие и текущие операции записи в порт
    // PURGE_RXABORT=2 - прерывает все ожидающие и текущие операции чтения из порта
    // PURGE_TXCLEAR=4 - очищает буфер передачи драйвера
    // PURGE_RXCLEAR=8 - очищает буфер приёма драйвера
    property PurgeActionsBeforeRead:LongWord index ndxPurgeActionsBeforeRead read GetUI32 write SetUI32;
    // операции, выполняемые перед любой операцией записи Writexxx (комбинация флагов)
    property PurgActionseBeforeWrite:LongWord index ndxPurgeActionsBeforeWrite read GetUI32 write SetUI32;
    // межсимвольный таймаут чтения
    property TimeoutReadInterChar:LongWord index ndxTimeoutReadInterChar read GetUI32 write SetUI32;
    // полный таймаут чтения
    property TimeoutReadTotal:LongWord index ndxTimeoutReadTotal read GetUI32 write SetUI32;
    // полный таймаут записи
    property TimeoutWriteTotal:LongWord index ndxTimeoutWriteTotal read GetUI32 write SetUI32;
  public
    class function GetClassCaption:AString; override;       // описание класса
    class function GetClassDescription:AString; override;   // подробное описание класса
  
    constructor Create; override;
    destructor Destroy; override;
    procedure SetDefault; override; // параметры по умолчанию

    // применение настроек коммуникационного режима к открытому сокету
    function ApplyCommunicationMode:boolean; virtual;
    // выполнение операций очистки перед чтением
    function ApplyPurgeBeforeRead:boolean; virtual;
    // выполнение операций очистки перед записью
    function ApplyPurgeBeforeWrite:boolean; virtual;
    // соединиться с настройками и именем сокета в CommunicationMode
    function Connect:boolean; overload; virtual;
    // соединиться с настройками в CommunicationMode и именем sCommName
    function Connect(sCommName:AnsiString):boolean; overload; virtual;
    // разъединиться с текущим коммуникационным сокетом
    function Disconnect:boolean; virtual;

    ////////// функции чтения данных из сокета
    // чтение в буфер pBuf размером iBufSize, при iBufSize=0 возвращается true, при значениях меньше 0 - false,
    // в других случаях возвращается true и в iBytesCount количество байт, если получилось считать
    function ReadBuffer(const pBuf:pointer; const iBufSize:integer; out iBytesCount:integer):boolean; overload; virtual;
    // чтение в буфер, возвращается true только при полном чтении всего буфера
    function ReadBuffer(const pBuf:pointer; const iBufSize:integer):boolean; overload; virtual;
    // чтение символа
    function ReadChar(out c:AnsiChar):boolean; virtual;
    // чтение числа с плавающей запятой типа single
    function ReadFloat(out s:single):boolean; overload; virtual;
    // чтение числа с плавающей запятой типа double, real
    function ReadFloat(out d:double):boolean; overload; virtual;
    // чтение числа с плавающей запятой типа extended
    function ReadFloat(out e:extended):boolean; overload; virtual;
    // чтение беззнакового 8-битного числа (байта)
    function ReadInteger(out ui8:byte):boolean; overload; virtual;
    // чтение знакового 8-битного числа
    function ReadInteger(out i8:shortint):boolean; overload; virtual;
    // чтение беззнакового 16-битного числа
    function ReadInteger(out ui16:word):boolean; overload; virtual;
    // чтение знакового 16-битного числа
    function ReadInteger(out i16:smallint):boolean; overload; virtual;
    // чтение беззнакового 32-битного числа
    function ReadInteger(out ui32:longword):boolean; overload; virtual;
    // чтение знакового 32-битного числа
    function ReadInteger(out i32:longint):boolean; overload; virtual;
    // чтение знакового 64-битного числа
    function ReadInteger(out i64:int64):boolean; overload; virtual;
    // чтение пакета в виде строки, длина определяется концом строки sEnd (Result=true) или таймаутом (Result=false),
    // начало строки sStart может не задаваться, тогда будет сразу идти чтение строки без ожидания начальных символов,
    // если конец строки sEnd не задан, то Result=false всегда
    // bIncludeStrings при значении true добавляет в пакет начало sStart и конец sEnd
    // таймаут может произойти и по межсимвольному таймауту, если он задан
    function ReadPacket(out sPacket:AnsiString; const sStart:AnsiString='';
      const sEnd:AnsiString=''; const bIncludeString:boolean=true):boolean; virtual;
    // чтение строки длиной iStringLen (если длина равна -1, то в течение таймаута)
    function ReadString(const iStringLen:integer=-1):AnsiString; virtual;

    ////////// функции ожидания определённых данных из сокета
    // ожидание байтов в буфере pBuf размером iBufSize, при iBufSize=0 возвращается true, при значениях меньше 0 - false,
    // в других случаях возвращается true при полном совпадении прочитанных байт с данными в буфере
    function WaitBuffer(const pBuf:pointer; const iBufSize:integer):boolean; virtual;
    // ожидание одиночного символа
    function WaitChar(const c:AnsiChar):boolean; virtual;
    // ожидание числа с плавающей запятой типа single
    function WaitFloat(const s:single):boolean; overload; virtual;
    // ожидание числа с плавающей запятой типа double, real
    function WaitFloat(const d:double):boolean; overload; virtual;
    // ожидание числа с плавающей запятой типа extended
    function WaitFloat(const e:extended):boolean; overload; virtual;
    // ожидание беззнакового 8-битного числа (байта)
    function WaitInteger(const ui8:byte):boolean; overload; virtual;
    // ожидание знакового 8-битного числа
    function WaitInteger(const i8:shortint):boolean; overload; virtual;
    // ожидание беззнакового 16-битного числа
    function WaitInteger(const ui16:word):boolean; overload; virtual;
    // ожидание знакового 16-битного числа
    function WaitInteger(const i16:smallint):boolean; overload; virtual;
    // ожидание беззнакового 32-битного числа
    function WaitInteger(const ui32:longword):boolean; overload; virtual;
    // ожидание знакового 32-битного числа
    function WaitInteger(const i32:longint):boolean; overload; virtual;
    // ожидание знакового 64-битного числа
    function WaitInteger(const i64:int64):boolean; overload; virtual;
    // ожидание строки
    function WaitString(const s:AnsiString):boolean; virtual;

    ////////// функции записи данных в сокет
    // запись из буфера pBuf размером iBufSize, при iBufSize=0 возвращается true, при значениях меньше 0 - false,
    // в других случаях возвращается true и в iBytesCount количество байт, если получилось записать, иначе - false
    function WriteBuffer(const pBuf:pointer; const iBufSize:integer; out iBytesCount:integer):boolean; overload; virtual;
    // запись из буфера, возвращается true только при полной записи всего буфера
    function WriteBuffer(const pBuf:pointer; const iBufSize:integer):boolean; overload; virtual;
    // запись символа
    function WriteChar(const c:AnsiChar):boolean; virtual;
    // запись числа с плавающей запятой типа single
    function WriteFloat(const s:single):boolean; overload; virtual;
    // запись числа с плавающей запятой типа double, real
    function WriteFloat(const d:double):boolean; overload; virtual;
    // запись числа с плавающей запятой типа extended
    function WriteFloat(const e:extended):boolean; overload; virtual;
    // запись беззнакового 8-битного числа (байта)
    function WriteInteger(out ui8:byte):boolean; overload; virtual;
    // запись знакового 8-битного числа
    function WriteInteger(const i8:shortint):boolean; overload; virtual;
    // запись беззнакового 16-битного числа
    function WriteInteger(const ui16:word):boolean; overload; virtual;
    // запись знакового 16-битного числа
    function WriteInteger(const i16:smallint):boolean; overload; virtual;
    // запись беззнакового 32-битного числа
    function WriteInteger(const ui32:longword):boolean; overload; virtual;
    // запись знакового 32-битного числа
    function WriteInteger(const i32:longint):boolean; overload; virtual;
    // запись знакового 64-битного числа
    function WriteInteger(const i64:int64):boolean; overload; virtual;
    // запись строки
    function WriteString(const s:AnsiString):boolean; virtual;
  end;

  TCommunicationConnectionClass=class of TCommunicationConnection;

////////// список соединений
  TCommunicationConnections=class(TCommunicationObjects)
  protected
    function GetObject(ndx:integer):TCommunicationConnection; reintroduce; virtual;
  public
    constructor Create; override;

    function CreateObject:TCommunicationConnection; reintroduce; virtual;
    function AddObject(cc:TCommunicationConnection):boolean; reintroduce; virtual;
    function RemoveObject(cc:TCommunicationConnection):boolean; reintroduce;  virtual;
    function IndexOf(cc:TCommunicationConnection):integer; reintroduce; virtual;
  public
    property Objects[ndx:integer]:TCommunicationConnection read GetObject; default;
  end;

////////// список классов соединений
  TCommunicationConnectionClasses=class(TCommunicationObjectClasses)
  protected
    function GetClass(ndx:integer):TCommunicationConnectionClass; reintroduce; virtual;
  public
    function AddClass(ccclass:TCommunicationConnectionClass):boolean; reintroduce; virtual;
    function RemoveClass(ccclass:TCommunicationConnectionClass):boolean; reintroduce; virtual;
    function IndexOf(ccclass:TCommunicationConnectionClass):integer; reintroduce; virtual;
  public
    property Classes[ndx:integer]:TCommunicationConnectionClass read GetClass; default;
  end;
  
////////// коммуникационный протокол
  TCommunicationProtocol=class(TCommunicationObject)
  protected
    flwAddressSize,flwBroadcastAddress,flwDefaultAddress,flwMaxPacketSize,flwTransmissionMode:longword;

    function DoGetAsText:AString; override;
    function DoGetStateInfo:AnsiString; override;
    procedure DoSetAsText(const s:AString); override;

    function DoGetUInt(const ndx:integer):UInt64; override;               // все беззнаковые целые свойства
    procedure DoSetUInt(const ndx:integer; const ui:UInt64); override;    // все беззнаковые целые свойства
  protected
    function GetErrorAsText(ce:integer):AnsiString; virtual;              // ошибка в виде строки
    function MakePacket(const sHexBody:AnsiString):AnsiString; virtual;   // создание пакета из тела пакета (символы начала и конца, контрольная сумма и т.д.
  public


//    property BitOrder:
//    property ByteOrder:
//    property ByteSize:longword;  // размер минимально передаваемых данных, обычно 8 бит
    property AddressSize:UInt32       index ndxAddressSize        read GetUI32  write SetUI32; // 0 - по умолчанию
    property BroadcastAddress:UInt32  index ndxBroadcastAddress   read GetUI32  write SetUI32; // 0xFF - по умолчанию
    property DefaultAddress:UInt32    index ndxDefaultAddress     read GetUI32  write SetUI32; // 1 - адрес по умолчанию
    property MaxPacketSize:UInt32     index ndxMaxPacketSize      read GetUI32  write SetUI32; // 0 - по умолчанию, обычно без ограничений
    property TransmissionMode:UInt32  index ndxTransmissionMode   read GetUI32  write SetUI32; // 0 - тип представления данных в протоколе    
  public
    procedure SetDefault; override; // параметры по умолчанию

    //
//    function HandleRequest(sRequest:AnsiString;
    // обрабатывает ответ на основе запроса, заполняет данными область памяти pDst, если нужно
    function HandleResponse(sRequest,sResponse:AnsiString; pDst:pointer; iDstSize:integer):integer; virtual;

    function IsBroadcastRequest(const sRequest:AnsiString):boolean; virtual; // проверка на широковещательный запрос
    // IsValidRequest
    // IsValidResponse
    function IsResponseSuccess(const ce:integer):boolean; virtual;           // проверка кода ошибки ответа (HandleResponse) на правильность ответа

    // создаёт запрос на основе массива значений или указателя на буфер данных (адрес устройства, функция, параметры)
    // в случае неуспешного формирования запроса вызывается исключение
    function MakeRequest(arrPacketData:array of Int64):AnsiString; overload; virtual;
    function MakeRequest(const pRequest:pointer; const lwSize:longword):AnsiString; overload; virtual;
    // в случае неуспешного формирования запроса возвращается код ошибки, и индекс ndxError в массиве
    function MakeRequest(arrPacketData:array of Int64; out sRequest:AnsiString; out ndxError:integer):integer; overload; virtual;
    function MakeRequest(const pRequest:pointer; const lwSize:longword; out sRequest:AnsiString; out ndxError:integer):integer; overload; virtual;

    // создаёт ответ на основе массива значений или указателя на буфер данных (адрес устройства, функция, параметры)
    // в случае неуспешного формирования твета вызывается исключение
    function MakeResponse(arrPacketData:array of Int64):AnsiString; overload; virtual;
    function MakeResponse(const pResponse:pointer; const lwSize:longword):AnsiString; overload; virtual;
    // в случае неуспешного формирования ответа возвращается код ошибки, и индекс ndxError в массиве
    function MakeResponse(arrPacketData:array of Int64; out sResponse:AnsiString; out ndxError:integer):integer; overload; virtual;
    function MakeResponse(const pResponse:pointer; const lwSize:longword; out sResponse:AnsiString; out ndxError:integer):integer; overload; virtual;
  end;

  TCommunicationProtocolClass=class of TCommunicationProtocol;

////////// список протоколов
  TCommunicationProtocols=class(TCommunicationObjects)
  protected
    function GetObject(ndx:integer):TCommunicationProtocol; reintroduce; virtual;
  public
    constructor Create; override;

    function CreateObject:TCommunicationProtocol; reintroduce; virtual;
    function AddObject(cp:TCommunicationProtocol):boolean; reintroduce; virtual;
    function RemoveObject(cp:TCommunicationProtocol):boolean; reintroduce;  virtual;
    function IndexOf(cp:TCommunicationProtocol):integer; reintroduce; virtual;
  public
    property Objects[ndx:integer]:TCommunicationProtocol read GetObject; default;
  end;

////////// список классов протоколов
  TCommunicationProtocolClasses=class(TCommunicationObjectClasses)
  protected
    function GetClass(ndx:integer):TCommunicationProtocolClass; reintroduce; virtual;
  public
    function AddClass(cpclass:TCommunicationProtocolClass):boolean; reintroduce; virtual;
    function RemoveClass(cpclass:TCommunicationProtocolClass):boolean; reintroduce; virtual;
    function IndexOf(cpclass:TCommunicationProtocolClass):integer; reintroduce; virtual;
  public
    property Classes[ndx:integer]:TCommunicationProtocolClass read GetClass; default;
  end;

  PrTagDescriptor=^TrTagDescriptor;
  TrTagDescriptor=packed record
    _id:longword; _sName,_sPath,_sType,_sValue:AnsiString;
    _sReadError,_sWriteError:AnsiString;
    _stLastRead,_stLastWrite:TSystemTime;
    _pData:pointer; // дополнительные данные - можно сколько угодно расширить
  end;

  PrOperationInfo=^TrOperationInfo;
  TrOperationInfo=packed record
    _bInitialized:boolean;    // операция проинициализирована
    _bAuto:boolean;           // автоматическое выполнение по периоду (при 0-м периоде - по своей логике)
    _bProcessing:boolean;     // операция выполняется    
    _lwOrgTicks:longword;     // время начала операции
    _lwLastTicks:longword;    // время в мс последней операции
    _lwInterval:longword;     // интервал повторения операции
    _pData:pointer;           // дополнительные данные операции
  end;

  PrRefreshInfo=^TrRefreshInfo;
  TrRefreshInfo=packed record // информация для общего опроса
    _ID:longword; _ndx,_cnt:integer; // номер общего опроса, текущий теги и количество тегов в общем опросе - для показа прогресса
  end;
  PrUpdateInfo=^TrUpdateInfo;
  TrUpdateInfo=TrRefreshInfo;

  TCommunicationThread=class;
  TCommunicationThreadClass=class of TCommunicationThread;

////////// коммуникационное устройство
  TCommunicationDevice=class(TCommunicationObject)
  private
    fOnProgress:TProgressCallBackEvent;
    function GetOnProgress:TProgressCallBackEvent;
    procedure SetOnProgress(const pcbe:TProgressCallBackEvent);
    function GetCC:TCommunicationConnection;
    function GetCP:TCommunicationProtocol;
    procedure SetCC(const acc:TCommunicationConnection);
    procedure SetCP(const acp:TCommunicationProtocol);
  protected
    fTagsDescriptors,fTaskTags,fUpdateTags:THashedStringList;

    cc:TCommunicationConnection; cp:TCommunicationProtocol;

    fCommunicationProtocolClass:TCommunicationProtocolClass;
    fCommunicationThreadClass:TCommunicationThreadClass;

    rAuthorizeInfo,rAliveInfo,rConnectInfo,rInitializeInfo,rRefreshInfo,rSynchronizeInfo,rTickInfo,rUpdateInfo:TrOperationInfo;
    rBusyInfo:TrOperationInfo;
    fui64Address:UInt64; fbAddressAssigned:boolean;

//    function DoGetAsText:AString; override;
//    function DoGetStateInfo:AnsiString; override;
//    procedure DoSetAsText(const s:AString); override;
    function DoGetUInt(const ndx:integer):UInt64; override;                       // все беззнаковые целые свойства
    procedure DoSetUInt(const ndx:integer; const ui:UInt64); override;            // все беззнаковые целые свойства    
  protected

    function GetTag(v:OleVariant):AnsiString; virtual;  // тег по имени или индексу

    function AllocTagDescriptor:pointer; virtual;                 // получение описания для тега
    procedure FreeTagDescriptor(pTagDescriptor:pointer); virtual; // освобождение описания для тега

    function GetTagInfo(pTagInfo:pointer):AnsiString; virtual;  // получение текстового описания для тега

    function AddTag(sName:AnsiString):pointer; virtual;   // добавление тега в список
    procedure RemoveTag(sName:AnsiString); virtual;       // удаление тега из списка
    procedure LoadTags(const sTags:AnsiString); virtual;  // загрузить пространство тегов
    function SaveTags:AnsiString; virtual;                // сохранение пространства тегов

    function DoAlive:integer; virtual;                // здесь реальная проверка соединения
    function DoAuthorize:integer; virtual;            // здесь реальная авторизация устройства
    function DoDeauthorize:integer; virtual;          // здесь реальная деавторизация устройства - с полным ожиданием завершения (только синхронная операция)
    function DoInitialize:integer; virtual;           // здесь реальная инициализация устройства
    function DoRefresh:integer; virtual;              // здесь реальная инициализация общего опроса
    function DoSynchronize:integer; virtual;          // здесь нужно описать реальную синхронизацию
    function DoSynchronizeBroadcast:integer; virtual; // здесь нужно описать реальную широковещательную синхронизацию

    function DoGetRefreshID:longword; virtual;        // идентификатор общего опроса

    function DoProgress(const idCurrentProcess,idParentProcess,lwCurrentProgress,lwMaximalProgress,lwTimeEllapsed:longword;
      const sProcessText:AnsiString; const enProgressState:TProgressState):boolean; virtual;

    procedure ExecuteTask; virtual;
    function GetErrorAsText(ce:integer):AnsiString; virtual;                  // ошибка в виде строки

    procedure InitDevice; virtual;                    // инициализация перед соединением
    procedure PerformBusy; virtual;                   // пока устройство занято, опрос его не происходит - можно что-то для себя полезное сделать
    function PerformTick:boolean; virtual;            // во время вызова Tick необходимо выполнить какую-либо операцию, т.к. ожидающие окончания не завершены

    procedure _OnChanged(Sender:TObject); virtual;    // изменение списка тегов
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure SetDefault; override;                   // параметры по умолчанию

    procedure BeginTask; virtual;
    procedure EndTask; virtual;
    procedure ClearTask; virtual;

//    function ReadTag(sName:AnsiString):AnsiString; overload; virtual;
//    function ReadTag(ndx:integer):AnsiString; overload; virtual;
//    procedure WriteTag(sName,sValue:AnsiString); overload; virtual;
//    procedure WriteTag(ndx:integer; sValue:AnsiString); overload; virtual;

    procedure ClearTags; virtual;                     // очистка пространства тегов
    procedure ClearUpdateTags; virtual;               // очистка списка обновляемых тегов

    property Tags[v:OleVariant]:AnsiString                                  read GetTag                     ; // тег по имени или по индексу
    property TagsCount:integer              index ndxTagsCount              read GetI32                     ; // количество тегов в пространстве имён
//    property TagsIndexes[sName:AnsiString]
    property TagsSpace:AnsiString                                           read SaveTags write LoadTags; // получение или создание пространства тегов

    function Alive:boolean; virtual;              // проверка действительной "живой" связи с устройством
    function Authorize:boolean; virtual;          // авторизация
    function Deauthorize:boolean; virtual;        // деавторизация
    function Connect:boolean; virtual;            // установить связь
    function Disconnect:boolean; virtual;         // разорвать связь
    function Initialize:boolean; virtual;         // инициализировать
    function Refresh:boolean; virtual;            // обновить пространство тегов - типа General Interrogation
    function Synchronize(bBroadcast:boolean=false):boolean; virtual; // синхронизировать устройство
    function Tick:boolean; virtual;               // один такт работы устройства (вся пошаговая автономная логика работы с устройством)
    function Update:boolean; virtual;             // обновить пространство тегов - изменяемый список тегов (прерывая уже идущее)
  public
    property CommunicationConnection:TCommunicationConnection read GetCC write SetCC;
    property CommunicationProtocol:TCommunicationProtocol read GetCP write SetCP;

    property Address:UInt64                 index ndxAddress                read GetUI64    write SetUI64;  // адрес устройства(для каждого протокола может обозначать своё)

    property AutoAuthorize:boolean          index ndxAutoAuthorize          read GetB1      write SetB1;    // авто авторизация
    property AutoAuthorizePeriod:longword   index ndxAutoAuthorizePeriod    read GetUI32    write SetUI32;  // период автоавторизации, при 0 - по умолчанию (по записи, например)
    property AutoAlive:boolean              index ndxAutoAlive              read GetB1      write SetB1;    // автопроверка "жизни" соединения (т.е. реально Connected ещё живой)
    property AutoAlivePeriod:longword       index ndxAutoAlivePeriod        read GetUI32    write SetUI32;  // период проверки "жизни" соединения, при 0 - по умолчанию
    property AutoConnect:boolean            index ndxAutoConnect            read GetB1      write SetB1;    // автосоединение с устройством
    property AutoConnectPeriod:longword     index ndxAutoConnectPeriod      read GetUI32    write SetUI32;  // период попытки автосоединения, при 0 - по умолчанию
    property AutoInitialize:boolean         index ndxAutoInitialize         read GetB1      write SetB1;    // автоинициализация устройства
    property AutoRefresh:boolean            index ndxAutoRefresh            read GetB1      write SetB1;    // автообновление тегов устройства, общий опрос
    property AutoRefreshPeriod:longword     index ndxAutoRefreshPeriod      read GetUI32    write SetUI32;  // период автообновления тегов, при 0 - по умолчанию
    property AutoSynchronize:boolean        index ndxAutoSynchronize        read GetB1      write SetB1;    // автосинхронизация устройства
    property AutoSynchronizePeriod:longword index ndxAutoSynchronizePeriod  read GetUI32    write SetUI32;  // период автосинхронизации, при 0 - по умолчанию
    property AutoTick:boolean               index ndxAutoTick               read GetB1      write SetB1;    // авторабота с устройством
    property AutoTickPeriod:longword        index ndxAutoTickPeriod         read GetUI32    write SetUI32;  // период автоработы с устройством, при 0 - по умолчанию
    property AutoUpdate:boolean             index ndxAutoUpdate             read GetB1      write SetB1;    // автообновление тегов устройства - изменяемый список тегов
    property AutoUpdatePeriod:longword      index ndxAutoUpdatePeriod       read GetUI32    write SetUI32;  // период автообновления тегов, при 0 - по умолчанию

    property Authorized:boolean             index ndxAuthorized             read GetB1      write SetB1;    // связь с устройством авторизована
    property Connected:boolean              index ndxConnected              read GetB1      write SetB1;    // связь с устройством установлена
    property Initialized:boolean            index ndxInitialized            read GetB1      write SetB1;    // устройство проинициализировано
    property Synchronized:boolean           index ndxSynchronized           read GetB1      write SetB1;    // устройство синхронизировано

    property Updating:boolean               index ndxUpdating               read GetB1                 ;    // устройство в режиме обновления тегов по Update

    property OnProgress:TProgressCallBackEvent read GetOnProgress write SetOnProgress; // обратная связь для отображения прогресса
  end;

// passwordTag
// aliveTag  

  TCommunicationDeviceClass=class of TCommunicationDevice;

////////// список устройств
  TCommunicationDevices=class(TCommunicationObjects)
  protected
    function GetObject(ndx:integer):TCommunicationDevice; reintroduce; virtual;
  public
    constructor Create; override;

    function CreateObject:TCommunicationDevice; reintroduce; virtual;
    function AddObject(cd:TCommunicationDevice):boolean; reintroduce; virtual;
    function RemoveObject(cd:TCommunicationDevice):boolean; reintroduce;  virtual;
    function IndexOf(cd:TCommunicationDevice):integer; reintroduce; virtual;
  public
    property Objects[ndx:integer]:TCommunicationDevice read GetObject; default;
  end;

////////// список классов устройств
  TCommunicationDeviceClasses=class(TCommunicationObjectClasses)
  protected
    function GetClass(ndx:integer):TCommunicationDeviceClass; reintroduce; virtual;
  public
    function AddClass(cdclass:TCommunicationDeviceClass):boolean; reintroduce; virtual;
    function RemoveClass(cdclass:TCommunicationDeviceClass):boolean; reintroduce; virtual;
    function IndexOf(cdclass:TCommunicationDeviceClass):integer; reintroduce; virtual;
  public
    property Classes[ndx:integer]:TCommunicationDeviceClass read GetClass; default;
  end;

  TTransactionData=class;
  TTransactionWaitCallBack=procedure(id:integer; td:TTransactionData); stdcall;
  TTransactionResult=(trSuccess,trTimeout,trProcessing,trWriteError,trAbort,trBroadCast,trOverflow,trHandleError,trException);
  // trSuccess - нет ошибок чтения, полученные данные соответствуют пакету или получены в течение выдержанного таймаута если пакет не используется
  // trTimeout - ошибка ожидания данных, соответствующих пакету в течение RetryTimeout*Retries
  // trProcessing - данные ещё обрабатываются
  // trWriteError - ошибка записи
  // trAbort - данные из очереди убраны пользователем или завершением обслуживающего их потока
  // trBroadcast - данные только на запись в широковещательном режиме без получения ответа
  // trOverflow - количество запросов достигло максимума, новые не могут быть поставлены в очередь
  // trHandleError - ошибка обработки ответа на запрос
  // trException - исключение во время работы

  TTransactionDataType=(tdtRequest,tdtResponse);
  // tdtRequest - запрос, с ожиданием ответа, если не широковещательный или пустой (размер 0)
  // tdtResponse - ответ, после записи через коммуникационное соединение ничего не ожидать

  TTransactionData=class
  protected
    sRequest:AnsiString;                                  // копия запроса
    sResponse:AnsiString;                                 // копия ответа
    tdt:TTransactionDataType;                             // тип транзакции
    pResponseDataBuf:pointer; iResponseDataSize:integer;  // пользовательский буфер, куда будут записаны данные ответа
    tr:TTransactionResult;                                // код обработки транзакции данных (запрос-ответ)
    ce:integer;                                           // ошибка коммуникации
    cd:TCommunicationDevice;                              // тип устройства
//    cc:TCommunicationConnection;                          // тип соединения
//    cp:TCommunicationProtocol;                            // протокол
    cb:TTransactionWaitCallBack;                          // при асинхронном режиме процедура обратного вызова
    id:integer;                                           // идентификатор транзакции (может быть объектом и т.д.)
    hCompleteEvent:THandle;                               // событие завершения для синхронного режима при cb=nil
    stWrite,stRead:TSystemTime;                           // время записи с сокет и чтения из сокета, а когда что там дальше обработается и сколько потребуется времени - неизвестно
  public
    destructor Destroy; override;
  end;

/////// класс потока протоколирования
  TCommunicationThread=class(TEventedThread)
  private
    fQueue:TThreadSafeQueue; fiQueueCount,fiRequestsLimit:integer;
    flwLastExecuted:longword;
  protected
    procedure AddToQueue(td:TTransactionData); virtual;
    procedure DoExecute; override;

    function GetLastAccess:longword; virtual;
  public
    procedure AllocateResources; override;
    procedure DeallocateResources; override;
    function IsIdle:boolean; override;

    function PutRequestBuf(const cd:TCommunicationDevice; const pRequest:pointer; const iRequestSize:integer;
      const pResponseDataBuf:pointer=nil; const iResponseDataSize:integer=0; cb:TTransactionWaitCallBack=nil):TTransactionData;
    function PutRequest(const cd:TCommunicationDevice; const sRequest:AnsiString;
      const pResponseDataBuf:pointer=nil; const iResponseDataSize:integer=0; cb:TTransactionWaitCallBack=nil):TTransactionData;

    function PutResponseBuf(const cd:TCommunicationDevice;
      const pResponse:pointer; const iResponseSize:integer; cb:TTransactionWaitCallBack=nil):TTransactionData;
    function PutResponse(const cd:TCommunicationDevice; const sResponse:AnsiString;
      cb:TTransactionWaitCallBack=nil):TTransactionData;
  end;

////////// список потоков
  TCommunicationThreads=class(TThreadSafeHashedStringList)
  private
    fOwner:TCommunicationSpace;
    ndxThread:integer; // индекс потока для проверки его использования - если не используется в течение долгого времени, то закрываем
  protected
    function GetThread(ndx:integer):TCommunicationThread; virtual;
    function GetThreadsCount:integer; virtual;    

    procedure DestroyThread(ct:TCommunicationThread); virtual;
  public
    constructor Create; override;
    destructor Destroy; override;

    function GetConnectionThread(cc:TCommunicationConnection; ctclass:TCommunicationThreadClass):TCommunicationThread;

    property ThreadsCount:integer read GetThreadsCount;
    property Threads[ndx:integer]:TCommunicationThread read GetThread; default;
  end;

////////// пространство всех объектов, связанных с коммуникациями - наследники могут использовать свои объекты
  TCommunicationSpace=class(TNamedSpace)
  private
    fSockets:TCommunicationSockets; fSocketClasses:TCommunicationSocketClasses;
    fModes:TCommunicationModes; fModeClasses:TCommunicationModeClasses;
    fConnections:TCommunicationConnections; fConnectionClasses:TCommunicationConnectionClasses;
    fProtocols:TCommunicationProtocols; fProtocolClasses:TCommunicationProtocolClasses;
    fDevices:TCommunicationDevices; fDeviceClasses:TCommunicationDeviceClasses;
    fThreads:TCommunicationThreads;
  protected
    function DoGetObjects(const no:TNamedObject):TNamedObjects; override;                       // получить список объектов по типу объекта
    function DoGetObjectClasses(const noclass:TNamedObjectClass):TNamedObjectClasses; override; // получить список классов объектов по типу класса объекта
    procedure _OnUSBNotify(Sender:TObject; dwEvent:longword; sName:AnsiString); virtual;
  public
    constructor Create; override;
    destructor Destroy; override;

    procedure RegisterConnection(cc:TCommunicationConnection); virtual;                   // регистрация соединения в списке
    procedure RegisterConnectionClass(ccclass:TCommunicationConnectionClass); virtual;    // регистрация класса соединения в списке
    procedure UnregisterConnection(cc:TCommunicationConnection); virtual;                 // разрегистрация соединения в списке
    procedure UnregisterConnectionClass(ccclass:TCommunicationConnectionClass); virtual;  // разрегистрация класса соединения в списке

    procedure RegisterDevice(cd:TCommunicationDevice); virtual;                           // регистрация устройства в списке
    procedure RegisterDeviceClass(cdclass:TCommunicationDeviceClass); virtual;            // регистрация класса устройства в списке
    procedure UnRegisterDevice(cd:TCommunicationDevice); virtual;                         // разрегистрация устройства в списке
    procedure UnregisterDeviceClass(cdclass:TCommunicationDeviceClass); virtual;          // разрегистрация класса устройства в списке

    procedure RegisterMode(cm:TCommunicationMode); virtual;                               // регистрация режима в списке
    procedure RegisterModeClass(cmclass:TCommunicationModeClass); virtual;                // регистрация класса режима в списке
    procedure UnRegisterMode(cm:TCommunicationMode); virtual;                             // разрегистрация режима в списке
    procedure UnregisterModeClass(cmclass:TCommunicationModeClass); virtual;              // разрегистрация класса режима в списке

    procedure RegisterProtocol(cp:TCommunicationProtocol); virtual;                       // регистрация протокола в списке
    procedure RegisterProtocolClass(cpclass:TCommunicationProtocolClass); virtual;        // регистрация класса протокола в списке
    procedure UnregisterProtocol(cp:TCommunicationProtocol); virtual;                     // разрегистрация протокола в списке
    procedure UnregisterProtocolClass(cpclass:TCommunicationProtocolClass); virtual;      // разрегистрация класса протокола в списке

    procedure RegisterSocket(cs:TCommunicationSocket); virtual;                           // регистрация сокета в списке
    procedure RegisterSocketClass(csclass:TCommunicationSocketClass); virtual;            // регистрация класса сокета в списке
    procedure UnregisterSocket(cs:TCommunicationSocket); virtual;                         // разрегистрация сокета в списке
    procedure UnregisterSocketClass(csclass:TCommunicationSocketClass); virtual;          // разрегистрация класса сокета в списке

    property Connections:TCommunicationConnections read fConnections;                     // список всех соединений
    property ConnectionClasses:TCommunicationConnectionClasses read fConnectionClasses;   // список всех классов соединений
    property Devices:TCommunicationDevices read fDevices;                                 // список всех устройств
    property DeviceClasses:TCommunicationDeviceClasses read fDeviceClasses;               // список всех классов устройств
    property Modes:TCommunicationModes read fModes;                                       // список всех режимов
    property ModeClasses:TCommunicationModeClasses read fModeClasses;                     // список всех классов режимов
    property Protocols:TCommunicationProtocols read fProtocols;                           // список всех протоколов
    property ProtocolClasses:TCommunicationProtocolClasses read fProtocolClasses;         // список всех классов протоколов
    property Sockets:TCommunicationSockets read fSockets;                                 // список всех сокетов
    property SocketClasses:TCommunicationSocketClasses read fSocketClasses;               // список всех классов сокетов
    property Threads:TCommunicationThreads read fThreads;                                 // список всех потоков
  public
//    property DeviceType:AnsiString
//    DeviceInfo
//    MeasurePairs
//    Lists
//    Coefficients
//    Colors
//    Pictures
//    Tags
//    Groups
//    passwordTag
//    aliveTag
//
  end;

  // функция ожидания ответа на запрос, либо асинхронная операция
  function comDoWait(cd:TCommunicationDevice; arrPacket:array of Int64; pDst:pointer=nil; iDstSize:integer=0; cb:TTransactionWaitCallBack=nil; tdt:TTransactionDataType=tdtRequest):integer;

  // довершение кода ожидания comDoWait при асинхронной операции
  function Complete_comDoWait(id:integer; td:TTransactionData):integer; stdcall; 


  function GetErrorStr(ce:integer):AnsiString;            // ошибка связи из идентификатора в строку

  function CommunicationSpace:TCommunicationSpace;        // глобальный объект, содержащий всё о "связи"

implementation

uses StrUtils,Variants,DBT,MMSystem,
  SynCommons,
  uUtilsFunctions,uSystem,uLogClasses2,uDateTime;

{$BOOLEVAL OFF}
{$RANGECHECKS OFF}
{$OVERFLOWCHECKS OFF}

const lwUnitVersion=$00010204; lwBufferSize=32768;
  sOverlappedModes:array[boolean]of AnsiString=('синхронный','отложенный');
  sBoolsNumber:array[boolean]of AnsiChar=('0','1');
  sBoolsString:array[boolean]of AnsiString=('нет','да');
  sSocketOverlappedModeUnabled_clients='невозможно изменить работу сокета "%s" с режима "%s" на режим "%s", т.к. к нему обращаются клиенты (%d)';

var gfs:TFormatSettings; oCommunicationSpace:TCommunicationSpace; oUSBNotifier:TUSBnotifier;
  lwTimerID:longword=0;

type TLBaseNotifier=class(TBaseNotifier);

  function CommunicationSpace:TCommunicationSpace; begin Result:=oCommunicationSpace; end;

  function GetErrorStr(ce:integer):AnsiString; begin      // ошибка связи из идентификатора в строку
    if not IntToIdent(ce,Result,CommunicationErrorsInfos)then
      if ce>0then Result:=GetSysError(ce)
      else Result:='0x'+IntToHex(ce,8)+' - неизвестный код ошибки';
  end;

  function GetVariantProperty(v:variant; sName:AnsiString; vDefault:variant):variant;
  begin Result:=vDefault; if v.Exists(sName)then try Result:=TDocVariantData(v).Value[sName]; except end; end;

  function GetNow:TSystemTime; begin GetLocalTime(Result); end;

  procedure SetDefaultCommunicationMode(cm:TCommunicationMode); begin
    with cm do begin fsCommName:=''; //'CommunicationPort0x'+IntToHex(integer(cp),8);
      with frCommTimeouts do begin ZeroMemory(@frCommTimeouts,SizeOf(frCommTimeouts));
        ReadIntervalTimeout:=MAXDWORD; ReadTotalTimeoutMultiplier:=0; ReadTotalTimeoutConstant:=0;
        WriteTotalTimeoutMultiplier:=0; WriteTotalTimeoutConstant:=1000;
      end;
      flwCommInputQueueSize:=lwBufferSize; flwCommOutputQueueSize:=lwBufferSize; flwCommMask:=0;
      fbLogDetailed:=false; fbLogging:=true; fbLogRecreate:=false; flwLogMaxSize:=30; fsLogFile:='communication.log'; // 30 МБайт хватит, а то копирование постоянно будет
      fiRetries:=0;
    end;
  end;

// bProcessMessages:boolean - при установленном значении в процессе ожидания окончания операции вызывается одно сообщение в очереди,
//                            если не получилось создать событие CreateEvent; если получилось, то bProcessMessages не используется
  const bProcessMessages:boolean=false;
  // ожидает окончания транзакции в синхронном режиме (cb=nil);
  // в асинхронном режиме (cb<>nil) выходит из функции с кодом ceCallbackWait
  function comDoWait(cd:TCommunicationDevice; arrPacket:array of Int64; pDst:pointer=nil; iDstSize:integer=0; cb:TTransactionWaitCallBack=nil; tdt:TTransactionDataType=tdtRequest):integer;
  var s:AnsiString; ndxError,ceResult:integer; td:TTransactionData; thr:TCommunicationThread;
  begin Result:=ceUnknownError; // if Length(arrPacket)=0then begin Result:=ceNoTransactionData; exit; end; // оставим нулевые посылки для синхронизации
    try if cd=nil then begin Result:=ceNoCommunicationDevice; exit; end;
//      SetThreadPriority(GetCurrentThread,THREAD_PRIORITY_TIME_CRITICAL);
      try cd.Lock; s:='';
        if(cd.CommunicationConnection=nil)then begin Result:=ceNoCommunicationConnection; exit; end;
        if(cd.CommunicationConnection.CommunicationSocket=nil)then begin Result:=ceNoCommunicationSocket; exit; end;
        if(cd.CommunicationProtocol=nil)then begin Result:=ceNoCommunicationProtocol; exit; end;
        if Length(arrPacket)=0then ceResult:=ceSuccess
        else if tdt=tdtRequest then ceResult:=cd.CommunicationProtocol.MakeRequest(arrPacket,s,ndxError)
          else ceResult:=cd.CommunicationProtocol.MakeResponse(arrPacket,s,ndxError);
        if ceResult<>ceSuccess then begin Result:=ceResult; exit; end;
        thr:=oCommunicationSpace.Threads.GetConnectionThread(cd.CommunicationConnection,cd.fCommunicationThreadClass);
        if thr=nil then begin Result:=ceNoCommunicationThread; exit; end;
        if(pDst<>nil)and(iDstSize>0)then ZeroMemory(pDst,iDstSize);
        if tdt=tdtRequest then td:=thr.PutRequest(cd,s,pDst,iDstSize,cb)else td:=thr.PutResponse(cd,s,cb);
      finally cd.Unlock; end;

      if td=nil then Result:=ceNoTransactionData  // не получилось создать "данные по транзакции"
      else if@cb<>nil then Result:=ceCallbackWait // выходим без ожидания в асинхронной операции
      else try
        if td.hCompleteEvent<>0then WaitForSingleObject(td.hCompleteEvent,INFINITE)
        else while td.tr=trProcessing do begin if bProcessMessages then Sys_HandleMessage; Sleep(16); end; // не даём "заморозить приложение"
        case td.tr of
          trSuccess:    Result:=ceSuccess;            trTimeout:      Result:=ceTimeout;
          trProcessing: Result:=ceAbortOperation;     trAbort:        Result:=ceAbortOperation;
          trWriteError: Result:=ceWriteError;         trBroadCast:    Result:=ceBroadCast;
          trOverflow:   Result:=ceQueueOverflow;      trHandleError:  Result:=td.ce;
          trException:  Result:=ceSysException;
        end;
      finally td.Free; end; // данные для транзакции нужно уничтожить после работы с ними
    except Result:=ceSysException; end;
  end;

  // довершение кода ожидания comDoWait при асинхронной передаче
  function Complete_comDoWait(id:integer; td:TTransactionData):integer; stdcall; begin
    try
      with td do case tr of
        trSuccess:    ce:=ceSuccess;                trTimeout:      ce:=ceTimeout;
        trProcessing: ce:=ceAbortOperation;         trAbort:        ce:=ceAbortOperation;
        trWriteError: ce:=ceWriteError;             trBroadCast:    ce:=ceBroadCast;
        trOverflow:   ce:=ceQueueOverflow;          trHandleError:  ; //ce:=td.ce;
        trException:  ce:=ceSysException;
      end;
      Result:=td.ce;
    except Result:=ceSysException; end;
  end;


  function WinGetOverlappedResult(hFile:THandle; lpOverlapped:POverlapped; var lpNumberOfBytesTransferred:DWORD;
    bWait:BOOL):BOOL; stdcall; external kernel32 name 'GetOverlappedResult';

  // по таймеру проверяет потоки, ассоциированные с определённым коммуникационным портом;
  // закрывает поочереди те, которые не используются в течение длительного времени
  procedure _OnMMTimer(uTimerID,uMessage:UINT; dwUser,dw1,dw2:dword); stdcall; var thr:TCommunicationThread; begin 
    with oCommunicationSpace.Threads do try Lock;
      if ndxThread<=ThreadsCount-1then try
        thr:=TCommunicationThread(Threads[ndxThread]);
        if thr.IsIdle and(GetTickCount-thr.GetLastAccess>180000)then begin DestroyThread(thr); dec(ndxThread); end; // если больше 3х минут не используется, то закрываем
      except end;
      inc(ndxThread); if ndxThread>=ThreadsCount then ndxThread:=0;
    finally Unlock; end;
  end;


{ TCommunicationObject }

constructor TCommunicationObject.Create; begin
  if Owner=nil then Owner:=oCommunicationSpace; // условие будет выполнено только для TCommunicationSpace,
  inherited Create;                               // для всех остальных инициализация в NewInstance
end;

procedure TCommunicationObject.DoActive; var bActive:boolean; begin if not fbActiveNotifyEnabled then exit;
  bActive:=TLBaseNotifier(Notifier).CriticalSection.RecursionCount<>0;
  if fbActive<>bActive then begin
    try inherited Lock; fbActive:=bActive; finally inherited Unlock; end; // внутреннее поле тоже засинхронизируем
      //inherited DoChanged; // сообщим об изменении активного состояния
  end;
end;

function TCommunicationObject.DoGetAsText:AString; var v:variant; begin
  v:=_JsonFast(StringToUTF8(inherited DoGetAsText));
  v.Connected:=fbConnected;
  Result:=v; if bJSONHumanReadable then Result:=JSONReformat(Result); // VariantSaveJSON(v)
  Result:=UTF8ToString(Result);
end;

function TCommunicationObject.DoGetBool(const ndx:integer):Bool64; begin
  case ndx of
    ndxActiveNotifyEnabled: Result:=Bool64(fbActiveNotifyEnabled);
    ndxConnected:           Result:=Bool64(fbConnected);
  else Result:=inherited DoGetBool(ndx); end;
end;

function TCommunicationObject.DoGetStateInfo:AnsiString;
begin Result:=Format('%s,C=%s',[inherited DoGetStateInfo,sBoolsNumber[fbConnected]],gfs); end;

procedure TCommunicationObject.DoSetAsText(const s:AString); var v:variant; begin
  try try BeginUpdate; v:=_JsonFast({StringToUTF8(}s{)});
    Connected:=GetVariantProperty(v,'Connected',fbConnected);
    inherited DoSetAsText(s);
  finally EndUpdate; end; except end;
end;

procedure TCommunicationObject.DoSetBool(const ndx:integer; const b:Bool64); begin
  case ndx of
    ndxActiveNotifyEnabled: if fbActiveNotifyEnabled<>Bool1(b)then begin fbActiveNotifyEnabled:=Bool1(b); Changed; end;
    ndxConnected:   if fbConnected<>Bool1(b)then begin fbConnected:=Bool1(b); Changed; end;
  else inherited DoSetBool(ndx,b); end;
end;

class function TCommunicationObject.GetObjectByName(sName:AnsiString):TCommunicationObject;
begin Result:=nil; end;

function TCommunicationObject.GetOwner:TCommunicationSpace;
begin Result:=TCommunicationSpace(inherited Owner); end;

procedure TCommunicationObject.Lock;
begin inherited Lock; DoActive; end;

class function TCommunicationObject.NewInstance:TObject;
begin Result:=inherited NewInstance; TCommunicationObject(Result).Owner:=oCommunicationSpace; end;

procedure TCommunicationObject.SetDefault; begin
  try Lock; BeginUpdate;
    inherited SetDefault; ActiveNotifyEnabled:=true;
    fsCaption:='CommunicationObject_0x'+IntToHex(fhID,8); fsName:=fsCaption; fsDescription:='коммуникационный объект (TCommunicationObject)';
  finally EndUpdate; Unlock; end;
end;

procedure TCommunicationObject.SetOwner(const cs:TCommunicationSpace);
begin inherited Owner:=cs; end;

function TCommunicationObject.TryLock:boolean;
begin Result:=inherited TryLock; DoActive; end;

procedure TCommunicationObject.Unlock;
begin inherited Unlock; DoActive; end;

{ TCommunicationObjects }

function TCommunicationObjects.AddObject(co:TCommunicationObject):boolean;
begin Result:=inherited AddObject(co); end;

constructor TCommunicationObjects.Create;
begin if fOwner=nil then fOwner:=oCommunicationSpace; if fObjectClass=nil then fObjectClass:=TCommunicationObject; inherited Create; end;

function TCommunicationObjects.CreateObject:TCommunicationObject;
begin Result:=TCommunicationObject(inherited CreateObject); end;

function TCommunicationObjects.GetObject(ndx:integer):TCommunicationObject;
begin Result:=TCommunicationObject(inherited GetObject(ndx)); end;

function TCommunicationObjects.IndexOf(co:TCommunicationObject):integer;
begin Result:=inherited IndexOf(co); end;

function TCommunicationObjects.RemoveObject(co:TCommunicationObject):boolean;
begin Result:=inherited RemoveObject(co); end;

{ TCommunicationObjectClasses }

function TCommunicationObjectClasses.AddClass(coclass:TCommunicationObjectClass):boolean;
begin Result:=inherited AddClass(coclass); end;

constructor TCommunicationObjectClasses.Create;
begin if fOwner=nil then fOwner:=oCommunicationSpace; inherited Create; end;

function TCommunicationObjectClasses.GetClass(ndx:integer):TCommunicationObjectClass;
begin Result:=TCommunicationObjectClass(inherited GetClass(ndx)); end;

function TCommunicationObjectClasses.IndexOf(coclass:TCommunicationObjectClass):integer;
begin Result:=inherited IndexOf(coclass); end;

function TCommunicationObjectClasses.RemoveClass(coclass:TCommunicationObjectClass):boolean;
begin Result:=inherited RemoveClass(coclass); end;

{ TCommunicationMode }

function TCommunicationMode.DoGetAsText:AString; var v:variant; begin
  v:=_JsonFast(StringToUTF8(inherited DoGetAsText));
  v.CommMask:=flwCommMask; v.CommName:=fsCommName;
  with frCommTimeouts do begin
    v.CommReadIntervalTimeout:=ReadIntervalTimeout;
    v.CommReadTotalTimeoutMultiplier:=ReadTotalTimeoutMultiplier;
    v.CommReadTotalTimeoutConstant:=ReadTotalTimeoutConstant;
    v.CommWriteTotalTimeoutMultiplier:=WriteTotalTimeoutMultiplier;
    v.CommWriteTotalTimeoutConstant:=WriteTotalTimeoutConstant;
  end;
  v.CommInputQueueSize:=flwCommInputQueueSize; v.CommOutputQueueSize:=flwCommOutputQueueSize;
  v.LogDetailed:=fbLogDetailed; v.LogFile:=fsLogFile; v.Logging:=fbLogging; v.LogMaxSize:=flwLogMaxSize; v.LogRecreate:=fbLogRecreate;
  v.Retries:=fiRetries;
  Result:=v; if bJSONHumanReadable then Result:=JSONReformat(Result); // VariantSaveJSON(v)
  Result:=UTF8ToString(Result);
end;

function TCommunicationMode.DoGetAString(const ndx:integer):AString; begin
  case ndx of
    ndxCommName:    Result:=fsCommName;               ndxLogFile:     Result:=fsLogFile;
  else Result:=inherited DoGetAString(ndx); end;
end;

function TCommunicationMode.DoGetBool(const ndx:integer):Bool64; begin
  case ndx of
    ndxLogDetailed: Result:=Bool64(fbLogDetailed);
    ndxLogging:     Result:=Bool64(fbLogging);        ndxLogRecreate: Result:=Bool64(fbLogRecreate);
  else Result:=inherited DoGetBool(ndx); end;
end;

function TCommunicationMode.DoGetInt(const ndx:integer):Int64; begin
  case ndx of
    ndxRetries: Result:=fiRetries;
  else Result:=inherited DoGetInt(ndx); end;
end;

function TCommunicationMode.DoGetUInt(const ndx:integer):UInt64; begin
  case ndx of
    ndxCommMask:            Result:=flwCommMask;                ndxCommInputQueueSize:  Result:=flwCommInputQueueSize;
    ndxCommOutputQueueSize: Result:=flwCommOutputQueueSize;     ndxLogMaxSize:          Result:=flwLogMaxSize;
  else Result:=inherited DoGetUInt(ndx); end;
end;

function TCommunicationMode.DoGetStateInfo:AnsiString; begin
  with frCommTimeouts do Result:=Format('сокет="%s",маска=0x%.8x,таймауты RI=%d RM=%d RC=%d WM=%d WC=%d,буферы R=%d W=%d,попыток=%d,лог файл="%s" размер=%d писать=%s детальный=%s пересоздать=%s,%s',
    [fsCommName,flwCommMask,ReadIntervalTimeout,ReadTotalTimeoutMultiplier,ReadTotalTimeoutConstant,
    WriteTotalTimeoutMultiplier,WriteTotalTimeoutConstant,flwCommInputQueueSize,flwCommOutputQueueSize,
    fiRetries,fsLogFile,flwLogMaxSize,sBoolsString[fbLogging],sBoolsString[fbLogDetailed],sBoolsString[fbLogRecreate],
    inherited DoGetStateInfo],gfs);
end;

procedure TCommunicationMode.DoSetAsText(const s:AString); var v:variant; ct:TCommTimeouts; begin
  try try BeginUpdate; v:=_JsonFast({StringToUTF8(}s{)});
    CommMask:=GetVariantProperty(v,'CommMask',CommMask); CommName:=GetVariantProperty(v,'CommName',CommName);
    ct:=CommTimeouts;
    with ct do begin
      ReadIntervalTimeout:=GetVariantProperty(v,'CommReadIntervalTimeout',ReadIntervalTimeout);
      ReadTotalTimeoutMultiplier:=GetVariantProperty(v,'CommReadTotalTimeoutMultiplier',ReadTotalTimeoutMultiplier);
      ReadTotalTimeoutConstant:=GetVariantProperty(v,'CommReadTotalTimeoutConstant',ReadTotalTimeoutConstant);
      WriteTotalTimeoutMultiplier:=GetVariantProperty(v,'CommWriteTotalTimeoutMultiplier',WriteTotalTimeoutMultiplier);
      WriteTotalTimeoutConstant:=GetVariantProperty(v,'CommWriteTotalTimeoutConstant',WriteTotalTimeoutConstant);
    end;
    CommTimeouts:=ct;
    CommInputQueueSize:=GetVariantProperty(v,'CommInputQueueSize',CommInputQueueSize);
    CommOutputQueueSize:=GetVariantProperty(v,'CommOutputQueueSize',CommOutputQueueSize);
    LogDetailed:=GetVariantProperty(v,'LogDetailed',LogDetailed); LogFile:=GetVariantProperty(v,'LogFile',LogFile);
    Logging:=GetVariantProperty(v,'Logging',Logging); LogMaxSize:=GetVariantProperty(v,'LogMaxSize',LogMaxSize);
    LogRecreate:=GetVariantProperty(v,'LogRecreate',LogRecreate); Retries:=GetVariantProperty(v,'Retries',Retries);
    inherited DoSetAsText(s);
  finally EndUpdate; end; except end;
end;

procedure TCommunicationMode.DoSetAString(const ndx:integer; const s:AString); begin
  case ndx of
    ndxCommName:  if fsCommName<>s then begin fsCommName:=s; Changed; end;
    ndxLogFile:   if fsLogFile<>s then begin fsLogFile:=s; Changed; end;
  else inherited DoSetAString(ndx,s); end;
end;

procedure TCommunicationMode.DoSetBool(const ndx:integer; const b:Bool64);
  procedure DeleteFile;
  begin if fbLogging and fbLogRecreate then Windows.DeleteFile(PAnsiChar(File_ExpandFileName('',fsLogFile))); end;
begin
  case ndx of
    ndxLogDetailed: if fbLogDetailed<>Bool1(b)then begin fbLogDetailed:=Bool1(b); Changed; end;
    ndxLogging:     if fbLogging<>Bool1(b)then begin fbLogging:=Bool1(b); Changed; DeleteFile; end;
    ndxLogRecreate: if fbLogRecreate<>Bool1(b)then begin fbLogRecreate:=Bool1(b); Changed; DeleteFile; end;
  else inherited DoSetBool(ndx,b); end;
end;

procedure TCommunicationMode.DoSetInt(const ndx:integer; const i:Int64); begin
  case ndx of
    ndxRetries:     if fiRetries<>i then begin fiRetries:=i; if fiRetries<0then fiRetries:=0; Changed; end;
  else inherited DoSetInt(ndx,i); end;
end;

procedure TCommunicationMode.DoSetUInt(const ndx:integer; const ui:UInt64); begin
  case ndx of
    ndxCommMask:            if flwCommMask<>ui then begin flwCommMask:=ui; Changed; end;
    ndxCommInputQueueSize:  if flwCommInputQueueSize<>ui then begin flwCommInputQueueSize:=ui; Changed; end;
    ndxCommOutputQueueSize: if flwCommOutputQueueSize<>ui then begin flwCommOutputQueueSize:=ui; Changed; end;
    ndxLogMaxSize:          if flwLogMaxSize<>ui then begin flwLogMaxSize:=ui; Changed; end;
  else inherited DoSetUInt(ndx,ui); end;
end;

function TCommunicationMode.GetCommTimeouts:TCOMMTIMEOUTS;
begin try Lock; Result:=frCommTimeouts; finally Unlock; end; end;

procedure TCommunicationMode.SetCommTimeouts(const ct:TCOMMTIMEOUTS); begin
  try Lock;
    if not CompareMem(@ct,@frCommTimeouts,SizeOf(ct))then
      begin frCommTimeouts:=ct; Changed; end;
  finally Unlock; end;
end;

procedure TCommunicationMode.SetDefault; begin
  try Lock; BeginUpdate;
    inherited SetDefault; // просто изменяем все свойства
    SetDefaultCommunicationMode(Self); // перезаписываем необходимые
    fsCaption:='CommunicationMode_0x'+IntToHex(fhID,8); fsName:=fsCaption; fsDescription:=GetClassCaption;
  finally EndUpdate; Unlock; end;
end;

class function TCommunicationMode.GetClassCaption:AString;
begin Result:='коммуникационный режим (TCommunicationMode)'; end;

class function TCommunicationMode.GetClassDescription:AString;
begin Result:='класс TCommunicationMode предоставляет набор свойств для управления режимом сокета'; end;

{ TCommunicationModes }

function TCommunicationModes.AddObject(cm:TCommunicationMode):boolean;
begin Result:=inherited AddObject(cm); end;

constructor TCommunicationModes.Create;
begin fObjectClass:=TCommunicationMode; inherited Create; end;

function TCommunicationModes.CreateObject:TCommunicationMode;
begin Result:=TCommunicationMode(inherited CreateObject); end;

function TCommunicationModes.GetObject(ndx:integer):TCommunicationMode;
begin Result:=TCommunicationMode(inherited GetObject(ndx)); end;

function TCommunicationModes.IndexOf(cm:TCommunicationMode):integer;
begin Result:=inherited IndexOf(cm); end;

function TCommunicationModes.RemoveObject(cm:TCommunicationMode):boolean;
begin Result:=inherited RemoveObject(cm); end;

{ TCommunicationModeClasses }

function TCommunicationModeClasses.AddClass(cmclass:TCommunicationModeClass):boolean;
begin Result:=inherited AddClass(cmclass); end;

function TCommunicationModeClasses.GetClass(ndx:integer):TCommunicationModeClass;
begin Result:=TCommunicationModeClass(inherited GetClass(ndx)); end;

function TCommunicationModeClasses.IndexOf(cmclass:TCommunicationModeClass):integer;
begin Result:=inherited IndexOf(cmclass); end;

function TCommunicationModeClasses.RemoveClass(cmclass:TCommunicationModeClass):boolean;
begin Result:=inherited RemoveClass(cmclass); end;

{ TCommunicationSocket }

function TCommunicationSocket.AllocateOverlapped:POverlapped;
begin Result:=GetMemory(SizeOf(Result^)); ZeroMemory(Result,SizeOf(Result^)); Result.hEvent:=CreateEvent(nil,true,false,nil); end;

constructor TCommunicationSocket.Create(sCommName:AnsiString; bOverlapped:boolean=false); var co:TCommunicationSocket; begin
  if sCommName=''then sCommName:='[???]';
  try Owner.fSockets.Lock; // при работе со списком сокетов нужна гарантия что никто туда не лезет (пока мы создаём кто-то удаляет)
    co:=TCommunicationSocket(GetObjectByName(sCommName)); // ищем такой же сокет с этим же именем
    if co=nil then begin inherited Create; {SetDefault;}// надо создать родительские объекты, инициализировать их
      {DoRealCreate;} // действительно здесь создаётся новый объект
      fbOverlapped:=bOverlapped; fsCommName:=sCommName; fsName:=fsCommName; fsCaption:=fsName; // сокет с уникальным именем
      inc(flwRefCount); // инициализируем только что созданный сокет
      fhCommHandle:=DoCreateHandle; fbConnected:=fhCommHandle<>INVALID_HANDLE_VALUE; // объект реально создан новый, надо создать ему, что необходимо
    end else begin FreeInstance; Self:=co; inc(flwRefCount); end; // такой уже есть, надо уничтожить созданный объект и вернуть существующий
  finally Owner.fSockets.Unlock; end; // теперь разблокируем
end;

destructor TCommunicationSocket.Destroy; begin
  try Owner.fSockets.Lock; // при работе со списком сокетов нужна гарантия что никто туда не лезет (пока удаляём кто-то создаёт такой же синглтон)
    if flwRefCount<>0then dec(flwRefCount); // меньше нуля нам не надо
    if flwRefCount<>0then begin try Lock; fbDestroying:=false; finally Unlock; end; exit; end; // объект ещё используется кем-то, не будем уничтожать
    {DoRealDestroy;} DoDestroyHandle; // объект будет реально уничтожен, надо всё созданное уничтожить
  finally Owner.fSockets.Lock; end;
  inherited;
end;

function TCommunicationSocket.DoCreateHandle:THandle;
begin Result:=INVALID_HANDLE_VALUE; fbConnected:=false; end;

procedure TCommunicationSocket.DoDestroyHandle;
begin if fhCommHandle<>INVALID_HANDLE_VALUE then CloseHandle(fhCommHandle); fhCommHandle:=INVALID_HANDLE_VALUE; fbConnected:=false; end;

{procedure TCommunicationSocket.DoRealCreate;
begin end;}

{procedure TCommunicationSocket.DoRealDestroy;
begin end;}

function TCommunicationSocket.DoGetAString(const ndx:integer):AString; begin
  case ndx of
    ndxCommName:    Result:=fsCommName;
  else Result:=inherited DoGetAString(ndx); end;
end;

function TCommunicationSocket.DoGetAsText:AString; var v:variant; begin
  v:=_JsonFast(StringToUTF8(inherited DoGetAsText));
  v.CommMask:=CommMask; v.CommName:=CommName; v.CommHandle:=CommHandle;
  with CommTimeouts do begin
    v.CommReadIntervalTimeout:=ReadIntervalTimeout;
    v.CommReadTotalTimeoutMultiplier:=ReadTotalTimeoutMultiplier;
    v.CommReadTotalTimeoutConstant:=ReadTotalTimeoutConstant;
    v.CommWriteTotalTimeoutMultiplier:=WriteTotalTimeoutMultiplier;
    v.CommWriteTotalTimeoutConstant:=WriteTotalTimeoutConstant;
  end;
  v.CommInputQueueSize:=CommInputQueueSize; v.CommOutputQueueSize:=CommOutputQueueSize;
  v.Overlapped:=Overlapped;
  Result:=v; if bJSONHumanReadable then Result:=JSONReformat(Result); // VariantSaveJSON(v)
  Result:=UTF8ToString(Result);
end;

function TCommunicationSocket.DoGetBool(const ndx:integer):Bool64; begin
  case ndx of
    ndxOverlapped: Result:=Bool64(fbOverlapped);
  else Result:=inherited DoGetBool(ndx); end;
end;

function TCommunicationSocket.DoGetStateInfo:AnsiString; begin
  with CommTimeouts do Result:=Format('сокет="%s",маска=0x%.8x,таймауты RI=%d RM=%d RC=%d WM=%d WC=%d,буферы R=%d W=%d,%s',
    [fsCommName,CommMask,ReadIntervalTimeout,ReadTotalTimeoutMultiplier,ReadTotalTimeoutConstant,
      WriteTotalTimeoutMultiplier,WriteTotalTimeoutConstant,CommInputQueueSize,CommOutputQueueSize,
      inherited DoGetStateInfo
    ],gfs);
end;

function TCommunicationSocket.DoGetUInt(const ndx:integer):UInt64; var lw:LongWord; begin
  case ndx of
    ndxBytesForRead:        Result:=0;                ndxBytesForWrite:       Result:=0;
    ndxCommInputQueueSize:  Result:=0;                ndxCommOutputQueueSize: Result:=0;
    ndxCommHandle:          Result:=fhCommHandle;     ndxCommMask:            if _GetCommMask(lw)then Result:=lw else Result:=0;
  else Result:=inherited DoGetUInt(ndx); end;
end;

procedure TCommunicationSocket.DoSetAsText(const s:AString); var v:variant; ct:TCommTimeouts; begin
  try try BeginUpdate; v:=_JsonFast(StringToUTF8(s));
    CommMask:=GetVariantProperty(v,'CommMask',CommMask);
    ct:=CommTimeouts;
    with ct do begin
      ReadIntervalTimeout:=GetVariantProperty(v,'CommReadIntervalTimeout',ReadIntervalTimeout);
      ReadTotalTimeoutMultiplier:=GetVariantProperty(v,'CommReadTotalTimeoutMultiplier',ReadTotalTimeoutMultiplier);
      ReadTotalTimeoutConstant:=GetVariantProperty(v,'CommReadTotalTimeoutConstant',ReadTotalTimeoutConstant);
      WriteTotalTimeoutMultiplier:=GetVariantProperty(v,'CommWriteTotalTimeoutMultiplier',WriteTotalTimeoutMultiplier);
      WriteTotalTimeoutConstant:=GetVariantProperty(v,'CommWriteTotalTimeoutConstant',WriteTotalTimeoutConstant);
    end;
    CommTimeouts:=ct;
    CommInputQueueSize:=GetVariantProperty(v,'CommInputQueueSize',CommInputQueueSize);
    CommOutputQueueSize:=GetVariantProperty(v,'CommOutputQueueSize',CommOutputQueueSize);
    inherited DoSetAsText(s);
  finally EndUpdate; end; except end;
end;

procedure TCommunicationSocket.DoSetBool(const ndx:integer; const b:Bool64); begin
  case ndx of
    ndxConnected: if fbConnected<>Bool1(b)then begin if not Bool1(b)then DoDestroyHandle else fhCommHandle:=DoCreateHandle;
      fbConnected:=fhCommHandle<>INVALID_HANDLE_VALUE; Changed;
    end;
{      ndxOverlapped: if fbOverlapped<>b1 then
      if flwRefCount<>1then raise Exception.Create(
        Format(sSocketOverlappedModeUnabled_clients,[fsCommName,sOverlappedModes[fbOverlapped],sOverlappedModes[b1],flwRefCount],gfs))
      else begin bConnected:=fbConnected; DoDestroyHandle; fbOverlapped:=b1;
        bChanged:=true; if bConnected then Connected:=true;
      end;}
  else inherited DoSetBool(ndx,b); end;
end;

procedure TCommunicationSocket.DoSetUInt(const ndx:integer; const ui:UInt64); begin
  case ndx of
    {ndxBytesForRead:; недоступно для записи}
    {ndxBytesForWrite:; недоступно для записи}
    ndxCommMask:            if _SetCommMask(ui)then Changed;
    ndxCommInputQueueSize:  if _SetupComm(ui,CommOutputQueueSize)then Changed;
    ndxCommOutputQueueSize: if _SetupComm(CommInputQueueSize,ui)then Changed;
  else inherited DoSetUInt(ndx,ui); end;
end;

procedure TCommunicationSocket.FreeInstance;
begin if flwRefCount=0then inherited; end;
(*  for i:=0to SingletonArray.Count-1do if Self=SingletonArray[i]then begin
    dec((SingletonArray[i]as TSingleton).RefCount);
    if (SingletonArray[i] as TSingleton).RefCount=0then begin SingletonArray.Delete(i); inherited FreeInstance; break; end;
  end;*)

procedure TCommunicationSocket.FreeOverlapped(const p:POverlapped);
begin if p<>nil then begin if p.hEvent<>0then CloseHandle(p.hEvent); FreeMemory(p); end; end;

function TCommunicationSocket.GetCommTimeouts:TCOMMTIMEOUTS;
begin if not _GetCommTimeouts(Result)then ZeroMemory(@Result,SizeOf(Result)); end;

(*class function TCommunicationSocket.NewInstance:TObject; var i:integer; Result:=nil; begin // вызывается в Create на самом первом begin, параметры неизвестны
  for i:=0to SingletonArray.Count-1do if Self=SingletonArray[i].ClassType then
    begin Result:=SingletonArray[i]; break; end;
  if Result=nil then begin Result:=inherited NewInstance; SingletonArray.Add(Result); end;
  inc((Result as TSingleton).RefCount);
end;*)

class function TCommunicationSocket.GetObjectByName(sName:AnsiString):TCommunicationObject; var ndx:integer; cs:TCommunicationSocket; begin Result:=nil;
  with oCommunicationSpace do try Sockets.Lock;
    for ndx:=0to {fSockets.SafeList.Count}fSockets.ObjectsCount-1do begin cs:=TCommunicationSocket(fSockets[ndx]);
      if(cs.CommName=sName)and(Self=cs.ClassType)then begin Result:=cs; break; end; // ищем по имени и классу
    end;
  finally Sockets.Unlock; end;
end;

procedure TCommunicationSocket.SetCommTimeouts(const ct:TCOMMTIMEOUTS);
begin if _SetCommTimeouts(ct)then Changed; end;

procedure TCommunicationSocket.SetDefault; var cm:TCommunicationMode; begin
  try Lock; BeginUpdate; cm:=nil;
    inherited SetDefault; // просто изменяем все свойства
    try cm:=TCommunicationMode.Create; SetDefaultCommunicationMode(cm); AsText:=cm.AsText; // перезаписываем необходимые
    finally cm.Free; end;
    DoDestroyHandle;
    fsCaption:='CommunicationSocket_0x'+IntToHex(fhID,8); fsName:=fsCaption; fsDescription:=GetClassCaption;
  finally EndUpdate; Unlock; end;
end;

function TCommunicationSocket._CancelIo:boolean;
begin try Lock; Result:=Windows.CancelIo(fhCommHandle); finally Unlock; end; end;

function TCommunicationSocket._FlushFileBuffers:boolean;
begin try Lock; Result:=Windows.FlushFileBuffers(fhCommHandle); finally Unlock; end; end;

function TCommunicationSocket._GetCommMask(var lwEventMask:longword):boolean;
begin try Lock; Result:=Windows.GetCommMask(fhCommHandle,lwEventMask); finally Unlock; end; end;

function TCommunicationSocket._GetCommTimeouts(var rCommTimeouts:TCommTimeouts):boolean;
begin try Lock; Result:=Windows.GetCommTimeouts(fhCommHandle,rCommTimeouts); finally Unlock; end; end;

function TCommunicationSocket._GetOverlappedResult(const prOverlapped:POverlapped; var lwNumberOfBytesTransferred:longword; const bWait:boolean):boolean;
begin try Lock; Result:=WinGetOverlappedResult(fhCommHandle,prOverlapped,lwNumberOfBytesTransferred,bWait); finally Unlock; end; end;

function TCommunicationSocket._PurgeComm(const lwPurgeAction:longword):boolean;
begin try Lock; Result:=Windows.PurgeComm(fhCommHandle,lwPurgeAction); finally Unlock; end; end;

function TCommunicationSocket._ReadFile(var Buffer; const lwNumberOfBytesToRead:longword; var lwNumberOfBytesRead:longword;
  const prOverlapped:POverlapped):boolean;
begin try Lock; Result:=Windows.ReadFile(fhCommHandle,Buffer,lwNumberOfBytesToRead,lwNumberOfBytesRead,prOverlapped); finally Unlock; end; end;

function TCommunicationSocket._SetCommMask(const lwEventMask:longword):boolean;
begin try Lock; Result:=Windows.SetCommMask(fhCommHandle,lwEventMask); finally Unlock; end; end;

function TCommunicationSocket._SetCommTimeouts(const rCommTimeouts:TCommTimeouts):boolean;
begin try Lock; Result:=Windows.SetCommTimeouts(fhCommHandle,rCommTimeouts); finally Unlock; end; end;

function TCommunicationSocket._SetupComm(const lwInputQueueSize,lwOutputQueueSize:longword):boolean;
begin try Lock; Result:=Windows.SetupComm(fhCommHandle,lwInputQueueSize,lwOutputQueueSize); finally Unlock; end; end;

function TCommunicationSocket._WaitCommEvent(var lwEventMask:longword; const prOverlapped:POverlapped):boolean;
begin try Lock; Result:=Windows.WaitCommEvent(fhCommHandle,lwEventMask,prOverlapped); finally Unlock; end; end;

function TCommunicationSocket._WriteFile(const Buffer; const lwNumberOfBytesToWrite:longword;
  var lwNumberOfBytesWritten:longword; prOverlapped:POverlapped):boolean;
begin try Lock;; Result:=Windows.WriteFile(fhCommHandle,Buffer,lwNumberOfBytesToWrite,lwNumberOfBytesWritten,prOverlapped); finally Unlock; end; end;

class function TCommunicationSocket.GetClassCaption:AString;
begin Result:='коммуникационный сокет (TCommunicationSocket)'; end;

class function TCommunicationSocket.GetClassDescription:AString;
begin Result:='класс TCommunicationSocket реализует набор базовых функций при работе с сокетом'; end;

{ TCommunicationSockets }

function TCommunicationSockets.AddObject(cs:TCommunicationSocket):boolean;
begin Result:=inherited AddObject(cs); end;

constructor TCommunicationSockets.Create;
begin fObjectClass:=TCommunicationSocket; inherited Create; end;

function TCommunicationSockets.CreateObject:TCommunicationSocket;
begin Result:=TCommunicationSocket(inherited CreateObject); end;

destructor TCommunicationSockets.Destroy; var i:integer; begin
  try Lock;
    for i:=0to ObjectsCount-1do Objects[i].flwRefCount:=1; // если уж мы завершаемся, то не важно сколько клиентов сокета было -
                                                           // сделаем 1, чтоб сокет точно закрылся (кто-то неверно завершил либо забыл закрыть сокет)
  finally Unlock; end;
  inherited;
end;

function TCommunicationSockets.GetObject(ndx:integer):TCommunicationSocket;
begin Result:=TCommunicationSocket(inherited GetObject(ndx)); end;

function TCommunicationSockets.IndexOf(cs:TCommunicationSocket):integer;
begin Result:=inherited IndexOf(cs); end;

function TCommunicationSockets.RemoveObject(cs:TCommunicationSocket):boolean;
begin Result:=inherited RemoveObject(cs); end;

{ TCommunicationSocketClasses }

function TCommunicationSocketClasses.AddClass(csclass:TCommunicationSocketClass):boolean;
begin Result:=inherited AddClass(csclass); end;

function TCommunicationSocketClasses.GetClass(ndx:integer):TCommunicationSocketClass;
begin Result:=TCommunicationSocketClass(inherited GetClass(ndx)); end;

function TCommunicationSocketClasses.IndexOf(csclass:TCommunicationSocketClass):integer;
begin Result:=inherited IndexOf(csclass); end;

function TCommunicationSocketClasses.RemoveClass(csclass:TCommunicationSocketClass):boolean;
begin Result:=inherited RemoveClass(csclass); end;

{ TCommunicationConnection }

function TCommunicationConnection.ApplyCommunicationMode:boolean; var {st:TSystemTime;} lwOrgTicks:longword; b1:boolean; begin Result:=false;
  {st:=GetNow;} lwOrgTicks:=GetTickCount;
  try Lock; // надо, чтобы с сокетом fCommunicationSocket никто в это время не работал (вдруг кто Connect или Disconnect новый делает,
            // а также, если с этим соединением ещё кто-то работает, заблокируем и им доступ на время чтения
    if not Connected then exit; // здесь получение свойства должно быть заблокировано, т.к. сокет должен существовать для работы с ним
    try fCommunicationSocket.Lock; // заблокируем и сам сокет, вдруг к нему из другого TCommunicationConnection или TCommunicationSocket обращаются
      b1:=fCommunicationMode.ChangeNotificationEnabled;
      try fCommunicationMode.ChangeNotificationEnabled:=false; // состояние Active постоянно меняется, что вызвается _OnChanged
        fCommunicationMode.Connected:=true;
        fCommunicationMode.Caption:=fCommunicationSocket.Caption; fCommunicationMode.Description:=fCommunicationSocket.Description;
        fCommunicationMode.Hint:=fCommunicationSocket.Hint; fCommunicationMode.Name:=fCommunicationSocket.Name;
        fCommunicationMode.IconHex:=fCommunicationSocket.IconHex;
        fCommunicationSocket.Assign(fCommunicationMode);
        if fCommunicationMode.Logging and fCommunicationMode.LogDetailed then LogMessage(Format('%s[=параметры][%.3dмс][%s]',
          [GetSelfTimeStamp(GetNow{st}),GetTickCount-lwOrgTicks,fCommunicationMode.StateInfo],gfs));
        fCommunicationSocket.fLastConnection:=Self; Result:=true;
      finally fCommunicationMode.ChangeNotificationEnabled:=b1; end;
    finally fCommunicationSocket.Unlock; end; // разрешаем работу с сокетом другим соединения
  finally Unlock; end; // восстанавливаем таймаут на запись, который в процессе работы менялся, разрешаем работу с нашим соединением
end;

function TCommunicationConnection.ApplyPurgeBeforeRead:boolean; begin Result:=false;
  try Lock; // надо, чтобы с сокетом fCommunicationSocket никто в это время не работал (вдруг кто Connect или Disconnect новый делает
    if(flwPurgeActionsBeforeRead=0)or not Connected then exit; // здесь получение свойства должно быть заблокировано, т.к. сокет должен существовать для работы с ним
    Result:=fCommunicationSocket._PurgeComm(flwPurgeActionsBeforeRead); // сам сокет блокировать не надо, т.к. функция Windows
    if(flwPurgeActionsBeforeRead and PURGE_RXCLEAR<>0)then fiBufferCnt:=0; // наш внутренний буфер тоже почистим
  finally Unlock; end;
end;

function TCommunicationConnection.ApplyPurgeBeforeWrite:boolean; begin Result:=false;
  try Lock; // надо, чтобы с сокетом fCommunicationSocket никто в это время не работал (вдруг кто Connect или Disconnect новый делает
    if(flwPurgeActionsBeforeWrite=0)or not Connected then exit; // здесь получение свойства должно быть заблокировано, т.к. сокет должен существовать для работы с ним
    Result:=fCommunicationSocket._PurgeComm(flwPurgeActionsBeforeWrite); // сам сокет блокировать не надо, т.к. функция Windows
  finally Unlock; end;
end;

function TCommunicationConnection.Connect:boolean; var {st:TSystemTime;} lwOrgTicks:longword; s,sFormat:AnsiString; b1,b2:boolean; begin
  {st:=GetNow;} lwOrgTicks:=GetTickCount;
  try Lock; BeginUpdate; // надо, чтобы с сокетом fCommunicationSocket никто в это время не работал (вдруг кто Connect или Disconnect новый делает
    if not Connected and(fCommunicationSocketClass<>nil)then begin
      if fCommunicationSocket<>nil then FreeAndNil(fCommunicationSocket); // сокет может быть создан
      try fCommunicationSocket:=fCommunicationSocketClass.Create(fCommunicationMode.CommName); except end;
      fbConnected:=(fCommunicationSocket<>nil)and fCommunicationSocket.Connected;
      if not fbConnected then FreeAndNil(fCommunicationSocket) // не смогли соединиться, то и сокет не будем держать
      else fCommunicationSocket.AddOnChange(Self,fCommunicationSocket,_OnChanged);
      b1:=fCommunicationMode.ChangeNotificationEnabled; 
      try fCommunicationMode.ChangeNotificationEnabled:=false; // состояние Active постоянно меняется, что вызывается _OnChanged
        if fCommunicationMode.Logging then begin
          s:=Format('открытие сокета "%s", %s',[fCommunicationMode.CommName,SystemTime2String(GetNow{st})],gfs);
          if fbConnected then sFormat:='%s[{открытие][%.3dмс]%s'else sFormat:='%s[!{открытие:не открыт][%.3dмс]%s';
          LogMessage(Format(sFormat,[GetSelfTimeStamp(GetNow{st}),GetTickCount-lwOrgTicks,s],gfs));
        end;
        b2:=fCommunicationMode.LogDetailed;
        try fCommunicationMode.LogDetailed:=true;
          if fbConnected then ApplyCommunicationMode;
        finally fCommunicationMode.LogDetailed:=b2; end;
      finally fCommunicationMode.ChangeNotificationEnabled:=b1; end;
    end;
    Result:=fbConnected; fTrafficInfo.Active:=Result;
  finally EndUpdate; Unlock; end;
end;

function TCommunicationConnection.Connect(sCommName:AnsiString):boolean; begin
  try Lock; BeginUpdate; // надо, чтобы с сокетом fCommunicationSocket никто в это время не работал (вдруг кто Connect или Disconnect новый делает
    if Connected and not AnsiSameText(sCommName,fCommunicationSocket.CommName)then Disconnect;
    if not Connected then begin fCommunicationMode.CommName:=sCommName; Connect; end;
    Result:=fbConnected;
  finally EndUpdate; Unlock; end;
end;

constructor TCommunicationConnection.Create; begin
  if fCommunicationModeClass<>nil then fCommunicationMode:=fCommunicationModeClass.Create
  else fCommunicationMode:=TCommunicationMode.Create;
  fTrafficInfo:=TTrafficInfo.Create; fpBuffer:=GetMemory(lwBufferSize); fCommunicationMode.ActiveNotifyEnabled:=false; // нам не нужно знать об изменении свойства Active
  inherited Create;
  fCommunicationMode.AddOnChange(Self,fCommunicationMode,_OnChanged); // пока унаследованные кострукторы не выполнены, рано добавлять оповещение
end;

destructor TCommunicationConnection.Destroy; begin
  try Lock; // заблокируем на всякий случай - по крайней мере все операции по уничтожению выполним
    Disconnect; FreeMemory(fpBuffer);
    fCommunicationMode.RemoveOnChange(Self,fCommunicationMode,_OnChanged);
    fCommunicationMode.Free; fCommunicationMode:=nil;
    fTrafficInfo.Free; fTrafficInfo:=nil;
  finally Unlock; end;
  inherited;
end;

function TCommunicationConnection.Disconnect:boolean; var {st:TSystemTime;} lwOrgTicks:longword; s,sFormat:AnsiString; begin
  {st:=GetNow;} lwOrgTicks:=GetTickCount;
  try Lock; BeginUpdate; // надо, чтобы с сокетом fCommunicationSocket никто в это время не работал (вдруг кто Connect или Disconnect новый делает
    if Connected then begin
      try fCommunicationSocket.RemoveOnChange(Self,fCommunicationSocket,_OnChanged);  FreeAndNil(fCommunicationSocket); except end;
        fbConnected:=fCommunicationSocket<>nil;
//      try fCommunicationMode.ChangeNotificationEnabled:=false; // состояние Active постоянно меняется, что вызывается _OnChanged
        if fCommunicationMode.Logging then begin
          s:=Format('закрытие сокета "%s", %s',[fCommunicationMode.CommName,SystemTime2String(GetNow{st})],gfs);
          if not fbConnected then sFormat:='%s[}закрытие][%.3dмс]%s'else sFormat:='%s[!}закрытие:не закрыт][%.3dмс]%s';
          LogMessage(Format(sFormat,[GetSelfTimeStamp(GetNow{st}),GetTickCount-lwOrgTicks,s],gfs));
        end;
//      finally fCommunicationMode.ChangeNotificationEnabled:=true; end;
    end;
    Result:=not fbConnected; fTrafficInfo.Active:=not Result;
  finally EndUpdate; Unlock; end;
end;

function TCommunicationConnection.DoGetAsText:AString; var v:variant; begin
  v:=_JsonFast(StringToUTF8(inherited DoGetAsText));
  v.PurgeActionsBeforeRead:=PurgeActionsBeforeRead; v.PurgeActionsBeforeWrite:=PurgActionseBeforeWrite;
  v.TimeoutReadInterChar:=TimeoutReadInterChar; v.TimeoutReadTotal:=TimeoutReadTotal; v.TimeoutWriteTotal:=TimeoutWriteTotal;
  if fCommunicationModeClass<>nil then v.CommunicationModeClass:=fCommunicationModeClass.ClassName;
  v.CommunicationMode:=_JsonFast(StringToUTF8(fCommunicationMode.AsText));
  if fCommunicationSocketClass<>nil then v.CommunicationSocketClass:=fCommunicationSocketClass.ClassName;
  if fCommunicationSocket<>nil then v.CommunicationSocket:=_JsonFast(StringToUTF8(fCommunicationSocket.AsText));
  Result:=v; if bJSONHumanReadable then Result:=JSONReformat(Result); // VariantSaveJSON(v)
  Result:=UTF8ToString(Result);
end;

function TCommunicationConnection.DoGetStateInfo:AnsiString; var s1,s2,s3,s4:AnsiString; i:integer; begin
  s4:=inherited DoGetStateInfo; s1:=Format('имя="%s"',[fsName],gfs);
  i:=Pos(s1,s4); if i<>0then Delete(s4,i,Length(s1)+1);
  s1:=''; if fCommunicationModeClass<>nil then s1:=fCommunicationModeClass.ClassName;
  s2:=''; if fCommunicationSocketClass<>nil then s2:=fCommunicationSocketClass.ClassName;
  s3:=''; if fCommunicationMode<>nil then s3:=fCommunicationMode.CommName;
  Result:=Format('имя="%s",сокет="%s",таймауты RI=%d RC=%d WC=%d,предоперации чтения=0x%.8x записи=0x%.8x,классы режим=%s сокет=%s,%s',
    [fsName,s3,TimeoutReadInterChar,TimeoutReadTotal,TimeoutWriteTotal,
      flwPurgeActionsBeforeRead,flwPurgeActionsBeforeWrite,s1,s2,s4],gfs)
    +#13#10#09+fCommunicationMode.StateInfo;
  if fCommunicationSocket<>nil then Result:=Result+#13#10#09+fCommunicationSocket.StateInfo;
end;

function TCommunicationConnection.DoGetUInt(const ndx:integer):UInt64; begin
  case ndx of
    ndxPurgeActionsBeforeRead:    Result:=flwPurgeActionsBeforeRead;
    ndxPurgeActionsBeforeWrite:   Result:=flwPurgeActionsBeforeWrite;
    ndxTimeoutReadInterChar:      Result:=fCommunicationMode.CommTimeouts.ReadIntervalTimeout;
    ndxTimeoutReadTotal:          Result:=fCommunicationMode.CommTimeouts.ReadTotalTimeoutConstant;
    ndxTimeoutWriteTotal:         Result:=fCommunicationMode.CommTimeouts.WriteTotalTimeoutConstant;
  else Result:=inherited DoGetUInt(ndx); end;
end;

procedure TCommunicationConnection.DoSetAsText(const s:AString); var v:variant; begin
  try try BeginUpdate; v:=_JsonFast({StringToUTF8(}s{)});
    flwPurgeActionsBeforeRead:=GetVariantProperty(v,'PurgeActionsBeforeRead',flwPurgeActionsBeforeRead);
    flwPurgeActionsBeforeWrite:=GetVariantProperty(v,'PurgeActionsBeforeWrite',flwPurgeActionsBeforeWrite);
    TimeoutReadInterChar:=GetVariantProperty(v,'TimeoutReadInterChar',TimeoutReadInterChar);
    TimeoutReadTotal:=GetVariantProperty(v,'TimeoutReadTotal',TimeoutReadTotal);
    TimeoutWriteTotal:=GetVariantProperty(v,'TimeoutWriteTotal',TimeoutWriteTotal);
    fCommunicationMode.AsText:=GetVariantProperty(v,'CommunicationMode',fCommunicationMode.AsText);
    inherited DoSetAsText(s);
  finally EndUpdate; end; except end;
end;

procedure TCommunicationConnection.DoSetBool(const ndx:integer; const b:Bool64); begin
  case ndx of
    ndxConnected: if fbConnected<>Bool1(b)then begin
      if Bool1(b)then Connect else Disconnect; if fbConnected=Bool1(b)then Changed;
    end; // блокировка не нужна, т.к. уже заблокировались
  else inherited DoSetBool(ndx,b); end;
end;

procedure TCommunicationConnection.DoSetUInt(const ndx:integer; const ui:UInt64); var ct:TCommTimeouts; begin
  with fCommunicationMode do case ndx of
    ndxPurgeActionsBeforeRead:  if flwPurgeActionsBeforeRead<>ui then begin flwPurgeActionsBeforeRead:=ui; Changed; end;
    ndxPurgeActionsBeforeWrite: if flwPurgeActionsBeforeWrite<>ui then begin flwPurgeActionsBeforeWrite:=ui; Changed; end;
    ndxTimeoutReadInterChar,ndxTimeoutReadTotal,ndxTimeoutWriteTotal: begin ct:=CommTimeouts;
      case ndx of
        ndxTimeoutReadInterChar:  ct.ReadIntervalTimeout:=ui;
        ndxTimeoutReadTotal:      ct.ReadTotalTimeoutConstant:=ui;
        ndxTimeoutWriteTotal:     ct.WriteTotalTimeoutConstant:=ui;
      end;
      CommTimeouts:=ct; // если изменились настройки, то будет вызов _OnChanged
    end;
  else inherited DoSetUInt(ndx,ui); end;
end;

function TCommunicationConnection.GetCommunicationMode:TCommunicationMode;
begin try Lock; Result:=fCommunicationMode; finally Unlock; end; end; // блокировка необязательная, т.к. объект существует всё время

function TCommunicationConnection.GetCommunicationSocket:TCommunicationSocket;
begin try Lock; Result:=fCommunicationSocket; finally Unlock; end; end; // блокировка обязательная, т.к. объект создаётся и уничтожается (не существует всё время)

function TCommunicationConnection.GetSelfTimeStamp(st:TSystemTime):AnsiString;
begin Result:=GetObjectTimeStamp(st,fCommunicationMode.CommName,hID); end;

function TCommunicationConnection.GetTrafficInfo:TTrafficInfo;
begin try Lock; Result:=fTrafficInfo; finally Unlock; end; end;

procedure TCommunicationConnection.LogMessage(s:AnsiString); begin
  with fCommunicationMode do WriteFileLogMessage(File_ExpandFileName('',fsLogFile),s,flwLogMaxSize);
  if@OnLogMessage<>nil then try Self.OnLogMessage(Self,s); except end;
end;

function TCommunicationConnection.ReadBuffer(const pBuf:pointer; const iBufSize:integer; out iBytesCount:integer):boolean; var s:AnsiString; begin
  Result:=false; if iBufSize<0then exit; if iBufSize=0then begin Result:=true; exit; end;
  s:=ReadDriverBuffer(iBufSize); Result:=s<>'';
  if Result then begin iBytesCount:=Length(s); CopyMemory(pBuf,@s[1],iBytesCount); end;
end;

function TCommunicationConnection.ReadBuffer(const pBuf:pointer; const iBufSize:integer):boolean; var i32:integer;
begin Result:=ReadBuffer(pBuf,iBufSize,i32); Result:=Result and(i32=iBufSize); end;

function TCommunicationConnection.ReadChar(out c:AnsiChar):boolean;
begin Result:=ReadBuffer(@c,SizeOf(c)); end;

function TCommunicationConnection.ReadFloat(out s:single):boolean;
begin Result:=ReadBuffer(@s,SizeOf(s)); end;

function TCommunicationConnection.ReadFloat(out d:double):boolean;
begin Result:=ReadBuffer(@d,SizeOf(d)); end;

function TCommunicationConnection.ReadDriverBuffer(const iBytesToRead:integer):AnsiString;
var {st:TSystemTime;} lw,lwOrgTicks,lwTicks,lwTimeout,lwBufferSize:longword;
begin Result:=''; if iBytesToRead=0then exit; // ничего читать не надо, значит как будто считали пустую строку
  {st:=GetNow;} lwOrgTicks:=GetTickCount; lwTimeout:=TimeoutReadTotal; // запоминаем текущие тики и общий таймаут на чтение
  try Lock; // надо, чтобы с сокетом fCommunicationSocket никто в это время не работал (вдруг кто Connect или Disconnect новый делает,
            // а также, если с этим соединением ещё кто-то работает, заблокируем и им доступ на время чтения
    lwBufferSize:=fCommunicationMode.CommInputQueueSize;
    if not Connected then exit; // здесь получение свойства должно быть заблокировано, т.к. сокет должен существовать для работы с ним
    try fCommunicationSocket.Lock; // заблокируем и сам сокет, вдруг к нему из другого TCommunicationConnection или TCommunicationSocket обращаются
      if fCommunicationSocket.fLastConnection<>Self then ApplyCommunicationMode; // если не мы в прошлый раз выставляли настройки, надо их применить для нашего соединения
      ApplyPurgeBeforeRead;  // здесь буферы могут быть почищены
      // внутренний наш буфер чем-то заполнен
      if fiBufferCnt<>0then begin
        lw:=fiBufferCnt; if(iBytesToRead>0)and(iBytesToRead<integer(lw))then lw:=iBytesToRead; // узнаем, сколько читать
        SetLength(Result,lw); CopyMemory(@Result[1],@fpBuffer[0],lw); dec(fiBufferCnt,lw); // копируем необходимую часть
        if fiBufferCnt<>0then CopyMemory(@fpBuffer[0],@fpBuffer[lw],fiBufferCnt); // оставшиеся байты переместим в начало
      end;
      if((iBytesToRead>0)and(Length(Result)=iBytesToRead))or((iBytesToRead=-1)and(Result<>''))then exit; // если сколько надо считали, то выходим
      // читаем всё что в буфере драйвера (в том числе символы, пришедшие во время чтения из буфера)
      repeat
        lw:=fCommunicationSocket.CommBytesForRead; if lw=0then break; // узнаем сколько уже есть в буфере драйвера
        if lw>lwBufferSize then lw:=lwBufferSize;  // больше чем может держать буфер, читать не будем
        if(iBytesToRead>0)and(lw<>0)then if longword(iBytesToRead-Length(Result))<lw then lw:=iBytesToRead-Length(Result); // не всё нам надо из буфера читать
        if lw<>0then if fCommunicationSocket._ReadFile(fpBuffer[0],lw,lw,nil)and(lw<>0)then begin
          SetLength(Result,Length(Result)+integer(lw)); CopyMemory(@Result[Length(Result)-integer(lw)+1],@fpBuffer[0],lw);
        end;
        if((iBytesToRead>0)and(Length(Result)=iBytesToRead))or((iBytesToRead=-1)and(Result<>''))then exit; // если сколько надо считали, то выходим
      until lw=0;
      if((iBytesToRead>0)and(Length(Result)=iBytesToRead))or((iBytesToRead=-1)and(Result<>''))then exit; // на всякий случай
      // читаем уже из самого сокета (в драйвере может не быть буфера)
      repeat
        lwTicks:=GetTickCount-lwOrgTicks; if lwTicks>=lwTimeout then break; // корректируем оставшееся время на чтение, если времени ожидать не осталось, выходим
        TimeoutReadTotal:=lwTimeout-lwTicks; // нельзя, чтобы было 0 - иначе функция ReadFile может зависнуть
        lw:=lwBufferSize;  // читаем по максимуму
        if(iBytesToRead>0){and(lw<>0)}then if longword(iBytesToRead-Length(Result))<lw then lw:=iBytesToRead-Length(Result); // не столько нам надо читать
        if lw<>0then if fCommunicationSocket._ReadFile(fpBuffer[0],lw,lw,nil)and(lw<>0)then begin
          SetLength(Result,Length(Result)+integer(lw)); CopyMemory(@Result[Length(Result)-integer(lw)+1],@fpBuffer[0],lw);
        end else lw:=0;
        if(TimeoutReadInterChar<>0)or((iBytesToRead=-1)and(Result<>''))then break; // если был установлен межсимвольный таймаут, то операция _ReadFile завершилась по нему
        // по идее операция _ReadFile должна быть вызвана только один раз - завершиться либо по TimeoutReadInterChar, либо по TimeoutReadTotal
      until lw=0;
      if Result<>''then fTrafficInfo.AddInBytes(Length(Result));
      if(iBytesToRead>0)and(Length(Result)<>iBytesToRead)then fTrafficInfo.AddInErrors(1);
      if fCommunicationMode.Logging then begin
        if Result<>''then LogMessage(Format('%s[<чтение:%.3d][%.3dмс][hex=%s][string=%s]',[GetSelfTimeStamp(GetNow{st}),Length(Result),GetTickCount-lwOrgTicks,
          Text_String2Hex(@Result[1],Length(Result)),AnsiQuotedStr(Text_EncodeNonPrintable(Result),'"')],gfs));
        if(iBytesToRead>0)and(Length(Result)<>iBytesToRead)and fCommunicationMode.LogDetailed then
          LogMessage(Format('%s[!<чтение:%.3d вместо %d байт][%.3dмс]',[GetSelfTimeStamp(GetNow{st}),Length(Result),iBytesToRead,GetTickCount-lwOrgTicks],gfs)); // это только в детальном логе, иначе не считали - значит не считали
      end;
    finally fCommunicationSocket.Unlock; end; // разрешаем работу с сокетом другим соединения
  finally TimeoutReadTotal:=lwTimeout; Unlock; end; // восстанавливаем таймаут на запись, который в процессе работы менялся, разрешаем работу с нашим соединением
end;

function TCommunicationConnection.ReadFloat(out e:extended):boolean;
begin Result:=ReadBuffer(@e,SizeOf(e)); end;

function TCommunicationConnection.ReadInteger(out ui8:byte):boolean;
begin Result:=ReadBuffer(@ui8,SizeOf(ui8)); end;

function TCommunicationConnection.ReadInteger(out i8:shortint):boolean;
begin Result:=ReadBuffer(@i8,SizeOf(i8)); end;

function TCommunicationConnection.ReadInteger(out ui16:word):boolean;
begin Result:=ReadBuffer(@ui16,SizeOf(ui16)); end;

function TCommunicationConnection.ReadInteger(out i16:smallint):boolean;
begin Result:=ReadBuffer(@i16,SizeOf(i16)); end;

function TCommunicationConnection.ReadInteger(out ui32:longword):boolean;
begin Result:=ReadBuffer(@ui32,SizeOf(ui32)); end;

function TCommunicationConnection.ReadInteger(out i32:integer):boolean;
begin Result:=ReadBuffer(@i32,SizeOf(i32)); end;

function TCommunicationConnection.ReadInteger(out i64:int64):boolean;
begin Result:=ReadBuffer(@i64,SizeOf(i64)); end;

function TCommunicationConnection.ReadPacket(out sPacket:AnsiString; const sStart:AnsiString; const sEnd:AnsiString; const bIncludeString:boolean):boolean;
var {st:TSystemTime;} lwOrgTicks,lwTicks,lwTimeout:longword; s,sCompare:AnsiString; i:integer; bLogging:boolean;
begin Result:=false;
  {st:=GetNow;} lwOrgTicks:=GetTickCount; lwTimeout:=TimeoutReadTotal; sCompare:=''; // запоминаем текущие тики и общий таймаут на чтение
  try Lock; // надо, чтобы с сокетом fCommunicationSocket никто в это время не работал (вдруг кто Connect или Disconnect новый делает,
            // а также, если с этим соединением ещё кто-то работает, заблокируем и им доступ на время чтения
    if not Connected then exit; // здесь получение свойства должно быть заблокировано, т.к. сокет должен существовать для работы с ним
    try fCommunicationSocket.Lock; // заблокируем и сам сокет, вдруг к нему из другого TCommunicationConnection или TCommunicationSocket обращаются
      if fCommunicationMode.Logging and fCommunicationMode.LogDetailed then begin
        LogMessage(Format('%s[#ожидание пакета][%.3dмс]старт=%s конец=%s',[GetSelfTimeStamp(GetNow{st}),GetTickCount-lwOrgTicks,
          Text_String2Hex(@sStart[1],Length(sStart)),Text_String2Hex(@sEnd[1],Length(sEnd))],gfs));
      end;
      lwTicks:=GetTickCount-lwOrgTicks; if lwTicks>=lwTimeout then lwTicks:=lwTimeout-1; // корректируем оставшееся время на чтение
      TimeoutReadTotal:=lwTimeout-lwTicks; // нельзя, чтобы было 0 - иначе функция ReadFile может зависнуть
      bLogging:=fCommunicationMode.Logging; // предварительно запомним
      try fCommunicationMode.Lock; bLogging:=fCommunicationMode.Logging;
        fCommunicationMode.Logging:=fCommunicationMode.LogDetailed; // нам не нужен лог и события об изменении, если не детализированный лог
        if not fCommunicationMode.Logging then fCommunicationMode.RemoveOnChange(Self,fCommunicationMode,_OnChanged);
        if(sStart='')or WaitBuffer(@sStart[1],Length(sStart))then begin if bIncludeString then sPacket:=sStart; // если есть старт пакета, ждём его
          repeat
            //!!! чтение сразу всего буфера, сколько есть, а потом побайтовое
            i:=fiBufferCnt+integer(fCommunicationSocket.CommBytesForRead); // узнаем сколько уже есть в нашем буфере считанных байт и в буфере драйвера
            if i>lwBufferSize then i:=lwBufferSize; // больше чем может держать буфер, читать не будем
            if(sEnd<>'')and(i<Length(sEnd)-Length(sCompare))then i:=Length(sEnd)-Length(sCompare); // если в буфере меньше чем нам надо, то дождёмся прихода других байт, иначе берём весь буфер
            if i=0then i:=-1; // будем читать в течение таймаута, если размер неизвестен
            s:=ReadDriverBuffer(i); // даже если таймаут очень маленький, мы должны попытаться считать хоть из буфера
            if(s<>'')and(sEnd<>'')then begin sCompare:=sCompare+s; s:=sEnd; // если что-то считали, то ищем нашу строку
              while s<>''do begin // ищем часть эталона от полной строки до единственного символа
                i:=Pos(s,sCompare); // ищем часть нашей строки от начала
                if i<>0then begin Result:=true; sPacket:=sPacket+Copy(sCompare,1,i-1); sCompare:=Copy(sCompare,i,MaxInt); break; end; // берём начало найденной строки до конца считанных байт
                SetLength(s,Length(s)-1); // уменьшаем искомую строку на один символ и продолжим поиск
              end;
              if not Result then begin sPacket:=sPacket+sCompare; sCompare:=''; end// если ни единного символа из искомой строки не найдено, значит ждём следующих байт
              else if s<>sEnd then Result:=false // пока ещё не нашли полностью
                else begin fiBufferCnt:=Length(sCompare)-Length(sEnd); // если после найденной строки мы ещё что-то считали, положим это обратно в буфер
                  if fiBufferCnt<>0then CopyMemory(@fpBuffer[0],@sCompare[Length(sEnd)+1],fiBufferCnt); // копируем обратно во внутренний буфер остаток
                  if bIncludeString then sPacket:=sPacket+sEnd; break; // полностью найден пакет
                  //break; // уже всё нашли
                end;
            end;
            lwTicks:=GetTickCount-lwOrgTicks; if lwTicks>=lwTimeout then break; // если таймаут вышел, то прерываем чтение
            TimeoutReadTotal:=lwTimeout-lwTicks;
            if TimeoutReadInterChar<>0then break; // если был установлен межсимвольный таймаут, то операция _ReadFile завершилась по нему
          until false;
        end;
      finally
        if not fCommunicationMode.Logging then fCommunicationMode.AddOnChange(Self,fCommunicationMode,_OnChanged);
        fCommunicationMode.Logging:=bLogging; fCommunicationMode.Unlock;
      end;
//      repeat
//            //!!! чтение сразу всего буфера, сколько есть, а потом побайтовое
//            i:=fiBufferCnt+integer(fCommunicationSocket.CommBytesForRead); // узнаем сколько уже есть в нашем буфере считанных байт и в буфере драйвера
//            if i>lwBufferSize then i:=lwBufferSize; // больше чем может держать буфер, читать не будем
//            s:=ReadDriverBuffer(i); // даже если таймаут очень маленький, мы должны попытаться считать хоть из буфера
//            if s<>''then begin
//
//            end;
//
//            lwTicks:=GetTickCount-lwOrgTicks; if lwTicks>=lwTimeout then break; // если таймаут вышел, то прерываем чтение
//            TimeoutReadTotal:=lwTimeout-lwTicks;
//            if TimeoutReadInterChar<>0then break; // если был установлен межсимвольный таймаут, то операция _ReadFile завершилась по нему
//      until false;
      if fCommunicationMode.Logging then begin
        LogMessage(Format('%s[<чтение:%d][%.3dмс][hex=%s][string=%s]',[GetSelfTimeStamp(GetNow{st}),Length(sPacket),GetTickCount-lwOrgTicks,
          Text_String2Hex(@sPacket[1],Length(sPacket)),AnsiQuotedStr(Text_EncodeNonPrintable(sPacket),'"')],gfs));
        if(not Result and(sEnd<>''))and fCommunicationMode.LogDetailed then // не прочитали полностью
          LogMessage(Format('%s[!<чтение:конец пакета %s не найден][%.3dмс]',[GetSelfTimeStamp(GetNow{st}),
            Text_String2Hex(@sEnd[1],Length(sEnd)),GetTickCount-lwOrgTicks],gfs)); // это только в детальном логе, иначе не считали - значит не считали
      end;
    finally fCommunicationSocket.Unlock; end; // разрешаем работу с сокетом другим соединения
  finally TimeoutReadTotal:=lwTimeout; Unlock; end; // восстанавливаем таймаут на чтение, который в процессе работы менялся, разрешаем работу с нашим соединением
end;

function TCommunicationConnection.ReadString(const iStringLen:integer):AnsiString;
begin Result:=ReadDriverBuffer(iStringLen); end; // напрямую, т.к. буфер не выделен, в отличие от остальных Readxxx (надо SetLength(Result) иначе)

procedure TCommunicationConnection.SetCommunicationMode(const cm:TCommunicationMode); var s:AnsiString; begin
  try Lock; fCommunicationMode.Lock; fCommunicationMode.BeginUpdate; fCommunicationMode.Assign(cm);
    if Connected then s:=fCommunicationMode.CommName; // если уже соединены, то имя порта изменить нельзя, изменим только настройки
    with fCommunicationMode.frCommTimeouts do begin ReadTotalTimeoutMultiplier:=0; WriteTotalTimeoutMultiplier:=0; end;
    if Connected then fCommunicationMode.CommName:=s; // если уже соединены, то имя порта изменить нельзя, изменим только настройки
  finally fCommunicationMode.EndUpdate; fCommunicationMode.Unlock; Unlock; end;
end; // здесь AutoLock будет у fCommunicationMode

procedure TCommunicationConnection.SetDefault; begin
  try Lock; BeginUpdate;
    inherited SetDefault;
    fsCaption:='CommunicationConnection_0x'+IntToHex(fhID,8); fsName:=fsCaption; fsDescription:=GetClassCaption;
    if fCommunicationMode<>nil then fCommunicationMode.SetDefault;
    Disconnect; TimeoutReadInterChar:=0; TimeoutReadTotal:=1000; TimeoutWriteTotal:=1000;
  finally EndUpdate; Unlock; end;
end;

function TCommunicationConnection.WaitBuffer(const pBuf:pointer; const iBufSize:integer):boolean;
var {st:TSystemTime;} lwOrgTicks,lwTicks,lwTimeout:longword; i:integer; s,sEtalon,sCompare:AnsiString; 
begin Result:=false; if pBuf=nil then exit; // не знаем, что ожидать
  if iBufSize<0then exit; if iBufSize=0then begin Result:=true; exit; end;
  {st:=GetNow;} lwOrgTicks:=GetTickCount; lwTimeout:=TimeoutReadTotal; sCompare:=''; // запоминаем текущие тики и общий таймаут на чтение
  try Lock; // надо, чтобы с сокетом fCommunicationSocket никто в это время не работал (вдруг кто Connect или Disconnect новый делает,
            // а также, если с этим соединением ещё кто-то работает, заблокируем и им доступ на время чтения
    if not Connected then exit; // здесь получение свойства должно быть заблокировано, т.к. сокет должен существовать для работы с ним
    try fCommunicationSocket.Lock; // заблокируем и сам сокет, вдруг к нему из другого TCommunicationConnection или TCommunicationSocket обращаются
      SetLength(sEtalon,iBufSize); CopyMemory(@sEtalon[1],pBuf,iBufSize); // создаём строку, которую надо ожидать
      lwTicks:=GetTickCount-lwOrgTicks; if lwTicks>=lwTimeout then lwTicks:=lwTimeout-1; // корректируем оставшееся время на чтение
      TimeoutReadTotal:=lwTimeout-lwTicks; // нельзя, чтобы было 0 - иначе функция ReadFile может зависнуть
      if fCommunicationMode.Logging and fCommunicationMode.LogDetailed then begin SetLength(s,iBufSize); CopyMemory(@s[1],pBuf,iBufSize);
        LogMessage(Format('%s[#ожидание:%.3d][%.3dмс][hex=%s][string=%s]',[GetSelfTimeStamp(GetNow{st}),iBufSize,GetTickCount-lwOrgTicks,
          Text_String2Hex(pBuf,iBufSize),AnsiQuotedStr(Text_EncodeNonPrintable(s),'"')],gfs));
      end;
      repeat
        //!!! чтение сразу всего буфера, сколько есть, а потом побайтовое
        i:=fiBufferCnt+integer(fCommunicationSocket.CommBytesForRead); // узнаем сколько уже есть в нашем буфере считанных байт и в буфере драйвера
        if i>lwBufferSize then i:=lwBufferSize; // больше чем может держать буфер, читать не будем
        if i<iBufSize-Length(sCompare)then i:=iBufSize-Length(sCompare); // если в буфере меньше чем нам надо, то дождёмся прихода других байт, иначе берём весь буфер
        s:=ReadDriverBuffer(i); // даже если таймаут очень маленький, мы должны попытаться считать хоть из буфера
        if s<>''then begin sCompare:=sCompare+s; s:=sEtalon; // если что-то считали, то ищем нашу строку
          while s<>''do begin // ищем часть эталона от полной строки до единственного символа
            i:=Pos(s,sCompare); // ищем часть нашей строки от начала
            if i<>0then begin Result:=true; sCompare:=Copy(sCompare,i,MaxInt); break; end; // берём начало найденной строки до конца считанных байт
            SetLength(s,Length(s)-1); // уменьшаем искомую строку на один символ и продолжим поиск
          end;
          if not Result then sCompare:=''// если ни единного символа из искомой строки не найдено, значит ждём следующих байт
          else if s<>sEtalon then Result:=false // пока ещё не нашли полностью
            else begin fiBufferCnt:=Length(sCompare)-Length(sEtalon); // если после найденной строки мы ещё что-то считали, положим это обратно в буфер
              if fiBufferCnt<>0then CopyMemory(@fpBuffer[0],@sCompare[Length(sEtalon)+1],fiBufferCnt); // копируем обратно во внутренний буфер остаток
              break; // уже всё нашли
            end;
        end;
        {//!!! побайтное чтение - так очень долго (в процессе ожидания прерывают другие потоки - каждые 30 мс на чтение),
        // таймаут выходит, на зато лишние байты не считываются
        s:=ReadDriverBuffer(iBufSize-Length(sCompare)); // даже если таймаут такой маленький, мы должны попытаться считать хотя бы из буфера, остаток до полного сравнения
        if(s<>'')then begin sCompare:=sCompare+s; // если что-то считали, добавляем к сравнению
          if AnsiSameStr(sCompare,sEtalon)then begin Result:=true; break; end // точно наша строка, найдена
          else begin // идём поиск начальных частей эталона в конце строки sCompare, вдруг там есть уже часть - будем дочитывать
            for i:=iBufSize-1downto 1do // ищем максимальную длину от начала эталона в конце считанной строки
              if AnsiSameStr(RightStr(sCompare,i),Copy(sEtalon,1,i))then // если есть такая в конце
                begin Result:=true; sCompare:=Copy(sEtalon,1,i); break; end; // копируем в считанную эту максимальную длину
            if not Result then sCompare:=''else Result:=false; // если ничего не нашли, то считанная строка пустая
          end;
        end;}
        lwTicks:=GetTickCount-lwOrgTicks; if lwTicks>=lwTimeout then break; // если таймаут вышел, то прерываем чтение
        TimeoutReadTotal:=lwTimeout-lwTicks;
//        if TimeoutReadInterChar<>0then break; // если был установлен межсимвольный таймаут, то операция _ReadFile завершилась по нему
      until false;
      if fCommunicationMode.Logging and fCommunicationMode.LogDetailed and(not Result)then LogMessage(Format('%s[!#ожидание:время вышло][%.3dмс]',[GetSelfTimeStamp(GetNow{st}),GetTickCount-lwOrgTicks],gfs));
    finally fCommunicationSocket.Unlock; end; // разрешаем работу с сокетом другим соединения
  finally TimeoutReadTotal:=lwTimeout; Unlock; end; // восстанавливаем таймаут на чтение, который в процессе работы менялся, разрешаем работу с нашим соединением
end;

function TCommunicationConnection.WaitChar(const c:AnsiChar):boolean;
begin Result:=WaitBuffer(@c,SizeOf(c)); end;

function TCommunicationConnection.WaitFloat(const s:single):boolean;
begin Result:=WaitBuffer(@s,SizeOf(s)); end;

function TCommunicationConnection.WaitFloat(const d:double):boolean;
begin Result:=WaitBuffer(@d,SizeOf(d)); end;

function TCommunicationConnection.WaitFloat(const e:extended):boolean;
begin Result:=WaitBuffer(@e,SizeOf(e)); end;

function TCommunicationConnection.WaitInteger(const ui8:byte):boolean;
begin Result:=WaitBuffer(@ui8,SizeOf(ui8)); end;

function TCommunicationConnection.WaitInteger(const i8:shortint):boolean;
begin Result:=WaitBuffer(@i8,SizeOf(i8)); end;

function TCommunicationConnection.WaitInteger(const ui16:word):boolean;
begin Result:=WaitBuffer(@ui16,SizeOf(ui16)); end;

function TCommunicationConnection.WaitInteger(const i16:smallint):boolean;
begin Result:=WaitBuffer(@i16,SizeOf(i16)); end;

function TCommunicationConnection.WaitInteger(const ui32:longword):boolean;
begin Result:=WaitBuffer(@ui32,SizeOf(ui32)); end;

function TCommunicationConnection.WaitInteger(const i32:integer):boolean;
begin Result:=WaitBuffer(@i32,SizeOf(i32)); end;

function TCommunicationConnection.WaitInteger(const i64:int64):boolean;
begin Result:=WaitBuffer(@i64,SizeOf(i64)); end;

function TCommunicationConnection.WaitString(const s:AnsiString):boolean;
begin Result:=WaitBuffer(@s[1],Length(s)); end;

function TCommunicationConnection.WriteBuffer(const pBuf:pointer; const iBufSize:integer; out iBytesCount:integer):boolean;
var {st:TSystemTime;} lw,lwOrgTicks,lwTicks,lwTimeout:longword; s:AnsiString;
begin Result:=false; if pBuf=nil then exit; // не знаем, что передавать
  if iBufSize<0then exit; if iBufSize=0then begin Result:=true; exit; end;
  {st:=GetNow;} lwOrgTicks:=GetTickCount; lwTimeout:=TimeoutWriteTotal; // запоминаем текущие тики и общий таймаут на запись
  try Lock; // надо, чтобы с сокетом fCommunicationSocket никто в это время не работал (вдруг кто Connect или Disconnect новый делает,
            // а также, если с этим соединением ещё кто-то работает, заблокируем и им доступ на время чтения
    if not Connected then exit; // здесь получение свойства должно быть заблокировано, т.к. сокет должен существовать для работы с ним
    try fCommunicationSocket.Lock; // заблокируем и сам сокет, вдруг к нему из другого TCommunicationConnection или TCommunicationSocket обращаются
      if fCommunicationSocket.fLastConnection<>Self then ApplyCommunicationMode; // если не мы в прошлый раз выставляли настройки, надо их применить для нашего соединения
      ApplyPurgeBeforeWrite;  // здесь буферы могут быть почищены
      lwTicks:=GetTickCount-lwOrgTicks; if lwTicks>=lwTimeout then lwTicks:=lwTimeout-1; // корректируем оставшееся время на запись
      TimeoutWriteTotal:=lwTimeout-lwTicks; // нельзя, чтобы было 0 - иначе функция WriteFile может зависнуть
      Result:=fCommunicationSocket._WriteFile(pBuf^,iBufSize,lw,nil); iBytesCount:=lw;
      if Result then fTrafficInfo.AddOutBytes(iBytesCount);
      if not Result or(iBytesCount<>iBufSize)then fTrafficInfo.AddOutErrors(1);
      if fCommunicationMode.Logging then begin SetLength(s,iBufSize); CopyMemory(@s[1],pBuf,iBufSize);
        LogMessage(Format('%s[>запись:%.3d][%.3dмс][hex=%s][string=%s]',[GetSelfTimeStamp(GetNow{st}),iBufSize,GetTickCount-lwOrgTicks,
          Text_String2Hex(pBuf,iBufSize),AnsiQuotedStr(Text_EncodeNonPrintable(s),'"')],gfs));
        if not Result or(iBytesCount<>iBufSize)then
          LogMessage(Format('%s[!<запись:%.3d из %d байт][%.3dмс]',[GetSelfTimeStamp(GetNow{st}),iBytesCount,iBufSize,GetTickCount-lwOrgTicks],gfs));
      end;
    finally fCommunicationSocket.Unlock; end; // разрешаем работу с сокетом другим соединения
  finally TimeoutWriteTotal:=lwTimeout; Unlock; end; // восстанавливаем таймаут на запись, который в процессе работы менялся, разрешаем работу с нашим соединением
end;

function TCommunicationConnection.WriteBuffer(const pBuf:pointer; const iBufSize:integer):boolean; var i32:integer;
begin Result:=WriteBuffer(pBuf,iBufSize,i32); Result:=Result and(i32=iBufSize); end;

function TCommunicationConnection.WriteChar(const c:AnsiChar):boolean;
begin Result:=WriteBuffer(@c,SizeOf(c)); end;

function TCommunicationConnection.WriteFloat(const s:single):boolean;
begin Result:=WriteBuffer(@s,SizeOf(s)); end;

function TCommunicationConnection.WriteFloat(const d:double):boolean;
begin Result:=WriteBuffer(@d,SizeOf(d)); end;

function TCommunicationConnection.WriteFloat(const e:extended):boolean;
begin Result:=WriteBuffer(@e,SizeOf(e)); end;

function TCommunicationConnection.WriteInteger(out ui8:byte):boolean;
begin Result:=WriteBuffer(@ui8,SizeOf(ui8)); end;

function TCommunicationConnection.WriteInteger(const i8:shortint):boolean;
begin Result:=WriteBuffer(@i8,SizeOf(i8)); end;

function TCommunicationConnection.WriteInteger(const ui16:word):boolean;
begin Result:=WriteBuffer(@ui16,SizeOf(ui16)); end;

function TCommunicationConnection.WriteInteger(const i16:smallint):boolean;
begin Result:=WriteBuffer(@i16,SizeOf(i16)); end;

function TCommunicationConnection.WriteInteger(const ui32:longword):boolean;
begin Result:=WriteBuffer(@ui32,SizeOf(ui32)); end;

function TCommunicationConnection.WriteInteger(const i32:integer):boolean;
begin Result:=WriteBuffer(@i32,SizeOf(i32)); end;

function TCommunicationConnection.WriteInteger(const i64:int64):boolean;
begin Result:=WriteBuffer(@i64,SizeOf(i64)); end;

function TCommunicationConnection.WriteString(const s:AnsiString):boolean;
begin Result:=WriteBuffer(@s[1],Length(s)); end;

procedure TCommunicationConnection._OnChanged(Sender:TObject); begin Changed;
  // считаем, что никто не уничтожает ни fCommunicationMode (мы его создаём), ни fCommunicationSocket (тоже мы создаём)
  if(Sender=fCommunicationMode)then ApplyCommunicationMode;
  if(fCommunicationSocket<>nil)and(Sender=fCommunicationSocket)and(not fCommunicationSocket.Destroying)
    and Connected and not fCommunicationSocket.Connected // будем отслеживать отсоединение сокета
      then Disconnect;
end;

class function TCommunicationConnection.GetClassCaption:AString;
begin Result:='коммуникационное соединение (TCommunicationConnection)'; end;

class function TCommunicationConnection.GetClassDescription:AString;
begin Result:='коммуникационное соединение TCommunicationConnection позволяет открыть сокет определённого класса TCommunicationSocket со своими настройками TCommunicationMode'; end;

{ TCommunicationConnections }

function TCommunicationConnections.AddObject(cc:TCommunicationConnection):boolean;
begin Result:=inherited AddObject(cc); end;

constructor TCommunicationConnections.Create;
begin fObjectClass:=TCommunicationConnection; inherited Create; end;

function TCommunicationConnections.CreateObject:TCommunicationConnection;
begin Result:=TCommunicationConnection(inherited CreateObject); end;

function TCommunicationConnections.GetObject(ndx:integer):TCommunicationConnection;
begin Result:=TCommunicationConnection(inherited GetObject(ndx)); end;

function TCommunicationConnections.IndexOf(cc:TCommunicationConnection):integer;
begin Result:=inherited IndexOf(cc); end;

function TCommunicationConnections.RemoveObject(cc:TCommunicationConnection):boolean;
begin Result:=inherited RemoveObject(cc); end;

{ TCommunicationConnectionClasses }

function TCommunicationConnectionClasses.AddClass(ccclass:TCommunicationConnectionClass):boolean;
begin Result:=inherited AddClass(ccclass); end;

function TCommunicationConnectionClasses.GetClass(ndx:integer):TCommunicationConnectionClass;
begin Result:=TCommunicationConnectionClass(inherited GetClass(ndx)); end;

function TCommunicationConnectionClasses.IndexOf(ccclass:TCommunicationConnectionClass):integer;
begin Result:=inherited IndexOf(ccclass); end;

function TCommunicationConnectionClasses.RemoveClass(ccclass:TCommunicationConnectionClass):boolean;
begin Result:=inherited RemoveClass(ccclass); end;

{ TCommunicationProtocol }

function TCommunicationProtocol.DoGetAsText:AString; var v:variant; begin
  v:=_JsonFast(StringToUTF8(inherited DoGetAsText));
  v.AddressSize:=flwAddressSize; v.BroadcastAddress:=flwBroadcastAddress; v.DefaultAddress:=flwDefaultAddress; v.MaxPacketSize:=flwMaxPacketSize;
  v.TransmissionMode:=flwTransmissionMode;
  Result:=v; if bJSONHumanReadable then Result:=JSONReformat(Result); // VariantSaveJSON(v)
  Result:=UTF8ToString(Result);
end;

function TCommunicationProtocol.DoGetStateInfo:AnsiString; begin
  Result:=Format('%s,AddressSize=%d,BroadcastAddress=%d,DefaultAddress=%d,MaxPacketSize=%d,TM=%d',[inherited DoGetStateInfo,flwAddressSize,flwBroadcastAddress,flwDefaultAddress,flwMaxPacketSize,flwTransmissionMode],gfs);
end;

function TCommunicationProtocol.DoGetUInt(const ndx:integer):UInt64; begin
  case ndx of
    ndxAddressSize:     Result:=flwAddressSize;             ndxBroadcastAddress:  Result:=flwBroadcastAddress;
    ndxDefaultAddress:  Result:=flwDefaultAddress;          ndxMaxPacketSize:     Result:=flwMaxPacketSize;
    ndxTransmissionMode: Result:=flwTransmissionMode;
  else Result:=inherited DoGetUInt(ndx); end;
end;

procedure TCommunicationProtocol.DoSetAsText(const s:AString); var v:variant; begin
  try try BeginUpdate; v:=_JsonFast({StringToUTF8(}s{)});
    AddressSize:=GetVariantProperty(v,'AddressSize',flwAddressSize);
    BroadcastAddress:=GetVariantProperty(v,'BroadcastAddress',flwBroadcastAddress);
    DefaultAddress:=GetVariantProperty(v,'DefaultAddress',flwDefaultAddress);
    MaxPacketSize:=GetVariantProperty(v,'MaxPacketSize',flwMaxPacketSize);
    TransmissionMode:=GetVariantProperty(v,'TransmissionMode',flwTransmissionMode);
    inherited DoSetAsText(s);
  finally EndUpdate; end; except end;
end;

procedure TCommunicationProtocol.DoSetUInt(const ndx:integer; const ui:UInt64); begin
  case ndx of
    ndxAddressSize:         if flwAddressSize<>ui then begin flwAddressSize:=ui; Changed; end;
    ndxBroadcastAddress:    if flwBroadcastAddress<>ui then begin flwBroadcastAddress:=ui; Changed; end;
    ndxDefaultAddress:      if(flwDefaultAddress<>ui)and(ui<>flwBroadcastAddress)then begin flwDefaultAddress:=ui; Changed; end;
    ndxMaxPacketSize:       if flwMaxPacketSize<>ui then begin flwMaxPacketSize:=ui; Changed; end;
    ndxTransmissionMode:    if flwTransmissionMode<>ui then begin flwTransmissionMode:=ui; Changed; end;
  else inherited DoSetUInt(ndx,ui); end;
end;

function TCommunicationProtocol.GetErrorAsText(ce:integer):AnsiString;
begin Result:=GetErrorStr(ce); end;

function TCommunicationProtocol.HandleResponse(sRequest,sResponse:AnsiString; pDst:pointer; iDstSize:integer):integer;
begin Result:=ceSuccess; end;

function TCommunicationProtocol.IsResponseSuccess(const ce:integer):boolean;
begin Result:=false; end;

function TCommunicationProtocol.MakeRequest(arrPacketData:array of Int64):AnsiString;
begin Result:=''; end;

function TCommunicationProtocol.MakeRequest(const pRequest:pointer; const lwSize:longword):AnsiString;
begin Result:=''; end;

function TCommunicationProtocol.MakeRequest(arrPacketData:array of Int64; out sRequest:AnsiString; out ndxError:integer):integer;
begin Result:=ceSuccess; end;

function TCommunicationProtocol.IsBroadcastRequest(const sRequest:AnsiString):boolean;
begin Result:=false; end;

function TCommunicationProtocol.MakeRequest(const pRequest:pointer; const lwSize:longword; out sRequest:AnsiString; out ndxError:integer):integer;
begin Result:=ceSuccess; end;

function TCommunicationProtocol.MakeResponse(arrPacketData:array of Int64):AnsiString;
begin Result:=''; end;

function TCommunicationProtocol.MakeResponse(const pResponse:pointer; const lwSize:longword):AnsiString;
begin Result:=''; end;

function TCommunicationProtocol.MakeResponse(arrPacketData:array of Int64; out sResponse:AnsiString; out ndxError:integer):integer;
begin Result:=ceSuccess; end;

function TCommunicationProtocol.MakeResponse(const pResponse:pointer; const lwSize:longword; out sResponse:AnsiString; out ndxError:integer):integer;
begin Result:=ceSuccess; end;

function TCommunicationProtocol.MakePacket(const sHexBody:AnsiString):AnsiString;
begin Result:=Text_Hex2String(sHexBody); end;

procedure TCommunicationProtocol.SetDefault; begin
  try Lock; BeginUpdate; inherited;
    fsCaption:='CommunicationProtocol_0x'+IntToHex(fhID,8); fsName:=fsCaption; fsDescription:='коммуникационный протокол (TCommunicationProtocol)';
    AddressSize:=1; BroadcastAddress:=255; DefaultAddress:=1; MaxPacketSize:=255; TransmissionMode:=0;
  finally Unlock; end;
end;

{ TCommunicationProtocols }

function TCommunicationProtocols.AddObject(cp:TCommunicationProtocol):boolean;
begin Result:=inherited AddObject(cp); end;

constructor TCommunicationProtocols.Create;
begin fObjectClass:=TCommunicationProtocol; inherited Create; end;

function TCommunicationProtocols.CreateObject:TCommunicationProtocol;
begin Result:=TCommunicationProtocol(inherited CreateObject); end;

function TCommunicationProtocols.GetObject(ndx:integer):TCommunicationProtocol;
begin Result:=TCommunicationProtocol(inherited GetObject(ndx)); end;

function TCommunicationProtocols.IndexOf(cp:TCommunicationProtocol):integer;
begin Result:=inherited IndexOf(cp); end;

function TCommunicationProtocols.RemoveObject(cp:TCommunicationProtocol):boolean;
begin Result:=inherited RemoveObject(cp); end;

{ TCommunicationProtocolClasses }

function TCommunicationProtocolClasses.AddClass(cpclass:TCommunicationProtocolClass):boolean;
begin Result:=inherited AddClass(cpclass); end;

function TCommunicationProtocolClasses.GetClass(ndx:integer):TCommunicationProtocolClass;
begin Result:=TCommunicationProtocolClass(inherited GetClass(ndx)); end;

function TCommunicationProtocolClasses.IndexOf(cpclass:TCommunicationProtocolClass):integer;
begin Result:=inherited IndexOf(cpclass); end;

function TCommunicationProtocolClasses.RemoveClass(cpclass:TCommunicationProtocolClass):boolean;
begin Result:=inherited RemoveClass(cpclass); end;

{ TCommunicatonDevice }

function TCommunicationDevice.AddTag(sName:AnsiString):pointer; var ndx:integer; begin
  try Lock;
    ndx:=fTagsDescriptors.IndexOf(sName);
    if ndx<>-1then Result:=PrTagDescriptor(fTagsDescriptors.Objects[ndx])else begin
      Result:=AllocTagDescriptor; PrTagDescriptor(Result)._sName:=sName;
    end;
  finally Unlock; end;
end;

function TCommunicationDevice.Alive:boolean; var s:AnsiString; ce:integer; begin Result:=false;
  try Lock; if(cc=nil)or(cp=nil)then exit; // нет соединения - ничего сделать не сможем
    with rAliveInfo do try // cc.Lock; {нельзя блокировать, т.к. поток транзакций потом будет использовать "соединение" и повиснет}
      _bInitialized:=true; _bProcessing:=false; ce:=DoAlive; Result:=ce=ceSuccess;
      if not Result then s:='!ошибка проверки соединения: '+GetErrorAsText(ce)else
        if _bProcessing then s:='<ожидание завершения проверки соединения'else s:='проверка соединения';
      LogMessage(s);
      if _bAuto then LogMessage('следующая проверка соединения будет выполнена через '+IntToStr(_lwInterval div 1000)+' с');
      _lwLastTicks:=GetTickCount; _lwOrgTicks:=_lwLastTicks; //_bProcessing:=Result;
    finally {cc.Unlock;} end;
  finally Unlock; end;
end;

function TCommunicationDevice.AllocTagDescriptor:pointer;
begin Result:=GetMemory(SizeOf(TrTagDescriptor)); ZeroMemory(Result,SizeOf(TrTagDescriptor)); end;

function TCommunicationDevice.Authorize:boolean; var s:AnsiString; ce:integer; begin Result:=false;
  try Lock; if(cc=nil)or(cp=nil)then exit; // нет соединения - ничего сделать не сможем
    with rAuthorizeInfo do try // cc.Lock; {нельзя блокировать, т.к. поток транзакций потом будет использовать "соединение" и повиснет}
      _bInitialized:=true; _bProcessing:=false; ce:=DoAuthorize; Result:=ce=ceSuccess;
      if not Result then s:='!ошибка авторизации: '+GetErrorAsText(ce)else
        if _bProcessing then s:='<ожидание завершения авторизации'else s:='авторизация устройства';
      LogMessage(s);
      if _bAuto then LogMessage('следующая авторизация будет выполнена через '+IntToStr(_lwInterval div 1000)+' с');
      _lwLastTicks:=GetTickCount; _lwOrgTicks:=_lwLastTicks; //_bProcessing:=Result;
    finally {cc.Unlock;} end;
  finally Unlock; end;
end;

procedure TCommunicationDevice.BeginTask;
begin Lock; if TLBaseNotifier(Notifier).CriticalSection.RecursionCount=1then ClearTask; end;

procedure TCommunicationDevice.ClearTags; {var i:integer;} begin
  try Lock;
    while fTagsDescriptors.Count<>0do begin
      try RemoveTag(fTagsDescriptors[0]); except end;
      fTagsDescriptors.Delete(0);
    end;
{    for i:=0to fTagsDescriptors.Count-1do try RemoveTag(fTagsDescriptors[i]); except end; fTagsDescriptors.Clear;}
  finally Unlock; end;
end;

procedure TCommunicationDevice.ClearTask; begin

end;

procedure TCommunicationDevice.ClearUpdateTags;
begin try Lock; fUpdateTags.Clear; finally Unlock; end; end;

function TCommunicationDevice.Connect:boolean; var s:AnsiString; const arr:array[Boolean]of Char=('!','+');  begin Result:=false;
  try Lock; if(cc=nil)then exit; // нет соединения - ничего сделать не сможем
    with rConnectInfo do try cc.Lock; cc.Connect; Result:=cc.Connected;
      _bInitialized:=true; _bProcessing:=false; _lwLastTicks:=GetTickCount; _lwOrgTicks:=_lwLastTicks;
//      if Result then Tick; // сделаем ещё один шаг после соединения
      if Result then s:='соединение установлено: 'else s:='ошибка соединения: ';
      LogMessage(arr[cc.Connected]+cc.ClassName+' '+s+cc.StateInfo);
    finally cc.Unlock; end;
  finally Unlock; end;
end;

constructor TCommunicationDevice.Create; begin inherited;
  fTagsDescriptors:=THashedStringList.Create; fTagsDescriptors.OnChange:=_OnChanged;
  fTaskTags:=THashedStringList.Create; fUpdateTags:=THashedStringList.Create;
  if fCommunicationProtocolClass=nil then fCommunicationProtocolClass:=TCommunicationProtocol;
  if fCommunicationThreadClass=nil then fCommunicationThreadClass:=TCommunicationThread;
end;

function TCommunicationDevice.Deauthorize:boolean; var s:AnsiString; ce:integer; begin Result:=false;
  try Lock; if(cc=nil)or(cp=nil)then exit; // нет соединения - ничего сделать не сможем
    try // cc.Lock; {нельзя блокировать, т.к. поток транзакций потом будет использовать "соединение" и повиснет}
      ce:=DoDeauthorize; Result:=ce=ceSuccess;
      if not Result then s:='!ошибка деавторизации: '+GetErrorAsText(ce)else s:='деавторизация устройства';
      LogMessage(s);
    finally {cc.Unlock;} end;
  finally Unlock; end;
end;

destructor TCommunicationDevice.Destroy; begin
  try Lock;
    Disconnect; 
    ClearUpdateTags; FreeAndNil(fUpdateTags);
    ClearTask; FreeAndNil(fTaskTags);
    ClearTags; FreeAndNil(fTagsDescriptors);
  finally Unlock; end;
  inherited;
end;

function TCommunicationDevice.Disconnect:boolean; begin Result:=false;
  try Lock;
    if(cc<>nil)and cc.Connected then try cc.Lock;
      Result:=true; Deauthorize; cc.Disconnect;
    finally {cc.Unlock;} end;
    InitDevice;
    if Result then LogMessage('-соединение разорвано: '+cc.ClassName+cc.StateInfo);
  finally Unlock; end;
end;

function TCommunicationDevice.DoAlive:integer;
begin Result:=ceInvalidFunction; end;

function TCommunicationDevice.DoAuthorize:integer;
begin Result:=ceInvalidFunction; end;

function TCommunicationDevice.DoDeauthorize:integer;
begin Result:=ceInvalidFunction; end;

function TCommunicationDevice.DoGetRefreshID:longword;
begin Result:=Random(High(Result)); end;

function TCommunicationDevice.DoGetUInt(const ndx:integer):UInt64; begin
  case ndx of
    ndxAddress: Result:=fui64Address;
  else Result:=inherited DoGetUInt(ndx); end;
end;

function TCommunicationDevice.DoInitialize:integer;
begin Result:=ceSuccess; end; // по умолчанию устройство типа проинициализировано

function TCommunicationDevice.DoProgress(const idCurrentProcess,idParentProcess,lwCurrentProgress,lwMaximalProgress,lwTimeEllapsed:longword;
  const sProcessText:AnsiString; const enProgressState:TProgressState):boolean;
begin if@fOnProgress=nil then begin Result:=false; exit; end; 
  try Result:=fOnProgress(Self,nil,idCurrentProcess,idParentProcess,lwCurrentProgress,lwMaximalProgress,lwTimeEllapsed,sProcessText,enProgressState);
  except Result:=true; end;
end;

function TCommunicationDevice.DoRefresh:integer;
begin Result:=ceInvalidFunction; end;

procedure TCommunicationDevice.DoSetUInt(const ndx:integer; const ui:UInt64); var iSize:integer; begin
  case ndx of
    ndxAddress: if ui<>fui64Address then begin fui64Address:=0;
      if CommunicationProtocol<>nil then iSize:=CommunicationProtocol.AddressSize else iSize:=SizeOf(ui);
      CopyMemory(@fui64Address,@ui,iSize); fbAddressAssigned:=true;
    end;
  end;
end;

function TCommunicationDevice.DoSynchronize:integer;
begin Result:=ceInvalidFunction; end;

function TCommunicationDevice.DoSynchronizeBroadcast:integer;
begin Result:=ceInvalidFunction; end;

procedure TCommunicationDevice.EndTask; begin
  try Lock;
    if TLBaseNotifier(Notifier).CriticalSection.RecursionCount=2then ExecuteTask;
    ClearTask;
  finally Unlock; end;
  Unlock;
end;

procedure TCommunicationDevice.ExecuteTask;
begin

end;

procedure TCommunicationDevice.FreeTagDescriptor(pTagDescriptor:pointer);
begin PrTagDescriptor(pTagDescriptor)._sName:=''; PrTagDescriptor(pTagDescriptor)._sValue:=''; FreeMemory(pTagDescriptor); end;

function TCommunicationDevice.GetCC:TCommunicationConnection;
begin try Lock; Result:=cc; finally Unlock; end; end;

function TCommunicationDevice.GetCP:TCommunicationProtocol;
begin try Lock; Result:=cp; finally Unlock; end; end;

function TCommunicationDevice.GetErrorAsText(ce:integer):AnsiString; begin
  try if cp<>nil then Result:=cp.GetErrorAsText(ce)else Result:='0x'+IntToHex(ce,8)+' - неизвестный код ошибки';
  except Result:='0x'+IntToHex(ce,8)+' - неизвестный код ошибки'; end;
end;

{function TCommunicationDevice.GetI32(const ndx:integer):integer; begin
  try Lock;
    case ndx of
      ndxTagsCount:     Result:=fTagsDescriptors.Count;
    else Result:=inherited GetI32(ndx); end;
  finally Unlock; end;
end;}

function TCommunicationDevice.GetOnProgress:TProgressCallBackEvent;
begin try Lock; Result:=fOnProgress; finally Unlock; end; end;

function TCommunicationDevice.GetTag(v:OleVariant):AnsiString; var ndx:integer; begin Result:='';
  if fTagsDescriptors.Count>0then try Lock;
    if VarIsOrdinal(v)then ndx:=v else ndx:=fTagsDescriptors.IndexOf(v);
    if(ndx>=0)and(ndx<=fTagsDescriptors.Count-1)then Result:=GetTagInfo(fTagsDescriptors.Objects[ndx]);
  finally Unlock; end;
end;

function TCommunicationDevice.GetTagInfo(pTagInfo:pointer):AnsiString; var v:variant; begin
  TDocVariant.New(v);
  with PrTagDescriptor(pTagInfo)^do begin
    v.Name:=_sName; v.Type:=_sType; v.Value:=_sValue;
    v.ReadError:=_sReadError; v.WriteError:=_sWriteError;
    v.LastRead:=SystemTime2String(_stLastRead); v.LastWrite:=SystemTime2String(_stLastWrite);
  end;
  Result:=v; if bJSONHumanReadable then Result:=JSONReformat(Result); Result:=UTF8ToString(Result);
end;

procedure TCommunicationDevice.InitDevice; begin
  try Lock;
    if rRefreshInfo._pData<>nil then FreeMemory(rRefreshInfo._pData);

    ZeroMemory(@rAuthorizeInfo,SizeOf(rAuthorizeInfo)); ZeroMemory(@rAliveInfo,SizeOf(rAliveInfo));
    ZeroMemory(@rConnectInfo,SizeOf(rConnectInfo));     ZeroMemory(@rInitializeInfo,SizeOf(rInitializeInfo));
    ZeroMemory(@rRefreshInfo,SizeOf(rRefreshInfo));     ZeroMemory(@rSynchronizeInfo,SizeOf(rSynchronizeInfo));
    ZeroMemory(@rTickInfo,SizeOf(rTickInfo));           ZeroMemory(@rUpdateInfo,SizeOf(rUpdateInfo));
    ZeroMemory(@rBusyInfo,SizeOf(rBusyInfo));

    rAuthorizeInfo._bAuto:=true;    rAuthorizeInfo._lwInterval:=0;              // авторизация по требованию
    rAliveInfo._bAuto:=true;        rAliveInfo._lwInterval:=90000;              // раз в 1.5 минуты проверка связи
    rConnectInfo._bAuto:=true;      rConnectInfo._lwInterval:=30000;            // раз в 30 секунд установка связи
    rInitializeInfo._bAuto:=true;   rInitializeInfo._lwInterval:=MAXDWORD;      // период не используется здесь
    rRefreshInfo._bAuto:=true;      rRefreshInfo._lwInterval:=90000;            // раз в 15 минут опрос общий

    rSynchronizeInfo._bAuto:=true;  rSynchronizeInfo._lwInterval:=60000;        // раз в 10 минут синхронизация
    rTickInfo._bAuto:=true;         rTickInfo._lwInterval:=100;                 // автотик каждые 100 мс
    rUpdateInfo._bAuto:=false;      rUpdateInfo._lwInterval:=12000;             // раз в 15 секунд обновление тегов
    rBusyInfo._bAuto:=true;         rBusyInfo._lwInterval:=15000;               // 15 секунд при занятости устройства его опрашивать нельзя
  finally Unlock; end;
end;

function TCommunicationDevice.Initialize:boolean; var s:AnsiString; ce:integer; begin Result:=false;
  try Lock; if(cc=nil)or(cp=nil)then exit; // нет соединения - ничего сделать не сможем
    with rInitializeInfo do try // cc.Lock; {нельзя блокировать, т.к. поток транзакций потом будет использовать "соединение" и повиснет}
      _bInitialized:=true; _bProcessing:=false; ce:=DoInitialize; Result:=ce=ceSuccess;
      if not Result then s:='!ошибка инициализации устройства: '+GetErrorAsText(ce)else
        if _bProcessing then s:='<ожидание завершения авторизации'else s:='инициализация устройства';
      LogMessage(s);
      _lwLastTicks:=GetTickCount; _lwOrgTicks:=_lwLastTicks; //_bProcessing:=Result;
      if not Result then begin _bInitialized:=false; rBusyInfo._bInitialized:=true; end; // уберём на несколько секунд опрос данного устройства - не можем даже проинициализироваться
    finally {cc.Unlock;} end;
  finally Unlock; end;
end;

procedure TCommunicationDevice.LoadTags(const sTags:AnsiString);
begin

end;

procedure TCommunicationDevice.PerformBusy;
begin

end;

function TCommunicationDevice.PerformTick:boolean;
begin Result:=false; end;

function TCommunicationDevice.Refresh:boolean; var s:AnsiString; ce:integer; begin Result:=false;
  try Lock; if(cc=nil)or(cp=nil)then exit; // нет соединения - ничего сделать не сможем
    if rRefreshInfo._pData=nil then begin rRefreshInfo._pData:=GetMemory(SizeOf(TrRefreshInfo)); ZeroMemory(rRefreshInfo._pData,SizeOf(TrRefreshInfo)); end;
    with rRefreshInfo,PrRefreshInfo(_pData)^do try // cc.Lock; {нельзя блокировать, т.к. поток транзакций потом будет использовать "соединение" и повиснет}
      if _bProcessing then LogMessage('!прерывание выполняемого общего опроса под номером '+IntToStr(+_ID));
      _bInitialized:=true; _bProcessing:=false; _ID:=DoGetRefreshID; ce:=DoRefresh; Result:=ce=ceSuccess; _ndx:=0;
      if not Result then s:='!ошибка инициализации общего опроса: '+GetErrorAsText(ce)else
        if _bProcessing then s:='<ожидание завершения общего опроса под номером '+IntToStr(+_ID)
        else s:='общий опрос под номером '+IntToStr(+_ID);
      LogMessage(s);
      if _bAuto then LogMessage('следующий общий опрос будет выполнен через '+IntToStr(_lwInterval div 1000)+' с');
      _lwLastTicks:=GetTickCount; _lwOrgTicks:=_lwLastTicks; //_bProcessing:=Result;
    finally {cc.Unlock;} end;
  finally Unlock; end;
end;

procedure TCommunicationDevice.RemoveTag(sName:AnsiString); var ndx:integer; begin
  try Lock;
    ndx:=fTagsDescriptors.IndexOf(sName);
    if ndx<>-1then begin FreeTagDescriptor(fTagsDescriptors.Objects[ndx]); fTagsDescriptors.Delete(ndx); end;

{    if ndx<>-1then Result:=PrTagInfo(fTagsInfo.SafeStringList.Objects[ndx])else begin
      Result:=AllocTagInfo; PrTagInfo(Result)._sName:=sName;
    end;}
  finally Unlock; end;
end;

function TCommunicationDevice.SaveTags:AnsiString;
begin

end;

procedure TCommunicationDevice.SetCC(const acc:TCommunicationConnection);
begin try Lock; if cc<>acc then begin cc:=acc; Changed; end; finally Unlock; end; end;

procedure TCommunicationDevice.SetCP(const acp:TCommunicationProtocol);
begin try Lock; if(cp<>acp)and((acp=nil)or(acp is fCommunicationProtocolClass))then begin cp:=acp; if not fbAddressAssigned then Address:=cp.DefaultAddress; Changed; end; finally Unlock; end; end;

procedure TCommunicationDevice.SetDefault; begin
  try Lock; BeginUpdate;
    inherited SetDefault; // просто изменяем все свойства
    fsCaption:='CommunicationDevice0x'+IntToHex(fhID,8); fsName:=fsCaption; fsDescription:='коммуникационное устройство (TCommunicationDevice)';
    InitDevice;
  finally EndUpdate; Unlock; end;
end;

procedure TCommunicationDevice.SetOnProgress(const pcbe:TProgressCallBackEvent);
begin try Lock; if@fOnProgress<>@pcbe then begin fOnProgress:=pcbe; Changed; end; finally Unlock; end; end;

function TCommunicationDevice.Synchronize(bBroadcast:boolean=false):boolean; var s:AnsiString; ce:integer; begin Result:=false;
  try Lock; if(cc=nil)or(cp=nil)then exit; // нет соединения - ничего сделать не сможем
    with rSynchronizeInfo do try // cc.Lock; {нельзя блокировать, т.к. поток транзакций потом будет использовать "соединение" и повиснет}
      if bBroadcast then ce:=DoSynchronizeBroadcast else ce:=DoSynchronize;
      _bInitialized:=true; _bProcessing:=false; Result:=ce=ceSuccess;
      if not Result then s:='!ошибка синхронизации устройства: '+GetErrorAsText(ce)else
        if bBroadcast then s:='широковещательная синхронизация устройств'else
          if _bProcessing then s:='<ожидание синхронизации устройства'else s:='синхронизация устройства';
      LogMessage(s);
      if _bAuto then LogMessage('следующая синхронизация будет выполнена через '+IntToStr(_lwInterval div 1000)+' с');
      _lwLastTicks:=GetTickCount; _lwOrgTicks:=_lwLastTicks; //_bProcessing:=Result;
    finally {cc.Unlock;} end;
  finally Unlock; end;
end;

function TCommunicationDevice.Tick:boolean; begin Result:=false;
  try Lock; if(cc=nil)then begin Result:=true; exit; end; // нет соединения - ничего сделать не сможем
    //try cc.Lock; {нельзя блокировать, т.к. поток транзакций потом будет использовать "соединение" и повиснет}
      if not cc.Connected then with rConnectInfo do if _bAuto then begin // автосоединение
        if not _bInitialized or((GetTickCount-_lwOrgTicks)>_lwInterval)then Connect;
        if not cc.Connected then begin Result:=true; exit; end; // невозможно открыть канал связи - выходим
      end;
      with rBusyInfo do if _bAuto then // автоожидание при занятости
        if _bProcessing then
          if GetTickCount-_lwOrgTicks<=_lwInterval then begin PerformBusy; Result:=true; exit; end // необходимое количество секунд ещё не прошло - опрос начинать нельзя
          else begin _bProcessing:=false; _bInitialized:=false;  end // необходимое количество секунд подождали, можем дальше опрашивать
        else if _bInitialized then begin _bProcessing:=true; _lwLastTicks:=GetTickCount; _lwOrgTicks:=_lwLastTicks;
          LogMessage('опрос устройства отложен на '+IntToStr(rBusyInfo._lwInterval div 1000)+' с');
          PerformBusy; Result:=true; exit; // устройство сообщило, что не может дальше обрабатывать запросы - будем ждать (15 секунд)
        end;
      with rInitializeInfo do if _bAuto then // инициализация устройства
        if not _bInitialized then begin Initialize; Result:=true; exit; end
        else if _bProcessing then begin Result:=PerformTick; exit; end;   // ожидание окончания инициализации устройства
      with rAliveInfo do if _bAuto then // проверка канала связи
        if not _bInitialized or((GetTickCount-_lwOrgTicks)>_lwInterval)then begin Alive; Result:=true; exit; end
        else if _bProcessing then begin Result:=PerformTick; exit; end;   // ожидание окончания проверки канала связи
      with rSynchronizeInfo do if _bAuto then // автосинхронизация
        if not _bInitialized or((GetTickCount-_lwOrgTicks)>_lwInterval)then begin Synchronize; Result:=true; exit; end // периодическая синхронизация
        else if _bProcessing then begin Result:=PerformTick; exit; end;   // ожидаем завершения синхронизации
      with rAuthorizeInfo do if _bAuto then // автоавторизация
        if not _bInitialized or(((GetTickCount-_lwOrgTicks)>_lwInterval)and(_lwInterval<>0))then begin Authorize; Result:=true; exit; end // периодическая авторизация
        else if _bProcessing then begin Result:=PerformTick; exit; end;
      with rRefreshInfo do if _bAuto then // общий опрос
        if not _bInitialized or((GetTickCount-_lwOrgTicks)>_lwInterval)then begin Refresh; Result:=true; exit; end // периодическая авторизация
        else if _bProcessing then begin Result:=PerformTick; exit; end;
      with rUpdateInfo do if _bAuto then // обновление тегов
        if not _bInitialized or((GetTickCount-_lwOrgTicks)>_lwInterval)then begin Update; Result:=true; exit; end // периодическая авторизация
        else if _bProcessing then begin Result:=PerformTick; exit; end;
      // Result:=PerformTick; здесь этого делать не нужно, пусть дочерние вызывают после добавления ещё каких-либо функций
    //finally cc.Unlock; end;
  finally Unlock; end;
end;

function TCommunicationDevice.Update:boolean;
begin Result:=false; rUpdateInfo._bInitialized:=true; end;

procedure TCommunicationDevice._OnChanged(Sender:TObject);
begin

end;

{ TCommunicationDevices }

function TCommunicationDevices.AddObject(cd:TCommunicationDevice):boolean;
begin Result:=inherited AddObject(cd); end;


constructor TCommunicationDevices.Create;
begin fObjectClass:=TCommunicationDevice; inherited Create; end;

function TCommunicationDevices.CreateObject:TCommunicationDevice;
begin Result:=TCommunicationDevice(inherited CreateObject); end;

function TCommunicationDevices.GetObject(ndx:integer):TCommunicationDevice;
begin Result:=TCommunicationDevice(inherited GetObject(ndx)); end;

function TCommunicationDevices.IndexOf(cd:TCommunicationDevice):integer;
begin Result:=inherited IndexOf(cd); end;

function TCommunicationDevices.RemoveObject(cd:TCommunicationDevice):boolean;
begin Result:=inherited RemoveObject(cd); end;

{ TCommunicationDeviceClasses }

function TCommunicationDeviceClasses.AddClass(cdclass:TCommunicationDeviceClass):boolean;
begin Result:=inherited AddClass(cdclass); end;

function TCommunicationDeviceClasses.GetClass(ndx:integer):TCommunicationDeviceClass;
begin Result:=TCommunicationDeviceClass(inherited GetClass(ndx)); end;

function TCommunicationDeviceClasses.IndexOf(cdclass:TCommunicationDeviceClass):integer;
begin Result:=inherited IndexOf(cdclass); end;

function TCommunicationDeviceClasses.RemoveClass(cdclass:TCommunicationDeviceClass):boolean;
begin Result:=inherited RemoveClass(cdclass); end;

{ TTransactionData }

destructor TTransactionData.Destroy;
begin if hCompleteEvent<>0then CloseHandle(hCompleteEvent); inherited; end;

{ TCommunicationThread }

procedure TCommunicationThread.AddToQueue(td:TTransactionData); begin if td=nil then exit;
  if Terminated then begin td.tr:=trAbort; exit; end; // если завершаемся, то возвращаем результат - прервано
  if fiRequestsLimit<=0then fiRequestsLimit:=1; if fiRequestsLimit>high(word)then fiRequestsLimit:=high(word);
  try fQueue.Lock;
    if fQueue.SafeQueue.Count>=fiRequestsLimit then begin td.tr:=trOverflow; exit; end;
    fQueue.SafeQueue.Push(td); fiQueueCount:=fQueue.SafeQueue.Count; SetEvent;
  finally fQueue.Unlock; end;
end;

procedure TCommunicationThread.AllocateResources; begin inherited;
  fQueue:=TThreadSafeQueue.Create; fiRequestsLimit:=high(word);
  SleepInterval:=1; WaitSleepInterval:=1;
  WaitInterval:=INFINITE; CompleteTermination:=true; // все транзакции надо информировать о завершении, иначе будет висеть код, их ожидающий
  flwLastExecuted:=GetTickCount;
//  SetThreadPriority(Handle,THREAD_PRIORITY_TIME_CRITICAL);
end;

procedure TCommunicationThread.DeallocateResources;
begin FreeAndNil(fQueue); end;

procedure TCommunicationThread.DoExecute;
var td:TTransactionData; iRetries:integer; // количество попыток для выполнения транзакции
  lwTicks:longword; bWriteError,bHandleError:boolean; // произошла ошибка записи или обработки ответа
  cd:TCommunicationDevice; cc:TCommunicationConnection; cs:TCommunicationSocket; cp:TCommunicationProtocol;
  p:pointer; len:integer;
  procedure DoResult(tr:TTransactionResult); begin  // не важно, получили хендл события или нет, если нет, то он равен 0
    try td.tr:=tr; if@td.cb<>nil then td.cb(td.id,td); {сначала надо cb вызвать, иначе после SetEvent будет td уничтожен!}
      Windows.SetEvent(td.hCompleteEvent); td:=nil; {сигнализируем что обработали посылку}
    except end;
  end;
begin
  try td:=nil;
    try fQueue.Lock; fiQueueCount:=fQueue.SafeQueue.Count; flwLastExecuted:=GetTickCount;
      if fiQueueCount<>0then begin td:=TTransactionData(fQueue.SafeQueue.Pop); dec(fiQueueCount); end;
    finally fQueue.Unlock; end;
    if td=nil then exit; // почему-то нет транзакции
    if Terminated then begin DoResult(trAbort); exit; end; // если поток завершается, просто прервём выполнение транзакции
    bWriteError:=false; bHandleError:=false;
    cd:=td.cd; if cd=nil then begin td.ce:=ceNoCommunicationDevice; DoResult(trHandleError); exit; end; // нет устройства
    try cd.Lock;
      cc:=cd.cc; if cc=nil then begin td.ce:=ceNoCommunicationConnection; DoResult(trHandleError); exit; end; // нет соединения
      cp:=cd.cp; if cp=nil then begin td.ce:=ceNoCommunicationProtocol; DoResult(trHandleError); exit; end;   // нет протокола - не сможем обработать
    finally cd.Unlock; end;
    iRetries:=cc.CommunicationMode.Retries; if iRetries=0then inc(iRetries);
    repeat
      try cc.Lock; // на время транзакции запрос-ответ соединение должно быть только нашим, чтоб никто не влез
        try cs:=cc.CommunicationSocket;
          if cs=nil then begin td.ce:=ceNoCommunicationSocket; DoResult(trHandleError); exit; end;   // нет сокета - не сможем обработать
          try cs.Lock; // по этому сокету тоже пока не получим ответ, не дадим работать никому
            if td.tdt=tdtRequest then begin p:=@td.sRequest[1]; len:=Length(td.sRequest); end else begin p:=@td.sResponse[1]; len:=Length(td.sResponse); end;
            if{(Length(td.sRequest)<>0)and }not cc.WriteBuffer(p,len)then bWriteError:=true else begin
              lwTicks:=GetTickCount; td.sResponse:=''; cc.TrafficInfo.AddOutPackets(1); // увеличим счётчик исходящих пакетов
              if td.tdt=tdtResponse then begin DoResult(trSuccess); break; end // только ответ, если нулевого размера - что-то синхронизируется 
              else if len<>0then if cp.IsBroadcastRequest(td.sRequest)then begin Sleep(cc.TimeoutReadTotal); DoResult(trBroadCast);
                if cc.CommunicationMode.Logging then begin
                  cc.LogMessage(Format('%s[?широковещание][%.3dмс]',[cc.GetSelfTimeStamp(GetNow),GetTickCount-lwTicks],gfs));
                  break;
                end;
              end;
//              cc.ReadPacket(td.sResponse,':',#13#10,true);
              td.sResponse:=cc.ReadString;
              if td.sResponse<>''then begin // если что-то приняли, попробуем это обработать
                td.ce:=cp.HandleResponse(td.sRequest,td.sResponse,td.pResponseDataBuf,td.iResponseDataSize);
                if cc.CommunicationMode.Logging then begin
                  cc.LogMessage(Format('%s[?<пакет:%.3d][%.3dмс][hex=%s][string=%s]',[cc.GetSelfTimeStamp(GetNow),
                    Length(td.sResponse),GetTickCount-lwTicks,Text_String2Hex(@td.sResponse[1],Length(td.sResponse)),
                    AnsiQuotedStr(Text_EncodeNonPrintable(td.sResponse),'"')],gfs));
                  if not cp.IsResponseSuccess(td.ce)then
                    cc.LogMessage(Format('%s[!ошибка:%.3d][%.3dмс]%s',[cc.GetSelfTimeStamp(GetNow),
                      td.ce,GetTickCount-lwTicks,AnsiQuotedStr(cp.GetErrorAsText(td.ce),'"')],gfs));
                end;
                if td.ce=ceSuccess then begin cc.TrafficInfo.AddInPackets(1); DoResult(trSuccess); break; end else bHandleError:=true;
                if cp.IsResponseSuccess(td.ce)then begin cc.TrafficInfo.AddInPackets(1); DoResult(trHandleError); break; end;
              end;
            end;
          finally cs.Unlock; end;
        except td.ce:=ceSysException; DoResult(trHandleError); exit; end;
      finally cc.Unlock; end; // дадим возможность (при повторных попытках) другим тоже поработать
      dec(iRetries); // если транзакция не обработана, будем повторять попытки
      if iRetries<>0then Sleep(SleepInterval); // дадим некоторое время другим потокам перед повторным запросом
    until iRetries=0;
    if(td<>nil)and(td.tr=trProcessing)then // если не удалось обработать транзакцию, то выставляем признак ошибки записи или таймаута
      if bWriteError then begin cc.TrafficInfo.AddOutTimeouts(1); DoResult(trWriteError); end else
        if bHandleError then DoResult(trHandleError)else begin cc.TrafficInfo.AddInTimeouts(1); DoResult(trTimeout); end;
  except if td<>nil then DoResult(trException); end; // что-то пошло не так (соединение закрылось)
end;

function TCommunicationThread.GetLastAccess:longword;
begin try fQueue.Lock; Result:=flwLastExecuted; finally fQueue.Unlock; end; end;

function TCommunicationThread.IsIdle:boolean;
begin Result:=fiQueueCount=0; end;

function TCommunicationThread.PutRequestBuf(const cd:TCommunicationDevice; const pRequest:pointer; const iRequestSize:integer;
  const pResponseDataBuf:pointer; const iResponseDataSize:integer; cb:TTransactionWaitCallBack):TTransactionData;
begin Result:=nil; if(pRequest=nil)or(iRequestSize<0)then exit; // при нулевом размере - на этот запрос ничего не отправляется, будет выполнено чтение
  Result:=TTransactionData.Create;
  SetLength(Result.sRequest,iRequestSize); CopyMemory(@Result.sRequest[1],pRequest,iRequestSize);
  Result.pResponseDataBuf:=pResponseDataBuf; Result.iResponseDataSize:=iResponseDataSize;
  Result.cd:=cd; Result.cb:=cb; Result.tr:=trProcessing; Result.tdt:=tdtRequest;
  if@cb=nil then Result.hCompleteEvent:=CreateEvent(nil,true,false,''); // если не создался, то равен 0
  AddToQueue(Result);
end;

function TCommunicationThread.PutRequest(const cd:TCommunicationDevice; const sRequest:AnsiString;
  const pResponseDataBuf:pointer; const iResponseDataSize:integer; cb:TTransactionWaitCallBack):TTransactionData;
begin Result:=PutRequestBuf(cd,@sRequest[1],Length(sRequest),pResponseDataBuf,iResponseDataSize,cb); end;

function TCommunicationThread.PutResponseBuf(const cd:TCommunicationDevice; const pResponse:pointer; const iResponseSize:integer;
  cb:TTransactionWaitCallBack):TTransactionData;
begin Result:=nil; if(pResponse=nil)or(iResponseSize<0)then exit; // при нулевом размере - на этот ответ ничего не отправляется, будет выполнена задержка (синхронизация с остальными запросами и ответами)
  Result:=TTransactionData.Create;
  SetLength(Result.sResponse,iResponseSize); CopyMemory(@Result.sResponse[1],pResponse,iResponseSize);
  Result.pResponseDataBuf:=nil; Result.iResponseDataSize:=0;
  Result.cd:=cd; Result.cb:=cb; Result.tr:=trProcessing; Result.tdt:=tdtResponse;
  if@cb=nil then Result.hCompleteEvent:=CreateEvent(nil,true,false,''); // если не создался, то равен 0
  AddToQueue(Result);
end;

function TCommunicationThread.PutResponse(const cd:TCommunicationDevice; const sResponse:AnsiString;
  cb:TTransactionWaitCallBack):TTransactionData;
begin Result:=PutResponseBuf(cd,@sResponse[1],Length(sResponse),cb); end;

{ TCommunicationThreads }

constructor TCommunicationThreads.Create;
begin fOwner:=oCommunicationSpace; inherited Create; end;

destructor TCommunicationThreads.Destroy; begin
  try Lock;
    while SafeStringList.Count<>0do DestroyThread(TCommunicationThread(SafeStringList.Objects[0]));
  finally Unlock; end;
  inherited;
end;

procedure TCommunicationThreads.DestroyThread(ct:TCommunicationThread); var ndx:integer; begin
  try Lock; ndx:=SafeStringList.IndexOfObject(ct);
    if ndx<>-1then begin SafeStringList.Delete(ndx); ct.Free; end;
  finally Unlock; end;
end;

function TCommunicationThreads.GetConnectionThread(cc:TCommunicationConnection;
  ctclass:TCommunicationThreadClass):TCommunicationThread; var i:integer; sName:AnsiString;
begin Result:=nil; if(cc=nil)or(ctclass=nil)then exit;
  try Lock; cc.Lock; if cc.CommunicationSocket=nil then exit;
    sName:=cc.CommunicationSocket.CommName;
    for i:=0to SafeStringList.Count-1do
      if AnsiSameText(SafeStringList[i],sName)and(TCommunicationThread(SafeStringList.Objects[i]).ClassType=ctclass)
        then begin Result:=TCommunicationThread(SafeStringList.Objects[i]); break; end;
    if Result=nil then begin Result:=ctclass.Create(false); SafeStringList.AddObject(cc.CommunicationSocket.CommName,Result); end;
  finally cc.Unlock; Unlock; end;
end;

function TCommunicationThreads.GetThread(ndx:integer):TCommunicationThread;
begin try Lock; Result:=TCommunicationThread(SafeStringList.Objects[ndx]); finally Unlock; end; end;

function TCommunicationThreads.GetThreadsCount:integer;
begin try Lock; Result:=SafeStringList.Count; finally Unlock; end; end;

{ TCommunicationSpace }

constructor TCommunicationSpace.Create; begin inherited;
  fSockets:=TCommunicationSockets.Create; fSocketClasses:=TCommunicationSocketClasses.Create;
  fModes:=TCommunicationModes.Create; fModeClasses:=TCommunicationModeClasses.Create;
  fConnections:=TCommunicationConnections.Create; fConnectionClasses:=TCommunicationConnectionClasses.Create;
  fProtocols:=TCommunicationProtocols.Create; fProtocolClasses:=TCommunicationProtocolClasses.Create;
  fDevices:=TCommunicationDevices.Create; fDeviceClasses:=TCommunicationDeviceClasses.Create;
  fThreads:=TCommunicationThreads.Create;
end;

destructor TCommunicationSpace.Destroy; begin
  try Lock; // пока работаем с коммуникационным пространством всех надо заблокировать - пусть будет, и уничтожаемся
    fDevices.Free; fDevices:=nil; fDeviceClasses.Free; fDeviceClasses:=nil;
    fProtocols.Free; fProtocols:=nil; fProtocolClasses.Free; fProtocolClasses:=nil;
    fConnections.Free; fConnections:=nil; fConnectionClasses.Free; fConnectionClasses:=nil;
    fSockets.Free; fSockets:=nil; fSocketClasses.Free; fSocketClasses:=nil;
    fModes.Free; fModes:=nil; fModeClasses.Free; fModeClasses:=nil;
    fThreads.Free; fThreads:=nil;
  finally Unlock; end;
  inherited Destroy;
end;

function TCommunicationSpace.DoGetObjectClasses(const noclass:TNamedObjectClass):TNamedObjectClasses; begin
  if noclass.InheritsFrom(TCommunicationSocket)then Result:=fSocketClasses
  else if noclass.InheritsFrom(TCommunicationConnection)then Result:=fConnectionClasses
  else if noclass.InheritsFrom(TCommunicationMode)then Result:=fModeClasses
  else if noclass.InheritsFrom(TCommunicationProtocol)then Result:=fProtocolClasses
  else if noclass.InheritsFrom(TCommunicationDevice)then Result:=fDeviceClasses
  else Result:=inherited DoGetObjectClasses(noclass);
end;

function TCommunicationSpace.DoGetObjects(const no:TNamedObject):TNamedObjects; begin
  if no is TCommunicationSocket then Result:=fSockets
  else if no is TCommunicationConnection then Result:=fConnections
  else if no is TCommunicationMode then Result:=fModes
  else if no is TCommunicationProtocol then Result:=fProtocols
  else if no is TCommunicationDevice then Result:=fDevices
  else Result:=inherited DoGetObjects(no);      
end;

procedure TCommunicationSpace.RegisterConnection(cc:TCommunicationConnection);
begin RegisterObject(cc,fConnections); end;

procedure TCommunicationSpace.RegisterConnectionClass(ccclass:TCommunicationConnectionClass);
begin RegisterObjectClass(ccclass,fConnectionClasses); end;

procedure TCommunicationSpace.RegisterDevice(cd:TCommunicationDevice);
begin RegisterObject(cd,fDevices); end;

procedure TCommunicationSpace.RegisterDeviceClass(cdclass:TCommunicationDeviceClass);
begin RegisterObjectClass(cdclass,fDeviceClasses); end;

procedure TCommunicationSpace.RegisterMode(cm:TCommunicationMode);
begin RegisterObject(cm,fModes); end;

procedure TCommunicationSpace.RegisterModeClass(cmclass:TCommunicationModeClass);
begin RegisterObjectClass(cmclass,fModeClasses); end;

procedure TCommunicationSpace.RegisterProtocol(cp:TCommunicationProtocol);
begin RegisterObject(cp,fProtocols); end;

procedure TCommunicationSpace.RegisterProtocolClass(cpclass:TCommunicationProtocolClass);
begin RegisterObjectClass(cpclass,fProtocolClasses); end;

procedure TCommunicationSpace.RegisterSocket(cs:TCommunicationSocket);
begin RegisterObject(cs,fSockets); end;

procedure TCommunicationSpace.RegisterSocketClass(csclass:TCommunicationSocketClass);
begin RegisterObjectClass(csclass,fSocketClasses); end;

procedure TCommunicationSpace.UnregisterConnection(cc:TCommunicationConnection);
begin UnregisterObject(cc,fConnections); end;

procedure TCommunicationSpace.UnregisterConnectionClass(ccclass:TCommunicationConnectionClass);
begin UnregisterObjectClass(ccclass,fConnectionClasses); end;

procedure TCommunicationSpace.UnRegisterDevice(cd:TCommunicationDevice);
begin UnregisterObject(cd,fDevices); end;

procedure TCommunicationSpace.UnregisterDeviceClass(cdclass:TCommunicationDeviceClass);
begin UnregisterObjectClass(cdclass,fDeviceClasses); end;

procedure TCommunicationSpace.UnRegisterMode(cm:TCommunicationMode);
begin UnregisterObject(cm,fModes); end;

procedure TCommunicationSpace.UnregisterModeClass(cmclass:TCommunicationModeClass);
begin UnregisterObjectClass(cmclass,fModeClasses); end;

procedure TCommunicationSpace.UnregisterProtocol(cp:TCommunicationProtocol);
begin UnregisterObject(cp,fProtocols); end;

procedure TCommunicationSpace.UnregisterProtocolClass(cpclass:TCommunicationProtocolClass);
begin UnregisterObjectClass(cpclass,fProtocolClasses); end;

procedure TCommunicationSpace.UnregisterSocket(cs:TCommunicationSocket);
begin UnregisterObject(cs,fSockets); end;

procedure TCommunicationSpace.UnregisterSocketClass(csclass:TCommunicationSocketClass);
begin UnregisterObjectClass(csclass,fSocketClasses); end;

procedure TCommunicationSpace._OnUSBNotify(Sender:TObject; dwEvent:longword; sName:AnsiString); var i:integer; begin
  case dwEvent of // проверим, не наш ли сокет
    DBT_DEVICEARRIVAL:;
    DBT_DEVICEREMOVECOMPLETE: while not fSockets.TryLock do Sleep(32)else try {fSockets.Lock;} // если из потока
      try sName:=GetComPortName(sName);
        for i:=0to fSockets.ObjectsCount-1do with fSockets[i]do
          if AnsiSameText(CommName,sName)or AnsiSameText(CommName,'\\.\'+sName)then Connected:=false; // закроем сокет, который исчез
      except end;
    finally fSockets.Unlock; end;
  end;
end;

initialization
  GetLocaleFormatSettings(SysLocale.DefaultLCID,gfs);
  oCommunicationSpace:=TCommunicationSpace.Create;
  oCommunicationSpace.Name:='DefaultCommunicationSpace';
  oCommunicationSpace.Description:='Пространство коммуникационных объектов, созданное по умолчанию. '+
    'Здесь хранятся абсолютно все объекты связи, которые были созданы в модуле qCDKclasses. '+
    'Если задано пространство коммуникаций в качестве владельца, то оно содержит только объекты, относящиеся к нему.'+
    'Версия модуля: 0x'+IntToHex(lwUnitVersion,8);
  oCommunicationSpace.RegisterObjectClass(TCommunicationMode);
  oUSBNotifier:=TUSBnotifier.Create(nil); oUSBNotifier.OnUSBNotify:=oCommunicationSpace._OnUSBNotify;
  lwTimerID:=timeSetEvent(30000,30000,@_OnMMTimer,0,TIME_PERIODIC+TIME_CALLBACK_FUNCTION);

finalization
  timeKillEvent(lwTimerID);
  FreeAndNil(oUSBNotifier);
  FreeAndNil(oCommunicationSpace);

end.


