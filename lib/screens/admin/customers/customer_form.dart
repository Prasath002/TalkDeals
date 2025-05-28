import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:talkdeals/screens/admin/customers/customer.dart';
import '../../../theme/color_theme.dart';
import '../../../theme/text_theme.dart';

void showCustomerForm(BuildContext context, {Customer? editing}) {
  showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => _CustomerForm(editing: editing),
  );
}

class _CustomerForm extends StatefulWidget {
  final Customer? editing;
  const _CustomerForm({this.editing});

  @override
  State<_CustomerForm> createState() => _CustomerFormState();
}

class _CustomerFormState extends State<_CustomerForm> {
  final _firestore = FirebaseFirestore.instance;
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _role = TextEditingController(text: 'User');
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.editing != null) {
      _name.text = widget.editing!.name;
      _email.text = widget.editing!.email;
      _phone.text = widget.editing!.phone;
      _role.text = widget.editing!.role;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.editing != null;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isEdit ? 'Edit Customer' : 'Add Customer',
            style: CustomTextStyle.titleLarge(
              context,
            ).copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 24),
          _field('Name', _name),
          const SizedBox(height: 16),
          _field(
            'Email',
            _email,
            type: TextInputType.emailAddress,
            autofill: true,
          ),
          const SizedBox(height: 16),
          _field('Phone', _phone, type: TextInputType.phone),
          const SizedBox(height: 16),
          _field('Role', _role),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: BorderSide(color: AppColors.gray),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _loading ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _loading ? null : () => _submit(isEdit),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : Text(isEdit ? 'Update' : 'Add'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController c, {
    TextInputType type = TextInputType.text,
    bool autofill = false,
  }) {
    return TextField(
      controller: c,
      keyboardType: type,
      autofillHints: autofill ? [AutofillHints.email] : null,
      style: TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.grayLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.grayLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Future<void> _submit(bool isEdit) async {
    if (_name.text.isEmpty || _email.text.isEmpty || _phone.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Fill all fields'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    setState(() => _loading = true);
    final data = {
      'name': _name.text.trim(),
      'email': _email.text.trim(),
      'phone': _phone.text.trim(),
      'role': _role.text.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    try {
      if (isEdit) {
        await _firestore
            .collection('customers')
            .doc(widget.editing!.id)
            .update(data);
      } else {
        await _firestore.collection('customers').add(data);
      }
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } finally {
      setState(() => _loading = false);
    }
  }
}
