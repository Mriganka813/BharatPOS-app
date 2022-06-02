import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopos/src/blocs/party/party_cubit.dart';
import 'package:shopos/src/models/input/party_input.dart';
import 'package:shopos/src/services/global.dart';
import 'package:shopos/src/services/locator.dart';
import 'package:shopos/src/widgets/custom_button.dart';
import 'package:shopos/src/widgets/custom_text_field.dart';

class CreatePartyPage extends StatefulWidget {
  static const String routeName = '/create_party';
  final String partyType;
  const CreatePartyPage({
    Key? key,
    required this.partyType,
  }) : super(key: key);

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
    _partyInput = PartyInput(type: widget.partyType);
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
        title: Text('Create ${widget.partyType} party'),
      ),
      body: BlocListener<PartyCubit, PartyState>(
        bloc: _partyCubit,
        listener: (context, state) {
          if (state is PartySuccess) {
            locator<GlobalServices>().successSnackBar('Party created');
            Navigator.pop(context, true);
          }
        },
        child: BlocBuilder<PartyCubit, PartyState>(
          bloc: _partyCubit,
          builder: (context, state) {
            bool isLoading = false;
            if (state is PartyLoading) {
              isLoading = true;
            }
            return Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    CustomTextField(
                      label: 'Name',
                      isLoading: isLoading,
                      onSave: (e) {
                        _partyInput.name = e;
                      },
                    ),
                    const Divider(color: Colors.transparent),
                    CustomTextField(
                      isLoading: isLoading,
                      inputType: TextInputType.phone,
                      label: 'Phone Number',
                      onSave: (e) {
                        _partyInput.phoneNumber = e;
                      },
                    ),
                    const Divider(color: Colors.transparent),
                    CustomTextField(
                      validator: (e) => null,
                      isLoading: isLoading,
                      label: 'Address',
                      hintText: "Optional",
                      onSave: (e) {
                        _partyInput.address = e;
                      },
                    ),
                    const Spacer(),
                    CustomButton(
                      title: "Save",
                      isLoading: isLoading,
                      onTap: () {
                        _formKey.currentState?.save();
                        if (_formKey.currentState?.validate() ?? false) {
                          _partyCubit.createParty(_partyInput);
                        }
                      },
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
