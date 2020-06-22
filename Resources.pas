unit Resources;

//*********************************************************************//
//            Modul by SUPERBOT                                        //
//           https://GitHub.com/Superbot-coder                         //
//*********************************************************************//

interface

Uses
   //SysUtils, //for debug
   windows, Error;

Type

  TResType = MakeIntResource;

  PTFileHeader= ^TFileHeader;
  TFileHeader = Packed record
    DataSize        : DWORD;      // размер данных
    HeaderSize      : DWORD;      // размер этой записи
    ResType         : DWORD;      // нижнее слово = $FFFF => ordinal
    ResId           : DWORD;      // нижнее слово = $FFFF => ordinal
    DataVersion     : DWORD;      // *
    MemoryFlags     : WORD;       // $0030
    LanguageId      : WORD;       // *
    Version         : DWORD;      // *
    Characteristics : DWORD;      // *
  end;

  PResIdHeader= ^TResIdHeader;
  TResIdHeader = Packed record
    DataSize        : DWORD;      // размер данных
    HeaderSize      : DWORD;      // размер этой записи
    ResType         : DWORD;      // нижнее слово = $FFFF => ordinal
    ResId           : DWORD;      // нижнее слово = $FFFF => ordinal
    DataVersion     : DWORD;      // *
    MemoryFlags     : WORD;       // $0030
    LanguageId      : WORD;       // *
    Version         : DWORD;      // *
    Characteristics : DWORD;      // *
  end;

  PResNameHeader= ^TResNameHeader;
  TResNameHeader = Packed record
    DataSize        : DWORD;      // размер данных
    HeaderSize      : DWORD;      // размер этой записи
    ResType         : DWORD;      // нижнее слово = $FFFF => ordinal
    ResName         : array[1..MAX_PATH] of char; // нижнее слово = $FFFF => ordinal
    DataVersion     : DWORD;       // *
    MemoryFlags     : WORD;        // $0030
    LanguageId      : WORD;        // *
    Version         : DWORD;       // *
    Characteristics : DWORD;       // *
  end;

function ResIdCreateFromData(PResData: Pointer; szData: Integer; FileName: String; ResID: WORD; ResType: TResType):Boolean;
function ResNameCreateFromData(PResData: Pointer; szData: Integer; FileName: String; ResName: String; ResType: TResType): Boolean;
function ResIDCreateFromFileData(FileData, FileRes: String; ResID: WORD; ResType: TResType): Boolean;
function ResNameCreateFromFileData(FileData, FileRes, ResName: String; ResType: TResType): Boolean;

function ResNameUpdateFromData(PData: Pointer; szData: Integer; FileName: String; ResName: String; ResType: TResType): Boolean;
function ResIdUpdateFromData(PData: Pointer; szData: Integer; FileName: String; ResId: WORD; ResType: TResType): Boolean;

function ResUpdateFromFileData(FileData: String; FileName, ResName: String; ResType: TResType): Boolean;
function ResUpdateFromFileRes(ResFile,UpDateFile: String): Boolean;

function ResUpdtFromResIdModule(Module,UpdtFile: String; FindResId: WORD; FindResType: TResType; UpdtResName: String; UpdtResId: WORD; UpdtResType: TResType): Boolean;
function ResUpdtFromResNameModule(Module,UpdtFile: String; FindResName: String; FindResType: TResType; UpdtResName: String; UpdtResId: WORD; UpdtResType: TResType): Boolean;

function ResIdSaveToFile(FileSave: String; ResId: WORD; ResType: TResType): Boolean;
function ResNameSaveToFile(FileSave: String; ResName: String; ResType: TResType): Boolean;

function ResNameSaveToBuffer(ResName: String; ResType: TResType; Var OutBuffer: Pointer; var OutBytes: Integer): Boolean;
function ResIdSaveToBuffer(ResId: WORD; ResType: TResType; Var OutBuffer; var OutBytes: Integer): Boolean;

function GetSizeResource(ResName: String; ResType: TResType): Integer;

var
  ArrayRT: set of Byte; //Reource Type Array;
  GLOBAL_LANG : WORD;
  ENABLED_RAISE_ERROR: Boolean = False;

implementation

