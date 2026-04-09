class Livro {
  String id;
  String titulo;
  String descricao;
  String autor;
  String status;
  String avaliacao;

  Livro({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.autor,
    required this.status,
    required this.avaliacao
  });

  Map<String, dynamic> toMap() {
    //converte objeto para map
    return {
      'titulo': titulo,
      'descricao': descricao,
      'autor': autor,
      'status': status,
      'avaliacao': avaliacao
    };
  }

  factory Livro.fromMap(Map<String, dynamic> map, String id){
    return Livro(id: id as String,
        titulo: map['titulo'] as String,
        descricao: map['descricao'] as String,
        autor: map['autor'] as String,
        status: map['status'] as String,
        avaliacao: map['avaliacao'] as String);
  }
}