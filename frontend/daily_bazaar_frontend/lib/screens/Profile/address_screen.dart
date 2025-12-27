import 'package:flutter/material.dart';
import 'package:daily_bazaar_frontend/shared_feature/api/user_api.dart';
import 'package:daily_bazaar_frontend/shared_feature/helper/api_exception.dart';
import 'package:daily_bazaar_frontend/shared_feature/models/address_model.dart';
import 'package:daily_bazaar_frontend/shared_feature/config/config.dart';
import 'package:daily_bazaar_frontend/shared_feature/config/hive.dart';
import 'package:daily_bazaar_frontend/shared_feature/widgets/snackbar.dart';

class AddressesPage extends StatefulWidget {
  const AddressesPage({super.key});

  @override
  State<AddressesPage> createState() => _AddressesPageState();
}

class _AddressesPageState extends State<AddressesPage> {
  late final ApiClient _client = ApiClient(baseUrl: AppEnvironment.apiBaseUrl);
  late final UserApi _userApi = UserApi(_client);

  List<UserAddress>? _addresses;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }

  Future<void> _loadAddresses() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final token = TokenStorage.getToken();
      if (token == null || token.isEmpty)
        throw const ApiException('Not authenticated');

      final list = await _userApi.listAddresses(token);
      setState(() {
        _addresses = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _showAddressForm({UserAddress? existing}) async {
    final formKey = GlobalKey<FormState>();
    String? label = existing?.label;
    String fullName = existing?.fullName ?? '';
    String phone = existing?.phone ?? '';
    String addressLine1 = existing?.addressLine1 ?? '';
    String? addressLine2 = existing?.addressLine2;
    String? landmark = existing?.landmark;
    String city = existing?.city ?? '';
    String? district = existing?.district;
    String state = existing?.state ?? '';
    String pincode = existing?.pincode ?? '';
    bool isDefault = existing?.isDefault ?? false;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Add address' : 'Edit address'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: label,
                  decoration: const InputDecoration(
                    labelText: 'Label (Home, Work...)',
                  ),
                  onChanged: (v) => label = v.trim().isEmpty ? null : v.trim(),
                ),
                TextFormField(
                  initialValue: fullName,
                  decoration: const InputDecoration(labelText: 'Full name'),
                  validator: (v) =>
                      (v ?? '').trim().isEmpty ? 'Required' : null,
                  onChanged: (v) => fullName = v.trim(),
                ),
                TextFormField(
                  initialValue: phone,
                  decoration: const InputDecoration(labelText: 'Phone'),
                  keyboardType: TextInputType.phone,
                  validator: (v) =>
                      (v ?? '').trim().isEmpty ? 'Required' : null,
                  onChanged: (v) => phone = v.trim(),
                ),
                TextFormField(
                  initialValue: addressLine1,
                  decoration: const InputDecoration(
                    labelText: 'Address line 1',
                  ),
                  validator: (v) =>
                      (v ?? '').trim().isEmpty ? 'Required' : null,
                  onChanged: (v) => addressLine1 = v.trim(),
                ),
                TextFormField(
                  initialValue: addressLine2,
                  decoration: const InputDecoration(
                    labelText: 'Address line 2',
                  ),
                  onChanged: (v) =>
                      addressLine2 = v.trim().isEmpty ? null : v.trim(),
                ),
                TextFormField(
                  initialValue: landmark,
                  decoration: const InputDecoration(labelText: 'Landmark'),
                  onChanged: (v) =>
                      landmark = v.trim().isEmpty ? null : v.trim(),
                ),
                TextFormField(
                  initialValue: city,
                  decoration: const InputDecoration(labelText: 'City'),
                  validator: (v) =>
                      (v ?? '').trim().isEmpty ? 'Required' : null,
                  onChanged: (v) => city = v.trim(),
                ),
                TextFormField(
                  initialValue: district,
                  decoration: const InputDecoration(labelText: 'District'),
                  onChanged: (v) =>
                      district = v.trim().isEmpty ? null : v.trim(),
                ),
                TextFormField(
                  initialValue: state,
                  decoration: const InputDecoration(labelText: 'State'),
                  validator: (v) =>
                      (v ?? '').trim().isEmpty ? 'Required' : null,
                  onChanged: (v) => state = v.trim(),
                ),
                TextFormField(
                  initialValue: pincode,
                  decoration: const InputDecoration(labelText: 'Pincode'),
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      (v ?? '').trim().isEmpty ? 'Required' : null,
                  onChanged: (v) => pincode = v.trim(),
                ),
                SwitchListTile(
                  title: const Text('Set as default'),
                  value: isDefault,
                  onChanged: (v) => setState(() => isDefault = v),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!(formKey.currentState?.validate() ?? false)) return;
              Navigator.of(ctx).pop(true);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != true) return;

    final token = TokenStorage.getToken();
    if (token == null || token.isEmpty) {
      showAppSnackBar(context, 'Not authenticated');
      return;
    }

    try {
      if (existing == null) {
        // Create
        final req = CreateAddressRequest(
          label: label,
          isDefault: isDefault,
          fullName: fullName,
          phone: phone,
          addressLine1: addressLine1,
          addressLine2: addressLine2,
          landmark: landmark,
          city: city,
          district: district,
          state: state,
          pincode: pincode,
        );
        await _userApi.createAddress(token, req);
        showAppSnackBar(context, 'Address added');
      } else {
        // Update - send full map (backend accepts partials too)
        final updates = {
          if (label != null) 'label': label,
          'is_default': isDefault,
          'full_name': fullName,
          'phone': phone,
          'address_line1': addressLine1,
          if (addressLine2 != null) 'address_line2': addressLine2,
          if (landmark != null) 'landmark': landmark,
          'city': city,
          if (district != null) 'district': district,
          'state': state,
          'pincode': pincode,
        };
        await _userApi.updateAddress(token, existing.id, updates);
        showAppSnackBar(context, 'Address updated');
      }
      await _loadAddresses();
    } catch (e) {
      showAppSnackBar(context, e.toString());
    }
  }

  Future<void> _confirmDelete(UserAddress addr) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete address'),
        content: Text('Delete address "${addr.label ?? addr.fullName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    final token = TokenStorage.getToken();
    if (token == null || token.isEmpty) {
      showAppSnackBar(context, 'Not authenticated');
      return;
    }

    try {
      await _userApi.deleteAddress(token, addr.id);
      showAppSnackBar(context, 'Address deleted');
      await _loadAddresses();
    } catch (e) {
      showAppSnackBar(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your addresses'),
        backgroundColor: cs.surface,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddressForm(),
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Error', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(_error ?? '', textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _loadAddresses,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : (_addresses == null || _addresses!.isEmpty)
          ? Center(
              child: Text(
                'No addresses yet',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadAddresses,
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: _addresses!.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (ctx, i) {
                  final a = _addresses![i];
                  return Card(
                    child: ListTile(
                      title: Text(a.label ?? a.fullName),
                      subtitle: Text(a.formattedAddress),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => _showAddressForm(existing: a),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _confirmDelete(a),
                          ),
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
