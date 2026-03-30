class Enrollment {
  final int upaId;
  final String upaNome;
  final String turmaHorario;
  final String escolaridade;
  final int scoreFagestrom;
  final String medicamento;
  final Map<String, List<String>> comorbidades;

  Enrollment({
    required this.upaId,
    required this.upaNome,
    required this.turmaHorario,
    required this.escolaridade,
    required this.scoreFagestrom,
    required this.medicamento,
    required this.comorbidades,
  });

  Map<String, dynamic> toJson() {
    return {
      'upaId': upaId,
      'upaNome': upaNome,
      'turmaHorario': turmaHorario,
      'escolaridade': escolaridade,
      'scoreFagestrom': scoreFagestrom,
      'medicamento': medicamento,
      'comorbidades': comorbidades,
    };
  }
}