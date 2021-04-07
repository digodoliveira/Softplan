object fThreads: TfThreads
  Left = 0
  Top = 0
  Caption = 'fThreads'
  ClientHeight = 353
  ClientWidth = 313
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lblNumThreads: TLabel
    Left = 16
    Top = 13
    Width = 54
    Height = 13
    Caption = 'N'#186' Threads'
  end
  object lblTempo: TLabel
    Left = 160
    Top = 13
    Width = 103
    Height = 13
    Caption = 'Tempo (milisegundos)'
  end
  object edtNumThreads: TEdit
    Left = 16
    Top = 32
    Width = 137
    Height = 21
    TabOrder = 0
  end
  object edtTempo: TEdit
    Left = 160
    Top = 32
    Width = 137
    Height = 21
    TabOrder = 1
  end
  object btnExecutar: TButton
    Left = 16
    Top = 59
    Width = 281
    Height = 25
    Caption = 'Executar'
    TabOrder = 2
    OnClick = btnExecutarClick
  end
  object barProgresso: TProgressBar
    Left = 16
    Top = 90
    Width = 281
    Height = 17
    TabOrder = 3
  end
  object mmoDetalhes: TMemo
    Left = 16
    Top = 113
    Width = 281
    Height = 223
    Lines.Strings = (
      'mmoDetalhes')
    ScrollBars = ssVertical
    TabOrder = 4
  end
end
