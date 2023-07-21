import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Constants.dart';

class EditableDropdown extends StatefulWidget {
  @override
  _EditableDropdownState createState() => _EditableDropdownState();
}

class _EditableDropdownState extends State<EditableDropdown> {
  List<String> _options = [];
  String? _selectedOption;
  TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch options from the API
    _fetchOptions();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  Future<void> _fetchOptions() async {
    try {
      // Make API request to fetch options
      const API_URL1 = '$Conquer_API/GRAItem';
      final String _accessToken1 = accessToken;

      final response = await http.get(Uri.parse(API_URL1), headers: {
        "Auth_Key": _accessToken1,
        "Connection": "Keep-Alive",
        "Keep-Alive": "timeout=5, max=1000",
      });
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List LoaddataItem = [];
        setState(() {
          LoaddataItem = data['response'];
          //dropdownItem.clear();
          //dropdownItem.add("Select");

          _options = LoaddataItem.map<String>((item) =>
              (item['ITEM_CODE'] as String) +
              "-" +
              (item['ITEM_NAME'] as String)).toList();

          print(_options);
        });
      } else {
        print('Failed to fetch options. Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editable Dropdown'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TypeAheadFormField<String?>(
              textFieldConfiguration: TextFieldConfiguration(
                controller: _textEditingController,
                decoration: InputDecoration(
                  labelText: 'Select or Enter Option',
                ),
              ),
              suggestionsCallback: (pattern) {
                return _options.where((option) =>
                    option.toLowerCase().contains(pattern.toLowerCase()));
              },
              itemBuilder: (context, suggestion) {
                return ListTile(
                  title: Text(suggestion ?? ''),
                );
              },
              onSuggestionSelected: (String? suggestion) {
                setState(() {
                  _selectedOption = suggestion;
                  _textEditingController.text = suggestion ?? '';
                });
              },
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please select or enter an option';
                }
                return null;
              },
            ),
            SizedBox(height: 16.0),
            Text('Selected Option: $_selectedOption'),
          ],
        ),
      ),
    );
  }
}
