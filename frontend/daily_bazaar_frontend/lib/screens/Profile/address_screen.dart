import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daily_bazaar_frontend/shared_feature/models/address_model.dart';
import 'package:daily_bazaar_frontend/shared_feature/widgets/snackbar.dart';
import 'package:daily_bazaar_frontend/shared_feature/provider/user_provider.dart';

class AddressesPage extends ConsumerStatefulWidget {
  const AddressesPage({super.key});

  @override
  ConsumerState<AddressesPage> createState() => _AddressesPageState();
}

class _AddressesPageState extends ConsumerState<AddressesPage> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final profileAsync = ref.watch(userControllerProvider);

    return profileAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(
          title: const Text('Your addresses'),
          backgroundColor: cs.surface,
        ),
        body: const Center(child: CircularProgressIndicator()),
        floatingActionButton: FloatingActionButton(
          onPressed: null,
          child: const Icon(Icons.add),
        ),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(
          title: const Text('Your addresses'),
          backgroundColor: cs.surface,
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(e.toString(), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () =>
                    ref.read(userControllerProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: null,
          child: const Icon(Icons.add),
        ),
      ),
      data: (data) => Scaffold(
        appBar: AppBar(
          title: const Text('Your addresses'),
          backgroundColor: cs.surface,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddressSheet(),
          child: const Icon(Icons.add),
        ),
        body: data.addresses.isEmpty
            ? Center(
                child: Text(
                  'No addresses yet',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              )
            : RefreshIndicator(
                onRefresh: () async =>
                    ref.read(userControllerProvider.notifier).refresh(),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: data.addresses.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (ctx, i) {
                        final a = data.addresses[i];
                        return Card(
                          child: ListTile(
                            leading: a.isDefault
                                ? Icon(Icons.check_circle, color: cs.primary)
                                : Icon(
                                    Icons.location_on_outlined,
                                    color: cs.onSurfaceVariant,
                                  ),
                            title: Row(
                              children: [
                                Expanded(child: Text(a.label ?? a.fullName)),
                                if (a.isDefault)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: cs.primaryContainer.withValues(
                                        alpha: 0.45,
                                      ),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: cs.outlineVariant.withValues(
                                          alpha: 0.4,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      'Default',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: cs.primary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                              ],
                            ),
                            subtitle: Text(a.formattedAddress),
                            isThreeLine: true,
                            trailing: PopupMenuButton<String>(
                              onSelected: (v) async {
                                if (v == 'edit') _showAddressSheet(existing: a);
                                if (v == 'delete') _confirmDelete(a);
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                            onTap: () => _showAddressSheet(existing: a),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
      ),
    );
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

    try {
      await ref.read(userControllerProvider.notifier).deleteAddress(addr.id);
      showAppSnackBar(context, 'Address deleted');
    } catch (e) {
      showAppSnackBar(context, e.toString());
    }
  }

  Future<void> _showAddressSheet({UserAddress? existing}) async {
    final cs = Theme.of(context).colorScheme;

    final formKey = GlobalKey<FormState>();

    final labelCtrl = TextEditingController(text: existing?.label ?? '');
    final fullNameCtrl = TextEditingController(text: existing?.fullName ?? '');
    final phoneCtrl = TextEditingController(text: existing?.phone ?? '');
    final line1Ctrl = TextEditingController(text: existing?.addressLine1 ?? '');
    final line2Ctrl = TextEditingController(text: existing?.addressLine2 ?? '');
    final landmarkCtrl = TextEditingController(text: existing?.landmark ?? '');
    final cityCtrl = TextEditingController(text: existing?.city ?? '');
    final districtCtrl = TextEditingController(text: existing?.district ?? '');
    final stateCtrl = TextEditingController(text: existing?.state ?? '');
    final pincodeCtrl = TextEditingController(text: existing?.pincode ?? '');

    final result = await showModalBottomSheet<_AddressSheetResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        bool isDefault = existing?.isDefault ?? false;
        bool isSaving = false;

        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            Future<void> submit() async {
              FocusScope.of(ctx).unfocus();
              if (!(formKey.currentState?.validate() ?? false)) return;

              setSheetState(() => isSaving = true);
              final res = _AddressSheetResult(
                label: labelCtrl.text.trim().isEmpty
                    ? null
                    : labelCtrl.text.trim(),
                isDefault: isDefault,
                fullName: fullNameCtrl.text.trim(),
                phone: phoneCtrl.text.trim(),
                addressLine1: line1Ctrl.text.trim(),
                addressLine2: line2Ctrl.text.trim().isEmpty
                    ? null
                    : line2Ctrl.text.trim(),
                landmark: landmarkCtrl.text.trim().isEmpty
                    ? null
                    : landmarkCtrl.text.trim(),
                city: cityCtrl.text.trim(),
                district: districtCtrl.text.trim().isEmpty
                    ? null
                    : districtCtrl.text.trim(),
                state: stateCtrl.text.trim(),
                pincode: pincodeCtrl.text.trim(),
              );
              if (ctx.mounted) Navigator.of(ctx).pop(res);
            }

            return SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom,
                  top: 6,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            existing == null ? 'Add address' : 'Edit address',
                            style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Close',
                          onPressed: isSaving
                              ? null
                              : () => Navigator.of(ctx).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: labelCtrl,
                                  textInputAction: TextInputAction.next,
                                  decoration: _dec(
                                    'Label',
                                    hint: 'Home / Work',
                                    icon: Icons.bookmark_border,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Small checkbox (requested)
                              InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: isSaving
                                    ? null
                                    : () => setSheetState(
                                        () => isDefault = !isDefault,
                                      ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 6,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Transform.scale(
                                        scale: 0.9,
                                        child: Checkbox(
                                          value: isDefault,
                                          onChanged: isSaving
                                              ? null
                                              : (v) => setSheetState(
                                                  () => isDefault = v ?? false,
                                                ),
                                          visualDensity: VisualDensity.compact,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Default',
                                        style: Theme.of(ctx)
                                            .textTheme
                                            .labelLarge
                                            ?.copyWith(
                                              color: cs.onSurfaceVariant,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: fullNameCtrl,
                            textInputAction: TextInputAction.next,
                            decoration: _dec(
                              'Full name',
                              hint: 'John Doe',
                              icon: Icons.person_outline,
                            ),
                            validator: (v) =>
                                (v ?? '').trim().isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: phoneCtrl,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            decoration: _dec(
                              'Phone',
                              hint: '9876543210',
                              icon: Icons.phone_outlined,
                            ),
                            validator: (v) =>
                                (v ?? '').trim().isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: line1Ctrl,
                            textInputAction: TextInputAction.next,
                            decoration: _dec(
                              'Address line 1',
                              hint: 'House no, Street',
                              icon: Icons.home_outlined,
                            ),
                            validator: (v) =>
                                (v ?? '').trim().isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: line2Ctrl,
                            textInputAction: TextInputAction.next,
                            decoration: _dec(
                              'Address line 2 (optional)',
                              hint: 'Apartment, Floor',
                              icon: Icons.apartment_outlined,
                            ),
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: landmarkCtrl,
                            textInputAction: TextInputAction.next,
                            decoration: _dec(
                              'Landmark (optional)',
                              hint: 'Near ...',
                              icon: Icons.place_outlined,
                            ),
                          ),
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: cityCtrl,
                                  textInputAction: TextInputAction.next,
                                  decoration: _dec(
                                    'City',
                                    icon: Icons.location_city,
                                  ),
                                  validator: (v) => (v ?? '').trim().isEmpty
                                      ? 'Required'
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: districtCtrl,
                                  textInputAction: TextInputAction.next,
                                  decoration: _dec(
                                    'District (optional)',
                                    icon: Icons.map_outlined,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: stateCtrl,
                                  textInputAction: TextInputAction.next,
                                  decoration: _dec(
                                    'State',
                                    icon: Icons.flag_outlined,
                                  ),
                                  validator: (v) => (v ?? '').trim().isEmpty
                                      ? 'Required'
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: pincodeCtrl,
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.done,
                                  decoration: _dec(
                                    'Pincode',
                                    icon: Icons.pin_drop_outlined,
                                  ),
                                  validator: (v) => (v ?? '').trim().isEmpty
                                      ? 'Required'
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isSaving
                                ? null
                                : () => Navigator.of(ctx).pop(),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: isSaving ? null : submit,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 150),
                              child: isSaving
                                  ? const SizedBox(
                                      key: ValueKey('saving'),
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      existing == null ? 'Add' : 'Save',
                                      key: const ValueKey('label'),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (result == null) return;

    try {
      if (existing == null) {
        final req = CreateAddressRequest(
          label: result.label,
          isDefault: result.isDefault,
          fullName: result.fullName,
          phone: result.phone,
          addressLine1: result.addressLine1,
          addressLine2: result.addressLine2,
          landmark: result.landmark,
          city: result.city,
          district: result.district,
          state: result.state,
          pincode: result.pincode,
        );
        await ref.read(userControllerProvider.notifier).createAddress(req);
        if (mounted) showAppSnackBar(context, 'Address added');
      } else {
        final updates = {
          if (result.label != null) 'label': result.label,
          'is_default': result.isDefault,
          'full_name': result.fullName,
          'phone': result.phone,
          'address_line1': result.addressLine1,
          if (result.addressLine2 != null) 'address_line2': result.addressLine2,
          if (result.landmark != null) 'landmark': result.landmark,
          'city': result.city,
          if (result.district != null) 'district': result.district,
          'state': result.state,
          'pincode': result.pincode,
        };
        await ref
            .read(userControllerProvider.notifier)
            .updateAddress(existing.id, updates);
        if (mounted) showAppSnackBar(context, 'Address updated');
      }
      await ref.read(userControllerProvider.notifier).refresh();
    } catch (e) {
      if (mounted) showAppSnackBar(context, e.toString());
    } finally {
      labelCtrl.dispose();
      fullNameCtrl.dispose();
      phoneCtrl.dispose();
      line1Ctrl.dispose();
      line2Ctrl.dispose();
      landmarkCtrl.dispose();
      cityCtrl.dispose();
      districtCtrl.dispose();
      stateCtrl.dispose();
      pincodeCtrl.dispose();
    }
  }

  InputDecoration _dec(String label, {String? hint, IconData? icon}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon == null ? null : Icon(icon),
    );
  }
}

class _AddressSheetResult {
  const _AddressSheetResult({
    required this.label,
    required this.isDefault,
    required this.fullName,
    required this.phone,
    required this.addressLine1,
    required this.addressLine2,
    required this.landmark,
    required this.city,
    required this.district,
    required this.state,
    required this.pincode,
  });

  final String? label;
  final bool isDefault;
  final String fullName;
  final String phone;
  final String addressLine1;
  final String? addressLine2;
  final String? landmark;
  final String city;
  final String? district;
  final String state;
  final String pincode;
}
