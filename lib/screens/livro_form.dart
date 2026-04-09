import 'package:flutter/material.dart';
import '../model/livro.dart';
import '../service/livroDao.dart';
import '../components/editor.dart';

class LivroForm extends StatefulWidget{
  final Livro? livro;

  LivroForm({this.livro});

  @override
  State<StatefulWidget> createState(){
    return LivroFormState();
  }
}




class LivroFormState extends State<LivroForm>{
  final TextEditingController _controllerTitulo = TextEditingController();
  final TextEditingController _controllerDescricao = TextEditingController();
  final TextEditingController _controllerAutor = TextEditingController();
  final TextEditingController _controllerAvaliacao = TextEditingController();
  String? id;
  Livrodao _service = Livrodao();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Livro")),
      floatingActionButton: FloatingActionButton(
          onPressed: (){
            gravar(context);
      }),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Editor(_controllerTitulo, "Titulo", "Informe o título", null),
            Editor(_controllerDescricao, "Descrição", "Informe a descrição", null),
            Editor(_controllerAutor, "Autor", "Informe os autores", null),
            Editor(_controllerAvaliacao, "Avaliação", "Avalie o livro", null),
          ],
        ),
      ),
    );
  }

  void gravar(BuildContext context) async{
    if (id != null){//alteração
      final liv = Livro(id : id!,
      titulo: _controllerTitulo.text,
      descricao: _controllerDescricao.text,
      autor: _controllerAutor.text,
      status: '0',
         avaliacao: _controllerAvaliacao.text);
      await _service.update(liv).then((v) => Navigator.pop(context));
    }else{//inclusão
      final liv = Livro(id : "",
          titulo: _controllerTitulo.text,
          descricao: _controllerDescricao.text,
          autor: _controllerAutor.text,
          status: '0',
          avaliacao: _controllerAvaliacao.text);
      await _service.add(liv).then((v) => Navigator.pop(context));
    }
    final SnackBar snackBar = SnackBar(
        content: Text("Operação realizada com sucesso!"));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void initState() {
    super.initState();
    if(widget.livro !=null){//livro pra alteração
      id = widget.livro!.id;
      _controllerTitulo.text = widget.livro!.titulo;
      _controllerDescricao.text = widget.livro!.descricao;
      _controllerAutor.text = widget.livro!.autor;
      _controllerAvaliacao.text = widget.livro!.avaliacao;
    }
  }


}