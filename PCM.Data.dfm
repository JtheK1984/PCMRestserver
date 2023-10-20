object dm_PCM: Tdm_PCM
  Height = 731
  Width = 1171
  object con_PCM: TFDConnection
    Params.Strings = (
      'Database=pcm'
      'User_Name=root'
      'Password=pcm'
      'Server='
      'Port=3307'
      'DriverID=MySQL')
    LoginPrompt = False
    BeforeConnect = con_PCMBeforeConnect
    Left = 96
    Top = 40
  end
  object qry_work: TFDQuery
    Connection = con_PCM
    SQL.Strings = (
      '')
    Left = 608
    Top = 448
  end
  object FDPhysMySQLDriverLink1: TFDPhysMySQLDriverLink
    Left = 608
    Top = 135
  end
  object FDPhysMSSQLDriverLink1: TFDPhysMSSQLDriverLink
    Left = 608
    Top = 248
  end
  object FDPhysADSDriverLink1: TFDPhysADSDriverLink
    Left = 608
    Top = 191
  end
  object qry_work1: TFDQuery
    Connection = con_PCM
    SQL.Strings = (
      '')
    Left = 656
    Top = 448
  end
  object qry_Service: TFDQuery
    Connection = con_PCM
    SQL.Strings = (
      '')
    Left = 144
    Top = 296
  end
end
