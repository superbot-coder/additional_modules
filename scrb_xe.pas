unit scrb;

{*****************************************************************************}
//   Module SCRB XE scramble of strings and text and short files
//   Autor by SUPERBOT
//   Https://GitHub.com/Superbot-coder
{*****************************************************************************}

interface

Uses
  //SysUtils, //for debug
  Error,
  Windows;

Type DWORD = LongWord;

function encode(st: AnsiString): AnsiString;
function decode(st: AnsiString): AnsiString;

function EncodeFile(InpFile, OutFile: String): Boolean;
function DecodeFile(InpFile, OutFile: String): boolean;

function StrToHex(StrValue: String): String;
function StrHexToStr(StrHex: String): String;
function PWDEncode(PWD: String): String;
Function PWDDecode(PWD: String): String;

Var
  ENABLED_RAISE_ERROR: Boolean = False;

implementation

{----------------------------------- encode -----------------------------------}
function encode(st: AnsiString): AnsiString;
var
  buf : array[1..4] of byte;
  i   : integer;
begin
  Result:=st;
  if Length(Result) = 0 then exit;

  if Length(Result) = 1 then begin
     FillChar(buf,4,0);
     buf[3] := ord(result[1]);
     Buf[4] := ord(result[1]);
     DWORD(buf) := DWORD(buf) shr 4;
     Buf[4]     := buf[2] or buf[4];
     Result[1]  := AnsiChar(buf[4]);
  end;

  for i:=2 to Length(Result) do begin
     FillChar(buf,4,0);
     buf[3] := ord(result[i-1]);
     Buf[4] := ord(result[i]);
     DWORD(buf)  := DWORD(buf) shr 4;
     Buf[4]      := buf[2] or buf[4];
     Result[i-1] := AnsiChar(buf[3]);
     Result[i]   := AnsiChar(buf[4]);
   end;
end;
{--------------------------------- decode -------------------------------------}
function decode(st: AnsiString): AnsiString;
var
  buf : array[1..4] of byte;
  i   : integer;
begin
  Result := st;
  if Length(Result) = 0 then exit;

  if Length(Result) = 1 then begin
    FillChar(buf, 4, 0);
    buf[1] := ord(Result[1]);
    buf[2] := ord(result[1]);
    DWORD(Buf) := DWORD(Buf) shl 4;
    buf[1] := buf[3] or buf[1];
    result[1]   := AnsiChar(buf[1]);
  end;

  for i:=Length(Result) downto 2 do begin
    FillChar(buf, 4, 0);
    buf[1] := ord(Result[i-1]);
    buf[2] := ord(result[i]);
    DWORD(Buf) := DWORD(Buf) shl 4;
    buf[1] := buf[3] or buf[1];
    result[i]   := AnsiChar(buf[2]);
    result[i-1] := AnsiChar(buf[1]);
  end;

end;

{------------------------------ EncodeFile ------------------------------------}
function EncodeFile(InpFile, OutFile: String): Boolean;
var
  hInpFile  : THandle;
  hOutFile  : THandle;
  Buffer    : String;
  cbWritten : DWORD;
  BytesRead : DWORD;
  szBuffer  : Integer;
begin
  Result:=false;

  try
    hInpFile := CreateFile(PChar(InpFile),GENERIC_READ,FILE_SHARE_READ,0,OPEN_EXISTING,0,0);
    if hInpFile = INVALID_HANDLE_VALUE then begin
      SaveErrorMessage('');
      Exit;
    end;

    hOutFile:= CreateFile(PChar(OutFile),        // name of file
                     GENERIC_READ or GENERIC_WRITE, // access mode
                     0,                            // share mode
                     nil,                        // default security
                     CREATE_ALWAYS,                // create flags
                     FILE_ATTRIBUTE_NORMAL,      // file attributes
                     0);
    if (hOutFile = INVALID_HANDLE_VALUE) Then begin
      SaveErrorMessage('');
      Exit;
    end;

    szBuffer:=GetFileSize(hInpFile,0);
    if szBuffer = 0 then Exit;
    SetLength(Buffer,szBuffer);

    if not ReadFile(hInpFile,Buffer[1],szBuffer,BytesRead,0) then begin
      SaveErrorMessage('');
      Exit;
    end;

    Buffer := encode(Buffer);

    if Not WriteFile(hOutFile,Buffer[1],szBuffer,cbWritten,0) then begin
      SaveErrorMessage('');
      exit;
    end;

    Result:=true;

  finally
    CloseHandle(hInpFile);
    CloseHandle(hOutFile);
  end;
end;

{------------------------------ DecodeFile ------------------------------------}
function DecodeFile(InpFile, OutFile: String): boolean;
var
  hInpFile  : THandle;
  hOutFile  : THandle;
  Buffer    : string;
  cbWritten : DWORD;
  szBuffer  : Integer;
  BytesRead : Cardinal;
  tmpStr    : String;
begin
  Result:=false;

  try
    hInpFile := CreateFile(PChar(InpFile),GENERIC_READ,FILE_SHARE_READ,0,OPEN_EXISTING,0,0);
    if hInpFile = INVALID_HANDLE_VALUE then begin
      //if ENABLED_RAISE_ERROR Then RaiseLastOSError;
      Exit;
    end;

    hOutFile:= CreateFile(PChar(OutFile),        // name of file
                     GENERIC_READ or GENERIC_WRITE, // access mode
                     0,                          // share mode
                     nil,                        // default security
                     CREATE_ALWAYS,              // create flags
                     FILE_ATTRIBUTE_NORMAL,      // file attributes
                     0);
    if (hOutFile = INVALID_HANDLE_VALUE) Then begin
      //if ENABLED_RAISE_ERROR then RaiseLastOSError;
      Exit;
    end;

    szBuffer:=GetFileSize(hInpFile,0);
    if szBuffer = 0 then Exit;

    SetLength(Buffer,szBuffer);

    if not ReadFile(hInpFile,Buffer[1],szBuffer,BytesRead,0) then begin
      //if ENABLED_RAISE_ERROR then RaiseLastOSError;
      Exit;
    end;

    tmpStr:=Decode(Buffer);

    if Not WriteFile(hOutFile,tmpStr[1],szBuffer,cbWritten,0) then begin
      //if ENABLED_RAISE_ERROR then RaiseLastOSError;
      exit;
    end;

    Result:=true;

  finally
    CloseHandle(hInpFile);
    CloseHandle(hOutFile);
  end;

{------------------------------ StrToHex --------------------------------------}
function StrToHex(StrValue: String): String;
begin
  SetLength(Result, length(StrValue) * 2);
  BinToHex(PChar(StrValue),PChar(Result), Length(StrValue));
end;
{---------------------------- StrHexToStr -------------------------------------}
function StrHexToStr(StrHex: String): String;
begin
  SetLength(Result, Length(StrHex) div 2);
  HexToBin(PChar(StrHex), Pointer(Result), length(StrHex) div 2);
end;

function PWDEncode(PWD: String): String;
begin
  Result := StrToHex(encode(PWD));
end;

function PWDDecode(PWD: String): String;
begin
  Result := decode(StrHexToStr(PWD));
end;


end.
