//**********************************************************************8***//
//   Modul modifed by SUPERBOT 28.03.2023                                   //
//   Https://GitHub.com/Superbot-coder                                      //
//   Get Resoure: https://www.programmersforum.ru/showthread.php?t=70470    //
//**************************************************************************//


unit EnumerateResource;

interface

Uses
   System.SysUtils, System.Classes, Winapi.Windows, Vcl.Dialogs, JSON, Error;

type

  //структура RT_ICON
  GRPICONDIRENTRY = packed record
    bWidth       :Byte;                 //ширина иконки в пикселях (если больше 255, то 0)
    bHeight      :Byte;                 //высота иконки в пикселях (если больше 255, то 0)
    bColorCount  :Byte;                 //число цветов (если больше 255, то 0)
    bReserved    :Byte;                 //зарезервировано, всегда 0
    wPlanes      :Word;                 //?
    wBitCount    :Word;                 //глубина цвета, в битах
    dwBytesInRes :DWORD;                //размер в байтах битового образа иконки
    nId          :Word;                 //ID ресурса иконки
  end;
  PGRPICONDIRENTRY = ^GRPICONDIRENTRY;

  GRPICONDIR = packed record
    idReserved : Word; //зарезервировано, всегда 0
    idType     : Word; //тип образа: 1 - иконка, 0 - курсор
    idCount    : Word; //число иконок типа RT_ICON
    idEntries  : array [0..0] of GRPICONDIRENTRY;
  end;

 { GRPICONDIR = packed record
    idReserved :Word; //зарезервировано, всегда 0
    idType     :Word; //тип образа: 1 - иконка, 0 - курсор
    idCount    :Word; //число иконок типа RT_ICON
  end; }
  PGRPICONDIR = ^GRPICONDIR;

type
  TResourceMap = class(TObject)
  private
    FSTLog  : TStrings;
    FResMap : TJSONObject;
    FModule : THandle;
    function GetResMapStr: string;
    function GetLog: String;
    procedure log(MsgStr: String);
  public
    procedure MapGroupIcon;
    property ViewLog: String read GetLog;
    property JSONResMap: TJSONObject read FResMap;
    property JSONResMapStr: string read GetResMapStr;
    constructor Create(FileName: String);
    destructor Destroy;
  end;



function StockResourceType(restype: PChar): string;
procedure GetResourceTypes(hModule: THandle; ResMap: TJSONObject); // hModule := LoadLibraryEx(); Resource Mam to JSON format

function LoadIconFromExe(FileName, ResName: PChar; X, Y: Integer): Cardinal;

implementation

USES Unit1;

{----------------------------- LoadIconFromExe  -------------------------------}
function LoadIconFromExe(FileName, ResName: PChar; X, Y: Integer): Cardinal;
var
  hModule: THandle;
begin
  hModule := LoadLibraryEx(FileName,0 , LOAD_LIBRARY_AS_DATAFILE);
  if hModule = 0 then
    RaiseLastOSError(GetLastError);
  try
    Result := LoadImage(hModule, ResName, IMAGE_ICON, X, Y, LR_DEFAULTCOLOR)
   {
    if HiWord(Cardinal(ResName)) <> 0 then
      Result := LoadImage(hModule, ResName, IMAGE_ICON, X, Y, LR_DEFAULTCOLOR)
    else
      Result := LoadImage(hModule, MAKEINTRESOURCE(ResName), IMAGE_ICON, X, Y, LR_DEFAULTCOLOR);
      }
  finally
    FreeLibrary(hModule);
  end;
end;

{----------------------------- enumResNamesProc -------------------------------}
function enumResNamesProc(module: HMODULE; restype, resname: PChar; SubMap: TJSONArray): Integer; stdcall;
var
  item: TJSONObject;
begin
 {if HiWord(Cardinal(resname)) <> 0 then
   list.Add(resname)
 else
   list.Add(Format('#%d', [loword(Cardinal(resname))])); }

 item := TJSONObject.Create;

 if HiWord(Cardinal(resname)) <> 0 then
   item.AddPair('name', resname)  // SubMap.Add(TJSONObject.Create(TJSONPair.Create('name', resname)))
 else
   item.AddPair('id', TJSONNumber.Create(Cardinal(resname))); //SubMap.Add(TJSONObject.Create(TJSONPair.Create('id', IntToStr(Cardinal(resname))) ));

 SubMap.Add(item);
 item   := Nil;
 Result := 1;

