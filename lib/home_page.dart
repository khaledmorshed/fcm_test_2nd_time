import 'package:fcm_second/utils/sharepreferences_class.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String? token = "hjh";
  bool isLoading = true;

  assignDefaultValue()async{
    setState(() {
      isLoading = true;
    });
    token = await SharedPreferencesClass.getValue(SharedPreferencesClass.fcmToken);
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async{
      assignDefaultValue();
    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:isLoading ? Container() : Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(child: SelectionArea(child: Text("${token.toString()}"))),
      ),
    );
  }
}
