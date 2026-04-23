import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './home.dart';
import './livro_list.dart';
import '../screens/login_or_register.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/user.dart';
import '../service/user_service.dart';

class MenuOptions extends StatefulWidget {
  User? user = null;
  UserModel? currentUser = null;

  @override
  State<StatefulWidget> createState() {
    return MenuOptionState();
  }
}

class MenuOptionState extends State<MenuOptions> {
  int paginaAtual = 0;
  PageController? pc;
  List paginas = ["Home", "Login", "Login"];
  String titulo = "Título APP";
  String _displayName = "";

  UserService _userService = UserService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titulo,
            style: GoogleFonts.lobsterTwo(fontSize: 28, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade700, Colors.teal.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              DrawerHeader(
                child: Center(
                    child: widget.currentUser != null
                        ? SizedBox(
                        height: 100,
                        child: UserAccountsDrawerHeader(
                          accountName: Text(
                              widget.currentUser?.displayName ?? 'Anônimo'),
                          accountEmail:
                          Text(widget.currentUser?.email ?? ''),
                        ))
                        : Container(
                      child: SizedBox(
                        height: 80,
                        child: ClipOval(
                            child: Image.asset('assets/logos/logo.jpg')),
                      ),
                    )),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    buildMenuItem(
                      icon: Icons.home,
                      text: 'Home',
                      onTap: () {
                        setPaginaAtual(0);
                        Navigator.pop(context);
                        pc?.jumpToPage(0);
                      },
                    ),
                    buildMenuItem(
                      icon: Icons.book,
                      text: 'Livros',
                      onTap: () {
                        setPaginaAtual(1);
                        Navigator.pop(context);
                        pc?.jumpToPage(1);
                      },
                    ),

                  ],
                ),
              ),
              Divider(
                color: Colors.white70,
                thickness: 1,
                indent: 16,
                endIndent: 16,
              ),
              widget.currentUser != null
                  ? buildMenuItem(
                icon: Icons.logout,
                text: 'Logout',
                onTap: () async {
                  try {
                    await FirebaseAuth.instance.signOut();
                    print('Logout realizado com sucesso.');
                    Navigator.pop(context);
                    Navigator.push(
                        context, MaterialPageRoute(builder: (context) => MenuOptions()));
                  } catch (e) {
                    print('Erro ao fazer logout: $e');
                  }
                },
                color: Colors.redAccent,
              )
                  : buildMenuItem(
                icon: Icons.login,
                text: 'Fazer Login',
                onTap: () {
                  setPaginaAtual(2);
                  Navigator.pop(context);
                  pc?.jumpToPage(2);
                },
                color: Colors.redAccent,
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
      body: PageView(
        controller: pc,
        children: [
          Home(),
          LivroList(),
          LoginOrRegisterScreen()
        ],
        onPageChanged: setPaginaAtual,
      ),
    );
  }

  Widget buildMenuItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.teal.shade800.withOpacity(0.9),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              SizedBox(width: 10),
              Text(
                text,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    pc = PageController(initialPage: paginaAtual);
    FirebaseAuth.instance.authStateChanges().listen((u) {
      widget.user = u;
      _userService.getUser().then((userModel) {
        if (userModel != null) {
          _displayName = userModel!.displayName;
          widget.currentUser = userModel;
        }else {
          _displayName = "";
          widget.currentUser = null;
        }
        setState(() {
        });
      });
    });
  }

  setPaginaAtual(pagina) {
    setState(() {
      paginaAtual = pagina;
      titulo = paginas[pagina];
    });
  }

}

