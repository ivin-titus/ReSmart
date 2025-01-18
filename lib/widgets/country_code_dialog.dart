import 'package:flutter/material.dart';
import 'package:resmart/models/countries.dart';

class CountryCodeDialog extends StatefulWidget {
  final List<Country> countries;
  final Country selectedCountry;

  const CountryCodeDialog({
    Key? key,
    required this.countries,
    required this.selectedCountry,
  }) : super(key: key);

  @override
  State<CountryCodeDialog> createState() => _CountryCodeDialogState();
}

class _CountryCodeDialogState extends State<CountryCodeDialog> {
  late TextEditingController _searchController;
  late List<Country> _filteredCountries;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredCountries = widget.countries;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCountries(String query) {
    setState(() {
      _filteredCountries = widget.countries.where((country) {
        return country.dialCode.toLowerCase().contains(query.toLowerCase()) ||
            country.code.toLowerCase().contains(query.toLowerCase()) ||
            country.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Country Name or Code ',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onChanged: _filterCountries,
            ),
            const SizedBox(height: 1),
            SizedBox(
              height: 280,
              child: ListView.builder(
                itemCount: _filteredCountries.length,
                itemBuilder: (context, index) {
                  final country = _filteredCountries[index];
                  return ListTile(
                    title: Text(
                        ' ${country.dialCode} ${country.name} (${country.code})'),
                    selected: country == widget.selectedCountry,
                    onTap: () => Navigator.pop(context, country),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