end;

{------------------------------ StockResourceType -----------------------------}
Function StockResourceType(restype: PChar): string;
const
 restypenames: Array [1..24] of String =
   ('RT_CURSOR',       // MakeIntResource(1);
    'RT_BITMAP',       // MakeIntResource(2);
    'RT_ICON',         // MakeIntResource(3);
    'RT_MENU',         // MakeIntResource(4);
    'RT_DIALOG',       // MakeIntResource(5);
    'RT_STRING',       // MakeIntResource(6);
    'RT_FONTDIR',      // MakeIntResource(7);
    'RT_FONT',         // MakeIntResource(8);
    'RT_ACCELERATOR',  // MakeIntResource(9);
    'RT_RCDATA',       // MakeIntResource(10);
    'RT_MESSAGETABLE', // MakeIntResource(11); // DIFFERENCE = 11;
    'RT_GROUP_CURSOR', // MakeIntResource(DWORD(RT_CURSOR +7DIFFERENCE));
    'UNKNOWN',         // 13 not used
    'RT_GROUP_ICON',   // MakeIntResource(DWORD(RT_ICON +DIFFERENCE));
    'UNKNOWN',         // 15 not used
    'RT_VERSION',      // MakeIntResource(16);
    'RT_DLGINCLUDE',   // MakeIntResource(17);
    'UNKNOWN',
    'RT_PLUGPLAY',     // MakeIntResource(19);
    'RT_VXD',          // MakeIntResource(20);
    'RT_ANICURSOR',    // MakeIntResource(21);
    'RT_ANIICON',      // MakeIntResource(22);
    'RT_HTML',         // MakeIntResource(23)
    'RT_MANIFEST'      // MakeIntResource(24)
  );

var
  resid: Cardinal absolute restype;
begin
 if resid in [1..24] then
   Result := restypenames[resid]
 else
   Result := 'UNKNOWN';
end;

{------------------------------ enumResTypesProc ------------------------------}
function enumResTypesProc(module: HMODULE; restype: PChar; ResMap: TJSONObject): Integer; stdcall;
var
  SubMap: TJSONArray;
  rt: String;
begin
  SubMap := TJSONArray.Create;

  if HiWord(Cardinal(restype)) <> 0 then
    rt := restype
  else
    rt := StockResourcetype(restype);
  EnumResourceNames(module, restype, @enumResNamesProc, Integer(SubMap));
  ResMap.AddPair(rt, SubMap);
  SubMap := Nil;
  Result := 1;
end;

{------------------------------ GetResourceTypes ------------------------------}
procedure GetResourceTypes(hModule: THandle; ResMap: TJSONObject);
begin
  if ResMap = Nil then Exit;
  if not EnumResourceTypes(hModule, @enumResTypesProc, Integer(ResMap)) then
  begin
    RaiseLastOSError(GetLastError);
    //
  end;
end;

{ ResourceMap }

constructor TResourceMap.Create(FileName: String);
Var
  arGrIcon  : TJSONArray;
  hResInfo  : THandle;
  hResLoad  : THandle;
  PGID      : PGRPICONDIR;
  PGIDE     : PGRPICONDIRENTRY;
  szData    : Cardinal;
  IconCount : SmallInt;
  i, j, id  : SmallInt;
  s_temp    : String;
  s_clr     : String;
  arIcons   : TJSONArray;
