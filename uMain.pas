{

edt - TEdit
btn - TButton
pnl - TPanel
lbl - TLabel
gpb - TGroupBox
spl - TSplitter
tv - TTreeView
mm - TMainMenu
mi - TMenuItem
fm - TForm

}
unit uMain;

interface

uses
  {$IFDEF Debug}
  uLog,
  {$ENDIF}
  uORDESY, uExplode, uShellFuncs, uProjectCreate, uOptions,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, ToolWin, ImgList, Buttons;

type
  TfmMain = class(TForm)
    tvMain: TTreeView;
    mmMain: TMainMenu;
    miFile: TMenuItem;
    miExit: TMenuItem;
    pnlMain: TPanel;
    imlMain: TImageList;
    pnlTop: TPanel;
    pnlBottom: TPanel;
    pnlClient: TPanel;
    edtUserName: TEdit;
    lblUserName: TLabel;
    miProject: TMenuItem;
    miCreateProject: TMenuItem;
    miOptions: TMenuItem;
    miShow: TMenuItem;
    miShowAll: TMenuItem;
    miScheme: TMenuItem;
    miCreateScheme: TMenuItem;
    miSchemeOptions: TMenuItem;
    miProjectOptions: TMenuItem;
    miObject: TMenuItem;
    miCreateObject: TMenuItem;
    miObjectOptions: TMenuItem;
    miLast: TMenuItem;
    miAbout: TMenuItem;
    miHelp: TMenuItem;
    splMain: TSplitter;
    BitBtn1: TBitBtn;
    procedure miExitClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure tvMainGetImageIndex(Sender: TObject; Node: TTreeNode);
    procedure splMainMoved(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure WMWindowPosChanged(var aMessage: TWMWindowPosChanged); message WM_WINDOWPOSCHANGED;
  private
    AppOptions: TOptions;
    procedure PrepareGUI;
    procedure PrepareOptions;
  public
    procedure InitApp;
    procedure FreeApp;
  end;

var
  fmMain: TfmMain;

implementation

{$R *.dfm}

procedure TfmMain.BitBtn1Click(Sender: TObject);
begin
  ShowProjectCreateDialog(AppOptions.UserName);
end;

procedure TfmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FreeApp;
end;

procedure TfmMain.FormCreate(Sender: TObject);
begin
  InitApp;
end;

procedure TfmMain.FreeApp;
begin
  try
    AppOptions.SetOption('GUI', 'GroupList', IntToStr(tvMain.Width));
    AppOptions.SetOption('GUI', 'FormLeft', inttostr(fmMain.Left));
    AppOptions.SetOption('GUI', 'FormTop', inttostr(fmMain.Top));
    if not AppOptions.SaveUserOptions() then
      raise Exception.Create('Cant''t save user options!');
  except
  on E: Exception do
    begin
      {$IFDEF Debug}
      AddToLog(ClassName + ' | FreeApp | ' + E.Message);
      MessageBox(Application.Handle, PChar(ClassName + ' | FreeApp | ' + E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ELSE}
      MessageBox(Application.Handle, PChar(E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ENDIF}
    end;
  end;
  Application.Terminate;
end;

procedure TfmMain.InitApp;
begin
  PrepareOptions;
  PrepareGUI;
end;

procedure TfmMain.miExitClick(Sender: TObject);
begin
  fmMain.Close;
end;

procedure TfmMain.PrepareGUI;
begin
  try
    edtUserName.Text:= AppOptions.UserName;
    tvMain.Width:= strtoint(AppOptions.GetOption('GUI', 'GroupList'));
    fmMain.Width:= strtoint(AppOptions.GetOption('GUI', 'FormWidth'));
    fmMain.Height:= strtoint(AppOptions.GetOption('GUI', 'FormHeight'));
  except
    on E: Exception do
    begin
      {$IFDEF Debug}
      AddToLog(ClassName + ' | PrepareGUI | ' + E.Message);
      MessageBox(Application.Handle, PChar(ClassName + ' | PrepareGUI | ' + E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ELSE}
      MessageBox(Application.Handle, PChar(E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ENDIF}
    end;
  end;
end;

procedure TfmMain.PrepareOptions;
begin
  try
    if not Assigned(AppOptions) then
      AppOptions:= TOptions.Create;
    AppOptions.AppTitle:= Application.Title;
    AppOptions.UserName:= GetWindowsUser; //������ ������� ��� ������������
    if not AppOptions.LoadUserOptions() then
      raise Exception.Create('Cant''t load user options!');
  except
    on E: Exception do
    begin
      {$IFDEF Debug}
      AddToLog(ClassName + ' | PrepareOptions | ' + E.Message);
      MessageBox(Application.Handle, PChar(ClassName + ' | PrepareOptions | ' + E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ELSE}
      MessageBox(Application.Handle, PChar(E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ENDIF}
    end;
  end;
end;

procedure TfmMain.splMainMoved(Sender: TObject);
begin
  AppOptions.SetOption('GUI', 'GroupList', IntToStr(tvMain.Width));
end;

procedure TfmMain.tvMainGetImageIndex(Sender: TObject; Node: TTreeNode);
begin
  try
    Node.SelectedIndex:= Node.ImageIndex;
    if TObject(Node.Data) is TOraItem then
      case TOraItem(Node.Data).ItemType of
        OraProcedure:
          begin
            Node.ImageIndex:= 15;
          end;
        OraFunction:
          begin
            Node.ImageIndex:= 14;
          end;
        OraPackage:
          begin
            Node.ImageIndex:= 9;
          end;
      end
    else if TObject(Node.Data) is TOraScheme then
      Node.ImageIndex:= 52
    else if TObject(Node.Data) is TORDESYModule then
      if Node.HasChildren and Node.Expanded then
        Node.ImageIndex:= 55
      else
        Node.ImageIndex:= 54
    else if TObject(Node.Data) is TORDESYProject then
      if Node.HasChildren and Node.Expanded then
        Node.ImageIndex:= 59
      else
        Node.ImageIndex:= 58;
  except
    on E: Exception do
    begin
      {$IFDEF Debug}
      AddToLog(ClassName + ' | tvMainGetImageIndex | ' + E.Message);
      MessageBox(Application.Handle, PChar(ClassName + ' | tvMainGetImageIndex | ' + E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ELSE}
      MessageBox(Application.Handle, PChar(E.Message), PChar(Application.Title + ' - Error'), 48);
      {$ENDIF}
    end;
  end;
end;

procedure TfmMain.WMWindowPosChanged(var aMessage: TWMWindowPosChanged);
begin
  inherited;
  if Assigned(AppOptions) then
  begin
    AppOptions.SetOption('GUI', 'FormWidth', inttostr(fmMain.Width));
    AppOptions.SetOption('GUI', 'FormHeight', inttostr(fmMain.Height));
  end;
end;

end.
