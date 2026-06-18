import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:invoice_maker/core/constants/hive_box_names.dart';
import 'package:invoice_maker/core/widgets/empty_state_widget.dart';
import 'package:invoice_maker/features/customers/data/models/customer_model.dart';
import 'package:invoice_maker/features/customers/presentation/widgets/customer_card.dart';
import 'package:uuid/uuid.dart';

class CustomerListScreen extends ConsumerStatefulWidget {
  const CustomerListScreen({super.key});

  @override
  ConsumerState<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends ConsumerState<CustomerListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddCustomerSheet([CustomerModel? customer]) {
    final isEditing = customer != null;
    final nameController = TextEditingController(text: customer?.name);
    final phoneController = TextEditingController(text: customer?.phone);
    final addressController = TextEditingController(text: customer?.address);
    final emailController = TextEditingController(text: customer?.email);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          top: 16.0,
          left: 16.0,
          right: 16.0,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditing ? 'Edit Customer' : 'Add New Customer',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email (Optional)'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: 'Address'),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final newCustomer = CustomerModel(
                  id: customer?.id ?? const Uuid().v4(),
                  name: nameController.text.trim(),
                  phone: phoneController.text.trim(),
                  address: addressController.text.trim(),
                  email: emailController.text.trim(),
                  createdAt: customer?.createdAt ?? DateTime.now(),
                  quotationIds: customer?.quotationIds ?? [],
                );

                final box = Hive.box<CustomerModel>(HiveBoxNames.customers);
                box.put(newCustomer.id, newCustomer);

                Navigator.pop(context);
              },
              child: Text(isEditing ? 'UPDATE' : 'SAVE'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Customers'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or phone...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: Hive.box<CustomerModel>(HiveBoxNames.customers).listenable(),
              builder: (context, box, _) {
                final customers = box.values.where((c) {
                  return c.name.toLowerCase().contains(_searchQuery) ||
                      c.phone.contains(_searchQuery);
                }).toList();

                if (customers.isEmpty) {
                  return const EmptyStateWidget(
                    message: 'No customers found',
                    icon: Icons.person_off_outlined,
                  );
                }

                return ListView.builder(
                  itemCount: customers.length,
                  itemBuilder: (context, index) {
                    final customer = customers[index];
                    return CustomerCard(
                      customer: customer,
                      onTap: () {
                        // Navigate to detail
                      },
                      onEdit: () => _showAddCustomerSheet(customer),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'customer_list_fab',
        onPressed: () => _showAddCustomerSheet(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
