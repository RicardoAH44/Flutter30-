import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Widgets Section'),
        centerTitle: true,

      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: <Widget>[
          GestureDetector(
            onTap: (){
              Navigator.pushNamed(context, 'Sup');
            },
            child: Container (
              width: double.infinity,
              height: 275,
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 3,
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)
                    ),
                    child: Image.asset('assets/images/Hospital.jpg', width: double.infinity,height: 225, fit: BoxFit.cover,)
                    ),
                    SizedBox(
                      height: 15,
                    ),
                  Text('Hospitales', style: TextStyle(fontSize: 20)),
                ],
               ),
              ),
             ),
          )
          ],
         ),
       )
     );
   }
 }