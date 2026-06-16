import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../providers/company_provider.dart';
import '../../data/models/company_model.dart';
import '../widgets/logo_picker_widget.dart';

class CompanyProfileScreen extends ConsumerStatefulWidget {
  const CompanyProfileScreen({super.key});

  @override
  ConsumerState<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends ConsumerState<CompanyProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ownerController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _emailController;
  late TextEditingController _taxController;
  String? _logoPath;
  String? _signaturePath;

  @override
  void initState() {
    super.initState();
    final company = ref.read(companyProvider);
    _nameController = TextEditingController(text: company?.name);
    _ownerController = TextEditingController(text: company?.ownerName);
    _phoneController = TextEditingController(text: company?.phone);
    _addressController = TextEditingController(text: company?.address);
    _emailController = TextEditingController(text: company?.email);
    _taxController = TextEditingController(text: company?.taxNumber);
    _logoPath = company?.logoPath;
    _signaturePath = company?.signaturePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ownerController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _taxController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final company = CompanyModel(
        name: _nameController.text.trim(),
        ownerName: _ownerController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        email: _emailController.text.trim(),
        taxNumber: _taxController.text.trim(),
        logoPath: _logoPath,
        signaturePath: _signaturePath,
      );
      ref.read(companyProvider.notifier).saveCompany(company);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Profile'),
        actions: [
          IconButton(
            onPressed: _saveProfile,
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: LogoPickerWidget(
                  initialPath: _logoPath,
                  onChanged: (path) => setState(() => _logoPath = path),
                ),
              ),
              const Gap(24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Company Name'),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const Gap(16),
              TextFormField(
                controller: _ownerController,
                decoration: const InputDecoration(labelText: 'Owner Name'),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const Gap(16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const Gap(16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email (Optional)'),
                keyboardType: TextInputType.emailAddress,
              ),
              const Gap(16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                maxLines: 3,
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const Gap(16),
              TextFormField(
                controller: _taxController,
                decoration: const InputDecoration(labelText: 'Trade License / Tax No'),
              ),
              const Gap(32),
              ElevatedButton(
                onPressed: _saveProfile,
                child: const Text('SAVE PROFILE'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