function GetSizeResource(ResName: String; ResType: TResType): Integer;
var hResInfo: THandle;
begin
  hResInfo := FindResource(HInstance,PChar(ResName),ResType);
  if hResInfo = 0 then begin
    SaveErrorMessage('FindResource '+ResName);
    Exit;
  end;

 Result := SizeofResource(HInstance,hResInfo);

end;

{---------------------------- AnsiUpperCase -----------------------------------}
function AnsiUpperCase(const S: string): string;
var
  Len: Integer;
begin
  Len := Length(S);
  SetString(Result, PChar(S), Len);
  if Len > 0 then CharUpperBuff(Pointer(Result), Len);
end;
{------------------------------- StrToUnicode ---------------------------------}
function StrToUnicode(S: String): String;
var i: integer;
begin
  Result:='';
  for i:=1 to Length(S) do Result:=Result+S[i]+#0;
end;
{------------------------------- UnicodeToStr ---------------------------------}
function UnicodeToStr(WS: String): String;
var i: integer;
begin
  for i:=1 to Length(WS) do begin
    if (i mod 2) <> 0 then Result:=Result+WS[i];
  end;
end;
{-------------------------------- FileExists ----------------------------------}
function FileExists(const FileName: string): Boolean;
var
  Code: Integer;
begin
  Code := GetFileAttributes(PChar(FileName));
  Result := (Code <> -1) and (FILE_ATTRIBUTE_DIRECTORY and Code = 0);
end;

{----------------------------- ResIdFileCreate --------------------------------}
function ResIdCreateFromData(PResData: Pointer; szData: Integer;
                   FileName: String; ResID: WORD; ResType: TResType):Boolean;
var hFileOut: THandle;
    FileHeader : TFileHeader;
    cbWritten  : DWORD;
    WResName   : string;
    ResHeader  : TResIdHeader;
begin
  Result:=false;
  If (Not Assigned(PResData)) or (FileName = '') then Exit;
  if Not (Byte(ResType) in ArrayRT) then Exit;

  hFileOut := CreateFile(PChar(FileName),        // name of file
                     GENERIC_WRITE or GENERIC_WRITE,              // access mode
                     0,                            // share mode
                     nil,                        // default security
                     CREATE_ALWAYS,                // create flags
                     FILE_ATTRIBUTE_NORMAL,      // file attributes
                     0);
  if (hFileOut = INVALID_HANDLE_VALUE)
     //or (hFileOut = ERROR_ALREADY_EXISTS)
     Then Exit;
  try
    FillChar(FileHeader, SizeOf(TFileHeader), 0);
    FileHeader.HeaderSize := SizeOf(FileHeader);
    FileHeader.ResId      := $0000FFFF;
    FileHeader.ResType    := $0000FFFF;

    // Write FileHeader Record
    if Not WriteFile(hFileOut, FileHeader,SizeOf(TFileHeader),cbWritten,Nil) then begin
      //RaiseLastOSError;
      Exit;
    end;

    //FillChar(ResHeader,SizeOf(TResIdHeader), 0);
    ResHeader.DataSize    := szData;
    ResHeader.HeaderSize  := SizeOf(TResIdHeader);
    ResHeader.ResType     := $0000FFFF or (WORD(ResType) shl 16);
    ResHeader.ResId       := $0000FFFF or (ResID shl 16);
    ResHeader.MemoryFlags := $0030;
    ResHeader.LanguageId  := GLOBAL_LANG;

    // Write ResHeader
    if Not WriteFile(hFileOut,ResHeader,SizeOf(TResIdHeader),cbWritten,Nil) then begin
      //RaiseLastOSError;
      Exit;
    end;

    // Write ResData
    if Not WriteFile(hFileOut,PResData^,szData,cbWritten,Nil) then begin
      //RaiseLastOSError;
      Exit;
    end;
    result:=true;

  finally
    CloseHandle(hFileOut);
  end;
end;

{----------------------------- ResNameFileCreate ------------------------------}
function ResNameCreateFromData(PResData: Pointer; szData: Integer;
                 FileName: String; ResName: String; ResType: TResType): Boolean;
Var hFileOut   : THandle;
    FileHeader : TFileHeader;
    cbWritten  : DWORD;
    WResName   : string;
    //ResHeader  : TResNameHeader;
    Value      : DWORD;
