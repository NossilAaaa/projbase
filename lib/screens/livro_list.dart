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

  // Controle de quais itens estão expandidos (guarda o ID do livro)
  Set<String> _expandidos = {};

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

  // Função para abrir/fechar o card
  void _toggleExpand(String id) {
    setState(() {
      if (_expandidos.contains(id)) {
        _expandidos.remove(id); // Se tá aberto, fecha
      } else {
        _expandidos.add(id); // Se tá fechado, abre
      }
    });
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

  // MÉTODO QUE MONTA O VISUAL EXPANSÍVEL (Igual ao do vídeo)
  Widget itemLivro(BuildContext context, Livro _livro) {
    bool isLido = _livro.status == '1';
    bool isExpanded = _expandidos.contains(_livro.id); // Verifica se este livro está aberto

    return GestureDetector(
      onTap: () => _toggleExpand(_livro.id), // Clica no card para abrir/fechar
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          // O Gradiente verde mostrado no vídeo
          gradient: LinearGradient(
            colors: [Colors.green[400]!, Colors.green[800]!],
            begin: Alignment.centerLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // CABEÇALHO DO CARD (Sempre visível)
            ListTile(
              leading: Icon(
                isLido ? Icons.book : Icons.menu_book,
                color: Colors.white,
                size: 40,
              ),
              title: Text(
                _livro.titulo,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 18,
                  decoration: isLido ? TextDecoration.lineThrough : null,
                ),
              ),
              subtitle: Text(
                "${_livro.autor}\nAvaliação: ${_livro.avaliacao} ⭐",
                style: TextStyle(color: Colors.white70),
              ),
              isThreeLine: true,
              // Seta que muda de acordo com o estado
              trailing: Icon(
                isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: Colors.white,
              ),
            ),

            // CONTEÚDO EXPANDIDO (Só aparece se isExpanded for true)
            if (isExpanded)
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(color: Colors.white54), // Linha divisória
                    SizedBox(height: 8),
                    Text(
                      _livro.descricao,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    SizedBox(height: 16),
                    // Botões de Ação
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.green[800],
                          ),
                          icon: Icon(Icons.edit, size: 18),
                          label: Text("Editar"),
                          onPressed: () {
                            final Future future = Navigator.push(context, MaterialPageRoute(builder: (context) {
                              return LivroForm(livro: _livro);
                            }));
                            future.then((v) => setState(() => _fetchLivros()));
                          },
                        ),
                        SizedBox(width: 8),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[400],
                            foregroundColor: Colors.white,
                          ),
                          icon: Icon(Icons.delete, size: 18),
                          label: Text("Excluir"),
                          onPressed: () => _excluir(context, _livro.id),
                        ),
                      ],
                    )
                  ],
                ),
              ),
          ],
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