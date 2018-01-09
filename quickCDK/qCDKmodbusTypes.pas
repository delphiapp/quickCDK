unit qCDKmodbusTypes;

interface

uses Classes,qCDKclasses;

type
  TModbusFunction=type byte;

const
// константы исключений
  mexcIllegalFunction=1; mexcIllegalDataAddress=2; mexcIllegalDataValue=3;
  mexcSlaveDeviceFailure=4; mexcAknowledge=5; mexcSlaveDeviceBusy=6;
  mexcSlaveDeviceProgramFailure=7; mexcMemoryParityError=8;
  mexcGatewayPathUnavailable=10; mexcGatewayTargetNoResponse=11;

  ModbusExceptionsInfos:array[0..9]of TIdentMapEntry=(
    (Value: mexcIllegalFunction;              Name: 'принятый код функции не может быть обработан'),
    (Value: mexcIllegalDataAddress;           Name: 'адрес данных, указанный в запросе, недоступен'),
    (Value: mexcIllegalDataValue;             Name: 'значение, содержащееся в поле данных запроса, является недопустимой величиной'),
    (Value: mexcSlaveDeviceFailure;           Name: 'невосстанавливаемая ошибка имела место, пока ведомое устройство пыталось выполнить затребованное действие'),
    (Value: mexcAknowledge;                   Name: 'ведомое устройство приняло запрос и обрабатывает его, но это требует много времени; этот ответ предохраняет ведущее устройство от генерации ошибки таймаута'),
    (Value: mexcSlaveDeviceBusy;              Name: 'ведомое устройство занято обработкой команды; ведущее устройство должно повторить запрос позже, когда ведомое освободится'),
    (Value: mexcSlaveDeviceProgramFailure;    Name: 'ведомое устройство не может выполнить программную функцию, заданную в запросе; данное исключение возвращается на неуспешные программные запросы с функциями 0x0D или 0x0E;'+' ведущее устройство должно запросить диагностическую информацию или информацию об ошибках'),
    (Value: mexcMemoryParityError;            Name: 'ведомое устройство при чтении расширенной памяти обнаружило ошибку контроля чётности; ведущее устройство может повторить запрос, но обычно в таких случаях требуется ремонт'),
    (Value: mexcGatewayPathUnavailable;       Name: 'путь к шлюзу недоступен'),
    (Value: mexcGatewayTargetNoResponse;      Name: 'шлюз доступен, но устройство не отвечает')
  );

////////// константы для Modbus-функций
  mfReadCoils=$01;                            mfReadDiscreteInputs=$02;
  mfReadHoldingRegisters=$03;                 mfReadInputRegisters=$04;
  mfWriteSingleCoil=$05;                      mfWriteSingleRegister=$06;
  mfReadExceptionStatus=$07;                  // mfDiagnostics:TModbusFunction=$08;
//  mfProgram484:TModbusFunction=$09;           mfPoll484=$0A;
  mfFetchCommEventCounter=$0B;                mfFetchCommEventLog=$0C;
//  mfProgrammController:TModbusFunction=$0D;   mfPollController=$0E;
  mfWriteMultipleCoils=$0F;                   mfWriteMultipleRegisters=$10;
//  mfReportSlaveID=$11;
//  mfProgram884M84:TModbusFunction=$12;        mfResetCommLink:TModbusFunction=$13;
  mfReadFileRecord=$14;                       mfWriteFileRecord=$15;
  mfMaskWriteRegister=$16;                    mfReadWriteMultipleRegisters=$17;
//  mfReadFIFOQueue=$18;
  mfReadScopeRecords=$41; // только для устройств БЭМП

  ModbusFuncsInfos:array[0..15]of TIdentMapEntry=(
    (Value: mfReadCoils;                        Name: 'чтение дискретных параметров'),
    (Value: mfReadDiscreteInputs;               Name: 'чтение дискретных входов'),
    (Value: mfReadHoldingRegisters;             Name: 'чтение аналоговых параметров'),
    (Value: mfReadInputRegisters;               Name: 'чтение аналоговых входов'),
    (Value: mfWriteSingleCoil;                  Name: 'запись дискретного параметра'),
    (Value: mfWriteSingleRegister;              Name: 'запись аналогового параметра'),
    (Value: mfReadExceptionStatus;              Name: 'чтение сигналов состояния'),
//    (Value: mfDiagnostics;                      Name: 'диагностика'),
//    (Value: mfProgram484;                       Name: 'программирование 484-контроллера'),
//    (Value: mfPoll484;                          Name: 'проверка состояния программирования 484-контроллера'),
    (Value: mfFetchCommEventCounter;            Name: 'чтение счётчика коммуникационных событий'),
    (Value: mfFetchCommEventLog;                Name: 'чтение журнала коммуникационных событий'),
//    (Value: mfProgrammController;               Name: 'программирование контроллера'),
//    (Value: mfPollController;                   Name: 'проверка состояния программирования контроллера'),
    (Value: mfWriteMultipleCoils;               Name: 'запись дискретных параметров'),
    (Value: mfWriteMultipleRegisters;           Name: 'запись аналоговых параметров'),
//    (Value: mfReportSlaveID;                    Name: 'чтение информации об устройстве'),
//    (Value: mfProgram884M84;                    Name: 'программирование 884M84-контроллера'),
//    (Value: mfResetCommLink;                    Name: 'сброс коммуникационного канала'),
    (Value: mfReadFileRecord;                   Name: 'чтение файловых дампов'),
    (Value: mfWriteFileRecord;                  Name: 'запись файловых дампов'),
    (Value: mfMaskWriteRegister;                Name: 'запись в аналоговый регистр с использованием масок "И" и "ИЛИ"'),
    (Value: mfReadWriteMultipleRegisters;       Name: 'одновременное чтение и запись аналоговых параметров'),
//    (Value: mfReadFIFOQueue;                    Name: 'чтение данных из очереди'),
    (Value: mfReadScopeRecords;                 Name: 'чтение дампов осциллограмм в устройствах БЭМП')
  );


