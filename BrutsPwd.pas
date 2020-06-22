unit BrutsPwd;

//********************************************************************
//     Module for Bruteforce passwords                              //
//     Математический модуль для перебора паролей                   //
//     Зависимость:  UMathServices.pas                              //
//     Dependence on the module: UMathServices.pas                  //
//     Autor: SUPERBOT                                              // 
//     https://GitHub.com/Superbot-coder                            //
//********************************************************************

interface

 Uses SysUtils, StrUtils, Math, UMathServices, Vcl.Dialogs;

Type TSpliterStyle = (splitSpace, splitPoint);

function IsHash(hash: AnsiString; l: integer): boolean;
function DigitalFormat(StrDigit: String; Spliter: TSpliterStyle): String;
function BigIntToPwdStr(BigIntStr, CharSet: AnsiString): AnsiString;
function PwdStrToBigInt(PwdStr, CharSet: AnsiString): AnsiString;
function PassCharIncFunc(PassChar, CharSet: AnsiString): AnsiString;
function PassCharCheckEnd(PassChar, PassCharEnd, CharSet: AnsiString): Boolean;
function Int64ToPwdStr(Digit: Int64; CharSet: AnsiString): AnsiString;
function ExtendedToPwdStr(Ext: Extended; CharSet: AnsiString): AnsiString;
function PwdStrToExtended(PwdStr, CharSet: AnsiString): Extended;
function PwdStrToInt64(PwdStr, CharSet: AnsiString): Int64;

implementation

{------------------------------- IsHash ---------------------------------------}
function IsHash(hash: AnsiString; l: integer): boolean;
var sh: set of AnsiChar;
     i: integer;
begin
  Result := false;
  sh := ['0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F','a','b','c','d','e','f'];
  if (Length(hash) <> l) then Exit;
  for i:=1 to Length(hash) do
    if Not (hash[i] in sh) then Exit;
  result := True;
end;

{------------------------------ DigitalFormat ---------------------------------}
function DigitalFormat(StrDigit: String; Spliter: TSpliterStyle): String;
var i,j: SmallInt;
    spl: char;
begin
  Result := '';

  case Spliter of
    splitSpace: spl := ' ';
    splitPoint: spl := '.';
  end;

  if Length(StrDigit) <= 3 then
  begin
    Result := StrDigit;
    Exit;
  end;
  j:=0;
  for i := Length(StrDigit) downto 1 do
  begin
    inc(j);
    if j = 3 then
    begin
     Result := Result + StrDigit[i] + spl;
     j := 0;
    end
    else Result := Result + StrDigit[i];
  end;
  Result := ReverseString(Result);
end;

{---------------------------- PassCharIncFunc  --------------------------------}
function PassCharIncFunc(PassChar, CharSet: AnsiString): AnsiString;
var i,L,P,max: SmallInt;
begin
  Result := '';
  Result := PassChar;
  L   := Length(PassChar);
  if L = 0 then Exit;
  Max := length(CharSet);

  for i:=L downto 1 do
  begin
    P := AnsiPos(Result[i], CharSet);
    inc(P);
    if P <= Max then
    begin
      Result[i] := CharSet[P];
      Exit;
    end
    else
    begin
      P := 1;
      Result[i] := CharSet[P];
      if i = 1 then
      begin
        Result := CharSet[1] + Result;
        Exit;
      end;
    end;
  end;
end;

{----------------------------- PassCharCheckEnd -------------------------------}
function PassCharCheckEnd(PassChar, PassCharEnd, CharSet: AnsiString): Boolean;
var L1, L2: SmallInt;
    i, p1,p2: SmallInt;
begin
  Result := false;
  L1 := Length(PassChar);
  L2 := Length(PassCharEnd);
  if L1 > L2 then
  begin
    Result := True;
    Exit;
  end;
  if L1 < L2 then Exit;
  for i:=1 to L1 do
  begin
    p1 := AnsiPos(PassChar[i], CharSet);
    p2 := AnsiPos(PassCharEnd[i], CharSet);
    if p1 < p2 then Exit;
    if P1 > P2 Then
    begin
      Result := true;
      Exit;
    end;
  end;
  Result := true;
end;

{------------------------------ Int64ToPwdStr ---------------------------------}
function Int64ToPwdStr(Digit: Int64; CharSet: AnsiString): AnsiString;
var
  sale, N, D: Int64;
  L: integer;