begin
  Result:=false;
  If (Not Assigned(PResData)) or (FileName = '') or (ResName = '') or (szData = 0) then Exit;
  if Not (Byte(ResType) in ArrayRT) then Exit;

  hFileOut := CreateFile(PChar(FileName),           // name of file
                     GENERIC_READ or GENERIC_WRITE, // access mode
                     0,                             // share mode
                     nil,                           // default security
                     CREATE_ALWAYS,                 // create flags
                     FILE_ATTRIBUTE_NORMAL,         // file attributes
                     0);
  if hFileOut = INVALID_HANDLE_VALUE Then Exit;
  try
    ResName  := AnsiUpperCase(ResName);
    WResName := StrToUnicode(ResName);

    FillChar(FileHeader, SizeOf(TFileHeader), 0);
    FileHeader.HeaderSize := SizeOf(FileHeader);
    FileHeader.ResId      := $0000FFFF;
    FileHeader.ResType    := $0000FFFF;

    // Write FileHeader Record
    WriteFile(hFileOut, FileHeader,SizeOf(FileHeader),cbWritten,Nil);

    {
    FillChar(ResHeader,SizeOf(TResNameHeader), 0);
    ResHeader.DataSize    := szData;
    ResHeader.HeaderSize  := SizeOf(TResNameHeader);
    ResHeader.ResType     := $0000FFFF or (WORD(ResType) shl 16);
    ResHeader.MemoryFlags := $0030;
    ResHeader.LanguageId  := GLOBAL_LANG;
    move(WResName[1],ResHeader.ResName,Length(WResName));
    //Write ResHeader
    WriteFile(hFileOut,ResHeader,SizeOf(TResNameHeader),cbWritten,Nil);
    }

    // [Write Resource Header]
    // Write DataSize
    WriteFile(hFileOut,szData,SizeOf(Integer),cbWritten,Nil);
    // Write HeaderSize
    Value:=(SizeOf(DWORD)*6)+(SizeOf(WORD)*2)+Length(WResName);
    WriteFile(hFileOut,Value,SizeOf(DWORD),cbWritten,Nil);
    //.. Write ResType
    Value := $0000FFFF or (DWORD(RT_RCDATA) shl 16);
    WriteFile(hFileOut,Value,SizeOf(DWORD),cbWritten,Nil);
    //.. Write ResName
    WriteFile(hFileOut,WResName[1],Length(WResName),cbWritten,Nil);
    Value := 0;      //.. Write DataVersion
    WriteFile(hFileOut,Value,SizeOf(DWORD),cbWritten,Nil);
    Value := $0030;    //.. Write MemoryFlags
    WriteFile(hFileOut,WORD(Value),SizeOf(WORD),cbWritten,Nil);
    Value := GLOBAL_LANG; //.. Write LanguageId
    WriteFile(hFileOut,WORD(Value),SizeOf(WORD),cbWritten,Nil);
    Value := 0;      //.. Write Version
    WriteFile(hFileOut,Value,SizeOf(DWORD),cbWritten,Nil);
    Value := 0;      //.. Write Characteristics
    WriteFile(hFileOut,Value,SizeOf(DWORD),cbWritten,Nil);

    // Write ResData
    WriteFile(hFileOut,PResData^,szData,cbWritten,Nil);
    Result:=true;
  finally
    CloseHandle(hFileOut);
  end;
end;

{---------------------------- ResIDCreateFromFileData -------------------------}
function ResIDCreateFromFileData(FileData, FileRes: String; ResID: WORD; ResType: TResType): Boolean;
var
  hFileData  : THandle;
  szData     : Integer;
  PData      : Pointer;
  OfByteRead : Cardinal;
begin
  Result:=False;
  if (Not FileExists(FileData)) or (Not (Byte(ResType) in ArrayRT)) then Exit;

  hFileData := CreateFile(PChar(FileData),GENERIC_READ,FILE_SHARE_READ,0,OPEN_EXISTING,0,0);
  if hFileData = INVALID_HANDLE_VALUE then begin
    //RaiseLastOSError;
    Exit;
  end;
  try
    szData := GetFileSize(hFileData,Nil);
    if szData = 0 Then Exit;
    GetMem(PData,szData);
    if Not ReadFile(hFileData,PData^,szData,OfByteRead,Nil) then begin
      //RaiseLastOSError;
      Exit;
    end;
    if OfByteRead = 0 Then Exit;

    Result:=ResIdCreateFromData(PData,szData,FileRes,ResID,ResType);

    Result:=True;
  finally
    FreeMem(PData);
    CloseHandle(hFileData);
  end;
