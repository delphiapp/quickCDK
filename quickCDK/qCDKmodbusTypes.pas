unit qCDKmodbusTypes;

interface

uses Classes,qCDKclasses;

type
  TModbusFunction=type byte;

const
// ��������� ����������
  mexcIllegalFunction=1; mexcIllegalDataAddress=2; mexcIllegalDataValue=3;
  mexcSlaveDeviceFailure=4; mexcAknowledge=5; mexcSlaveDeviceBusy=6;
  mexcSlaveDeviceProgramFailure=7; mexcMemoryParityError=8;
  mexcGatewayPathUnavailable=10; mexcGatewayTargetNoResponse=11;

  ModbusExceptionsInfos:array[0..9]of TIdentMapEntry=(
    (Value: mexcIllegalFunction;              Name: '�������� ��� ������� �� ����� ���� ���������'),
    (Value: mexcIllegalDataAddress;           Name: '����� ������, ��������� � �������, ����������'),
    (Value: mexcIllegalDataValue;             Name: '��������, ������������ � ���� ������ �������, �������� ������������ ���������'),
    (Value: mexcSlaveDeviceFailure;           Name: '������������������� ������ ����� �����, ���� ������� ���������� �������� ��������� ������������� ��������'),
    (Value: mexcAknowledge;                   Name: '������� ���������� ������� ������ � ������������ ���, �� ��� ������� ����� �������; ���� ����� ������������ ������� ���������� �� ��������� ������ ��������'),
    (Value: mexcSlaveDeviceBusy;              Name: '������� ���������� ������ ���������� �������; ������� ���������� ������ ��������� ������ �����, ����� ������� �����������'),
    (Value: mexcSlaveDeviceProgramFailure;    Name: '������� ���������� �� ����� ��������� ����������� �������, �������� � �������; ������ ���������� ������������ �� ���������� ����������� ������� � ��������� 0x0D ��� 0x0E;'+' ������� ���������� ������ ��������� ��������������� ���������� ��� ���������� �� �������'),
    (Value: mexcMemoryParityError;            Name: '������� ���������� ��� ������ ����������� ������ ���������� ������ �������� ��������; ������� ���������� ����� ��������� ������, �� ������ � ����� ������� ��������� ������'),
    (Value: mexcGatewayPathUnavailable;       Name: '���� � ����� ����������'),
    (Value: mexcGatewayTargetNoResponse;      Name: '���� ��������, �� ���������� �� ��������')
  );

////////// ��������� ��� Modbus-�������
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
  mfReadScopeRecords=$41; // ������ ��� ��������� ����

  ModbusFuncsInfos:array[0..15]of TIdentMapEntry=(
    (Value: mfReadCoils;                        Name: '������ ���������� ����������'),
    (Value: mfReadDiscreteInputs;               Name: '������ ���������� ������'),
    (Value: mfReadHoldingRegisters;             Name: '������ ���������� ����������'),
    (Value: mfReadInputRegisters;               Name: '������ ���������� ������'),
    (Value: mfWriteSingleCoil;                  Name: '������ ����������� ���������'),
    (Value: mfWriteSingleRegister;              Name: '������ ����������� ���������'),
    (Value: mfReadExceptionStatus;              Name: '������ �������� ���������'),
//    (Value: mfDiagnostics;                      Name: '�����������'),
//    (Value: mfProgram484;                       Name: '���������������� 484-�����������'),
//    (Value: mfPoll484;                          Name: '�������� ��������� ���������������� 484-�����������'),
    (Value: mfFetchCommEventCounter;            Name: '������ �������� ���������������� �������'),
    (Value: mfFetchCommEventLog;                Name: '������ ������� ���������������� �������'),
//    (Value: mfProgrammController;               Name: '���������������� �����������'),
//    (Value: mfPollController;                   Name: '�������� ��������� ���������������� �����������'),
    (Value: mfWriteMultipleCoils;               Name: '������ ���������� ����������'),
    (Value: mfWriteMultipleRegisters;           Name: '������ ���������� ����������'),
//    (Value: mfReportSlaveID;                    Name: '������ ���������� �� ����������'),
//    (Value: mfProgram884M84;                    Name: '���������������� 884M84-�����������'),
//    (Value: mfResetCommLink;                    Name: '����� ����������������� ������'),
    (Value: mfReadFileRecord;                   Name: '������ �������� ������'),
    (Value: mfWriteFileRecord;                  Name: '������ �������� ������'),
    (Value: mfMaskWriteRegister;                Name: '������ � ���������� ������� � �������������� ����� "�" � "���"'),
    (Value: mfReadWriteMultipleRegisters;       Name: '������������� ������ � ������ ���������� ����������'),
//    (Value: mfReadFIFOQueue;                    Name: '������ ������ �� �������'),
    (Value: mfReadScopeRecords;                 Name: '������ ������ ������������ � ����������� ����')
  );


