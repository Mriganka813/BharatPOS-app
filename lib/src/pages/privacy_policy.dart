import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  static const String routeName = '/privacy_policy';

  TextStyle heading = TextStyle(fontWeight: FontWeight.bold, fontSize: 17);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Policy'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(23),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text("""This Privacy Policy outlines how Magicstep Solutions Private Limited ("we," "us," or "our") collects, uses, and safeguards the information provided by users ("you" or "your") while using the CUBE mobile application ("the App"). By using the App, you agree to the terms of this Privacy Policy."""),
              SizedBox(height: 50,),
              Text(
                "1. Information Collection:",
                style: heading,
              ),
              Text(
                  """We may collect the following types of information from you:
- Email ID: We collect your email ID to communicate with you and provide updates regarding the App.
- Phone Number: We collect your phone number to enable certain features of the App and facilitate communication.
- Location: We collect your location information to enhance your experience within the App.
- Files and Images: The App may require access to your files and images stored on your device for specific functionalities. """),
               SizedBox(height: 20,),
              Text(
                "2. Use of Collected Information:",
                style: heading,
              ),
              Text("""We use the information we collect to:
- Provide, maintain, and improve the functionality and features of the App.
- Communicate with you and respond to your inquiries, requests, or feedback.
- Personalize your experience within the App.
- Enforce our Terms and Conditions and protect the rights, property, or safety of our users or others.
- Comply with legal obligations. """),
               SizedBox(height: 20,),
              Text(
                "3. Data Sharing:",
                style: heading,
              ),
              Text(
                  """We do not share your information with any third parties, except in the following circumstances:
- With your consent: We may share your information with third parties if you explicitly consent to such sharing.
- Compliance with the law: We may disclose your information if required to do so by law or in response to a valid legal request.
 """),
     SizedBox(height: 20,),
              Text(
                "4. Data Security:",
                style: heading,
              ),
              Text(
                  """We implement industry-standard security measures to protect your information from unauthorized access, disclosure, or alteration. However, please note that no method of transmission over the internet or electronic storage is completely secure."""),
     SizedBox(height: 20,),
              Text(
                "5. Data Retention:",
                style: heading,
              ),
              Text(
                  """We will retain your information for as long as necessary to fulfill the purposes outlined in this Privacy Policy, unless a longer retention period is required or permitted by law."""),
     SizedBox(height: 20,),



     Text("6. User Rights:",
                style: heading,
              ),
              Text(
                  """You have the right to request access to, correction, or deletion of the personal information we hold about you. To exercise these rights, please contact us at the email address provided below."""),
     SizedBox(height: 20,), 

    Text(
                "7. California Privacy Rights:",
                style: heading,
              ),
              Text(
                  """The App does not specifically target or cater to California residents, and therefore, we do not offer any special rights or provisions under the California Consumer Privacy Act (CCPA)."""),



  SizedBox(height: 20,),
     Text(
                "8. Changes to the Privacy Policy:",
                style: heading,
              ),
              Text(
                  """We reserve the right to update or modify this Privacy Policy at any time. We will notify you of any changes by posting the revised version on our website or within the App. Your continued use of the App following the posting of changes constitutes your acceptance of such changes."""),
              Text(
                """If you have any questions or concerns about this Privacy Policy, please contact us at info@getcube.shop.
""",
          
              ),

           
            ],
          ),
        ),
      ),
    );
  }
}
