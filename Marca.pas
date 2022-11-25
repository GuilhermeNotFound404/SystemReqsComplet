unit Marca;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.StdCtrls, FMX.Edit,
  FMX.Controls.Presentation, FMX.ListView, FMX.TabControl, FMX.Layouts, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TForm4 = class(TForm)
    FDQuery1: TFDQuery;
    Layout2: TLayout;
    TabControl1: TTabControl;
    TabItem1: TTabItem;
    ListView1: TListView;
    TabItem2: TTabItem;
    Label1: TLabel;
    EditNome: TEdit;
    Gravar: TButton;
    Button2: TButton;
    ToolBar1: TToolBar;
    Layout1: TLayout;
    searchEdit: TEdit;
    addNewTypeButton: TButton;
    searchButton: TButton;
    backButton: TButton;
    searchLabel: TLabel;
    procedure CarregarLista;
    procedure addNewTypeButtonClick(Sender: TObject);
    procedure backButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure GravarClick(Sender: TObject);
    procedure ListView1ItemClickEx(const Sender: TObject; ItemIndex: Integer;
      const [Ref] LocalClickPos: TPointF; const ItemObject: TListItemDrawable);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form4: TForm4;
  acao: Char;
  id: Integer;

implementation

{$R *.fmx}

uses Menu, Cliente, Product;


procedure TForm4.addNewTypeButtonClick(Sender: TObject);
begin
  TabItem1.Enabled := false;
  TabItem2.Enabled := true;
  TabControl1.ActiveTab := TabItem2;
  acao := 'I';
  EditNome.Text := '';
end;

procedure TForm4.backButtonClick(Sender: TObject);
begin
  acao := 'A';
  Close;
end;

procedure TForm4.Button2Click(Sender: TObject);
var
  qryDelete: TFDQuery;
begin
  try
    qryDelete := TFDQuery.Create(nil);
    qryDelete.Connection := Form1.FDConnection1;
    qryDelete.SQL.Clear;
    qryDelete.SQL.Add('DELETE FROM Marca WHERE CodMarca = :codMarca');
    qryDelete.ParamByName('codMarca').AsInteger := id;
    qryDelete.ExecSQL;

    ShowMessage('Deletado com sucesso!');
    CarregarLista;
    TabControl1.ActiveTab := TabItem1;
    TabItem1.Enabled := True;
    TabItem2.Enabled := False;
    addNewTypeButton.Enabled := True;
  except
    on e: Exception do
  begin
    ShowMessage(e.Message);
  end;
  end;
end;

procedure TForm4.FormShow(Sender: TObject);
begin
  if acao = 'B' then
  begin
    TabItem2.Enabled := False;
    addNewTypeButton.Enabled := False;
  end
  else
  begin
    TabItem2.Enabled := False;
    addNewTypeButton.Enabled := True;
    TabControl1.ActiveTab := TabItem1;
  end;

  Form1.FDConnection1.Connected := True;
  CarregarLista;
end;

procedure TForm4.GravarClick(Sender: TObject);
var qrySalvar: TFDQuery;
begin
  try
    qrySalvar := TFDQuery.Create(Nil);
    qrySalvar.Connection := Form1.FDConnection1;
    qrySalvar.SQL.Clear;

    if acao = 'I' then
    begin
      qrySalvar.SQL.Add('INSERT INTO Marca(nome) VALUES (:nome)');
      qrySalvar.ParamByName('nome').AsString := EditNome.Text;
      qrySalvar.ExecSQL;

      EditNome.Text := '';

      CarregarLista;
      TabControl1.ActiveTab := TabItem1;
      TabItem1.Enabled := True;
      TabItem2.Enabled := False;
      addNewTypeButton.Enabled := True;
    end
    else if acao = 'A' then
    begin
      qrySalvar.SQL.Add('UPDATE Marca SET nome = :nome WHERE CodMarca = :id');
      qrySalvar.ParamByName('nome').AsString := EditNome.Text;
      qrySalvar.ParamByName('id').AsInteger := id;
      qrySalvar.ExecSQL;

      EditNome.Text := '';

      ShowMessage('Alterado com sucesso!');
      CarregarLista;
      TabControl1.ActiveTab := TabItem1;
      TabItem1.Enabled := True;
      TabItem2.Enabled := False;
      addNewTypeButton.Enabled := True;
    end;


  except
    on e: Exception do
  begin
    ShowMessage(e.Message);
  end;
  end;

  acao := 'I';
end;

procedure TForm4.ListView1ItemClickEx(const Sender: TObject; ItemIndex: Integer;
  const [Ref] LocalClickPos: TPointF; const ItemObject: TListItemDrawable);
  var
    qryCarregar: TFDQuery;
begin

  if LocalClickPos.X >= TListView (Sender).Width - 65 then
  begin
    qryCarregar := TFDQuery.Create(nil);
    qryCarregar.Connection := Form1.FDConnection1;
    qryCarregar.SQL.Clear;

    qryCarregar.SQL.Add('SELECT * FROM Marca WHERE CodMarca = :id');
    qryCarregar.ParamByName('id').AsInteger := StrToIntDef(ListView1.Items[ItemIndex].Detail, 0);
    qryCarregar.Open();

    if acao = 'B' then
    begin
      Product.Form5.EditMarcaID.Text := IntToStr(qryCarregar.FieldByName('CodMarca').AsInteger);
      Close;
    end
    else
    begin
      if qryCarregar.RecordCount > 0 then
      begin
        acao := 'A';
        id := qryCarregar.FieldByName('CodMarca').AsInteger;
        EditNome.Text := qryCarregar.FieldByName('Nome').AsString;
        TabItem2.Enabled := True;
        TabControl1.ActiveTab := TabItem2;
      end;
    end;
  end;
end;

procedure TForm4.CarregarLista;
var
  qryLista: TFDQuery;
  AddItem: TListViewItem;
begin
  try
    qryLista := TFDQuery.Create(Nil);
    qryLista.Connection := Form1.FDConnection1;
    qryLista.SQL.Clear;
    qryLista.SQL.Add('Select * from Marca');
    qryLista.Open();
    qryLista.First;
    ListView1.Items.Clear;
    while not qryLista.Eof do
    begin
      AddItem := ListView1.Items.Add;
      AddItem.Detail:= qryLista.FieldByName('CodMarca').AsString;
      AddItem.Text:= qryLista.FieldByName('CodMarca').AsString + ' - ' + qryLista.FieldByName('Nome').AsString;
      qryLista.Next;
    end;

    qryLista.Close;
    qryLista.Free;

  except
    on e: Exception do
  begin
    ShowMessage(e.Message);
  end;

  end;
end;

end.
