unit ValidateException;

interface

uses
  System.SysUtils, System.Classes;

type
  TException = class
  private
    FArquivoLog: String;
    procedure SetArquivoLog(const Value: String);
  public
    constructor Create;

    property ArquivoLog: String read FArquivoLog write SetArquivoLog;

    procedure TratarException(Sender: TObject; E: Exception);
    procedure GravaLog(Value: String);
  end;

implementation

uses
  Forms, Vcl.Dialogs, Winapi.Windows;

{ TException }

constructor TException.Create;
begin
  ArquivoLog := ChangeFileExt(ParamStr(0), '.log');

  Application.OnException := TratarException;
end;

procedure TException.GravaLog(Value: String);
var
  FArquivoLog: TextFile;
begin
  AssignFile(FArquivoLog, ArquivoLog);

  try
    if FileExists(ArquivoLog) then
      Append(FArquivoLog)
    else
      Rewrite(FArquivoLog);

    Writeln(FArquivoLog, Value);

  finally
    CloseFile(FArquivoLog);
  end;
end;

procedure TException.SetArquivoLog(const Value: String);
begin
  FArquivoLog := Value;
end;

procedure TException.TratarException(Sender: TObject; E: Exception);
var
  sMsg: String;
begin
  if E.Message <> EmptyStr then
  begin
    if TComponent(Sender) is TForm then
    begin
      GravaLog('Data/Hora: ' + FormatDateTime('DD/MM/YYYY HH:MM:SS', Now));
      GravaLog('Form: ' + TForm(Sender).Name);
      GravaLog('Class: ' + E.ClassName);
      GravaLog('Erro: ' + E.Message);
      GravaLog('');
    end
    else
    begin
      GravaLog('Data/Hora: ' + FormatDateTime('DD/MM/YYYY HH:MM:SS', Now));
      GravaLog('Unit: ' + TClass(Sender).UnitName);
      GravaLog('Class: ' + E.ClassName);
      GravaLog('Erro: ' + E.Message);
      GravaLog('');
    end;
  end;

  sMsg := EmptyStr;
  sMsg := sMsg + 'Ocorreu um erro.' + #13 + #10 + #13 + #10;
  sMsg := sMsg + 'Erro: ' + E.Message + #13 + #10 + #13 + #10;
  sMsg := sMsg + 'Por favor, verifique o arquivo de log.';

  Application.MessageBox(PChar(sMsg), 'ATENÇÃO', MB_ICONERROR);
end;

var
  Exception: TException;

initialization

Exception := TException.Create;

finalization

Exception.Free;

end.
