

class Usuario {

  dynamic _idUsuario;
  dynamic _nome;
  dynamic _email;
  dynamic _senha;

  Usuario();


  toMap(){

    Map<String, dynamic> map = {

      "idUsuario" : this.idUsuario,
      "nome"      : this.email,
      "email"     : this.email,
    };
    return map;
  }

  dynamic get senha => _senha;

  set senha(dynamic value) {
    _senha = value;
  }

  dynamic get email => _email;

  set email(dynamic value) {
    _email = value;
  }

  dynamic get nome => _nome;

  set nome(dynamic value) {
    _nome = value;
  }

  dynamic get idUsuario => _idUsuario;

  set idUsuario(dynamic value) {
    _idUsuario = value;
  }
}