////////// константы ошибок, дополняют список в qCDKclasses
  meSuccess=ceSuccess;              // нет ошибки

//  meMismatch=8;                   // несовпадение запроса и ответа

  meModbusException=-100;           // modbus-исключение
  meUnknownFunctionCode=-101;       // неизвестная функция
  meDeviceAddress=-102;             // ожидается адрес устройства
  meFunctionCode=-103;              // ожидается код функции
  meElementReadStartAddress=-104;   // ожидается начальный адрес первого элемента на чтение
  meElementReadCount=-105;          // ожидается количество элементов на чтение
  meElementReadByteCount=-106;      // ожидается количество байт на чтение
  meElementReadValues=-107;         // ожидается верное количество читаемых значений
  meElementWriteAddress=-108;       // ожидается адрес записываемого элемента
  meElementWriteValue=-109;         // ожидается записываемое значение
  meElementWriteStartAddress=-110;  // ожидается начальный адрес первого элемента на запись
  meElementWriteCount=-111;         // ожидается количество элементов на запись
  meElementWriteByteCount=-112;     // ожидается количество байт на запись
  meElementWriteValues=-113;        // ожидается верное количество записываемых значений
  meFileRequestSize=-114;           // ожидается размер всех запросов для файла
  meFileSubRequestType=-115;        // ожидается тип подзапроса для файла
  meFileSubRequestFileNumber=-116;  // ожидается номер файла в подзапросе
  meFileSubRequestAddress=-117;     // ожидается номер записи для файла в подзапросе
  meFileSubRequestLength=-118;      // ожидается длина записи для файле в подзапросе
  meElementWriteMaskAnd=-119;       // ожидается маска логического И на запись
  meElementWriteMaskOr=-120;        // ожидается маска логического ИЛИ на запись
  meExceptionCode=-121;             // ожидается код исключения

  lwModbusErrorsCount=22;
  ModbusErrorsInfos:array[0..lwModbusErrorsCount-1]of TIdentMapEntry=(
    (Value:meModbusException;                   Name:'-100 - modbus-исключение'),
    (Value:meUnknownFunctionCode;               Name:'-101 - неизвестная функция'),
    (Value:meDeviceAddress;                     Name:'-102 - ожидается адрес устройства'),
    (Value:meFunctionCode;                      Name:'-103 - ожидается код функции'),
    (Value:meElementReadStartAddress;           Name:'-104 - ожидается начальный адрес первого элемента на чтение'),
    (Value:meElementReadCount;                  Name:'-105 - ожидается количество элементов на чтение'),
    (Value:meElementReadByteCount;              Name:'-106 - ожидается количество байт на чтение'),
    (Value:meElementReadValues;                 Name:'-107 - ожидается верное количество читаемых значений'),
    (Value:meElementWriteAddress;               Name:'-108 - ожидается адрес записываемого элемента'),
    (Value:meElementWriteValue;                 Name:'-109 - ожидается записываемое значение'),
    (Value:meElementWriteStartAddress;          Name:'-110 - ожидается начальный адрес первого элемента на запись'),
    (Value:meElementWriteCount;                 Name:'-111 - ожидается количество элементов на запись'),
    (Value:meElementWriteByteCount;             Name:'-112 - ожидается количество байт на запись'),
    (Value:meElementWriteValues;                Name:'-113 - ожидается верное количество записываемых значений'),
    (Value:meFileRequestSize;                   Name:'-114 - ожидается размер всех запросов для файла'),
    (Value:meFileSubRequestType;                Name:'-115 - ожидается тип подзапроса для файла'),
    (Value:meFileSubRequestFileNumber;          Name:'-116 - ожидается номер файла в подзапросе'),
    (Value:meFileSubRequestAddress;             Name:'-117 - ожидается номер записи для файла в подзапросе'),
    (Value:meFileSubRequestLength;              Name:'-118 - ожидается длина записи для файле в подзапросе'),
    (Value:meElementWriteMaskAnd;               Name:'-119 - ожидается маска логического И на запись'),
    (Value:meElementWriteMaskOr;                Name:'-120 - ожидается маска логического ИЛИ на запись'),
    (Value:meExceptionCode;                     Name:'-121 - ожидается код исключения')
  );

implementation

uses SysUtils;

{$BOOLEVAL OFF}
{$RANGECHECKS OFF}
{$OVERFLOWCHECKS OFF}


(*class function TModbus.GetVersion(iNewVersion:Integer=0):AnsiString;
{$WRITEABLECONST ON}
const fVersion:integer=$0101;
{$WRITEABLECONST OFF}
begin
  Result:='0x'+IntToHex(fVersion,8);
  if iNewVersion<>0then fVersion:=iNewVersion;
end;*)


end.
