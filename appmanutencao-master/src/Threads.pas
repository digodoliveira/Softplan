unit Threads;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, System.Generics.Collections;

type
  TMinhaThread = class(TThread)
  private
    FTempo: Integer;
    FProgress: TProgressBar;
    FMemo: TMemo;
    procedure SetMemo(const Value: TMemo);
    procedure SetProgress(const Value: TProgressBar);
    procedure SetTempo(const Value: Integer);

  protected
    procedure Execute; override;
  public
    constructor Create; overload;
    constructor Create(ATempo: Integer; AProgress: TProgressBar; AMemo: TMemo); overload;
    destructor Destroy; override;

    property Memo: TMemo read FMemo write SetMemo;
    property Progress: TProgressBar read FProgress write SetProgress;
    property Tempo: Integer read FTempo write SetTempo;

    procedure Inicializar;
    procedure Finalizar;
  end;

  TfThreads = class(TForm)
    edtNumThreads: TEdit;
    edtTempo: TEdit;
    btnExecutar: TButton;
    barProgresso: TProgressBar;
    mmoDetalhes: TMemo;
    lblNumThreads: TLabel;
    lblTempo: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure btnExecutarClick(Sender: TObject);
  private
    FNumThreads: Integer;
    procedure SetNumThreads(const Value: Integer);
    { Private declarations }
  public
    { Public declarations }
    property NumThreads: Integer read FNumThreads write SetNumThreads;
  end;

var
  fThreads: TfThreads;

implementation

{$R *.dfm}
{ TMinhaThread }

constructor TMinhaThread.Create;
begin
  inherited Create(True);
end;

constructor TMinhaThread.Create(ATempo: Integer; AProgress: TProgressBar; AMemo: TMemo);
begin
  inherited Create(True);
  FreeOnTerminate := True;

  Tempo := ATempo;
  Progress := AProgress;
  Memo := AMemo;
end;

destructor TMinhaThread.Destroy;
begin
  inherited;
end;

procedure TMinhaThread.Execute;
var
  i: Integer;
begin
  inherited;

  for i := 0 to 100 do
  begin
    Synchronize(Inicializar);
    Sleep(Random(Tempo));
    Synchronize(Finalizar);
  end;
end;

procedure TMinhaThread.SetMemo(const Value: TMemo);
begin
  FMemo := Value;
end;

procedure TMinhaThread.SetProgress(const Value: TProgressBar);
begin
  FProgress := Value;
end;

procedure TMinhaThread.SetTempo(const Value: Integer);
begin
  FTempo := Value;
end;

procedure TMinhaThread.Inicializar;
begin
  Memo.Lines.Add(IntToStr(ThreadID) + ' - Iniciando processamento');
end;

procedure TMinhaThread.Finalizar;
begin
  Memo.Lines.Add(IntToStr(ThreadID) + ' - Processamento finalizado');
  Progress.Position := Progress.Position + 1;
end;

procedure TfThreads.btnExecutarClick(Sender: TObject);
var
  i: Integer;
  ListaThread: TObjectList<TMinhaThread>;
begin
  if (edtNumThreads.Text = EmptyStr) or (StrToInt(edtNumThreads.Text) < 0) then
  begin
    Application.MessageBox(PChar('Informe o nº de threads.'), 'ATENÇÃO', MB_ICONWARNING);
    ActiveControl := edtNumThreads;

    Abort;
  end;

  if (edtTempo.Text = EmptyStr) or (StrToInt(edtTempo.Text) < 0) then
  begin
    Application.MessageBox(PChar('Informe o tempo.'), 'ATENÇÃO', MB_ICONWARNING);
    ActiveControl := edtTempo;

    Abort;
  end;

  mmoDetalhes.Lines.Clear;

  barProgresso.Position := 0;
  barProgresso.Min := 0;
  barProgresso.Max := StrToInt(edtNumThreads.Text) * 100;

  for i := 0 to StrToInt(edtNumThreads.Text) - 1 do
  begin
    ListaThread := TObjectList<TMinhaThread>.Create;
    ListaThread.Add(TMinhaThread.Create(StrToInt(edtTempo.Text), barProgresso, mmoDetalhes));
    ListaThread[0].Start;
  end;
end;

procedure TfThreads.FormCreate(Sender: TObject);
begin
  mmoDetalhes.Lines.Clear;
end;

procedure TfThreads.SetNumThreads(const Value: Integer);
begin
  FNumThreads := Value;
end;

end.