end;

{--------------------------- ResNameCreateFromFileData ------------------------}
function ResNameCreateFromFileData(FileData, FileRes, ResName: String; ResType: TResType): Boolean;
var
  hFileData  : THandle;
  szData     : Integer;
  PData      : Pointer;
  OfByteRead : Cardinal;
begin
  Result:=False;
  if (Not FileExists(FileData)) or (Not (Byte(ResType) in ArrayRT)) then Exit;

  hFileData := CreateFile(PChar(FileData),GENERIC_READ,FILE_SHARE_READ,0,OPEN_EXISTING,0,0);
  if hFileData = INVALID_HANDLE_VALUE then begin
    //RaiseLastOSError;
    Exit;
  end;
  try
    szData := GetFileSize(hFileData,Nil);
    if szData = 0 Then Exit;
    GetMem(PData,szData);
    if Not ReadFile(hFileData,PData^,szData,OfByteRead,Nil) then begin
      //RaiseLastOSError;
      Exit;
    end;
    if OfByteRead = 0 Then Exit;

    Result:=ResNameCreateFromData(PData,szData,FileRes,ResName,ResType);

    Result:=True;
  finally
    FreeMem(PData);
    CloseHandle(hFileData);
  end;
end;

{-------------------------------- ResUpdateFromData ---------------------------}
function ResNameUpdateFromData(PData: Pointer; szData: Integer; FileName: String; ResName: String; ResType: TResType): Boolean;
var hUpdate: THandle;
begin
  Result:=false;
  if (Not Assigned(PData)) or (szData=0) or (ResName = '') or
    (Not(Byte(ResType) in ArrayRT)) or (Not FileExists(FileName)) then Exit;

  hUpdate := BeginUpdateResource(PChar(FileName),false);
  if hUpdate = 0 then begin
    //RaiseLastOSError;
    Exit;
  end;

  ResName := AnsiUpperCase(ResName);
  if Not UpdateResource(hUpdate,ResType,PChar(ResName),GLOBAL_LANG,PData,szData) then begin
    //RaiseLastOSError;
    Exit;
  end;

  if Not EndUpdateResource(hUpdate,false) then begin
    //RaiseLastOSError;
    Exit;
  end;
  result:=true;
end;

{--------------------------- ResIdUpdateFromData ------------------------------}
function ResIdUpdateFromData(PData: Pointer; szData: Integer; FileName: String; ResId: WORD; ResType: TResType): Boolean;
var hUpdate: THandle;
begin
  Result:=false;
  if (Not Assigned(PData)) or (szData=0) or
    (Not(Byte(ResType) in ArrayRT)) or (Not FileExists(FileName)) then Exit;

  hUpdate := BeginUpdateResource(PChar(FileName),false);
  if hUpdate = 0 then begin
    //RaiseLastOSError;
    Exit;
  end;

  if Not UpdateResource(hUpdate,ResType,PChar(ResId),GLOBAL_LANG,PData,szData) then begin
    //RaiseLastOSError;
    Exit;
  end;

  if Not EndUpdateResource(hUpdate,false) then begin
    //RaiseLastOSError;
    Exit;
  end;
  result:=true;
end;
{--------------------------------- ResUpdateFromFileData ----------------------}
function ResUpdateFromFileData(FileData: String; FileName, ResName: String; ResType: TResType): Boolean;
var
  hFile   : Thandle;
  hUpdate : THandle;
  szData  : Integer;
  PBuffer : Pointer;
  BytesRead: Cardinal;