begin
  inherited Create;

  FSTLog   := TStringList.Create;
  FResMap  := TJSONObject.Create;

  FModule :=  LoadLibraryEx(PChar(FileName),0 , LOAD_LIBRARY_AS_DATAFILE);
  if FModule = 0 then
  begin
    //RaiseLastOSError(GetLastError, SystemErrorMessage(GetLastError));

    Exit;
  end;

  if not EnumResourceTypes(FModule, @enumResTypesProc, Integer(FResMap)) then
  begin
    // RaiseLastOSError(GetLastError, SystemErrorMessage(GetLastError));
    Exit;
  end;


  MapGroupIcon;

  (*
  if FResMap.FindValue(StockResourceType(RT_GROUP_ICON)) = Nil then
  begin
    //
    Exit;
  end;

  arGrIcon := FResMap.GetValue(StockResourceType(RT_GROUP_ICON)) as TJSONArray;
  for i := 0 to arGrIcon.Count -1 do
  begin

    // Поиск ресурса по имени
    if arGrIcon.Items[i].FindValue('name') <> nil then
    begin
      s_temp := (arGrIcon.Items[i] as TJSONObject).GetValue('name').Value;
      //Form1.log('name: ' + s_temp);
      hResInfo := FindResource(FModule, PChar(s_temp), RT_GROUP_ICON);
    end
    else
    begin
      // Error message...
      Continue;
    end;

    // Поиск ресурса по Id
    if arGrIcon.Items[i].FindValue('id') <> nil then
    begin
      id := (arGrIcon.Items[i] as TJSONObject).GetValue('id').Value.ToInteger;
      //Form1.log('id: ' + IntToStr(id));
      hResInfo := FindResource(FModule, MAKEINTRESOURCE(Id), RT_GROUP_ICON);
    end
    else
    begin
      // Error Message ...
      Continue;
    end;

    if hResInfo = 0 then
    begin
      // Send Error message...
      continue;
    end;

    hResLoad := LoadResource(FModule, hResInfo);
    if hResLoad = 0 then
    begin
      // Send Error message...
      Continue; // Exit;
    end;

    // функция LockResource блокирует указанный ресурс в памяти.
    PGID := LockResource(hResLoad);
    if Not Assigned(PGID) then begin
      // Send error message...
      FreeResource(hResLoad);
      Continue;
    end;

    //check size of resource
    szData := SizeofResource(FModule, hResInfo);
    if szData = 0 then
    begin
      // Send error message...
      FreeResource(hResLoad);
      Continue;
    end;

   IconCount := PGRPICONDIR(PGID)^.idCount;
   arIcons   := TJSONArray.Create;

   for j := 0 to IconCount -1 do
   begin
     arIcons.Add(TJSONObject.Create);

     with PGRPICONDIR(PGID)^ do
     begin
       case idEntries[j].wBitCount of
         4 : s_clr := '16';
         8 : s_clr := '256';
         12: s_clr := '4096';
         16: s_clr := '65.536 (High Color)';
         24: s_clr := '16.8mln (True Color)';
         32: s_clr := '4.3bln (True Color)';
       end;

       with (arIcons.Items[arIcons.Count-1] as TJSONObject) do
       begin
         AddPair('id', TJSONNumber.Create(idEntries[j].nId));
         AddPair('width', TJSONNumber.Create(idEntries[j].bWidth));
         AddPair('height', TJSONNumber.Create(idEntries[j].bHeight));
         AddPair('bit', TJSONNumber.Create(idEntries[j].wBitCount));
         AddPair('colors', s_clr);
       end;
     end;
   end;

   (arGrIcon.Items[i] as TJSONObject).AddPair('icons', arIcons);
   arIcons := Nil;
   PGID := Nil;
   FreeResource(hResLoad);

  end; {for i := 0 to arGrIcon.Count -1 do}
  *)

end;

destructor TResourceMap.Destroy;
begin
  inherited Destroy;
  FreeAndNil(FResMap);
  FreeLibrary(FModule);
  FSTLog.Free;
  //FreeResource(FhResLoad);
end;

function TResourceMap.GetLog: String;
begin
  Result := FSTLog.Text;
end;

function TResourceMap.GetResMapStr: string;
begin
  Result := FResMap.ToJSON;
end;

procedure TResourceMap.log(MsgStr: String);
begin
  FSTLog.Add(MsgStr);
end;

