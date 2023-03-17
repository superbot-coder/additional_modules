//**********************************************************************8***//
//   Modul modifed by SUPERBOT 18.03.2023                                   //
//   Https://GitHub.com/Superbot-coder                                      //
//   Get Resoure: https://www.programmersforum.ru/showthread.php?t=70470    //
//**************************************************************************//


unit EnumerateResource;

interface

Uses
   System.SysUtils, System.Classes, Winapi.Windows, JSON;

procedure GetResourceTypes(hModule: THandle;     // hModule := LoadLibraryEx()
                           ResMap: TJSONObject); // Resource Mam to JSON format

implementation

function enumResNamesProc(module: HMODULE; restype, resname: PChar; list: TJSONArray): Integer; stdcall;
begin
 if HiWord(Cardinal(resname)) <> 0 then
   list.Add(resname)
 else
   list.Add(Format('#%d', [loword(Cardinal(resname))]));
 Result := 1;
end;

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
 Result := 1;
end;


procedure GetResourceTypes(hModule: THandle; ResMap: TJSONObject);
begin
  if ResMap = Nil then Exit;
  if not EnumResourceTypes(hModule, @enumResTypesProc, Integer(ResMap)) then
  begin
    RaiseLastOSError(GetLastError);
    //
  end;
end;

end.
