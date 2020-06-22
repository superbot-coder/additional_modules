unit SelectDirMod;

//********************************************************
//      "Modul by SUPERBOT                              //
//      Https://GitHub.com/Superbot-coder               //
//********************************************************

interface

Uses FileCtrl;

function SelectDir: String;


implementation

function SelectDir: String;
var
  Options: TSelectDirExtOpts;
  ChosenDirectory: String;
begin
  Options := [sdShowShares, sdNewUI];
  if Not SelectDirectory('Выбрать директорию','',ChosenDirectory, Options, Nil) then Exit;
  if ChosenDirectory = '' then Exit;
  Result := ChosenDirectory;
end;

end.