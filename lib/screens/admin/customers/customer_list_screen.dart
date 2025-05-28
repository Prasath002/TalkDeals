// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:talkdeals/screens/admin/customers/customer.dart';
import 'package:talkdeals/screens/admin/customers/customer_form.dart';
import 'package:talkdeals/screens/customer_chat_screen.dart';
import 'package:talkdeals/theme/color_theme.dart';
import 'package:talkdeals/theme/text_theme.dart';

/* ───────────────────────── screen ───────────────────────── */

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  final firestore = FirebaseFirestore.instance;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /* ───────── helpers ───────── */

  List<Customer> _filterCustomers(List<Customer> customers) {
    if (_searchQuery.isEmpty) return customers;
    final q = _searchQuery.toLowerCase();
    return customers
        .where(
          (c) =>
              c.name.toLowerCase().contains(q) ||
              c.phone.toLowerCase().contains(q),
        )
        .toList();
  }

  Future<void> _deleteCustomer(Customer c) async {
    final ok =
        await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Delete customer?'),
            content: Text(
              'Are you sure you want to delete "${c.name}"? This cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: AppColors.white),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (!ok) return;

    await firestore.collection('customers').doc(c.id).delete();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Customer deleted')));
    }
  }

  /* ───────── UI ───────── */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _gradientAppBar(),
      floatingActionButton: _gradientFab(),
      body: Column(
        children: [
          _searchBox(),
          Expanded(child: _customersStream()),
        ],
      ),
    );
  }

  PreferredSizeWidget _gradientAppBar() => AppBar(
    title: const Text('Customers'),
    centerTitle: true,
    elevation: 0,
    backgroundColor: Colors.transparent,
    foregroundColor: AppColors.white,
    flexibleSpace: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.darkBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    ),
  );

  Widget _gradientFab() => Container(
    width: 56,
    height: 56,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [AppColors.primary, AppColors.darkBlue],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withOpacity(.35),
          offset: const Offset(0, 6),
          blurRadius: 10,
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => showCustomerForm(context),
        child: const Icon(Icons.add, color: AppColors.white, size: 26),
      ),
    ),
  );

  Widget _searchBox() => Padding(
    padding: const EdgeInsets.all(16),
    child: TextField(
      controller: _searchController,
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        hintText: 'Search by name or phone…',
        prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
        suffixIcon: _searchQuery.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close),
                color: AppColors.textSecondary,
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
              ),
        filled: true,
        fillColor: AppColors.surface,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.gray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.tertiary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
      onChanged: (v) => setState(() => _searchQuery = v.trim()),
    ),
  );

  Widget _customersStream() => StreamBuilder<QuerySnapshot>(
    stream: firestore.collection('customers').snapshots(),
    builder: (ctx, snap) {
      if (snap.connectionState == ConnectionState.waiting) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      }
      if (snap.hasError) {
        return Center(
          child: Text(
            'Error loading customers',
            style: CustomTextStyle.bodyMedium(
              ctx,
            ).copyWith(color: AppColors.error),
          ),
        );
      }

      final all = snap.data!.docs.map(Customer.fromDoc).toList();
      final list = _filterCustomers(all);

      if (list.isEmpty) return _emptyState();

      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: list.length,
        separatorBuilder: (_, __) =>
            Divider(color: AppColors.grayLight, height: 1),
        itemBuilder: (_, i) => _CustomerTile(
          customer: list[i],
          index: i,
          onDelete: _deleteCustomer,
        ),
      );
    },
  );

  Widget _emptyState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.search_off,
          size: 48,
          color: AppColors.textSecondary.withOpacity(.5),
        ),
        const SizedBox(height: 16),
        Text(
          _searchQuery.isEmpty ? 'No customers yet' : 'No matching customers',
          style: CustomTextStyle.bodyLarge(
            context,
          ).copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        Text(
          _searchQuery.isEmpty
              ? 'Tap the + button to add a customer'
              : 'Try a different search term',
          style: CustomTextStyle.bodyMedium(
            context,
          ).copyWith(color: AppColors.textDisabled),
        ),
      ],
    ),
  );
}

class _CustomerTile extends StatelessWidget {
  final Customer customer;
  final int index;
  final void Function(Customer) onDelete;

  const _CustomerTile({
    required this.customer,
    required this.index,
    required this.onDelete,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tint = index.isEven ? AppColors.surface : AppColors.lightBlue;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      color: tint,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigateToChat(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              /* avatar */
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.darkBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    customer.name.isNotEmpty
                        ? customer.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              /* details */
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: CustomTextStyle.bodyLarge(context).copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      customer.email,
                      overflow: TextOverflow.ellipsis,
                      style: CustomTextStyle.bodyMedium(
                        context,
                      ).copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.phone,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          customer.phone,
                          style: CustomTextStyle.bodySmall(
                            context,
                          ).copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              /* edit + delete buttons */
              Row(
                children: [
                  IconButton(
                    tooltip: 'Edit',
                    splashRadius: 22,
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.edit, color: AppColors.tertiary),
                    ),
                    onPressed: () =>
                        showCustomerForm(context, editing: customer),
                  ),
                  IconButton(
                    tooltip: 'Delete',
                    splashRadius: 22,
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.delete, color: AppColors.error),
                    ),
                    onPressed: () => onDelete(customer),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CustomerChatScreen(customer: customer)),
    );
  }
}
