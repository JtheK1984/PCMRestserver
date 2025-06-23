object dm_PCM: Tdm_PCM
  Height = 1097
  Width = 1757
  PixelsPerInch = 144
  object con_PCM: TFDConnection
    Params.Strings = (
      'Database=pcm'
      'User_Name=root'
      'Password=pcm'
      'Server='
      'Port=3307'
      'DriverID=MySQL')
    ResourceOptions.AssignedValues = [rvAutoReconnect]
    ResourceOptions.AutoReconnect = True
    LoginPrompt = False
    BeforeConnect = con_PCMBeforeConnect
    Left = 144
    Top = 60
  end
  object qry_work: TFDQuery
    Connection = con_PCM
    FetchOptions.AssignedValues = [evMode, evRecordCountMode]
    FetchOptions.Mode = fmAll
    FetchOptions.RecordCountMode = cmTotal
    SQL.Strings = (
      '')
    Left = 144
    Top = 228
  end
  object FDPhysMySQLDriverLink1: TFDPhysMySQLDriverLink
    Left = 912
    Top = 203
  end
  object FDPhysMSSQLDriverLink1: TFDPhysMSSQLDriverLink
    Left = 912
    Top = 372
  end
  object FDPhysADSDriverLink1: TFDPhysADSDriverLink
    Left = 912
    Top = 287
  end
  object qry_work1: TFDQuery
    Connection = con_PCM
    SQL.Strings = (
      '')
    Left = 216
    Top = 228
  end
  object qry_Service: TFDQuery
    Connection = con_PCM
    SQL.Strings = (
      '')
    Left = 144
    Top = 144
  end
end
