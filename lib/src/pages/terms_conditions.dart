import 'package:flutter/material.dart';

class TermsAndConditionsPage extends StatelessWidget {
  static const String routeName = '/terms_conditions';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terms And Conditions'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Text(
            """

These Terms and Conditions ("Terms") govern your use of the CUBE mobile application ("the App") provided by Magicstep Solutions Private Limited ("we," "us," or "our"). By using the App, you agree to comply with these Terms. If you do not agree with any part of these Terms, please refrain from using the App.

App Usage:
a. You may use the App for personal, non-commercial purposes only. Any commercial use or unauthorized distribution of the App is strictly prohibited.
b. You must be at least 18 years old or have the legal capacity to enter into agreements to use the App.
c. You are solely responsible for any actions taken through your account and for maintaining the security of your account credentials.

Intellectual Property:
a. All intellectual property rights related to the App, including but not limited to trademarks, logos, copyrights, and trade secrets, belong to Magicstep Solutions Private Limited.
b. You may not copy, modify, distribute, or reproduce any part of the App without our prior written consent.

Limitation of Liability:
a. We strive to provide accurate and up-to-date information through the App. However, we do not guarantee the accuracy, completeness, or reliability of any information or content within the App.
b. We are not liable for any direct, indirect, incidental, consequential, or punitive damages arising from your use of the App or any actions or decisions made based on the information provided through the App.

User Responsibilities:
a. You agree to use the App in compliance with applicable laws, regulations, and these Terms.
b. You are solely responsible for any content you upload, post, or transmit through the App and must ensure that it does not infringe any third-party rights or violate any laws.
c. You must not engage in any activity that may disrupt or interfere with the operation or security of the App.

Modification of Terms:
We reserve the right to modify or update these Terms at any time. We will notify you of any material changes through the App. Your continued use of the App after the changes become effective constitutes your acceptance of the revised Terms.

Termination:
We may, at our sole discretion, suspend or terminate your access to the App at any time and for any reason without prior notice.

Governing Law and Jurisdiction:
These Terms are governed by and construed in accordance with the laws of India. Any dispute arising out of or relating to these Terms shall be subject to the exclusive jurisdiction of the courts in Khelmati, North Lakhimpur, Assam, India.

If you have any questions or concerns about these Terms and Conditions, please contact us at info@getcube.shop.

""",
            style: TextStyle(color: Colors.grey)
          ),
        ),
      ),
    );
  }
}
