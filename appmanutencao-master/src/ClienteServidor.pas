unit ClienteServidor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, Datasnap.DBClient, Data.DB;

type
  TServidor = class
  private
    FPath: AnsiString;
    FProgressBar: TProgressBar;
    FListaArquivos: TStringList;
    procedure SetProgressBar(const Value: TProgressBar);
    procedure SetListaArquivos(const Value: TStringList);
  public
    property ProgressBar: TProgressBar read FProgressBar write SetProgressBar;
    property ListaArquivos: TStringList read FListaArquivos write SetListaArquivos;

    constructor Create; overload;
    constructor Create(AOwner: TComponent; AProgressBar: TProgressBar); overload;
    // Tipo do parâmetro não pode ser alterado
    function SalvarArquivos(AData: OleVariant): Boolean;

    procedure InitBarraProgresso;
    procedure SetBarraProgresso(Value: Integer);
  end;

  TfClienteServidor = class(TForm)
    ProgressBar: TProgressBar;
    btEnviarSemErros: TButton;
    btEnviarComErros: TButton;
    btEnviarParalelo: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btEnviarSemErrosClick(Sender: TObject);
    procedure btEnviarComErrosClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FPath: AnsiString;
    FServidor: TServidor;

    function InitDataset: TClientDataset;
  public
  end;

var
  fClienteServidor: TfClienteServidor;

const
  QTD_ARQUIVOS_ENVIAR = 100;

implementation

uses
  IOUtils;

{$R *.dfm}

procedure TfClienteServidor.btEnviarComErrosClick(Sender: TObject);
var
  cds: TClientDataset;
  i: Integer;
begin
  cds := InitDataset;
  for i := 0 to QTD_ARQUIVOS_ENVIAR do
  begin
    cds.Append;
    // TBlobField(cds.FieldByName('Arquivo')).LoadFromFile(String(FPath));
    cds.FieldByName('Arquivo').AsString := String(FPath);
    cds.Post;

{$REGION Simulação de erro, não alterar}
    if i = (QTD_ARQUIVOS_ENVIAR / 2) then
      FServidor.SalvarArquivos(NULL);
{$ENDREGION}
  end;

  FServidor.SalvarArquivos(cds.Data);
end;

procedure TfClienteServidor.btEnviarSemErrosClick(Sender: TObject);
var
  cds: TClientDataset;
  i: Integer;
begin
  cds := InitDataset;
  for i := 0 to QTD_ARQUIVOS_ENVIAR do
  begin
    cds.Append;
    // TBlobField(cds.FieldByName('Arquivo')).LoadFromFile(String(FPath));
    cds.FieldByName('Arquivo').AsString := String(FPath);
    cds.Post;
  end;

  // FServidor.SalvarArquivos(cds.Data);
end;

procedure TfClienteServidor.FormCreate(Sender: TObject);
begin
  inherited;
  FPath := AnsiString(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'pdf.pdf');
  FServidor := TServidor.Create(nil, ProgressBar);
end;

procedure TfClienteServidor.FormShow(Sender: TObject);
begin
  FServidor.InitBarraProgresso;
end;

function TfClienteServidor.InitDataset: TClientDataset;
begin
  Result := TClientDataset.Create(nil);
  // Result.FieldDefs.Add('Arquivo', ftBlob);
  Result.FieldDefs.Add('Arquivo', ftString, 100);
  Result.CreateDataSet;
end;

{ TServidor }

constructor TServidor.Create;
begin
  FPath := AnsiString(ExtractFilePath(ParamStr(0)) + 'Servidor\');
end;

constructor TServidor.Create(AOwner: TComponent; AProgressBar: TProgressBar);
begin
  // inherited Create;

  FProgressBar := AProgressBar;

  FPath := AnsiString(ExtractFilePath(ParamStr(0)) + 'Servidor\');
  ListaArquivos := TStringList.Create;
end;

procedure TServidor.InitBarraProgresso;
begin
  ProgressBar.Max := QTD_ARQUIVOS_ENVIAR;
  ProgressBar.Position := 0;
end;

function TServidor.SalvarArquivos(AData: OleVariant): Boolean;
var
  cds: TClientDataset;
  FileName: string;
  ms: TMemoryStream;
  i: Integer;
begin
  Result := False;

  if AData = NULL then
  begin
    for i := 0 to ListaArquivos.Count - 1 do
    begin
      DeleteFile(ListaArquivos.Strings[i]);
    end;
  end
  else
  begin
    try
      try
        InitBarraProgresso;

        // Se o diretório destino não existir, força a criação do diretório
        if not DirectoryExists(String(FPath)) then
          ForceDirectories(String(FPath));
        // ---

        cds := TClientDataset.Create(nil);
        cds.Data := AData;

{$REGION Simulação de erro, não alterar}
        if cds.RecordCount = 0 then
          Exit;
{$ENDREGION}
        cds.First;

        while not cds.Eof do
        begin
          FileName := String(FPath) + cds.RecNo.ToString + '.pdf';

          if TFile.Exists(FileName) then
            TFile.Delete(FileName);

          ListaArquivos.Add(FileName);

          // Carrega os arquivos da pasta inicial e salva na pasta "Servidor"
          try
            ms := TMemoryStream.Create;
            ms.LoadFromFile(cds.FieldByName('Arquivo').AsString);
            ms.SaveToFile(FileName);
          finally
            FreeAndNil(ms);
          end;
          // ---

          // TBlobField(cds.FieldByName('Arquivo')).SaveToFile(FileName);

          SetBarraProgresso(cds.RecNo);

          Application.ProcessMessages;

          cds.Next;
        end;

        Result := True;
      except
        raise;
      end;
    finally
      FreeAndNil(cds);
    end;
  end;
end;

procedure TServidor.SetBarraProgresso(Value: Integer);
begin
  ProgressBar.Position := Value;
end;

procedure TServidor.SetListaArquivos(const Value: TStringList);
begin
  FListaArquivos := Value;
end;

procedure TServidor.SetProgressBar(const Value: TProgressBar);
begin
  FProgressBar := Value;
end;

end.