begin
  Result := '';
  L := Length(CharSet);
  D := Digit;
  while D > 0 do
  begin
    if D > L then
    begin
      N    := D div L;
      sale := D mod L;

      if sale = 0 then
      begin
        Result := CharSet[L] + Result;
        D := N - 1;
      end
      else
      begin
        Result := CharSet[sale] + Result;
        D := N;
      end;
    end
    else
    begin
      Result := CharSet[D] + Result;
      Break;
    end;
  end;
end;
{------------------------------- ExtendedToPwdStr -----------------------------}
function ExtendedToPwdStr(Ext: Extended; CharSet: AnsiString): AnsiString;
var
  sale, N: Extended;
  Ex: Extended;
  L: integer;
begin
  Result := '';
  L := Length(CharSet);
  Ex := Ext;
  while Ex > 0 do
  begin
    if Ex > L then
    begin
      N    := Int(Ex / L);
      sale := Ex - (L*N);

      if sale = 0 then
      begin
        Result := CharSet[L] + Result;
        Ex := N - 1;
      end
      else
      begin
        Result := CharSet[Trunc(sale)] + Result;
        Ex := N;
      end;
    end
    else
    begin
      Result := CharSet[Trunc(Ex)] + Result;
      Break;
    end;
  end;
end;
{------------------------------- PwdStrToExtended --------------------------------}
function PwdStrToExtended(PwdStr, CharSet: AnsiString): Extended;
var
  l,sl: integer;
  i, n: integer;
begin
  Result := 0;
  l  := Length(CharSet);
  sl := Length(PwdStr);
  if (sl = 0) or (l = 0) then Exit;
  Dec(sl);
  for i := 0 to sl do
  begin
    n := AnsiPos(PwdStr[i + 1], CharSet);
    if n = 0 then
    begin
      Result := 0;
      Exit;
    end;
    Result := Result  + n * Power(l, sl - i);
  end;

end;
{------------------------------- PwdStrToInt64 -----------------------------}
function PwdStrToInt64(PwdStr, CharSet: AnsiString): Int64;
begin
  Result := Trunc(PwdStrToExtended(PwdStr, CharSet));
end;
{------------------------------ BigIntToPwdStr --------------------------------}
function BigIntToPwdStr(BigIntStr, CharSet: AnsiString): AnsiString;
var
  LCharSet: integer;
  sale, N : string;
  BigInt  : string;
  DigInt  : Integer;
     Err  : Integer;
  isale   : Integer;
begin
  Result := '';
  LCharSet := Length(CharSet);
  BigInt   := BigIntStr;
  if (Length(BigIntStr) = 0) or (LCharSet = 0) then Exit;

  while true do //Length(BigInt) > 0 do
  begin
    Val(BigInt, DigInt, Err);
    if Err > 0 then DigInt := MaxInt;
    if DigInt > LCharSet then
    begin
      N := ulDiv(BigInt, IntToStr(LCharSet),0);
      sale := ulSub(BigInt, ulMPL(N, IntToStr(LCharSet)));
      isale := StrToInt(sale);
      if isale = 0 then
      begin
        Result := CharSet[LCharSet] + Result;
        BigInt := ulSub(N, '1');
      end
      else
      begin
        Result := CharSet[isale] + Result;
        BigInt := N;
      end;
    end
    else
    begin
      Result := CharSet[DigInt] + Result;
      Break;
    end;
  end;
  
end;

{------------------------------- PwdStrToBigInt -------------------------------}
function PwdStrToBigInt(PwdStr, CharSet: AnsiString): AnsiString;
var
  LCharSet : integer;
  LPwdStr  : integer;
  i, n     : Integer;
  PowerResult: String;
begin
  Result := '';
  LCharSet := Length(CharSet);
  LPwdStr  := Length(PwdStr);
  if (LPwdStr = 0) or (LCharSet = 0) then Exit;
  Dec(LPwdStr);
  for i := 0 to LPwdStr do
  begin
    n := AnsiPos(PwdStr[i+1], CharSet);
    if n = 0 then
    begin
      Result := '';
      Exit;
    end;
    PowerResult := ulPower(IntToStr(LCharSet), IntToStr(LPwdStr - i));
    Result      := ulSum(Result, ulMPL(PowerResult, IntToStr(n)));
  end;

end;



end.
