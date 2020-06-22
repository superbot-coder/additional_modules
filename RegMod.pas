unit MiniReg;

interface 

uses Windows; 

function RegSetString(RootKey: HKEY; Name: String; Value: String): boolean; 
function RegSetMultiString(RootKey: HKEY; Name: String; Value: String): boolean; 
function RegSetExpandString(RootKey: HKEY; Name: String; Value: String): boolean; 
function RegSetDWORD(RootKey: HKEY; Name: String; Value: Cardinal): boolean; 
function RegSetBinary(RootKey: HKEY; Name: String; Value: Array of Byte): boolean; 
function RegGetString(RootKey: HKEY; Name: String; Var Value: String): boolean; 
function RegGetMultiString(RootKey: HKEY; Name: String; Var Value: String): boolean; 
function RegGetExpandString(RootKey: HKEY; Name: String; Var Value: String): boolean; 
function RegGetDWORD(RootKey: HKEY; Name: String; Var Value: Cardinal): boolean; 
function RegGetBinary(RootKey: HKEY; Name: String; Var Value: String): boolean;
function RegGetValueType(RootKey: HKEY; Name: String; var Value: Cardinal): boolean; 
function RegValueExists(RootKey: HKEY; Name: String): boolean;
function RegKeyExists(RootKey: HKEY; Name: String): boolean; 
function RegDelValue(RootKey: HKEY; Name: String): boolean; 
function RegDelKey(RootKey: HKEY; Name: String): boolean; 
function RegConnect(MachineName: String; RootKey: HKEY; var RemoteKey: HKEY): boolean; 
function RegDisconnect(RemoteKey: HKEY): boolean; 
function RegEnumKeys(RootKey: HKEY; Name: String; var KeyList: String): boolean; 
function RegEnumValues(RootKey: HKEY; Name: String; var ValueList: String): boolean; 

implementation 

{----------------------------------- LastPos ----------------------------------}
function LastPos(Needle: Char; Haystack: String): integer;
begin 
  for Result := Length(Haystack) downto 1 do 
    if Haystack[Result] = Needle then 
      Break; 
end; 
{---------------------------------- RegConnect --------------------------------}
function RegConnect(MachineName: String; RootKey: HKEY; var RemoteKey: HKEY): boolean;
begin 
  Result := (RegConnectRegistry(PChar(MachineName), RootKey, RemoteKey) = ERROR_SUCCESS); 
end; 
{--------------------------------- RegDisconnect ------------------------------}
function RegDisconnect(RemoteKey: HKEY): boolean;
begin 
  Result := (RegCloseKey(RemoteKey) = ERROR_SUCCESS); 
end; 
{--------------------------------- RegSetValue --------------------------------}
function RegSetValue(RootKey: HKEY; Name: String; ValType: Cardinal; PVal: Pointer; ValSize: Cardinal): boolean;
var 
  SubKey: String; 
  n: integer; 
  dispo: DWORD; 
  hTemp: HKEY; 
