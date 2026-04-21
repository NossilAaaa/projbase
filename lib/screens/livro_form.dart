import 'package:flutter/material.dart';
import '../model/livro.dart';
import '../service/livroDao.dart';
import '../components/editor.dart';

class LivroForm extends StatefulWidget {
  final Livro? livro;

  LivroForm({this.livro});

  @override
  State<StatefulWidget> createState() => LivroFormState();
}

class LivroFormState extends State<LivroForm> {
  final _formKey = GlobalKey<FormState>(); // CHAVE DE VALIDAÇÃO

  final TextEditingController _controllerTitulo = TextEditingController();
  final TextEditingController _controllerDescricao = TextEditingController();
  final TextEditingController _controllerAutor = TextEditingController();

  // Variáveis para os novos Widgets
  String? _avaliacaoSelecionada;
  bool _lido = false;
  String? id;

  Livrodao _service = Livrodao();

  @override
  void initState() {
    super.initState();
    if (widget.livro != null) { // Livro para alteração
      id = widget.livro!.id;
      _controllerTitulo.text = widget.livro!.titulo;
      _controllerDescricao.text = widget.livro!.descricao;
      _controllerAutor.text = widget.livro!.autor;

      // Ajusta o dropdown e o switch com os dados do Firebase
      _avaliacaoSelecionada = widget.livro!.avaliacao.isEmpty ? null : widget.livro!.avaliacao;
      _lido = widget.livro!.status == '1'; // Vamos tratar '1' como lido e '0' como não lido
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Formulário de Livro")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // VALIDAÇÃO: Só salva se todos os campos estiverem preenchidos
          if (_formKey.currentState!.validate()) {
            gravar(context);
          }
        },
        child: Icon(Icons.save),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form( // ENVELOPE DO FORMULÁRIO PARA VALIDAÇÃO
          key: _formKey,
          child: Column(
            children: <Widget>[
              // Passando a mensagem de erro de validação para o Editor
              Editor(_controllerTitulo, "Título", "Informe o título", Icons.book, "O título é obrigatório!"),
              Editor(_controllerAutor, "Autor", "Informe os autores", Icons.person, "O autor é obrigatório!"),
              Editor(_controllerDescricao, "Descrição", "Informe a descrição", Icons.description, "A descrição é obrigatória!"),

              SizedBox(height: 16),

              // WIDGET NOVO 1: Dropdown para Avaliação
              DropdownButtonFormField<String>(
                value: _avaliacaoSelecionada,
                decoration: InputDecoration(
                  labelText: "Avaliação (Estrelas)",
                  icon: Icon(Icons.star, color: Colors.amber),
                ),
                items: ['1', '2', '3', '4', '5'].map((String valor) {
                  return DropdownMenuItem<String>(
                    value: valor,
                    child: Text("$valor Estrelas"),
                  );
                }).toList(),
                onChanged: (novoValor) => setState(() => _avaliacaoSelecionada = novoValor),
                validator: (value) => value == null ? "Selecione uma avaliação!" : null,
              ),

              SizedBox(height: 16),

              // WIDGET NOVO 2: Switch para Status de Leitura
              SwitchListTile(
                title: Text("Livro Lido?"),
                secondary: Icon(Icons.check_circle, color: _lido ? Colors.green : Colors.grey),
                value: _lido,
                activeColor: Colors.green,
                onChanged: (bool valor) => setState(() => _lido = valor),
              )
            ],
          ),
        ),
      ),
    );
  }

  void gravar(BuildContext context) async {
    // Converte o Switch (bool) para o formato do banco (String '1' ou '0')
    String statusFinal = _lido ? '1' : '0';

    if (id != null) { // Alteração
      final liv = Livro(
          id: id!,
          titulo: _controllerTitulo.text,
          descricao: _controllerDescricao.text,
          autor: _controllerAutor.text,
          status: statusFinal,
          avaliacao: _avaliacaoSelecionada!
      );
      await _service.update(liv).then((v) => Navigator.pop(context));
    } else { // Inclusão
      final liv = Livro(
          id: "", // O Firebase gera o ID automaticamente depois
          titulo: _controllerTitulo.text,
          descricao: _controllerDescricao.text,
          autor: _controllerAutor.text,
          status: statusFinal,
          avaliacao: _avaliacaoSelecionada!
      );
      await _service.add(liv).then((v) => Navigator.pop(context));
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Operação realizada com sucesso!")));
  }
}