import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopos/src/blocs/party/party_cubit.dart';
import 'package:shopos/src/models/input/party_input.dart';
// import 'package:shopos/src/models/party.dart';
import 'package:shopos/src/services/global.dart';
import 'package:shopos/src/services/locator.dart';
import 'package:shopos/src/widgets/custom_button.dart';
import 'package:shopos/src/widgets/custom_text_field.dart';

class CreatePartyArguments {
  final String partyId;
  final String partName;
  final String partyContactNo;
  final String partyAddress;
  final String partyType;

  CreatePartyArguments(this.partyId, this.partName, this.partyContactNo,
      this.partyAddress, this.partyType);
}

class CreatePartyPage extends StatefulWidget {
  static const String routeName = '/create_party';
  final CreatePartyArguments args;
  const CreatePartyPage({Key? key, required this.args}) : super(key: key);

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
    _partyInput =
        PartyInput(type: widget.args.partyType, id: widget.args.partyId);
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
        title: Text('Create ${widget.args.partyType} party'),
        centerTitle: true,
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
                child: SingleChildScrollView(

                  child: SizedBox(
                    height: 700,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        CustomTextField(
                          label: 'Name',
                          isLoading: isLoading,
                          initialValue: widget.args.partName,
                          onSave: (e) {
                            _partyInput.name = e;
                          },
                          validator: (e) {
                            if (e!.length <= 3) {
                              return "Minimum 3 character";
                            }
                          },
                        ),
                        const Divider(color: Colors.transparent),
                        CustomTextField(
                          isLoading: isLoading,
                          inputType: TextInputType.phone,
                          initialValue: widget.args.partyContactNo,
                          inputFormatters: [LengthLimitingTextInputFormatter(10)],
                          label: 'Phone Number',
                          onSave: (e) {
                            _partyInput.phoneNumber = e;
                          },
                          validator: (e) {
                            if (e!.length < 10) {
                              return "Minimum 10-digit";
                            }
                          },
                        ),
                        const Divider(color: Colors.transparent),
                        
                        CustomTextField(
                          maxLines: 8,
                          validator: (e) => null,
                          isLoading: isLoading,
                          initialValue: widget.args.partyAddress,
                          label: 'Address',
                       
                          
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
                              _partyInput.id == ""
                                  ? _partyCubit.createParty(_partyInput)
                                  : _partyCubit.updateParty(_partyInput);
                            }
                          },
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
