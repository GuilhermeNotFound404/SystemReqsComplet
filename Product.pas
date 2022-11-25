unit Product;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.StdCtrls, FMX.Edit, FMX.Controls.Presentation, FMX.ListView,
  FMX.TabControl, FMX.Layouts, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TForm5 = class(TForm)
    Layout2: TLayout;
    TabControl1: TTabControl;
    TabItem1: TTabItem;
    ListView1: TListView;
    TabItem2: TTabItem;
    Gravar: TButton;
    Button2: TButton;
    ToolBar1: TToolBar;
    Layout1: TLayout;
    searchEdit: TEdit;
    addNewTypeButton: TButton;
    searchButton: TButton;
    backButton: TButton;
    searchLabel: TLabel;
    Layout3: TLayout;
    EditDesc: TEdit;
    Label1: TLabel;
    Layout4: TLayout;
    EditPreco: TEdit;
    Label2: TLabel;
    Layout5: TLayout;
    EditEstoque: TEdit;
    Label3: TLabel;
    Layout6: TLayout;
    EditPrecoVenda: TEdit;
    Label4: TLabel;
    Layout7: TLayout;
    EditMarcaID: TEdit;
    Label5: TLabel;
    Button1: TButton;
    FDQuery1: TFDQuery;
    procedure FormShow(Sender: TObject);
    procedure CarregarLista;
    procedure addNewTypeButtonClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure backButtonClick(Sender: TObject);
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
  Form5: TForm5;
  acao: Char;
  id: Integer;

implementation

{$R *.fmx}

uses Menu, Tipo, Marca, Venda;

procedure TForm5.FormShow(Sender: TObject);
begin
  TabItem2.Enabled := False;
  addNewTypeButton.Enabled := True;
  TabControl1.ActiveTab := TabItem1;

  Menu.Form1.FDConnection1.Connected := True;
  CarregarLista;
end;

procedure TForm5.GravarClick(Sender: TObject);
var qrySalvar: TFDQuery;
begin
  try
    qrySalvar := TFDQuery.Create(Nil);
    qrySalvar.Connection := Form1.FDConnection1;
    qrySalvar.SQL.Clear;

    if acao = 'I' then
    begin
      qrySalvar.SQL.Add('INSERT INTO Produto (descr, preco, estoque, precoVenda, codmarca) VALUES (:descr, :preco, :estoque, :precoVenda, :codmarca)');
      qrySalvar.ParamByName('descr').AsString := EditDesc.Text;
      qrySalvar.ParamByName('preco').AsFloat := StrToFloat(EditPreco.Text);
      qrySalvar.ParamByName('estoque').AsInteger := StrToIntDef(EditEstoque.Text, 0);
      qrySalvar.ParamByName('precoVenda').AsFloat := StrToFloat(EditPrecoVenda.Text);
      qrySalvar.ParamByName('codmarca').AsInteger := StrToIntDef(EditMarcaID.Text, 0);

      qrySalvar.ExecSQL;

      EditDesc.Text := '';
      EditPreco.Text := '';
      EditEstoque.Text := '';
      EditPrecoVenda.Text := '';
      EditMarcaId.Text := '';

      CarregarLista;
      TabItem1.Enabled := True;
      TabControl1.ActiveTab := TabItem1;
      addNewTypeButton.Enabled := True;
    end
    else if acao = 'A' then
    begin
      qrySalvar.SQL.Add('UPDATE Produto SET descr = :descr, preco = :preco, estoque = :estoque, precoVenda = :precoVenda, codmarca = :codmarca WHERE id = :id');
      qrySalvar.ParamByName('id').AsInteger := id;
      qrySalvar.ParamByName('descr').AsString := EditDesc.Text;
      qrySalvar.ParamByName('preco').AsFloat := StrToFloatDef(EditPreco.Text, 0.0);
      qrySalvar.ParamByName('estoque').AsInteger := StrToIntDef(EditEstoque.Text, 0);
      qrySalvar.ParamByName('precoVenda').AsFloat := StrToFloatDef(EditPrecoVenda.Text, 0.0);
      qrySalvar.ParamByName('codmarca').AsInteger := StrToIntDef(EditMarcaID.Text, 0);
      qrySalvar.ExecSQL;

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
  TabItem2.Enabled := False;
end;


procedure TForm5.ListView1ItemClickEx(const Sender: TObject; ItemIndex: Integer;
  const [Ref] LocalClickPos: TPointF; const ItemObject: TListItemDrawable);
  var
    qryCarregar: TFDQuery;
begin
  if LocalClickPos.X >= TListView (Sender).Width - 65 then
  begin
    qryCarregar := TFDQuery.Create(nil);
    qryCarregar.Connection := Form1.FDConnection1;
    qryCarregar.SQL.Clear;

    qryCarregar.SQL.Add('SELECT * FROM Produto WHERE id = :id');
    qryCarregar.ParamByName('id').AsInteger := StrToIntDef(ListView1.Items[ItemIndex].Detail, 0);
    qryCarregar.Open();

    if qryCarregar.RecordCount > 0 then
    begin
      if acao = 'B' then
      begin
        Venda.Form6.EditProdutoID.Text := qryCarregar.FieldByName('id').AsString;
        Close;
      end;
      end
      else
      begin
        acao := 'A';
        id := qryCarregar.FieldByName('id').AsInteger;
        EditDesc.Text := qryCarregar.FieldByName('descr').AsString;
        EditPreco.Text := qryCarregar.FieldByName('preco').AsString;
        EditEstoque.Text := qryCarregar.FieldByName('estoque').AsString;
        EditPrecoVenda.Text := qryCarregar.FieldByName('precoVenda').AsString;
        EditMarcaID.Text := qryCarregar.FieldByName('codmarca').AsString;
        TabItem2.Enabled := True;
        TabControl1.ActiveTab := TabItem2;
      end;
  end;
end;

procedure TForm5.addNewTypeButtonClick(Sender: TObject);
begin
  TabControl1.ActiveTab := TabItem2;
  acao := 'I';
  addNewTypeButton.Enabled := false;
  TabItem1.Enabled := false;
  TabItem2.Enabled := true;
  EditDesc.Text := '';
end;

procedure TForm5.backButtonClick(Sender: TObject);
begin
  acao := 'A';
  Close;
end;

procedure TForm5.Button1Click(Sender: TObject);
begin
  Marca.acao := 'B';
  Marca.Form4.Show;
end;

procedure TForm5.Button2Click(Sender: TObject);
var
  qryDelete: TFDQuery;
begin
  try
    qryDelete := TFDQuery.Create(nil);
    qryDelete.Connection := Form1.FDConnection1;
    qryDelete.SQL.Clear;
    qryDelete.SQL.Add('DELETE FROM Produto WHERE id = :id');
    qryDelete.ParamByName('id').AsInteger := id;
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

procedure TForm5.CarregarLista;
var
  qryLista: TFDQuery;
  AddItem: TListViewItem;
begin
  try
    qryLista := TFDQuery.Create(Nil);
    qryLista.Connection := Form1.FDConnection1;
    qryLista.SQL.Clear;
    qryLista.SQL.Add('Select * from Produto');
    qryLista.Open();
    qryLista.First;
    ListView1.Items.Clear;
    while not qryLista.Eof do
    begin
      AddItem := ListView1.Items.Add;
      AddItem.Detail:= qryLista.FieldByName('id').AsString;
      AddItem.Text:= qryLista.FieldByName('id').AsString + ' - ' + qryLista.FieldByName('descr').AsString;
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
