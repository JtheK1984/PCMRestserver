object PCM_Restserver: TPCM_Restserver
  DisplayName = 'PCM-Restserver'
  AfterInstall = ServiceAfterInstall
  OnStart = ServiceStart
  OnStop = ServiceStop
  Height = 977
  Width = 1433
  PixelsPerInch = 144
  object tmrServiceStart: TTimer
    Enabled = False
    Interval = 250
    OnTimer = tmrServiceStartTimer
    Left = 840
    Top = 420
  end
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'Forms'
    Left = 300
    Top = 540
  end
  object FDPhysMySQLDriverLink1: TFDPhysMySQLDriverLink
    Left = 324
    Top = 624
  end
end
