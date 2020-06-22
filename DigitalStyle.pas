unit DigitalStyle;

{*****************************************************************************}
//   Форматированный вывод чисел 
//   например, 1 = 01, 23 = 023; 100000 = 100 000 или 100.000 
//   Autor: SUPERBOT
//   https://GitHub.com/Superbot-coder
{*****************************************************************************}

interface

Uses SysUtils, StrUtils;

Type TSpliterStyle = (splitSpace, splitPoint);

function BeforZero(x: ShortInt; StrInt: String): String;
function DigitalSplit(strDigitalValue: string;  Spliter: TSpliterStyle): string;

implementation

function BeforZero(x: ShortInt; StrInt: String): String;
begin
  if Length(StrInt) > 127 then
  begin
    Result := StrInt;
    Exit;
  end;
  Result := StringOfChar('0', x-Length(StrInt)) + StrInt;
end;

function DigitalSplit(strDigitalValue: string;  Spliter: TSpliterStyle): string;
var i: SmallInt;
    s: AnsiString;
   spl: Char;
begin
  Result := '';
  if Length(strDigitalValue) <=3 then
  begin
    Result := strDigitalValue;
    Exit;
  end;

  case Spliter of
    splitSpace: spl := ' ';
    splitPoint: spl := '.';
  end;

  s := AnsiReverseString(strDigitalValue);
  for i :=1 to Length(s) do
  begin
    Result := Result + s[i];
    if i <> Length(s) then
      if (i mod 3) = 0 then result := Result + spl;
  end;
  Result := AnsiReverseString(Result);
  Result := Trim(Result);
end;

end.