begin
  Result:=false;
  if (Not FileExists(FileData)) or (Not FileExists(FileName) or
     (ResName = '') or (Not (Byte(ResType) in ArrayRT))) then Exit;

  hFile := CreateFile(PChar(FileData),GENERIC_READ,FILE_SHARE_READ,0,OPEN_EXISTING,0,0);
  if hFile = INVALID_HANDLE_VALUE then begin
    //RaiseLastOSError;
    Exit;
  end;

  try
    szData:=GetFileSize(hFile,Nil);
    if szData = 0 then Exit;

    GetMem(PBuffer,szData);

    if Not ReadFile(hFile,PBuffer^,szData,BytesRead,0) then begin
      //RaiseLastOSError;
      Exit;
    end;
    if BytesRead = 0 then Exit;

    hUpdate := BeginUpdateResource(PChar(FileName),false);
    if hUpdate = 0 Then begin
      //RaiseLastOSError;
      Exit;
    end;

    ResName:=AnsiUpperCase(ResName);
    if Not UpdateResource(hUpdate,ResType,PChar(ResName),
                          GLOBAL_LANG,PBuffer,szData) then begin
      //RaiseLastOSError;
      Exit;
    end;

    if Not EndUpdateResource(hUpdate,false) Then begin
      //RaiseLastOSError;
      Exit;
    end;

    Result:=True;
  finally
    FreeMem(PBuffer);
    CloseHandle(hFile);
  end;
end;

{----------------------------- ResUpdateFromFileRes ---------------------------}
function ResUpdateFromFileRes(ResFile,UpDateFile: String): Boolean;
Var
  szFileRes   : Integer; //size of File Resource
  szData      : Integer; //size DATA
  szResHeader : Integer; //size Resource Header
  szName      : Integer; //size Of Resource Name
  hFileRes    : THandle;
  PBuffer     : Pointer;
  ByteRead    : Cardinal;
  ResType     : TResType;
  ResName     : String;
  RT          : DWORD;
begin
  result := false;
  if (Not FileExists(ResFile))
     or (Not FileExists(UpDateFile))
      then Exit;

  hFileRes:=CreateFile(PChar(ResFile), // name of file
                     GENERIC_READ,        // access mode
                     FILE_SHARE_READ,     // share mode
                     nil,                 // default security
                     OPEN_EXISTING,       // create flags
                     0,                   // file attributes
                     0);
  if hFileRes = INVALID_HANDLE_VALUE then begin
    //RaiseLastOSError;
    exit;
  end;
  try
    szFileRes := GetFileSize(hFileRes,nil);
    if (szFileRes = 0) then Exit;

    GetMem(PBuffer, SizeOf(DWORD));

    If SizeOf(TFileHeader)+SizeOf(DWORD) > szFileRes Then Exit;

    //read size DATA
    SetFilePointer(hFileRes, SizeOf(TFileHeader), nil, 0);
    if Not ReadFile(hFileRes,PBuffer^,SizeOf(DWORD),ByteRead,0) then begin
      //RaiseLastOSError;
      Exit;
    end;
    szData := Integer(PBuffer^);
    if szData = 0 Then Exit;

    // read size ResHeader
    if Not ReadFile(hFileRes,PBuffer^,SizeOf(DWORD),ByteRead,0) then begin
      //RaiseLastOSError;
      Exit;
    end;
    szResHeader   := Integer(PBuffer^);
    if szResHeader = 0 then Exit;
    //check resFile of full size
    if Not (SizeOf(TFileHeader)+szResHeader+szData = szFileRes) then Exit;

    // reade Resurce Type
    SetFilePointer(hFileRes, SizeOf(TFileHeader)+8, nil, 0);
    if Not ReadFile(hFileRes,PBuffer^,SizeOf(DWORD),ByteRead,0) then begin
      //RaiseLastOSError;
      Exit;
    end;
    RT := $00000000 or DWORD(PBuffer^) shr 16;
    if RT = 0 Then Exit;
    if (ByteRead = 0) or (Not (Byte(RT) In ArrayRT)) then Exit;
    ResType := MakeIntResource(RT);

    //set size of res Name or Id
    if (szResHeader-28) < 4 Then Exit;
    szName := szResHeader-28;
    // reade Resource Name
    ReallocMem(PBuffer,szName);
    FillChar(PBuffer^, szName, 0);
    if Not ReadFile(hFileRes,PBuffer^,szName,ByteRead,0) then begin
      //RaiseLastOSError;
      Exit;
    end;
    //if (ByteRead = 0) or (ByteRead <> szName) then Exit;
    SetString(ResName,Pchar(PBuffer),szName);
    ResName:=UnicodeToStr(ResName);

    //Res Lang
    ReallocMem(PBuffer,SizeOf(WORD));
    SetFilePointer(hFileRes, SizeOf(TFileHeader)+18+szName, nil, 0);
    if Not ReadFile(hFileRes,PBuffer^,SizeOf(WORD),ByteRead,0) then begin
      //RaiseLastOSError;
      Exit;
    end;
    if ByteRead = 0 Then Exit;
    GLOBAL_LANG := WORD(PBuffer^);

    // reade of DATA to Buffer
    ReallocMem(PBuffer,szData);
    FillChar(PBuffer^,szData,0);
    SetFilePointer(hFileRes, SizeOf(TFileHeader)+szResHeader, nil, 0);
    if Not ReadFile(hFileRes,PBuffer^,szData,ByteRead,0) then begin
      //RaiseLastOSError;
      Exit;
    end;
    if (ByteRead = 0) or (ByteRead <> szData) then Exit;

    // Resource Update
    Result:=ResNameUpdateFromData(PBuffer,szData,UpDateFile,ResName,ResType);

  finally
    FreeMem(PBuffer);
    CloseHandle(hFileRes);
  end;
