unit qCKDtags;

interface

type
// класс контейнера коэффициентов
  TCoefficientReplacingEvent=procedure(Sender:TObject; cOld,cNew:TCoefficient) of object;
  TCoefficients=class // !!! владелец коэффициентов - удаляет коэффициенты сам!!!
  private
    fOnReplacing:TCoefficientReplacingEvent;
    procedure SetCoefficient(cndx:integer; const c:TCoefficient); // замена коэффициента на новый, уничтожение старого
  public
    property Coefficient[cndx:integer]:TCoefficient read GetCoefficient write SetCoefficient; default;

    property OnReplacing:TCoefficientReplacingEvent read fOnReplacing write fOnReplacing;
  end;

implementation

{ TCoefficients }

procedure TCoefficients.SetCoefficient(cndx:integer; const c:TCoefficient); var cOld:TCoefficient; begin
  cOld:=TCoefficient(fCoefficients[cndx]); if cOld=c then exit;
  if@fOnReplacing<>nil then fOnReplacing(Self,cOld,c);
  fCoefficients[cndx]:=c; Changed; {cOld.Free происходит в TObjectList.Items[cndx]!!!}
end;

end.
