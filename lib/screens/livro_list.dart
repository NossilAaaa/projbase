import 'package:flutter/material.dart';
import 'package:projbase/screens/livro_form.dart';
import '../model/livro.dart';
import '../service/livroDao.dart';


class LivroList extends StatefulWidget{
  @override
  State<StatefulWidget> createState(){
    return LivroListState();
  }
}

class LivroListState extends State<LivroList>{
  final Livrodao _service = Livrodao();
  List<Livro> _livros = [];

  Future<void> _fetchLivros() async{
    try{
      final livros = await _service.getList();
      setState(() {
        _livros = livros;
      });
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados!')));
    }
  }


  @override
  void initState() {
    super.initState();
  _fetchLivros();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text("Livros"),),
      floatingActionButton:
      FloatingActionButton(onPressed: (){
          final Future future = Navigator.push(context,
          MaterialPageRoute(builder: (context){
            return LivroForm();
          }));
          future.then((v){
            setState(() {
              _fetchLivros();
            });
          });
      },
      child: Icon(Icons.add),),
      body: ListView.builder(
      itemCount: _livros.length,
      itemBuilder: (context, index){
        final item = _livros[index];
        String docId = item.id;
        return itemLivro(context, item);
    }),
    );
  }

  Widget itemLivro(BuildContext context, Livro _livro) {
    return GestureDetector(
      onTap: () {
        final Future future = Navigator.push(context,
            MaterialPageRoute(builder: (context){
              return LivroForm(livro : _livro);
            }));
        future.then((v){
          setState(() {
            _fetchLivros();
          });
        });
      },
      child: Card(
        child: ListTile(
          title: Text(_livro.titulo),
          subtitle: Text(_livro.autor),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  _excluir(context, _livro.id);
                },
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    Icons.delete_forever,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  void _excluir(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirma Exclusão"),
          content: Text("Tem certeza que deseja excluir?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                _service.delete(id).then((v) {
                  setState(() {
                    _fetchLivros();
                  });
                  Navigator.of(context).pop();
                });
              },
              child: Text("Excluir"),
            ),
          ],
        );
      },
    );
  }
}