end;

{------------------------- ResUpdateFromResIdModule ---------------------------}
function ResUpdtFromResIdModule(Module,UpdtFile: String; FindResId: WORD;
   FindResType: TResType; UpdtResName: String; UpdtResId: WORD; UpdtResType: TResType): Boolean;
Var
  hModule  : THandle;
  PData    : Pointer;
  hResInfo : HRSRC;
  hResLoad : HRSRC;
  szData   : Integer;
begin
  Result:=False;
  if (Not FileExists(Module)) or (Not FileExists(UpDtFile))
     or (Not (Byte(FindResType) in ArrayRT))
     or (Not (Byte(UpDtResType) in ArrayRT)) then Exit;

    // Load Library
  hModule:= LoadLibrary(PChar(Module));
  if hModule = 0 then begin
    //RaiseLastOSError;
    exit;
  end;

  try
    //Find Resource
    hResInfo := FindResource(hModule,PChar(FindResId),FindResType);
    if hResInfo = 0 then begin
      //RaiseLastOSError;
      exit;
    end;
    //check size of resource
    szData := SizeofResource(hModule,hResInfo);
    if szData = 0 then Exit;

    // Функция LoadResource Загружает указанный ресурс в глобальную память
    hResLoad := LoadResource(hModule,hResInfo);
    if hResLoad = 0 then begin
      //RaiseLastOSError;
      Exit;
    end;

    // функция LockResource блокирует указанный ресурс в памяти.
    PData := LockResource(hResLoad);
    if Not Assigned(PData) then begin
      //RaiseLastOSError;
      exit;
    end;

    if UpdtResName <> '' Then begin
      Result := ResNameUpdateFromData(PData, szData, UpdtFile,UpdtResName,UpDtResType);
      Exit;
    end;

    Result := ResIdUpdateFromData(PData, szData, UpdtFile,UpdtResId,UpDtResType);


  finally
    ///CloseHandle(hFileOut);
    if Not FreeLibrary(hModule) then //RaiseLastOSError;
  end;
end;
{--------------------------- ResUpdateFromResNameModul ------------------------}
function ResUpdtFromResNameModule(Module,UpdtFile: String; FindResName: String;
 FindResType: TResType; UpdtResName: String; UpdtResId: WORD; UpdtResType: TResType): Boolean;
var
  hModule  : THandle;
  PData    : Pointer; // Это указатель на ресурс
  hResInfo : HRSRC;
  hResLoad : HRSRC;
  szData   : Integer;
  //hFileOut : THandle;
  //cbWritten: DWORD;
  //ResId    : DWORD;
