unit ExportToExel;

//********************************************************
//      "Modul ExportToExel" by SUPERBOT                //
//      Https://GitHub.com/Superbot-coder               //
//********************************************************

interface

Uses Graphics,Variants,Dialogs, DBGrids, ComObj;

Var
  EvenRowColor: TColor = clWhite;
  OddRowColor : TColor = clWhite;
  CaptionColor: TColor = clWindow;
  CaptionFontColor: TColor = clBlack;

Const
  xlExcel9795 = $0000002B;
  xlExcel8    = 56;


Procedure ExportDBGridToExel(ExlsFile: String; DBG: TDBGrid; Colors: Boolean);

implementation

Procedure ExportDBGridToExel(ExlsFile: String; DBG: TDBGrid; Colors: Boolean);
Var
  ExlApp, Sheet: OLEVariant;
  rec, col,colx, r, c: integer;
  ContNil: integer;
begin
  ExlApp := CreateOleObject('Excel.Application');
  //ExlApp.Visible := false;
  ExlApp.Workbooks.Add;
  Sheet := ExlApp.Workbooks[1].WorkSheets[1];
  Sheet.name:='Все терминалы';

  r := DBG.DataSource.DataSet.RecordCount;
  c := DBG.Columns.Count;

  if Colors then
  begin
    CaptionColor := TColor($004B4B4B);
    EvenRowColor := TColor($00E6E6E6);
    OddRowColor  := clSilver;
    CaptionFontColor := clWhite;
  end;

  colx :=1;
  for col:=1 to DBG.Columns.Count do begin
    if DBG.Columns[col-1].Visible then begin
      sheet.cells[1,colx] := DBG.Columns[col-1].Title.Caption;
      sheet.cells[1,colx].Interior.Color := CaptionColor;
	    sheet.cells[1,colx].Font.Color     := CaptionFontColor;
	  inc(colx);
    end;
  end;

  DBG.DataSource.DataSet.First;
  for rec:= 2 to r+1 do begin
    colx :=1;
    for col:= 1 to c do begin
      if DBG.Columns[col-1].Visible then begin
        sheet.cells[rec,colx] := DBG.fields[col-1].asstring+#9;
        if (rec mod 2) = 0 then
          sheet.cells[rec,colx].Interior.Color    := EvenRowColor
        else sheet.cells[rec,colx].Interior.Color := OddRowColor;
        inc(colx);
      end;
    end;
    DBG.DataSource.DataSet.Next;
  end;

  //отключаем все предупреждения Excel
  ExlApp.DisplayAlerts := False;

  //обработка исключения при сохраннении файла
  try
    //формат xls 97-2003 если установлен 2003 Excel
    ExlApp.Workbooks[1].saveas(ExlsFile, xlExcel9795);
    showmessage('Файл сохранил 2003-ий офис');
  except
    //формат xls 97-2003 если установлен 2007-2010 Excel
    ExlApp.Workbooks[1].saveas(ExlsFile, xlExcel8);
    showmessage('Файл сохранил 2007 или 2010-ый офис');
  end;

  ExlApp.Quit;
  //очищаем выделенную память
  ExlApp := Unassigned;
  Sheet := Unassigned;
end;

end.
