import 'package:flutter/material.dart';
import 'package:magicstep/src/blocs/party/party_cubit.dart';
import 'package:magicstep/src/models/input/party_input.dart';
import 'package:magicstep/src/widgets/custom_button.dart';
import 'package:magicstep/src/widgets/custom_text_field.dart';

class CreatePartyPage extends StatefulWidget {
  static const String routeName = '/create_party';
  const CreatePartyPage({Key? key}) : super(key: key);

  @override
  State<CreatePartyPage> createState() => _CreatePartyPageState();
}

class _CreatePartyPageState extends State<CreatePartyPage> {
  late PartyInput _partyInput;
  late final PartyCubit _partyCubit;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _partyInput = PartyInput();
    _partyCubit = PartyCubit();
  }

  @override
  void dispose() {
    _partyCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Create Party'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Name',
                onSave: (e) {
                  _partyInput.name = e;
                },
              ),
              const Divider(color: Colors.transparent),
              CustomTextField(
                label: 'Phone Number',
                onSave: (e) {
                  _partyInput.phoneNumber = e;
                },
              ),
              const Divider(color: Colors.transparent),
              CustomTextField(
                label: 'Address',
                onSave: (e) {
                  _partyInput.address = e;
                },
              ),
              const Spacer(),
              Align(
                alignment: Alignment.centerRight,
                child: CustomButton(
                  title: "Save",
                  onTap: () {
                    _formKey.currentState?.save();
                    if (_formKey.currentState?.validate() ?? false) {}
                  },
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