Begin
  Result:=False;
  if (Not FileExists(Module)) or (Not FileExists(UpDtFile))
    or (Not(Byte(FindResType) in ArrayRT)) or (Not(Byte(UpDtResType) in ArrayRT))
    then Exit;

    // Load Library
  hModule:= LoadLibrary(PChar(Module));
  if hModule = 0 then begin
    //RaiseLastOSError;
    exit;
  end;

  try
    //Find Resource
    hResInfo := FindResource(hModule,PChar(FindResName),FindResType);
    if hResInfo = 0 then begin
      //RaiseLastOSError;
      exit;
    end;

    //check size of resource
    szData := SizeofResource(hModule,hResInfo);
    if szData = 0 then Exit;

    // Функция LoadResource Загружает указанный ресурс в глобальную память
    hResLoad := LoadResource(hModule,hResInfo);
    if hResLoad = 0 then begin
      //RaiseLastOSError;
      Exit;
    end;

    // функция LockResource блокирует указанный ресурс в памяти.
    PData := LockResource(hResLoad);
    if Not Assigned(PData) then begin
      //RaiseLastOSError;
      exit;
    end;

    if UpdtResName <> '' Then begin
      Result := ResNameUpdateFromData(PData, szData, UpdtFile,UpdtResName,UpDtResType);
      Exit;
    end;

    Result := ResIdUpdateFromData(PData, szData, UpdtFile,UpdtResId,UpDtResType);

  finally
    ///CloseHandle(hFileOut);
    if Not FreeLibrary(hModule) then //RaiseLastOSError;
  end;
End;
{-------------------------------- ResIdSaveTofile -----------------------------}
function ResIdSaveTofile(FileSave: String; ResId: WORD; ResType: TResType): Boolean;
Var
  hFileOut  : THandle;
  szData    : Integer;
  hResInfo  : THandle;
  hResLoad  : THandle;
  PData     : Pointer;
  cbWritten : DWORD;
begin
  Result:=false;
  try
    //Find Resource
    hResInfo := FindResource(HInstance,PChar(ResId),ResType);
    if hResInfo = 0 then begin
      //RaiseLastOSError;
      exit;
    end;

    //check size of resource
    szData := SizeofResource(HInstance,hResInfo);
    if szData = 0 then Exit;

    // Функция LoadResource Загружает указанный ресурс в глобальную память
    hResLoad := LoadResource(HInstance,hResInfo);
    if hResLoad = 0 then begin
      //RaiseLastOSError;
      Exit;
    end;

    // функция LockResource блокирует указанный ресурс в памяти.
    PData := LockResource(hResLoad);
    if Not Assigned(PData) then begin
      //RaiseLastOSError;
      exit;
    end;

    hFileOut := CreateFile(PChar(FileSave),           // name of file
                     GENERIC_READ or GENERIC_WRITE, // access mode
                     0,                             // share mode
                     nil,                           // default security
                     CREATE_ALWAYS,                 // create flags
                     FILE_ATTRIBUTE_NORMAL,         // file attributes
                     0);
    if hFileOut = INVALID_HANDLE_VALUE Then begin
      //RaiseLastOSError;
      Exit;
    end;
    if Not WriteFile(hFileOut,PData^,szData,cbWritten,Nil) then begin
      //RaiseLastOSError;
      exit;
    end;
    result:=true;
  finally
    FreeResource(hResLoad);
    CloseHandle(hFileOut);
  end;
end;

{------------------------------- ResNameSaveTofile ----------------------------}
function ResNameSaveTofile(FileSave: String; ResName: String; ResType: TResType): Boolean;
Var
  hFileOut  : THandle;
  szData    : Integer;
  hResInfo  : THandle;
  hResLoad  : THandle;
  PData     : Pointer;
  cbWritten : DWORD;
begin
  Result:=false;
  try
    //Find Resource
    hResInfo := FindResource(HInstance,PChar(ResName),ResType);
    if hResInfo = 0 then begin
      //RaiseLastOSError;
      exit;
    end;

    //check size of resource
    szData := SizeofResource(HInstance,hResInfo);
    if szData = 0 then Exit;

    // Функция LoadResource Загружает указанный ресурс в глобальную память
    hResLoad := LoadResource(HInstance,hResInfo);
    if hResLoad = 0 then begin
      //RaiseLastOSError;
      Exit;
    end;

    // функция LockResource блокирует указанный ресурс в памяти.
    PData := LockResource(hResLoad);
    if Not Assigned(PData) then begin
      //RaiseLastOSError;
      exit;
    end;

    hFileOut := CreateFile(PChar(FileSave),           // name of file
                     GENERIC_READ or GENERIC_WRITE, // access mode
                     0,                             // share mode
                     nil,                           // default security
                     CREATE_ALWAYS,                 // create flags
                     FILE_ATTRIBUTE_NORMAL,         // file attributes
                     0);
    if hFileOut = INVALID_HANDLE_VALUE Then begin
      //RaiseLastOSError;
      Exit;
    end;

    if Not WriteFile(hFileOut,PData^,szData,cbWritten,Nil) then begin
      //RaiseLastOSError;
      exit;
    end;
    result:=true;
  finally
    FreeResource(hResLoad);
    CloseHandle(hFileOut);
  end;