////////// ��������� ������, ��������� ������ � qCDKclasses
  meSuccess=ceSuccess;              // ��� ������

//  meMismatch=8;                   // ������������ ������� � ������

  meModbusException=-100;           // modbus-����������
  meUnknownFunctionCode=-101;       // ����������� �������
  meDeviceAddress=-102;             // ��������� ����� ����������
  meFunctionCode=-103;              // ��������� ��� �������
  meElementReadStartAddress=-104;   // ��������� ��������� ����� ������� �������� �� ������
  meElementReadCount=-105;          // ��������� ���������� ��������� �� ������
  meElementReadByteCount=-106;      // ��������� ���������� ���� �� ������
  meElementReadValues=-107;         // ��������� ������ ���������� �������� ��������
  meElementWriteAddress=-108;       // ��������� ����� ������������� ��������
  meElementWriteValue=-109;         // ��������� ������������ ��������
  meElementWriteStartAddress=-110;  // ��������� ��������� ����� ������� �������� �� ������
  meElementWriteCount=-111;         // ��������� ���������� ��������� �� ������
  meElementWriteByteCount=-112;     // ��������� ���������� ���� �� ������
  meElementWriteValues=-113;        // ��������� ������ ���������� ������������ ��������
  meFileRequestSize=-114;           // ��������� ������ ���� �������� ��� �����
  meFileSubRequestType=-115;        // ��������� ��� ���������� ��� �����
  meFileSubRequestFileNumber=-116;  // ��������� ����� ����� � ����������
  meFileSubRequestAddress=-117;     // ��������� ����� ������ ��� ����� � ����������
  meFileSubRequestLength=-118;      // ��������� ����� ������ ��� ����� � ����������
  meElementWriteMaskAnd=-119;       // ��������� ����� ����������� � �� ������
  meElementWriteMaskOr=-120;        // ��������� ����� ����������� ��� �� ������
  meExceptionCode=-121;             // ��������� ��� ����������

  lwModbusErrorsCount=22;
  ModbusErrorsInfos:array[0..lwModbusErrorsCount-1]of TIdentMapEntry=(
    (Value:meModbusException;                   Name:'-100 - modbus-����������'),
    (Value:meUnknownFunctionCode;               Name:'-101 - ����������� �������'),
    (Value:meDeviceAddress;                     Name:'-102 - ��������� ����� ����������'),
    (Value:meFunctionCode;                      Name:'-103 - ��������� ��� �������'),
    (Value:meElementReadStartAddress;           Name:'-104 - ��������� ��������� ����� ������� �������� �� ������'),
    (Value:meElementReadCount;                  Name:'-105 - ��������� ���������� ��������� �� ������'),
    (Value:meElementReadByteCount;              Name:'-106 - ��������� ���������� ���� �� ������'),
    (Value:meElementReadValues;                 Name:'-107 - ��������� ������ ���������� �������� ��������'),
    (Value:meElementWriteAddress;               Name:'-108 - ��������� ����� ������������� ��������'),
    (Value:meElementWriteValue;                 Name:'-109 - ��������� ������������ ��������'),
    (Value:meElementWriteStartAddress;          Name:'-110 - ��������� ��������� ����� ������� �������� �� ������'),
    (Value:meElementWriteCount;                 Name:'-111 - ��������� ���������� ��������� �� ������'),
    (Value:meElementWriteByteCount;             Name:'-112 - ��������� ���������� ���� �� ������'),
    (Value:meElementWriteValues;                Name:'-113 - ��������� ������ ���������� ������������ ��������'),
    (Value:meFileRequestSize;                   Name:'-114 - ��������� ������ ���� �������� ��� �����'),
    (Value:meFileSubRequestType;                Name:'-115 - ��������� ��� ���������� ��� �����'),
    (Value:meFileSubRequestFileNumber;          Name:'-116 - ��������� ����� ����� � ����������'),
    (Value:meFileSubRequestAddress;             Name:'-117 - ��������� ����� ������ ��� ����� � ����������'),
    (Value:meFileSubRequestLength;              Name:'-118 - ��������� ����� ������ ��� ����� � ����������'),
    (Value:meElementWriteMaskAnd;               Name:'-119 - ��������� ����� ����������� � �� ������'),
    (Value:meElementWriteMaskOr;                Name:'-120 - ��������� ����� ����������� ��� �� ������'),
    (Value:meExceptionCode;                     Name:'-121 - ��������� ��� ����������')
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