begin 
  Result := False; 
  n := LastPos('\', Name); 
  if n > 0 then 
  begin 
    SubKey := Copy(Name, 1, n - 1); 
    if RegCreateKeyEx(RootKey, PChar(SubKey), 0, nil, REG_OPTION_NON_VOLATILE, KEY_WRITE, 
      nil, hTemp, @dispo) = ERROR_SUCCESS then 
    begin 
      SubKey := Copy(Name, n + 1, Length(Name) - n); 
      Result := (RegSetValueEx(hTemp, PChar(SubKey), 0, ValType, PVal, ValSize) = ERROR_SUCCESS); 
      RegCloseKey(hTemp); 
    end; 
  end; 
end; 
{---------------------------------- RegGetValue -------------------------------}
function RegGetValue(RootKey: HKEY; Name: String; ValType: Cardinal; var PVal: Pointer;
  var ValSize: Cardinal): boolean; 
var 
  SubKey: String; 
  n: integer; 
  MyValType: DWORD; 
  hTemp: HKEY; 
  Buf: Pointer; 
  BufSize: Cardinal; 
begin 
  Result := False; 
  n := LastPos('\', Name); 
  if n > 0 then 
  begin 
    SubKey := Copy(Name, 1, n - 1); 
    if RegOpenKeyEx(RootKey, PChar(SubKey), 0, KEY_READ, hTemp) = ERROR_SUCCESS then 
    begin 
      SubKey := Copy(Name, n + 1, Length(Name) - n); 
      if RegQueryValueEx(hTemp, PChar(SubKey), nil, @MyValType, nil, @BufSize) = ERROR_SUCCESS then 
      begin 
        GetMem(Buf, BufSize); 
        if RegQueryValueEx(hTemp, PChar(SubKey), nil, @MyValType, Buf, @BufSize) = ERROR_SUCCESS then 
        begin 
          if ValType = MyValType then 
          begin 
            PVal := Buf; 
            ValSize := BufSize; 
            Result := True; 
          end else 
          begin 
            FreeMem(Buf); 
          end; 
        end else 
        begin 
          FreeMem(Buf); 
        end; 
      end; 
      RegCloseKey(hTemp); 
    end; 
  end; 
end; 
{-------------------------------- RegSetString --------------------------------}
function RegSetString(RootKey: HKEY; Name: String; Value: String): boolean;
begin 
  Result := RegSetValue(RootKey, Name, REG_SZ, PChar(Value + #0), Length(Value) + 1); 
end; 
{----------------------------- RegSetMultiString ------------------------------}
function RegSetMultiString(RootKey: HKEY; Name: String; Value: String): boolean;
begin 
  Result := RegSetValue(RootKey, Name, REG_MULTI_SZ, PChar(Value + #0#0), Length(Value) + 2); 
end; 
{----------------------------- RegSetExpandString -----------------------------}
function RegSetExpandString(RootKey: HKEY; Name: String; Value: String): boolean;
begin 
  Result := RegSetValue(RootKey, Name, REG_EXPAND_SZ, PChar(Value + #0), Length(Value) + 1); 
end; 
{--------------------------------- RegSetDword --------------------------------}
function RegSetDword(RootKey: HKEY; Name: String; Value: Cardinal): boolean;
begin 
  Result := RegSetValue(RootKey, Name, REG_DWORD, @Value, SizeOf(Cardinal)); 
end; 
{--------------------------------- RegSetBinary -------------------------------}
function RegSetBinary(RootKey: HKEY; Name: String; Value: Array of Byte): boolean;
begin 
  Result := RegSetValue(RootKey, Name, REG_BINARY, @Value[Low(Value)], length(Value)); 
end; 
{---------------------------------- RegGetString ------------------------------}
function RegGetString(RootKey: HKEY; Name: String; Var Value: String): boolean;
var 
  Buf: Pointer; 
  BufSize: Cardinal; 
begin 
  Result := False; 
  if RegGetValue(RootKey, Name, REG_SZ, Buf, BufSize) then 
  begin 
    Dec(BufSize); 
    SetLength(Value, BufSize); 
    if BufSize > 0 then 
      CopyMemory(@Value[1], Buf, BufSize); 
    FreeMem(Buf); 
    Result := True; 
  end; 
end; 
{----------------------------- RegGetMultiString ------------------------------}
function RegGetMultiString(RootKey: HKEY; Name: String; Var Value: String): boolean;
var
  Buf: Pointer; 
  BufSize: Cardinal; 
begin 
  Result := False; 
  if RegGetValue(RootKey, Name, REG_MULTI_SZ, Buf, BufSize) then 
  begin 
    Dec(BufSize); 
    SetLength(Value, BufSize); 
    if BufSize > 0 then 
      CopyMemory(@Value[1], Buf, BufSize); 
    FreeMem(Buf); 
    Result := True; 
  end; 
end; 
{------------------------------- RegGetExpandString ---------------------------}
function RegGetExpandString(RootKey: HKEY; Name: String; Var Value: String): boolean;
var 
  Buf: Pointer; 
  BufSize: Cardinal; 
begin 
  Result := False; 
  if RegGetValue(RootKey, Name, REG_EXPAND_SZ, Buf, BufSize) then 
  begin 
    Dec(BufSize); 
    SetLength(Value, BufSize); 
    if BufSize > 0 then 
      CopyMemory(@Value[1], Buf, BufSize); 
    FreeMem(Buf); 
    Result := True; 
  end; 
end; 
{-------------------------------- RegGetDWORD ---------------------------------}
function RegGetDWORD(RootKey: HKEY; Name: String; Var Value: Cardinal): boolean;
var 
  Buf: Pointer; 
  BufSize: Cardinal; 
begin 
  Result := False; 
  if RegGetValue(RootKey, Name, REG_DWORD, Buf, BufSize) then 
  begin 
    CopyMemory(@Value, Buf, BufSize); 
    FreeMem(Buf); 
    Result := True; 
  end; 
end; 
{------------------------------ RegGetBinary ----------------------------------}
function RegGetBinary(RootKey: HKEY; Name: String; Var Value: String): boolean;
var 
  Buf: Pointer; 
  BufSize: Cardinal; 
begin 
  Result := False; 
  if RegGetValue(RootKey, Name, REG_BINARY, Buf, BufSize) then 
  begin 
    SetLength(Value, BufSize); 
    CopyMemory(@Value[1], Buf, BufSize); 
    FreeMem(Buf); 
    Result := True; 
  end; 
end; 
{----------------------------- RegValueExists ---------------------------------}
function RegValueExists(RootKey: HKEY; Name: String): boolean;
var 
  SubKey: String; 
  n: integer; 
  hTemp: HKEY; 
begin 
  Result := False; 
  n := LastPos('\', Name); 
  if n > 0 then 
  begin 
    SubKey := Copy(Name, 1, n - 1); 
    if RegOpenKeyEx(RootKey, PChar(SubKey), 0, KEY_READ, hTemp) = ERROR_SUCCESS then 
    begin 
      SubKey := Copy(Name, n + 1, Length(Name) - n); 
      Result := (RegQueryValueEx(hTemp, PChar(SubKey), nil, nil, nil, nil) = ERROR_SUCCESS); 
      RegCloseKey(hTemp); 
    end; 
  end; 
end; 
{----------------------------- RegGetValueType --------------------------------}
function RegGetValueType(RootKey: HKEY; Name: String; var Value: Cardinal): boolean;
var 
  SubKey: String; 
  n: integer; 
  hTemp: HKEY; 
  ValType: Cardinal; 
begin 
  Result := False; 
  Value := REG_NONE; 
  n := LastPos('\', Name); 
  if n > 0 then 
  begin 
    SubKey := Copy(Name, 1, n - 1); 
    if (RegOpenKeyEx(RootKey, PChar(SubKey), 0, KEY_READ, hTemp) = ERROR_SUCCESS) then 
    begin 
      SubKey := Copy(Name, n + 1, Length(Name) - n); 
      Result := (RegQueryValueEx(hTemp, PChar(SubKey), nil, @ValType, nil, nil) = ERROR_SUCCESS); 
      if Result then 
        Value := ValType; 
      RegCloseKey(hTemp); 
    end; 
  end; 
end; 
{------------------------------ RegKeyExists ----------------------------------}
function RegKeyExists(RootKey: HKEY; Name: String): boolean;
var 
  SubKey: String; 
  n: integer; 
  hTemp: HKEY; 
begin 
  Result := False; 
  n := LastPos('\', Name); 
  if n > 0 then 
  begin 
    SubKey := Copy(Name, 1, n - 1); 
    if RegOpenKeyEx(RootKey, PChar(SubKey), 0, KEY_READ, hTemp) = ERROR_SUCCESS then 
    begin 
      Result := True; 
      RegCloseKey(hTemp); 
    end; 
  end; 
end; 
{------------------------------- RegDelValue ----------------------------------}
function RegDelValue(RootKey: HKEY; Name: String): boolean;
var 
  SubKey: String; 
  n: integer; 
  hTemp: HKEY; 
begin 
  Result := False; 
  n := LastPos('\', Name); 
  if n > 0 then 
  begin 
    SubKey := Copy(Name, 1, n - 1); 
    if RegOpenKeyEx(RootKey, PChar(SubKey), 0, KEY_WRITE, hTemp) = ERROR_SUCCESS then 
    begin 
      SubKey := Copy(Name, n + 1, Length(Name) - n); 
      Result := (RegDeleteValue(hTemp, PChar(SubKey)) = ERROR_SUCCESS); 
      RegCloseKey(hTemp); 
    end; 
  end; 
end; 
{-------------------------------- RegDelKey -----------------------------------}
function RegDelKey(RootKey: HKEY; Name: String): boolean;
var 
  SubKey: String; 
  n: integer; 
  hTemp: HKEY; 
begin 
  Result := False; 
  n := LastPos('\', Name); 
  if n > 0 then 
  begin 
    SubKey := Copy(Name, 1, n - 1); 
    if RegOpenKeyEx(RootKey, PChar(SubKey), 0, KEY_WRITE, hTemp) = ERROR_SUCCESS then 
    begin 
      SubKey := Copy(Name, n + 1, Length(Name) - n); 
      Result := (RegDeleteKey(hTemp, PChar(SubKey)) = ERROR_SUCCESS); 
      RegCloseKey(hTemp); 
    end; 
  end; 
end; 
{---------------------------------- RegEnum -----------------------------------}
function RegEnum(RootKey: HKEY; Name: String; var ResultList: String; const DoKeys: Boolean): boolean;
var 
  i: integer; 
  iRes: integer; 
  s: String; 
  hTemp: HKEY; 
  Buf: Pointer; 
  BufSize: Cardinal; 
begin 
  Result := False; 
  ResultList := ''; 
  if RegOpenKeyEx(RootKey, PChar(Name), 0, KEY_READ, hTemp) = ERROR_SUCCESS then 
  begin 
    Result := True; 
    BufSize := 1024; 
    GetMem(buf, BufSize); 
    i := 0; 
    iRes := ERROR_SUCCESS; 
    while iRes = ERROR_SUCCESS do 
    begin 
      BufSize := 1024; 
      if DoKeys then 
        iRes := RegEnumKeyEx(hTemp, i, buf, BufSize, nil, nil, nil, nil) 
      else 
        iRes := RegEnumValue(hTemp, i, buf, BufSize, nil, nil, nil, nil); 
      if iRes = ERROR_SUCCESS then 
      begin 
        SetLength(s, BufSize); 
        CopyMemory(@s[1], buf, BufSize); 
        if ResultList = '' then 
          ResultList := s 
        else 
          ResultList := Concat(ResultList, #13#10, s); 
        inc(i); 
      end; 
    end; 
    FreeMem(buf); 
    RegCloseKey(hTemp); 
  end; 
end; 
{--------------------------- RegEnumValues ------------------------------------}
function RegEnumValues(RootKey: HKEY; Name: String; var ValueList: String): boolean;
begin 
  Result := RegEnum(RootKey, Name, ValueList, False); 
end; 
{----------------------------- RegEnumKeys ------------------------------------}
function RegEnumKeys(RootKey: HKEY; Name: String; var KeyList: String): boolean;
begin 
  Result := RegEnum(RootKey, Name, KeyList, True); 
end; 

end.