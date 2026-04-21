import 'package:flutter/material.dart';
import 'package:projbase/screens/livro_form.dart';
import '../model/livro.dart';
import '../service/livroDao.dart';

class LivroList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LivroListState();
}

class LivroListState extends State<LivroList> {
  final Livrodao _service = Livrodao();
  List<Livro> _livros = [];

  Future<void> _fetchLivros() async {
    try {
      final livros = await _service.getList();
      setState(() {
        _livros = livros;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao carregar dados!')));
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchLivros();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Livros")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final Future future = Navigator.push(context, MaterialPageRoute(builder: (context) {
            return LivroForm();
          }));
          future.then((v) => setState(() => _fetchLivros()));
        },
        child: Icon(Icons.add),
      ),
      // Adicionado um FutureBuilder falso visual ou verificação de carregamento básica
      body: _livros.isEmpty
          ? Center(child: Text("Nenhum livro encontrado ou carregando..."))
          : ListView.builder(
        itemCount: _livros.length,
        itemBuilder: (context, index) {
          final item = _livros[index];
          return itemLivro(context, item);
        },
      ),
    );
  }

  // MÉTODO QUE MONTA O VISUAL DE CADA LIVRO
  Widget itemLivro(BuildContext context, Livro _livro) {
    // Verifica se o livro está lido (Status '1')
    bool isLido = _livro.status == '1';

    return GestureDetector(
      onTap: () {
        final Future future = Navigator.push(context, MaterialPageRoute(builder: (context) {
          return LivroForm(livro: _livro);
        }));
        future.then((v) => setState(() => _fetchLivros()));
      },
      child: Card(
        // ALTERAÇÃO VISUAL 1: Cor de fundo verdinha se o livro estiver lido
        color: isLido ? Colors.green[50] : Colors.white,
        elevation: 2,
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: ListTile(
          // Ícone dinâmico baseado no status
          leading: Icon(
            isLido ? Icons.book : Icons.menu_book,
            color: isLido ? Colors.green : Colors.grey,
            size: 40,
          ),
          title: Text(
            _livro.titulo,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              // ALTERAÇÃO VISUAL 2: Riscado e cinza se já foi lido
              decoration: isLido ? TextDecoration.lineThrough : null,
              color: isLido ? Colors.grey[700] : Colors.black,
            ),
          ),
          // ALTERAÇÃO VISUAL 3: Mostra o autor e as estrelas no subtítulo
          subtitle: Text("${_livro.autor}\nAvaliação: ${_livro.avaliacao} ⭐"),
          isThreeLine: true, // Dá um espaço extra já que o subtítulo tem duas linhas
          trailing: IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () => _excluir(context, _livro.id),
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
          content: Text("Tem certeza que deseja excluir este livro?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                _service.delete(id).then((v) {
                  setState(() => _fetchLivros());
                  Navigator.of(context).pop();
                });
              },
              child: Text("Excluir", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}