unit qCKDtags;

interface

type
// ����� ���������� �������������
  TCoefficientReplacingEvent=procedure(Sender:TObject; cOld,cNew:TCoefficient) of object;
  TCoefficients=class // !!! �������� ������������� - ������� ������������ ���!!!
  private
    fOnReplacing:TCoefficientReplacingEvent;
    procedure SetCoefficient(cndx:integer; const c:TCoefficient); // ������ ������������ �� �����, ����������� �������
  public
    property Coefficient[cndx:integer]:TCoefficient read GetCoefficient write SetCoefficient; default;

    property OnReplacing:TCoefficientReplacingEvent read fOnReplacing write fOnReplacing;
  end;

implementation

{ TCoefficients }

procedure TCoefficients.SetCoefficient(cndx:integer; const c:TCoefficient); var cOld:TCoefficient; begin
  cOld:=TCoefficient(fCoefficients[cndx]); if cOld=c then exit;
  if@fOnReplacing<>nil then fOnReplacing(Self,cOld,c);
  fCoefficients[cndx]:=c; Changed; {cOld.Free ���������� � TObjectList.Items[cndx]!!!}
end;

end.
