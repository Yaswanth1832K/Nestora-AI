import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:house_rental/features/auth/presentation/providers/auth_providers.dart';
import 'package:house_rental/features/roommate/domain/entities/roommate_entity.dart';
import 'package:house_rental/features/roommate/presentation/providers/roommate_providers.dart';

class RoommateProfileScreen extends ConsumerStatefulWidget {
  final RoommateEntity? existingProfile;

  const RoommateProfileScreen({super.key, this.existingProfile});

  @override
  ConsumerState<RoommateProfileScreen> createState() => _RoommateProfileScreenState();
}

class _RoommateProfileScreenState extends ConsumerState<RoommateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _cityController;
  late TextEditingController _budgetController;
  late TextEditingController _bioController;
  String _selectedGender = 'Male';
  String _preferredGender = 'Any';
  String _occupation = 'Student';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existingProfile?.name ?? '');
    _cityController = TextEditingController(text: widget.existingProfile?.city ?? '');
    _budgetController = TextEditingController(text: widget.existingProfile?.budget.toString() ?? '');
    _bioController = TextEditingController(text: widget.existingProfile?.bio ?? '');
    if (widget.existingProfile != null) {
      _selectedGender = widget.existingProfile!.gender;
      _preferredGender = widget.existingProfile!.preferredGender;
      _occupation = widget.existingProfile!.occupation;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _budgetController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    final roommate = RoommateEntity(
      userId: user.uid,
      name: _nameController.text.trim(),
      city: _cityController.text.trim(),
      budget: int.parse(_budgetController.text.trim()),
      gender: _selectedGender,
      preferredGender: _preferredGender,
      occupation: _occupation,
      bio: _bioController.text.trim(),
      createdAt: widget.existingProfile?.createdAt ?? DateTime.now(),
    );

    final result = await ref.read(saveRoommateProfileUseCaseProvider)(roommate);

    if (mounted) {
      setState(() => _isLoading = false);
      result.fold(
        (failure) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message ?? 'An error occurred')),
        ),
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Roommate profile saved!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFFFF385C);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.existingProfile != null ? 'Edit Profile' : 'Create Profile', 
          style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Personal Details',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
              ),
              const SizedBox(height: 8),
              const Text(
                'Let potential roommates know about you.',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 32),
              _buildTextField('Full Name', _nameController, Icons.person_outline, isDark),
              const SizedBox(height: 20),
              _buildTextField('City', _cityController, Icons.location_city_outlined, isDark),
              const SizedBox(height: 20),
              _buildTextField('Monthly Budget (₹)', _budgetController, Icons.currency_rupee_outlined, isDark, isNumber: true),
              const SizedBox(height: 32),
              Text(
                'Preferences',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
              ),
              const SizedBox(height: 24),
              _buildDropdown('Your Gender', ['Male', 'Female', 'Other'], _selectedGender, (val) => setState(() => _selectedGender = val!), isDark),
              const SizedBox(height: 20),
              _buildDropdown('Preferred Roommate', ['Any', 'Male', 'Female'], _preferredGender, (val) => setState(() => _preferredGender = val!), isDark),
              const SizedBox(height: 20),
              _buildDropdown('Occupation', ['Student', 'Working Professional'], _occupation, (val) => setState(() => _occupation = val!), isDark),
              const SizedBox(height: 32),
              Text(
                'About You',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
              ),
              const SizedBox(height: 16),
              _buildTextField('Bio (Your lifestyle, habits, etc.)', _bioController, Icons.edit_note_outlined, isDark, maxLines: 4),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: _isLoading ? null : _saveProfile,
                  child: _isLoading
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(widget.existingProfile != null ? 'Update Profile' : 'Save Profile', 
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, bool isDark, {bool isNumber = false, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: isDark ? Colors.white60 : Colors.black45, size: 20),
            filled: true,
            fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), 
              borderSide: BorderSide(color: const Color(0xFFFF385C).withOpacity(0.5), width: 1.5)
            ),
            hintText: 'Enter $label',
            hintStyle: TextStyle(color: isDark ? Colors.white24 : Colors.black26, fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          validator: (value) => value == null || value.isEmpty ? 'This field is required' : null,
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, List<String> items, String value, Function(String?) onChanged, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100, 
            borderRadius: BorderRadius.circular(12)
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              items: items.map((item) => DropdownMenuItem(
                value: item, 
                child: Text(item, style: TextStyle(color: isDark ? Colors.white : Colors.black))
              )).toList(),
              onChanged: onChanged,
              dropdownColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down, color: isDark ? Colors.white60 : Colors.black45),
            ),
          ),
        ),
      ],
    );
  }
}

