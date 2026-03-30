class User {
  final int? id;
  final String nomeCompleto;
  final String sexo;
  final DateTime dataNascimento;
  final int idade;
  final String email;
  final String senha;
  final String? cpf;
  final String? telefone;

  User({
    this.id,
    required this.nomeCompleto,
    required this.sexo,
    required this.dataNascimento,
    required this.idade,
    required this.email,
    required this.senha,
    this.cpf,
    this.telefone,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nomeCompleto': nomeCompleto,
      'sexo': sexo,
      'dataNascimento': dataNascimento.toIso8601String(),
      'idade': idade,
      'email': email,
      'senha': senha,
      'cpf': cpf,
      'telefone': telefone,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      nomeCompleto: json['nomeCompleto'],
      sexo: json['sexo'],
      dataNascimento: DateTime.parse(json['dataNascimento']),
      idade: json['idade'],
      email: json['email'],
      senha: json['senha'],
      cpf: json['cpf'],
      telefone: json['telefone'],
    );
  }
}