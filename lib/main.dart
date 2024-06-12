import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({ super.key });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Login(),
    );
  }
}

class Login extends StatefulWidget {

  const Login({ super.key });

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  void _login() {

    final email = _emailController.text;
    final senha = _senhaController.text;

    if (email.isEmpty || senha.isEmpty) {
      print('Faça o login corretamente');
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const InfoMain(),
        ),
      );
    }
  }

  void _irRegistro() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Registro()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(133, 216, 65, 1),
        title: const Center(
          child: Text(
            'Login',
            style: TextStyle(
              color: Colors.white,
            ),
          )
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),
            TextField(
              controller: _senhaController,
              decoration: const InputDecoration(
                labelText: 'Senha',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                  const Color.fromRGBO(133, 216, 65, 1),
                ),
              ),
              child: const Text(
                'Login',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            TextButton(
              onPressed: _irRegistro,
              child: const Text(
                'Cadastrar-se',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Registro extends StatefulWidget {

  const Registro({ super.key });

  @override
  _RegistroState createState() => _RegistroState();
}

class _RegistroState extends State<Registro> {

  final _usernameController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmSenhaController = TextEditingController();

  void _registro() {

    final username = _usernameController.text;
    final senha = _senhaController.text;
    final confirmSenha = _confirmSenhaController.text;

    if (username.isEmpty || senha.isEmpty || senha.isEmpty) {
      print('Preencha todos os campos');
    } else {
      if (senha == confirmSenha ) {
        final Usuario novoUsuario = Usuario(0, username, senha);

        Navigator.pop(context);
      } else {
        print('Preencha as senhas iguais');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(133, 216, 65, 1),
        title: const Center(
          child: Text(
            'Cadastro',
            style: TextStyle(
              color: Colors.white,
            )
          )
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Usuário',
              ),
            ),
            TextField(
              controller: _senhaController,
              decoration: const InputDecoration(
                labelText: 'Senha',
              ),
              obscureText: true,
            ),
            TextField(
              controller: _confirmSenhaController,
              decoration: const InputDecoration(
                labelText: 'Confirmar Senha',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _registro,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                  const Color.fromRGBO(133, 216, 65, 1),
                ),
              ),
              child: const Text(
                'Cadastrar',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoMain extends StatefulWidget {
  const InfoMain({super.key});

  @override
  _InfoMainState createState() => _InfoMainState();
}

class _InfoMainState extends State<InfoMain> {
  final TextEditingController _temperaturaController = TextEditingController();
  final TextEditingController _umidadeArController = TextEditingController();
  final TextEditingController _umidadeSoloController = TextEditingController();
  bool bombaLigada = false;
  String resultado = '';

  void verificarBomba() async {
    final int temperatura = int.tryParse(_temperaturaController.text) ?? 0;
    final int umidadeAr = int.tryParse(_umidadeArController.text) ?? 0;
    final int umidadeSolo = int.tryParse(_umidadeSoloController.text) ?? 0;

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/predict'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, int>{
          'soilMoisture': umidadeSolo,
          'temperature': temperatura,
          'airMoisture': umidadeAr,        
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        setState(() {
          bombaLigada = result['activatePump'] == 'yes';
          resultado = bombaLigada ? 'Sim' : 'Não';
        });
      } else {
        setState(() {
          resultado = 'Erro ao carregar a previsão';
        });
        throw Exception('Failed to load prediction');
      }
    } catch (e) {
      setState(() {
        resultado = 'Erro: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(133, 216, 65, 1),
        title: const Center(
          child: Text(
            'Informações',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _temperaturaController,
              decoration: const InputDecoration(
                labelText: 'Temperatura (°C)',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _umidadeArController,
              decoration: const InputDecoration(
                labelText: 'Umidade do Ar (%)',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _umidadeSoloController,
              decoration: const InputDecoration(
                labelText: 'Umidade da Terra (%)',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: verificarBomba,
              child: const Text('Verificar Bomba'),
            ),
            const SizedBox(height: 20),
            Text(
              'Bomba Ligada: $resultado',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class Usuario {
  final int id; 
  final String username;
  final String? senha;

  Usuario(this.id, this.username, this.senha);
}