end;

{-------------------------------- ResNameSaveToBuffer -------------------------}
function ResNameSaveToBuffer(ResName: String; ResType: TResType; Var OutBuffer: Pointer; var OutBytes: Integer): Boolean;
var
  hResInfo  : THandle;
  hResLoad  : THandle;
  PData     : Pointer;
begin
  Result:=false;

  hResInfo := FindResource(HInstance,PChar(ResName),ResType);
  if hResInfo = 0 then begin
    SaveErrorMessage('FindResource '+ResName);
    Exit;
  end;

  OutBytes := SizeofResource(HInstance,hResInfo);
  if OutBytes = 0 then Exit;
  
  try
    hResLoad := LoadResource(HInstance,hResInfo);
    if hResLoad = 0 then begin
      SaveErrorMessage('func. LoadResource()');
      Exit;
    end;

    PData := LockResource(hResLoad);
    if Not Assigned(PData) then begin
      SaveErrorMessage('func. LockResource()');
      exit;
    end;

    try

      if Assigned(OutBuffer) then
      begin
        ReallocMem(OutBuffer, OutBytes);
        move(PData^, OutBuffer^, OutBytes);
      end
      else Exit;

    except
      SaveErrorMessage('');
      Exit;
    end;

    result := true;

  finally
    FreeResource(hResLoad);
  end;
end;

{--------------------------------- ResIdSaveToBuffer --------------------------}
function ResIdSaveToBuffer(ResId: WORD; ResType: TResType; Var OutBuffer; var OutBytes: Integer): Boolean;
var
  hResInfo  : THandle;
  hResLoad  : THandle;
  PData     : Pointer;
begin
  Result:=false;

  hResInfo := FindResource(HInstance,PChar(ResId),ResType);
  if hResInfo = 0 then begin
    SaveErrorMessage('');
    Exit;
  end;

  OutBytes := SizeofResource(HInstance,hResInfo);
  if OutBytes = 0 then Exit;

  try
    hResLoad := LoadResource(HInstance,hResInfo);
    if hResLoad = 0 then begin
      SaveErrorMessage('');
      Exit;
    end;

    PData := LockResource(hResLoad);
    if Not Assigned(PData) then begin
      SaveErrorMessage('');
      exit;
    end;

    try
      if Not Assigned(Pointer(OutBuffer)) then
        GetMem(Pointer(OutBuffer),OutBytes);

      ReallocMem(Pointer(OutBuffer),OutBytes);
      move(PData^,OutBuffer,OutBytes);
    except
      SaveErrorMessage('');
      exit;
    end;
    Result:=true;

  finally
    FreeResource(hResLoad);
   // FreeMem(PData);
  end;
end;

{------------------------------- FindResId ------------------------------------
function FindResId(ResId: DWORD; ResType: TResType; var PData; var szData: Integer): Boolean;
var
  hResInfo  : THandle;
  hResLoad  : THandle;
begin
  Result:=false;
  try
    //Find Resource
    hResInfo := FindResource(HInstance,PChar(ResId),ResType);
    if hResInfo = 0 then begin
      if ENABLED_RAISE_ERROR then RaiseLastOSError;
      exit;
    end;

    //check size of resource
    szData := SizeofResource(HInstance,hResInfo);
    if szData = 0 then Exit;

    // Функция LoadResource Загружает указанный ресурс в глобальную память
    hResLoad := LoadResource(HInstance,hResInfo);
    if hResLoad = 0 then begin
      if ENABLED_RAISE_ERROR then RaiseLastOSError;
      Exit;
    end;

    // функция LockResource блокирует указанный ресурс в памяти.
    Pointer(PData) := LockResource(hResLoad);
    if Not Assigned(Pointer(PData)) then begin
      if ENABLED_RAISE_ERROR then RaiseLastOSError;
      exit;
    end;

    result:=true;

  finally
    FreeResource(hResLoad);
  end;
end;
            }

Initialization

ArrayRT := [1..22];
GLOBAL_LANG := LANG_NEUTRAL;

end.