procedure TResourceMap.MapGroupIcon;
Var
  arGrIcon  : TJSONArray;
  arIcons   : TJSONArray;
  hResInfo  : THandle;
  hResLoad  : THandle;
  PGID      : PGRPICONDIR;
  PGIDE     : PGRPICONDIRENTRY;
  szData    : Cardinal;
  IconCount : SmallInt;
  i, j, id  : SmallInt;
  s_clr     : String;
  ResName   : String;
begin

  if FResMap = Nil then
  begin
    // send error message...
    Form1.log('FResMap = Nil');
    exit;
  end;

  if FResMap.FindValue(StockResourceType(RT_GROUP_ICON)) = Nil then
  begin
    // Send Error Message...
    Log('FResMap.FindValue(StockResourceType(RT_GROUP_ICON)) = nil');
    Exit;
  end;

  arGrIcon := TJSONArray.Create;
  arGrIcon := FResMap.GetValue(StockResourceType(RT_GROUP_ICON)) as TJSONArray;

  //log('arGrIcon = ' + arGrIcon.ToString);

  for i := 0 to arGrIcon.Count -1 do
  begin

    // Поиск ресурса по имени
    if arGrIcon.Items[i].FindValue('name') <> nil then
    begin
      ResName := (arGrIcon.Items[i] as TJSONObject).GetValue('name').Value;
      log('FindValue(''name''): ' + resName);
      hResInfo := FindResource(FModule, PChar(ResName), RT_GROUP_ICON);
    end
    else
    begin
      // Error message...
      log(' FindValue(''name'') = Nil');
    end;

    // Поиск ресурса по Id
    if arGrIcon.Items[i].FindValue('id') <> nil then
    begin
      id := (arGrIcon.Items[i] as TJSONObject).GetValue('id').Value.ToInteger;
      log('Ok. FindValue(''id''): ' + IntToStr(id));
      hResInfo := FindResource(FModule, MAKEINTRESOURCE(Id), RT_GROUP_ICON);
    end
    else
    begin
      // Error Message ...
      log('FindValue(''id'') = nil');
    end;

    if hResInfo = 0 then
    begin
      // Send Error message...
      log('hResInfo = 0');
      continue;
    end;

    hResLoad := LoadResource(FModule, hResInfo);
    if hResLoad = 0 then
    begin
      // Send Error message...
      log('LoadResource hResLoad = 0');
      Continue; // Exit;
    end;

    // функция LockResource блокирует указанный ресурс в памяти.
    PGID := LockResource(hResLoad);
    if Not Assigned(PGID) then
    begin
      // Send error message...
      FreeResource(hResLoad);
      log('Assigned(PGID) = false');
      Continue;
    end;

    //check size of resource
    szData := SizeofResource(FModule, hResInfo);
    if szData = 0 then
    begin
      // Send error message...
      log('SizeofResource(FModule, hResInfo) = 0');
      FreeResource(hResLoad);
      Continue;
    end;

   IconCount := PGRPICONDIR(PGID)^.idCount;
   arIcons   := TJSONArray.Create;

   for j := 0 to IconCount -1 do
   begin
     arIcons.Add(TJSONObject.Create);

     with PGRPICONDIR(PGID)^ do
     begin
       case idEntries[j].wBitCount of
         4 : s_clr := '16';
         8 : s_clr := '256';
         12: s_clr := '4096';
         16: s_clr := '65.536 (High Color)';
         24: s_clr := '16.8mln (True Color)';
         32: s_clr := '4.3bln (True Color)';
       end;

       with (arIcons.Items[arIcons.Count-1] as TJSONObject) do
       begin
         AddPair('id', TJSONNumber.Create(idEntries[j].nId));
         AddPair('width', TJSONNumber.Create(idEntries[j].bWidth));
         AddPair('height', TJSONNumber.Create(idEntries[j].bHeight));
         AddPair('bit', TJSONNumber.Create(idEntries[j].wBitCount));
         AddPair('colors', s_clr);
       end;
     end;
   end;

   (arGrIcon.Items[i] as TJSONObject).AddPair('icons', arIcons);
   arIcons := Nil;
   PGID    := Nil;
   FreeResource(hResLoad);

  end; {for i := 0 to arGrIcon.Count -1 do}

end;

end.
