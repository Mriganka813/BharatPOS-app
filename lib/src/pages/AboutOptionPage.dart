

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shopos/src/pages/privacy_policy.dart';
import 'package:shopos/src/pages/terms_conditions.dart';

class AboutOptionPage extends StatelessWidget
{


  static const String routeName="about";
  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(leading: GestureDetector(
          onTap: (){Navigator.of(context).pop();},
          child: Icon(Icons.arrow_back)),title: Text("About"),centerTitle: true,),
        body: SizedBox(width: double.infinity,
        child: Column(children: [
          SizedBox(height: 20,),
            ListTile(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>TermsAndConditionsPage()));
              },
              leading: Text("Terms of Service",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17),),trailing: Icon(Icons.arrow_forward_ios,size: 15,),),
            ListTile(
              
              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>PrivacyPolicyPage()));

              },
              leading: Text("Privacy Policy",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17),),trailing: Icon(Icons.arrow_forward_ios,size: 15,),)

      
        ],),
        ),
      );
  }

}